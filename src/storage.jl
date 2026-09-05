## Description #############################################################################
#
# Functions related to custom storage objects for the SatelliteToolbox.jl ecosystem.
#
############################################################################################

############################################################################################
#                                        Julia API                                         #
############################################################################################

# == LowerTriangularStorage ================================================================

# -- Conversion ----------------------------------------------------------------------------

# The interface is described in the docstring of `LowerTriangularStorage`.
Base.convert(::Type{Matrix}, L::LowerTriangularStorage) = convert(Matrix{eltype(L)}, L)

function Base.convert(::Type{Matrix{T}}, L::LowerTriangularStorage) where {T}
    mat = zeros(T, size(L))

    # The indices are within the bounds of `mat` and `L` by construction, so we can skip the
    # bounds checking. The loop follows the column-major layout of `mat`.
    @inbounds for j in 1:size(L, 2), i in j:size(L, 1)
        mat[i, j] = L[i, j]
    end

    return mat
end

# -- Indexing ------------------------------------------------------------------------------
#
# The accessors are inlined and propagate `@inbounds` from the caller so that loops over the
# storage are as fast as loops over the underlying array.

Base.eachindex(L::LowerTriangularStorage) = Base.OneTo(length(L.data))

@inline @propagate_inbounds function Base.getindex(L::LowerTriangularStorage, i::Int)
    @boundscheck (i < 1 || i > length(L.data)) && throw_boundserror(L, i)
    return L.data[i]
end

@inline @propagate_inbounds function Base.getindex(
    L::LowerTriangularStorage, i::Int, j::Int
)
    @boundscheck (i < 1 || j < 1 || i > L.n || j > L.n || j > i) &&
        throw_boundserror(L, (i, j))

    return L.data[_axes_to_index(L, i, j)]
end

@inline @propagate_inbounds function Base.setindex!(L::LowerTriangularStorage, v, i::Int)
    @boundscheck (i < 1 || i > length(L.data)) && throw_boundserror(L, i)
    L.data[i] = v
    return L
end

@inline @propagate_inbounds function Base.setindex!(
    L::LowerTriangularStorage, v, i::Int, j::Int
)
    @boundscheck (i < 1 || j < 1 || i > L.n || j > L.n || j > i) &&
        throw_boundserror(L, (i, j))

    index = _axes_to_index(L, i, j)
    L.data[index] = v
    return L
end

Base.size(L::LowerTriangularStorage) = (L.n, L.n)

# -- Initialization ------------------------------------------------------------------------

function Base.zeros(::Type{T}, n::Int) where {T <: LowerTriangularStorage}
    L = T(n)
    L.data .= zero(eltype(L.data))
    return L
end

# -- Printing ------------------------------------------------------------------------------

# Since the upper triangular part is not stored, we replace the printed values with `×`.
function Base.replace_in_print_matrix(
    L::LowerTriangularStorage, i::Int, j::Int, s::AbstractString
)
    i >= j && return s

    str = if s == "#undef"
        "  ×" * repeat(" ", length(s) - 3)
    else
        repeat(" ", length(s))
    end

    # Trim trailing spaces if this is the last element.
    j == L.n && return rstrip(str)
    return str
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

# `_axes_to_index` is inlined because it is called in the indexing hot path.

"""
    _axes_to_index(L::LowerTriangularStorage{RowMajor}, i::Integer, j::Integer) -> Int
    _axes_to_index(L::LowerTriangularStorage{ColumnMajor}, i::Integer, j::Integer) -> Int

Convert the matrix axes `(i, j)` to the corresponding linear index in the storage array of
`L`, according to its data alignment.
"""
@inline function _axes_to_index(::LowerTriangularStorage{RowMajor}, i::Integer, j::Integer)
    return (i * (i - 1)) ÷ 2 + j
end

@inline function _axes_to_index(
    L::LowerTriangularStorage{ColumnMajor}, i::Integer, j::Integer
)
    return ((j - 1) * (2L.n - j) + 2i) ÷ 2
end

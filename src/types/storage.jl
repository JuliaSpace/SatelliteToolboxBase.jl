## Description #############################################################################
#
# Types and structures related to custom storage objects for the SatelliteToolbox.jl
# ecosystem.
#
############################################################################################

export LowerTriangularStorage

"""
    abstract type AbstractDataAlignment

Abstract type for the data alignment in `LowerTriangularStorage`.
"""
abstract type AbstractDataAlignment end


"""
    struct RowMajor <: AbstractDataAlignment

Defines a row major data alignment for `LowerTriangularStorage`.
"""
struct RowMajor <: AbstractDataAlignment end

"""
    struct ColumnMajor <: AbstractDataAlignment

Defines a column major data alignment for `LowerTriangularStorage`.
"""
struct ColumnMajor <: AbstractDataAlignment end

"""
    struct LowerTriangularStorage{Ta, Tt} <: AbstractMatrix{Tt}

Defines a lower triangular, squared array storage object.

`Ta` defines the data alignment, which can be `SatelliteToolboxBase.RowMajor` for a row
major ordering, or `SatelliteToolboxBase.ColumnMajor` for a column major ordering. The type
of the elements is defined by `Tt`.

!!! warning

    Although this type is a subtype of `AbstractMatrix`, it **does not** support all the
    operations defined for matrices in Julia since it was created for storage purposes only.
    It is required to convert it to a standard matrix using `convert(Matrix, L)` before
    performing matrix operations.

# Fields

- `data::Vector{Tt}` or `data::Memory{Tt}`: The storage container for the elements.
- `n::Int`: The number of rows/columns in the storage.

!!! note

    In Julia versions `1.11` and above, the internal storage uses `Memory{Tt}` for better
    performance. In earlier versions, it uses a standard `Vector{Tt}`.

# Constructors

    LowerTriangularStorage{[Ta,][ Tt]}(n::Int) where {Ta<:AbstractDataAlignment, Tt} -> LowerTriangularStorage{Ta, Tt}

Create a lower triangular storage of size `n x n`, with data alignment `Ta` and element type
`Tt`. If `Ta` is not provided, it defaults to `ColumnMajor`. If `Tt` is not provided, it
defaults to `Float64`.

    zeros(::Type{LowerTriangularStorage{[Ta], [Tt]}}, n::Int) where {Ta<:AbstractDataAlignment, Tt} -> LowerTriangularStorage{Ta, Tt}

Create a lower triangular storage of size `n x n`, with data alignment `Ta` and element type
`Tt`, with all elements initialized to zero. If `Ta` is not provided, it defaults to
`ColumnMajor`. If `Tt` is not provided, it defaults to `Float64`.

# Extended Help

## Examples

The following code creates a `4 x 4` lower triangular storage with column major ordering and
`Float64` elements:

```julia-repl
julia> L = LowerTriangularStorage{Float64}(4)
4×4 LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64}:
 9.4e-323        ×               ×               ×
 2.26365e-314    2.26192e-314    ×               ×
 9.0e-323        9.4e-323        2.38327e-314    ×
 5.0e-324        2.26192e-314    1.0e-322        0.0
```

In the sequence, we create the same type of storage but initialized with zeros:

```julia-repl
julia> L = zeros(LowerTriangularStorage{Float64}, 4)
4×4 LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64}:
 0.0    ×       ×       ×
 0.0    0.0     ×       ×
 0.0    0.0     0.0     ×
 0.0    0.0     0.0     0.0
```

The following code creates a `4 x 4` lower triangular storage with row major ordering,
`Float32` elements, and initializes with zeros:

```julia-repl
julia> L = zeros(LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float32}, 4)
4×4 LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float32}:
 0.0    ×       ×       ×
 0.0    0.0     ×       ×
 0.0    0.0     0.0     ×
 0.0    0.0     0.0     0.0
```

The user can use the following code to populate the storage:

```julia-repl
julia> L = LowerTriangularStorage{Tuple{Int, Int}}(5);

julia> for (i, j) in eachindex(L)
           L[i, j] = (i, j)
       end

julia> L
5×5 LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Tuple{Int64, Int64}}:
 (1, 1)    ×          ×          ×          ×
 (2, 1)     (2, 2)    ×          ×          ×
 (3, 1)     (3, 2)     (3, 3)    ×          ×
 (4, 1)     (4, 2)     (4, 3)     (4, 4)    ×
 (5, 1)     (5, 2)     (5, 3)     (5, 4)     (5, 5)
```

Attempting to access or set an element in the upper triangular part of the storage will
result in an error:

```julia-repl
julia> L[2, 3]
ERROR: BoundsError: attempt to access 4×4 LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64} at index [2, 3]
Stacktrace:
 [1] throw_boundserror(A::LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64}, I::Tuple{Int64, Int64})
   @ Base ./essentials.jl:14
 [2] getindex(L::LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64}, i::Int64, j::Int64)
   @ SatelliteToolboxBase ~/.julia/dev/SatelliteToolboxBase/src/storage.jl:30
 [3] top-level scope
   @ REPL[23]:1

julia> L[2, 3] = 1
ERROR: BoundsError: attempt to access 4×4 LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64} at index [2, 3]
Stacktrace:
 [1] throw_boundserror(A::LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64}, I::Tuple{Int64, Int64})
   @ Base ./essentials.jl:14
 [2] setindex!(L::LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64}, v::Int64, i::Int64, j::Int64)
   @ SatelliteToolboxBase ~/.julia/dev/SatelliteToolboxBase/src/storage.jl:37
 [3] top-level scope
   @ REPL[24]:1
```
"""
struct LowerTriangularStorage{Ta, Tt} <: AbstractMatrix{Tt}
    @static if VERSION >= v"1.11-"
        data::Memory{Tt}
    else
        data::Vector{Tt}
    end

    n::Int

    # == Constructors ======================================================================

    function LowerTriangularStorage{Ta, Tt}(n::Int) where {Ta<:AbstractDataAlignment, Tt}
        n < 1 && throw(ArgumentError("Matrix size must be positive"))
        len  = (n * (n + 1)) ÷ 2

        data = @static if VERSION >= v"1.11-"
            Memory{Tt}(undef, len)
        else
            Vector{Tt}(undef, len)
        end

        new{Ta, Tt}(data, n)
    end

    function LowerTriangularStorage{Ta}(n::Int) where Ta <: AbstractDataAlignment
        return LowerTriangularStorage{Ta, Float64}(n)
    end

    function LowerTriangularStorage{T}(n::Int) where T
        return LowerTriangularStorage{ColumnMajor, T}(n)
    end

    function LowerTriangularStorage(n::Int)
        return LowerTriangularStorage{ColumnMajor, Float64}(n)
    end
end

"""
    struct LowerTriangularStorageIndex

Structure to define the iterator through the valid `LowerTriangularStorage` indices.
"""
struct LowerTriangularStorageIndex
    n::Int
end

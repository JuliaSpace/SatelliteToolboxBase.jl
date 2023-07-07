# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Definitions of types related to ellipsoids.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export Ellipsoid

"""
    Ellipsoid{T <: Number}

Ellipsoid of rotation to be used for geocentric, geodetic and ECEF transformations.

# Fields

- `a::T` : Semi-major axis [m].
- `f::T`: Flattening of the ellipsoid.
- `b::T`: Semi-minor axis [m].
- `e²::T`: Eccentricity squared.
- `el²::T`: Second Eccentricity squared.
"""
struct Ellipsoid{T <: Number}
    # Main Variables
    # ======================================================================================

    a::T # Semi-major axis in [m]
    f::T # Flattening of the ellipsoid

    # Auxiliary variables, pre-computed for convenience
    # ======================================================================================

    b::T # Semi-minor axis in [m]
    e²::T # Eccentricity squared
    el²::T # Second eccentricity squared
end

"""
    Ellipsoid(a::T1, f::T2) where {T1 <: Number, T2 <: Number}

Construct an ellipsoid (see [`Ellipsoid`](@ref)) with semi-major axis `a` and flattening
`f`. The other elements in the structure are computed automatically.

The ellipsoid type is obtained by promoting `T1` and `T2` and converting to `float`.
"""
function Ellipsoid(a::T1, f::T2) where {T1 <: Number, T2 <: Number}
    a <= 0 && throw(ArgumentError("The semi-major axis must be positive."))
    f >= 1 && throw(ArgumentError("The flattening should be lower than 1."))

    T = promote_type(T1, T2) |> float

    b   = T(a) * (1 - T(f))
    e²  = T(f) * (2 - T(f))
    el² = e² / (1 - e²)

    return Ellipsoid{T}(T(a), T(f), b, e², el²)
end

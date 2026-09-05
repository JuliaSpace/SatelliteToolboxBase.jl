## Description #############################################################################
#
# Definitions of types related to ellipsoids.
#
############################################################################################

export Ellipsoid

"""
    struct Ellipsoid{T <: Number}

Ellipsoid of rotation to be used for geocentric, geodetic, and ECEF transformations.

# Fields

- `a::T`: Semi-major axis [m].
- `f::T`: Flattening of the ellipsoid [-].
- `b::T`: Semi-minor axis [m].
- `e²::T`: Eccentricity squared [-].
- `el²::T`: Second eccentricity squared [-].
"""
struct Ellipsoid{T <: Number}
    # == Main Variables ====================================================================

    a::T

    f::T

    # == Auxiliary Variables ===============================================================
    #
    # Those variables are computed for convenience.

    b::T

    e²::T

    el²::T
end

"""
    Ellipsoid(a::T1, f::T2) where {T1 <: Number, T2 <: Number} -> Ellipsoid{T}

Construct an ellipsoid (see [`Ellipsoid`](@ref)) with semi-major axis `a` [m] and flattening
`f` [-]. The other elements in the structure are computed automatically. The semi-major axis
must be positive and the flattening must be lower than 1.

The ellipsoid type `T` is obtained by promoting `T1` and `T2` and converting to `float`.

# Extended help

## Throws

- `ArgumentError`: If `a` is not positive or `f` is not lower than 1.
"""
function Ellipsoid(a::T1, f::T2) where {T1 <: Number, T2 <: Number}
    a <= 0 && throw(ArgumentError("The semi-major axis must be positive."))
    f >= 1 && throw(ArgumentError("The flattening should be lower than 1."))

    T = float(promote_type(T1, T2))

    b   = T(a) * (1 - T(f))
    e²  = T(f) * (2 - T(f))
    el² = e² / (1 - e²)

    return Ellipsoid{T}(T(a), T(f), b, e², el²)
end

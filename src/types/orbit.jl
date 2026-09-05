## Description #############################################################################
#
# Types and structures related to orbit representation.
#
############################################################################################

export Orbit, KeplerianElements, EquinoctialElements, OrbitStateVector

"""
    abstract type Orbit{Tepoch<:Number, T<:Number}

Abstract type of an orbit representation.
"""
abstract type Orbit{Tepoch <: Number, T <: Number} end

############################################################################################
#                                    Keplerian Elements                                    #
############################################################################################

"""
    struct KeplerianElements{Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}

Defines the orbit in terms of the Keplerian elements.

The parameter `Tanomaly` selects which anomaly is stored in the field `anomaly`. It must be
one of `TrueAnomaly`, `EccentricAnomaly`, or `MeanAnomaly`. Use the functions
[`true_anomaly`](@ref), [`eccentric_anomaly`](@ref), and [`mean_anomaly`](@ref) to obtain
the anomaly in a specific form regardless of `Tanomaly`.

# Fields

- `epoch::Tepoch`: Epoch.
- `semi_major_axis::T`: Semi-major axis [m].
- `eccentricity::T`: Eccentricity [ ].
- `inclination::T`: Inclination [rad].
- `raan::T`: Right ascension of the ascending node [rad].
- `argument_of_periapsis::T`: Argument of periapsis [rad].
- `anomaly::T`: Anomaly [rad], where the type depends on the parameter `Tanomaly`.

# Property Aliases

For backward compatibility, the following short property names are also available: `t`
(epoch), `a` (semi-major axis), `e` (eccentricity), `i` (inclination), `Ω` (RAAN), `ω`
(argument of periapsis), and `f` (**true** anomaly, converted from the stored anomaly if
necessary).
"""
struct KeplerianElements{Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number} <:
       Orbit{Tepoch, T}
    epoch::Tepoch

    semi_major_axis::T

    eccentricity::T

    inclination::T

    raan::T

    argument_of_periapsis::T

    anomaly::T
end

"""
    KeplerianElements(epoch::Tepoch, semi_major_axis::T1, eccentricity::T2, inclination::T3, raan::T4, argument_of_periapsis::T5, anomaly::T6) -> KeplerianElements{TrueAnomaly, Tepoch, T}
    KeplerianElements{Tanomaly}(epoch::Tepoch, semi_major_axis::T1, eccentricity::T2, inclination::T3, raan::T4, argument_of_periapsis::T5, anomaly::T6) -> KeplerianElements{Tanomaly, Tepoch, T}

Create a Keplerian elements object with `epoch` [UTC], `semi_major_axis` [m], `eccentricity`
[ ], `inclination` [rad], `raan` [rad], `argument_of_periapsis` [rad], and `anomaly` [rad].
The type of the anomaly is determined by the parameter `Tanomaly`. If it is omitted, the
default is `TrueAnomaly`.

The object type `T` is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6` to
float.
"""
function KeplerianElements(
    epoch::Number,
    semi_major_axis::Number,
    eccentricity::Number,
    inclination::Number,
    raan::Number,
    argument_of_periapsis::Number,
    anomaly::Number,
)
    return KeplerianElements{TrueAnomaly}(
        epoch,
        semi_major_axis,
        eccentricity,
        inclination,
        raan,
        argument_of_periapsis,
        anomaly,
    )
end

function KeplerianElements{Tanomaly}(
    epoch::Tepoch,
    semi_major_axis::T1,
    eccentricity::T2,
    inclination::T3,
    raan::T4,
    argument_of_periapsis::T5,
    anomaly::T6,
) where {
    Tanomaly <: AbstractAnomaly,
    Tepoch <: Number,
    T1 <: Number,
    T2 <: Number,
    T3 <: Number,
    T4 <: Number,
    T5 <: Number,
    T6 <: Number,
}
    T = float(promote_type(T1, T2, T3, T4, T5, T6))
    return KeplerianElements{Tanomaly, Tepoch, T}(
        epoch,
        semi_major_axis,
        eccentricity,
        inclination,
        raan,
        argument_of_periapsis,
        anomaly,
    )
end

############################################################################################
#                                   Equinoctial Elements                                   #
############################################################################################

"""
    struct EquinoctialElements{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}

Defines the orbit in terms of the equinoctial elements **[1]**. Given the Keplerian elements
`a`, `e`, `i`, `Ω`, `ω`, and the mean anomaly `M`, the equinoctial elements are:

    h = e * sin(ω + Ω)
    k = e * cos(ω + Ω)
    p = tan(i / 2) * sin(Ω)
    q = tan(i / 2) * cos(Ω)
    λ = Ω + ω + M

This set is non-singular for circular (`e = 0`) and equatorial (`i = 0`) orbits.

!!! warning

    The equinoctial elements are singular for retrograde equatorial orbits (`i = π`), because
    `tan(i / 2)` diverges. Converting Keplerian elements whose inclination is so close to `π`
    that `tan(i / 2)` exceeds `1 / eps(T)` throws an `ArgumentError`.

# Fields

- `epoch::Tepoch`: Epoch.
- `semi_major_axis::T`: Semi-major axis [m].
- `h::T`: h = e * sin(ω + Ω) [ ].
- `k::T`: k = e * cos(ω + Ω) [ ].
- `p::T`: p = tan(i / 2) * sin(Ω) [ ].
- `q::T`: q = tan(i / 2) * cos(Ω) [ ].
- `mean_longitude::T`: Mean longitude λ = Ω + ω + M [rad].

# References

- **[1]** Broucke, R. A., Cefola, P. J (1972). On the equinoctial orbit elements. Celestial
    Mechanics, v. 5, p. 303-310.
"""
struct EquinoctialElements{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}
    epoch::Tepoch

    semi_major_axis::T

    h::T

    k::T

    p::T

    q::T

    mean_longitude::T

    # == Constructors ======================================================================

    # This inner constructor avoids the automatic outer constructor, which would bypass the
    # float promotion when all the elements have the same type.
    function EquinoctialElements{Tepoch, T}(
        epoch, semi_major_axis, h, k, p, q, mean_longitude
    ) where {Tepoch <: Number, T <: Number}
        return new{Tepoch, T}(epoch, semi_major_axis, h, k, p, q, mean_longitude)
    end
end

"""
    EquinoctialElements(epoch::Tepoch, semi_major_axis::T1, h::T2, k::T3, p::T4, q::T5, mean_longitude::T6) -> EquinoctialElements{Tepoch, T}

Create an equinoctial elements object with `epoch` [UTC], `semi_major_axis` [m], `h`, `k`,
`p`, `q` [ ], and `mean_longitude` [rad].

The object type `T` is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6` to
float.
"""
function EquinoctialElements(
    epoch::Tepoch, semi_major_axis::T1, h::T2, k::T3, p::T4, q::T5, mean_longitude::T6
) where {
    Tepoch <: Number,
    T1 <: Number,
    T2 <: Number,
    T3 <: Number,
    T4 <: Number,
    T5 <: Number,
    T6 <: Number,
}
    T = float(promote_type(T1, T2, T3, T4, T5, T6))
    return EquinoctialElements{Tepoch, T}(
        epoch, semi_major_axis, h, k, p, q, mean_longitude
    )
end

############################################################################################
#                                    Orbit State Vector                                    #
############################################################################################

"""
    struct OrbitStateVector{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}

Store the state vector representation of an orbit.

# Fields

- `epoch::Tepoch`: Epoch [Julian Day].
- `r::SVector{3, T}`: Position vector [m].
- `v::SVector{3, T}`: Velocity vector [m/s].
- `a::SVector{3, T}`: Acceleration vector [m/s²].

# Property Aliases

For backward compatibility, the property `t` is an alias for `epoch`.
"""
struct OrbitStateVector{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}
    epoch::Tepoch

    r::SVector{3, T}

    v::SVector{3, T}

    a::SVector{3, T}

    # == Constructors ======================================================================

    # This inner constructor avoids the automatic outer constructor, which would bypass the
    # float promotion when all the vectors are `SVector`s with the same element type.
    function OrbitStateVector{Tepoch, T}(
        epoch, r, v, a
    ) where {Tepoch <: Number, T <: Number}
        return new{Tepoch, T}(epoch, r, v, a)
    end
end

"""
    OrbitStateVector(epoch::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}[, a::AbstractVector{Ta}]) -> OrbitStateVector{Tepoch, T}

Create an orbit state vector with `epoch` [Julian Day], position `r` [m], velocity `v`
[m / s], and acceleration `a` [m / s²]. If the latter is omitted, it will be filled with
`[0, 0, 0]`.

The object type `T` is obtained by promoting `Tr`, `Tv`, and `Ta` to float.
"""
function OrbitStateVector(
    epoch::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}, a::AbstractVector{Ta}
) where {Tepoch <: Number, Tr <: Number, Tv <: Number, Ta <: Number}
    T = float(promote_type(Tr, Tv, Ta))
    return OrbitStateVector{Tepoch, T}(epoch, r, v, a)
end

function OrbitStateVector(
    epoch::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}
) where {Tepoch <: Number, Tr <: Number, Tv <: Number}
    T = float(promote_type(Tr, Tv))
    a = @SVector zeros(T, 3)
    return OrbitStateVector(epoch, r, v, a)
end

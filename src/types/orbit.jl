## Description #############################################################################
#
# Types and structures related to orbit representation.
#
############################################################################################

export Orbit, KeplerianElements, OrbitStateVector

"""
    abstract type Orbit{Tepoch<:Number, T<:Number}

Abstract type of an orbit representation.
"""
abstract type Orbit{Tepoch<:Number, T<:Number} end

"""
    KeplerianElements{
        Tanomaly <: AbstractAnomaly,
        Tepoch <: Number,
        T <: Number
    } <: Orbit{Tepoch, T}

Defines the orbit in terms of the Keplerian elements.

# Fields

- `epoch::Tepoch`: Epoch.
- `semi_major_axis::T`: Semi-major axis [m].
- `eccentricity::T`: Eccentricity [ ].
- `inclination::T`: Inclination [rad].
- `raan::T`: Right ascension of the ascending node [rad].
- `argument_of_periapsis::T`: Argument of periapsis [rad].
- `anomaly::T`: Anomaly [rad], where the type depends on the parameter `Tanomaly`.
"""
struct KeplerianElements{
    Tanomaly <: AbstractAnomaly,
    Tepoch <: Number,
    T <: Number
} <: Orbit{Tepoch, T}
    epoch::Tepoch
    semi_major_axis::T
    eccentricity::T
    inclination::T
    raan::T
    argument_of_periapsis::T
    anomaly::T
end

"""
    KeplerianElements{Tanomaly <: AbstractAnomaly}(
        epoch::Tepoch,
        semi_major_axis::T1,
        eccentricity::T2,
        inclination::T3,
        raan::T4,
        argument_of_periapsis::T5,
        anomaly::T6
    ) where {

Create a Keplerian elements object with `epoch` [UTC], `semi_major_axis` [m], `eccentricity`
[ ], `inclination` [rad], `raan` [rad], `argument_of_periapsis` [rad], and `anomaly` [rad].
The type of the anomaly is determined by the parameter `Tanomaly`. If it is omitted, the
default is `TrueAnomaly`.

The object type is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6`.
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
        anomaly
    )
end

function KeplerianElements{Tanomaly}(
    epoch::Tepoch,
    semi_major_axis::T1,
    eccentricity::T2,
    inclination::T3,
    raan::T4,
    argument_of_periapsis::T5,
    anomaly::T6
) where {
    Tanomaly <: AbstractAnomaly,
    Tepoch <: Number,
    T1<:Number,
    T2<:Number,
    T3<:Number,
    T4<:Number,
    T5<:Number,
    T6<:Number
}
    T = promote_type(T1, T2, T3, T4, T5, T6) |> float
    return KeplerianElements{Tanomaly, typeof(epoch), T}(
        epoch,
        semi_major_axis,
        eccentricity,
        inclination,
        raan,
        argument_of_periapsis,
        anomaly,
    )
end

"""
    struct EquinoctialElements{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}

Defines the orbit in terms of the equinoctial elements.

# Fields

- `epoch::Tepoch`: Epoch.
- `semi_major_axis::T`: Semi-major axis [m].
- `h::T`: h = e * sin(ω + Ω) [ ].
- `k::T`: k = e * cos(ω + Ω) [ ].
- `p::T`: p = tan(i / 2) * sin(Ω) [ ].
- `q::T`: q = tan(i / 2) * cos(Ω) [ ].
- `longitude::T`: Longitude [rad].
"""
struct EquinoctialElements{Tepoch <: Number, T <: Number} <: Orbit{Tepoch, T}
    epoch::Tepoch
    semi_major_axis::T
    h::T
    k::T
    p::T
    q::T
    longitude::T
end

"""
    EquinoctialElements(
        epoch::Tepoch,
        semi_major_axis::T1,
        h::T2,
        k::T3,
        p::T4,
        q::T5,
        longitude::T6
    ) -> EquinoctialElements{Tepoch, T}

Create an equinoctial elements object with `epoch` [UTC], `semi_major_axis` [m], `h`, `k`,
`p`, `q`, and `longitude` [rad].

The object type is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6`.
"""
function EquinoctialElements(
    epoch::Tepoch,
    semi_major_axis::T1,
    h::T2,
    k::T3,
    p::T4,
    q::T5,
    longitude::T6
) where {
    Tepoch <: Number,
    T1<:Number,
    T2<:Number,
    T3<:Number,
    T4<:Number,
    T5<:Number,
    T6<:Number
}
    T = promote_type(T1, T2, T3, T4, T5, T6) |> float
    return KeplerianElements{typeof(t), T}(t, a, e, i, Ω, ω, f)
end

"""
    struct OrbitStateVector{Tepoch<:Number, T<:Number} <: Orbit{Tepoch, T}

Store the state vector representation of an orbit.

# Fields

- `t::Tepoch`: Epoch [Julian Day].
- `r::SVector{3, T}`: Position vector [m].
- `v::SVector{3, T}`: Velocity vector [m/s].
- `a::SVector{3, T}`: Acceleration vector [m/s²].
"""
struct OrbitStateVector{Tepoch<:Number, T<:Number} <: Orbit{Tepoch, T}
    t::Tepoch
    r::SVector{3, T}
    v::SVector{3, T}
    a::SVector{3, T}
end

"""
    OrbitStateVector(t::Tepoch, r::AbstractVector{Tr}, v::AbstractVector{Tv}[, a::AbstractVector{Ta}])

Create an orbit state vector with epoch `t` [Julian Day], position `r` [m], velocity `v`
[m / s], and acceleration `a` [m / s²]. If the latter is omitted, it will be filled with
`[0, 0, 0]`.

The object type is obtained by promoting `Tr`, `Tv`, and `Ta`.
"""
function OrbitStateVector(
    t::Tepoch,
    r::AbstractVector{Tr},
    v::AbstractVector{Tv},
    a::AbstractVector{Ta},
) where {Tepoch <: Number, Tr <: Number, Tv <: Number, Ta <: Number}

    T = promote_type(Tr, Tv, Ta)

    return OrbitStateVector{Tepoch, T}(t, r, v, a)
end

function OrbitStateVector(
    t::Tepoch,
    r::AbstractVector{Tr},
    v::AbstractVector{Tv},
) where {Tepoch <: Number, Tr <: Number, Tv <: Number}

    T = promote_type(Tr, Tv)
    a = @SVector zeros(T, 3)

    return OrbitStateVector(t, r, v, a)
end

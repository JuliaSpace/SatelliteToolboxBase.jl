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
    KeplerianElements{Tepoch<:Number, T<:Number} <: Orbit{Tepoch, T}

This structure defines the orbit in terms of the Keplerian elements.

# Fields

- `t::Tepoch`: Epoch.
- `a::T`: Semi-major axis [m].
- `e::T`: Eccentricity [ ].
- `i::T`: Inclination [rad].
- `Ω::T`: Right ascension of the ascending node [rad].
- `ω::T`: Argument of perigee [rad].
- `f::T`: True anomaly [rad].
"""
struct KeplerianElements{Tepoch<:Number, T<:Number} <: Orbit{Tepoch, T}
    t::Tepoch
    a::T
    e::T
    i::T
    Ω::T
    ω::T
    f::T
end

"""
    KeplerianElements(t::Tepoch, a::T1, e::T2, i::T3, Ω::T4, ω::T5, f::T6)

Create an orbit representation using Keplerian elements with semi-major axis `a` [m],
eccentricity `e` [ ], inclination `i` [rad], right ascension of the ascending node `Ω`
[rad], argument of perigee `ω` [rad], and true anomaly `f` [rad].

The object type is obtained by promoting `T1`, `T2`, `T3`, `T4`, `T5`, and `T6`.
"""
function KeplerianElements(
    t::Tepoch,
    a::T1,
    e::T2,
    i::T3,
    Ω::T4,
    ω::T5,
    f::T6
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

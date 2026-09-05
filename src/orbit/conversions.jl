## Description #############################################################################
#
# Conversion between the orbit representations using Julia built-in system.
#
# `convert` takes no options, so the conversions between Keplerian elements and orbit state
# vectors use the default central body (Earth). Call `kepler_to_sv` or `sv_to_kepler` with
# the keyword `μ` for an orbit around another body.
#
## References ##############################################################################
#
# [1] Broucke, R. A., Cefola, P. J (1972). On the equinoctial orbit elements. Celestial
#     Mechanics, v. 5, p. 303-310.
#
############################################################################################

############################################################################################
#                                     Julia Conversions                                    #
############################################################################################

# == To Equinoctial Elements ===============================================================

"""
    Base.convert(::Type{EquinoctialElements{Tepoch, T}}, ee::EquinoctialElements) -> EquinoctialElements{Tepoch, T}
    Base.convert(::Type{EquinoctialElements}, ke::KeplerianElements) -> EquinoctialElements
    Base.convert(::Type{EquinoctialElements{Tepoch, T}}, ke::KeplerianElements) -> EquinoctialElements{Tepoch, T}
    Base.convert(::Type{EquinoctialElements}, sv::OrbitStateVector) -> EquinoctialElements
    Base.convert(::Type{EquinoctialElements{Tepoch, T}}, sv::OrbitStateVector) -> EquinoctialElements{Tepoch, T}

Convert the orbit representation `ee`, `ke`, or `sv` to equinoctial elements. If the epoch
type `Tepoch` and the element type `T` are omitted, they are taken from the input.

The conversion from an `OrbitStateVector` uses [`sv_to_kepler`](@ref) with the Earth's
standard gravitational parameter `GM_EARTH`. Call that function directly with the keyword
`μ` for an orbit around another central body.

The conversion from Keplerian elements fails for retrograde equatorial orbits (`i = π`),
where the equinoctial elements are singular.

# Extended help

## Throws

- `ArgumentError`: If the inclination is so close to `π` that `tan(i / 2)` exceeds
    `1 / eps(T)`.
"""
function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, ee::EquinoctialElements
) where {Tepoch, T}
    return EquinoctialElements{Tepoch, T}(
        ee.epoch, ee.semi_major_axis, ee.h, ee.k, ee.p, ee.q, ee.mean_longitude
    )
end

function Base.convert(::Type{EquinoctialElements}, ke::KeplerianElements)
    return _keplerian_to_equinoctial(ke)
end

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, ke::KeplerianElements
) where {Tepoch, T}
    return convert(EquinoctialElements{Tepoch, T}, _keplerian_to_equinoctial(ke))
end

function Base.convert(
    ::Type{EquinoctialElements}, sv::OrbitStateVector{Tepoch, T}
) where {Tepoch, T}
    return convert(EquinoctialElements{Tepoch, T}, sv)
end

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, sv::OrbitStateVector
) where {Tepoch, T}
    return convert(EquinoctialElements{Tepoch, T}, sv_to_kepler(sv))
end

# == To Keplerian Elements =================================================================

"""
    Base.convert(::Type{KeplerianElements{Tanomaly}}, ke::KeplerianElements) -> KeplerianElements{Tanomaly, Tepoch, T}
    Base.convert(::Type{KeplerianElements{Tanomaly, Tepoch, T}}, ke::KeplerianElements) -> KeplerianElements{Tanomaly, Tepoch, T}
    Base.convert(::Type{KeplerianElements}, ee::EquinoctialElements) -> KeplerianElements{TrueAnomaly, Tepoch, T}
    Base.convert(::Type{KeplerianElements{Tanomaly}}, ee::EquinoctialElements) -> KeplerianElements{Tanomaly, Tepoch, T}
    Base.convert(::Type{KeplerianElements{Tanomaly, Tepoch, T}}, ee::EquinoctialElements) -> KeplerianElements{Tanomaly, Tepoch, T}
    Base.convert(::Type{KeplerianElements}, sv::OrbitStateVector) -> KeplerianElements{TrueAnomaly, Tepoch, T}
    Base.convert(::Type{KeplerianElements{Tanomaly}}, sv::OrbitStateVector) -> KeplerianElements{Tanomaly, Tepoch, T}
    Base.convert(::Type{KeplerianElements{Tanomaly, Tepoch, T}}, sv::OrbitStateVector) -> KeplerianElements{Tanomaly, Tepoch, T}

Convert the orbit representation `ke`, `ee`, or `sv` to Keplerian elements storing the
anomaly selected by `Tanomaly` (`TrueAnomaly` if omitted). If the epoch type `Tepoch` and
the element type `T` are omitted, they are taken from the input.

Converting between anomaly types uses [`true_anomaly`](@ref), [`eccentric_anomaly`](@ref),
and [`mean_anomaly`](@ref) with the default settings of the Kepler's equation solver. The
conversion from equinoctial elements returns the RAAN, the argument of periapsis, and the
anomaly in the interval [0, 2π). The conversion from an `OrbitStateVector` uses
[`sv_to_kepler`](@ref) with the Earth's standard gravitational parameter `GM_EARTH`. Call
that function directly with the keyword `μ` for an orbit around another central body.
"""
function Base.convert(
    ::Type{KeplerianElements{Tanomaly}}, ke::KeplerianElements{<:AbstractAnomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, ke)
end

for (Tanomaly, getter) in (
    (:EccentricAnomaly, :eccentric_anomaly),
    (:MeanAnomaly, :mean_anomaly),
    (:TrueAnomaly, :true_anomaly),
)
    @eval function Base.convert(
        ::Type{KeplerianElements{$Tanomaly, Tepoch, T}}, ke::KeplerianElements
    ) where {Tepoch, T}
        return KeplerianElements{$Tanomaly, Tepoch, T}(
            ke.epoch,
            ke.semi_major_axis,
            ke.eccentricity,
            ke.inclination,
            ke.raan,
            ke.argument_of_periapsis,
            $getter(ke),
        )
    end
end

function Base.convert(
    ::Type{KeplerianElements}, ee::EquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    return convert(KeplerianElements{TrueAnomaly, Tepoch, T}, ee)
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly}}, ee::EquinoctialElements{Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, ee)
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly, Tepoch, T}}, ee::EquinoctialElements
) where {Tanomaly, Tepoch, T}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, _equinoctial_to_keplerian(ee))
end

function Base.convert(
    ::Type{KeplerianElements}, sv::OrbitStateVector{Tepoch, T}
) where {Tepoch, T}
    return convert(KeplerianElements{TrueAnomaly, Tepoch, T}, sv)
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly}}, sv::OrbitStateVector{Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, sv)
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly, Tepoch, T}}, sv::OrbitStateVector
) where {Tanomaly, Tepoch, T}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, sv_to_kepler(sv))
end

# == To Orbit State Vector =================================================================

"""
    Base.convert(::Type{OrbitStateVector{Tepoch, T}}, sv::OrbitStateVector) -> OrbitStateVector{Tepoch, T}
    Base.convert(::Type{OrbitStateVector}, ke::KeplerianElements) -> OrbitStateVector
    Base.convert(::Type{OrbitStateVector{Tepoch, T}}, ke::KeplerianElements) -> OrbitStateVector{Tepoch, T}
    Base.convert(::Type{OrbitStateVector}, ee::EquinoctialElements) -> OrbitStateVector
    Base.convert(::Type{OrbitStateVector{Tepoch, T}}, ee::EquinoctialElements) -> OrbitStateVector{Tepoch, T}

Convert the orbit representation `sv`, `ke`, or `ee` to an orbit state vector. If the epoch
type `Tepoch` and the element type `T` are omitted, they are taken from the input.

The conversions from Keplerian and equinoctial elements use [`kepler_to_sv`](@ref) with the
Earth's standard gravitational parameter `GM_EARTH`, and the acceleration of the result is
zero. Call that function directly with the keyword `μ` for an orbit around another central
body.
"""
function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}}, sv::OrbitStateVector
) where {Tepoch, T}
    return OrbitStateVector{Tepoch, T}(sv.epoch, sv.r, sv.v, sv.a)
end

function Base.convert(
    ::Type{OrbitStateVector}, ke::KeplerianElements{<:AbstractAnomaly, Tepoch, T}
) where {Tepoch, T}
    return convert(OrbitStateVector{Tepoch, T}, ke)
end

function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}}, ke::KeplerianElements
) where {Tepoch, T}
    return convert(OrbitStateVector{Tepoch, T}, kepler_to_sv(ke))
end

function Base.convert(
    ::Type{OrbitStateVector}, ee::EquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    return convert(OrbitStateVector{Tepoch, T}, ee)
end

function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}}, ee::EquinoctialElements
) where {Tepoch, T}
    ke = convert(KeplerianElements{TrueAnomaly, Tepoch, T}, ee)
    return convert(OrbitStateVector{Tepoch, T}, ke)
end

############################################################################################
#                                     Private Functions                                    #
############################################################################################

"""
    _equinoctial_to_keplerian(ee::EquinoctialElements{Tepoch, T}) -> KeplerianElements{MeanAnomaly, Tepoch, T}

Convert the equinoctial elements `ee` to Keplerian elements storing the mean anomaly. The
RAAN, the argument of periapsis, and the mean anomaly are returned in the interval [0, 2π).
"""
function _equinoctial_to_keplerian(ee::EquinoctialElements{Tepoch, T}) where {Tepoch, T}
    a = ee.semi_major_axis
    h = ee.h
    k = ee.k
    p = ee.p
    q = ee.q
    λ = ee.mean_longitude

    e = hypot(h, k)
    i = 2atan(hypot(p, q))
    Ω = _wrap_to_2π(atan(p, q))
    ω = _wrap_to_2π(atan(h, k) - Ω)
    M = _wrap_to_2π(λ - Ω - ω)

    return KeplerianElements{MeanAnomaly, Tepoch, T}(ee.epoch, a, e, i, Ω, ω, M)
end

"""
    _keplerian_to_equinoctial(ke::KeplerianElements{Tanomaly, Tepoch, T}) -> EquinoctialElements{Tepoch, T}

Convert the Keplerian elements `ke`, with any anomaly type, to equinoctial elements. The
conversion fails for retrograde equatorial orbits (`i = π`), where the equinoctial elements
are singular.

# Extended help

## Throws

- `ArgumentError`: If the inclination is so close to `π` that `tan(i / 2)` exceeds
    `1 / eps(T)`.
"""
function _keplerian_to_equinoctial(
    ke::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    a = ke.semi_major_axis
    e = ke.eccentricity
    i = ke.inclination
    Ω = ke.raan
    ω = ke.argument_of_periapsis
    M = mean_anomaly(ke)

    sin_Ω₊ω, cos_Ω₊ω = sincos(Ω + ω)
    sin_Ω, cos_Ω     = sincos(Ω)
    tan_io2          = tan(i / 2)

    # The elements `p` and `q` are singular at i = π. In floating point, `tan(i / 2)` does
    # not overflow at `i = π`, but it exceeds `1 / eps(T)`, where `p` and `q` lose all the
    # fractional precision. We use this threshold to detect the singularity.
    abs(tan_io2) < 1 / eps(T) ||
        throw(ArgumentError("The equinoctial elements are singular at i = π."))

    h = e * sin_Ω₊ω
    k = e * cos_Ω₊ω
    p = tan_io2 * sin_Ω
    q = tan_io2 * cos_Ω
    λ = Ω + ω + M

    return EquinoctialElements{Tepoch, T}(ke.epoch, a, h, k, p, q, λ)
end

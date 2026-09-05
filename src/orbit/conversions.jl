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

# The docstrings of the orbit representations describe the conversions. The identity
# conversions are handled by `Base.convert(::Type{T}, x::T)`, which is more specific than
# every method below.

# == Type Parameters Taken from the Input ==================================================

function Base.convert(
    ::Type{EquinoctialElements}, orbit::Orbit{Tepoch, T}
) where {Tepoch <: Number, T <: Number}
    return convert(EquinoctialElements{Tepoch, T}, orbit)
end

function Base.convert(
    ::Type{AlternateEquinoctialElements}, orbit::Orbit{Tepoch, T}
) where {Tepoch <: Number, T <: Number}
    return convert(AlternateEquinoctialElements{Tepoch, T}, orbit)
end

function Base.convert(
    ::Type{KeplerianElements}, orbit::Orbit{Tepoch, T}
) where {Tepoch <: Number, T <: Number}
    return convert(KeplerianElements{TrueAnomaly, Tepoch, T}, orbit)
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly}}, orbit::Orbit{Tepoch, T}
) where {Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, orbit)
end

function Base.convert(
    ::Type{OrbitStateVector}, orbit::Orbit{Tepoch, T}
) where {Tepoch <: Number, T <: Number}
    return convert(OrbitStateVector{Tepoch, T}, orbit)
end

# == To Equinoctial Elements ===============================================================

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, ee::EquinoctialElements
) where {Tepoch <: Number, T <: Number}
    return EquinoctialElements{Tepoch, T}(
        ee.epoch, ee.semi_major_axis, ee.h, ee.k, ee.p, ee.q, ee.mean_longitude
    )
end

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, aee::AlternateEquinoctialElements
) where {Tepoch <: Number, T <: Number}
    return convert(
        EquinoctialElements{Tepoch, T}, _alternate_equinoctial_to_equinoctial(aee)
    )
end

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, ke::KeplerianElements
) where {Tepoch <: Number, T <: Number}
    return convert(
        EquinoctialElements{Tepoch, T}, _keplerian_to_equinoctial(EquinoctialElements, ke)
    )
end

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, sv::OrbitStateVector
) where {Tepoch <: Number, T <: Number}
    return convert(EquinoctialElements{Tepoch, T}, sv_to_kepler(sv))
end

# == To Alternate Equinoctial Elements =====================================================

function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, aee::AlternateEquinoctialElements
) where {Tepoch <: Number, T <: Number}
    return AlternateEquinoctialElements{Tepoch, T}(
        aee.epoch, aee.semi_major_axis, aee.h, aee.k, aee.p, aee.q, aee.mean_longitude
    )
end

function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, ee::EquinoctialElements
) where {Tepoch <: Number, T <: Number}
    return convert(
        AlternateEquinoctialElements{Tepoch, T}, _equinoctial_to_alternate_equinoctial(ee)
    )
end

function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, ke::KeplerianElements
) where {Tepoch <: Number, T <: Number}
    return convert(
        AlternateEquinoctialElements{Tepoch, T},
        _keplerian_to_equinoctial(AlternateEquinoctialElements, ke),
    )
end

function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, sv::OrbitStateVector
) where {Tepoch <: Number, T <: Number}
    return convert(AlternateEquinoctialElements{Tepoch, T}, sv_to_kepler(sv))
end

# == To Keplerian Elements =================================================================

function Base.convert(
    ::Type{KeplerianElements{Tanomaly, Tepoch, T}}, ke::KeplerianElements
) where {Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number}
    return KeplerianElements{Tanomaly, Tepoch, T}(
        ke.epoch,
        ke.semi_major_axis,
        ke.eccentricity,
        ke.inclination,
        ke.raan,
        ke.argument_of_periapsis,
        _anomaly(Tanomaly, ke),
    )
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly, Tepoch, T}}, orbit::AbstractEquinoctialElements
) where {Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, _equinoctial_to_keplerian(orbit))
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly, Tepoch, T}}, sv::OrbitStateVector
) where {Tanomaly <: AbstractAnomaly, Tepoch <: Number, T <: Number}
    return convert(KeplerianElements{Tanomaly, Tepoch, T}, sv_to_kepler(sv))
end

# == To Orbit State Vector =================================================================

function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}}, sv::OrbitStateVector
) where {Tepoch <: Number, T <: Number}
    return OrbitStateVector{Tepoch, T}(sv.epoch, sv.r, sv.v, sv.a)
end

function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}}, ke::KeplerianElements
) where {Tepoch <: Number, T <: Number}
    return convert(OrbitStateVector{Tepoch, T}, kepler_to_sv(ke))
end

function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}}, orbit::AbstractEquinoctialElements
) where {Tepoch <: Number, T <: Number}
    ke = _equinoctial_to_keplerian(orbit)
    return convert(OrbitStateVector{Tepoch, T}, kepler_to_sv(ke))
end

############################################################################################
#                                     Private Functions                                    #
############################################################################################

"""
    _equinoctial_to_keplerian(orbit::AbstractEquinoctialElements{Tepoch, T}) -> KeplerianElements{MeanAnomaly, Tepoch, T}

Convert the equinoctial elements `orbit`, of any set, to Keplerian elements storing the mean
anomaly. The RAAN, the argument of periapsis, and the mean anomaly are returned in the
interval [0, 2π). The conversion fails if the alternate equinoctial elements satisfy
`p² + q² > 1`, which does not represent an orbit.

# Extended help

## Throws

- `ArgumentError`: If `orbit` is an `AlternateEquinoctialElements` with `p² + q² > 1` beyond
    the floating-point rounding error.
"""
function _equinoctial_to_keplerian(
    orbit::AbstractEquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    h = orbit.h
    k = orbit.k
    p = orbit.p
    q = orbit.q
    λ = orbit.mean_longitude

    e = hypot(h, k)
    i = _equinoctial_inclination(orbit)
    Ω = _wrap_to_2π(atan(p, q))
    ω = _wrap_to_2π(atan(h, k) - Ω)
    M = _wrap_to_2π(λ - Ω - ω)

    return KeplerianElements{MeanAnomaly, Tepoch, T}(
        orbit.epoch, orbit.semi_major_axis, e, i, Ω, ω, M
    )
end

"""
    _equinoctial_inclination(ee::EquinoctialElements{Tepoch, T}) -> T
    _equinoctial_inclination(aee::AlternateEquinoctialElements{Tepoch, T}) -> T

Recover the inclination [rad] from the elements `p` and `q` of the equinoctial set. For the
alternate set, the conversion fails if `p² + q² > 1`, which does not represent an orbit.

# Extended help

## Throws

- `ArgumentError`: If the alternate equinoctial elements satisfy `p² + q² > 1` beyond the
    floating-point rounding error.
"""
_equinoctial_inclination(ee::EquinoctialElements) = 2atan(hypot(ee.p, ee.q))

function _equinoctial_inclination(
    aee::AlternateEquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    sin_io2 = hypot(aee.p, aee.q)

    # `sin(i / 2)` cannot exceed 1. We tolerate the rounding error of the conversion from
    # the Keplerian elements of a retrograde equatorial orbit, where `sin(i / 2) = 1`.
    sin_io2 ≤ 1 + 10eps(T) ||
        throw(ArgumentError("The alternate equinoctial elements must satisfy p² + q² ≤ 1."))

    return 2asin(min(sin_io2, one(T)))
end

"""
    _keplerian_to_equinoctial(::Type{EquinoctialElements}, ke::KeplerianElements{Tanomaly, Tepoch, T}) -> EquinoctialElements{Tepoch, T}
    _keplerian_to_equinoctial(::Type{AlternateEquinoctialElements}, ke::KeplerianElements{Tanomaly, Tepoch, T}) -> AlternateEquinoctialElements{Tepoch, T}

Convert the Keplerian elements `ke`, with any anomaly type, to the equinoctial set selected
by the first argument. The conversion to `EquinoctialElements` fails for retrograde
equatorial orbits (`i = π`), where that set is singular.

# Extended help

## Throws

- `ArgumentError`: If the target is `EquinoctialElements` and the inclination is so close to
    `π` that `tan(i / 2)` exceeds `1 / eps(T)`.
"""
function _keplerian_to_equinoctial(
    ::Type{Tequinoctial}, ke::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tequinoctial <: AbstractEquinoctialElements, Tanomaly, Tepoch, T}
    e = ke.eccentricity
    Ω = ke.raan
    ω = ke.argument_of_periapsis
    M = mean_anomaly(ke)

    sin_Ω₊ω, cos_Ω₊ω = sincos(Ω + ω)
    sin_Ω, cos_Ω     = sincos(Ω)

    h = e * sin_Ω₊ω
    k = e * cos_Ω₊ω
    λ = Ω + ω + M

    # The sets differ only in the factor that encodes the inclination in `p` and `q`.
    s = _inclination_factor(Tequinoctial, ke.inclination)
    p = s * sin_Ω
    q = s * cos_Ω

    return Tequinoctial{Tepoch, T}(ke.epoch, ke.semi_major_axis, h, k, p, q, λ)
end

"""
    _inclination_factor(::Type{EquinoctialElements}, i::T) -> T
    _inclination_factor(::Type{AlternateEquinoctialElements}, i::T) -> T

Compute the factor that multiplies `sin(Ω)` and `cos(Ω)` in the elements `p` and `q` of the
selected equinoctial set given the inclination `i` [rad]: `tan(i / 2)` for
`EquinoctialElements` and `sin(i / 2)` for `AlternateEquinoctialElements`. The former fails
for retrograde equatorial orbits (`i = π`), where the equinoctial elements are singular.

# Extended help

## Throws

- `ArgumentError`: If the target is `EquinoctialElements` and the inclination is so close to
    `π` that `tan(i / 2)` exceeds `1 / eps(T)`.
"""
function _inclination_factor(::Type{EquinoctialElements}, i::Number)
    tan_io2 = tan(i / 2)

    # The elements `p` and `q` are singular at i = π. In floating point, `tan(i / 2)` does
    # not overflow at `i = π`, but it exceeds `1 / eps(T)`, where `p` and `q` lose all the
    # fractional precision. We use this threshold to detect the singularity.
    _check_equinoctial_singularity(tan_io2)

    return tan_io2
end

_inclination_factor(::Type{AlternateEquinoctialElements}, i::Number) = sin(i / 2)

"""
    _equinoctial_to_alternate_equinoctial(ee::EquinoctialElements{Tepoch, T}) -> AlternateEquinoctialElements{Tepoch, T}

Convert the equinoctial elements `ee` to alternate equinoctial elements by scaling `p` and
`q` with `cos(i / 2) = 1 / √(1 + tan²(i / 2))`.
"""
function _equinoctial_to_alternate_equinoctial(
    ee::EquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    tan_io2 = hypot(ee.p, ee.q)
    cos_io2 = 1 / √(1 + tan_io2^2)

    return AlternateEquinoctialElements{Tepoch, T}(
        ee.epoch,
        ee.semi_major_axis,
        ee.h,
        ee.k,
        ee.p * cos_io2,
        ee.q * cos_io2,
        ee.mean_longitude,
    )
end

"""
    _alternate_equinoctial_to_equinoctial(aee::AlternateEquinoctialElements{Tepoch, T}) -> EquinoctialElements{Tepoch, T}

Convert the alternate equinoctial elements `aee` to equinoctial elements by scaling `p` and
`q` with `1 / cos(i / 2) = 1 / √(1 - sin²(i / 2))`. The conversion fails for retrograde
equatorial orbits (`i = π`), where the equinoctial elements are singular.

# Extended help

## Throws

- `ArgumentError`: If the inclination is so close to `π` that `tan(i / 2)` exceeds
    `1 / eps(T)`.
"""
function _alternate_equinoctial_to_equinoctial(
    aee::AlternateEquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    sin_io2 = hypot(aee.p, aee.q)
    cos_io2 = √(max(1 - sin_io2^2, zero(T)))
    tan_io2 = sin_io2 / cos_io2

    _check_equinoctial_singularity(tan_io2)

    scale = 1 / cos_io2

    return EquinoctialElements{Tepoch, T}(
        aee.epoch,
        aee.semi_major_axis,
        aee.h,
        aee.k,
        aee.p * scale,
        aee.q * scale,
        aee.mean_longitude,
    )
end

"""
    _check_equinoctial_singularity(tan_io2::T) -> Nothing

Throw an `ArgumentError` if `tan_io2`, the value of `tan(i / 2)`, is not lower than
`1 / eps(T)`, meaning that the orbit is so close to a retrograde equatorial orbit (`i = π`)
that the equinoctial elements `p` and `q` are singular.
"""
function _check_equinoctial_singularity(tan_io2::T) where {T}
    abs(tan_io2) < 1 / eps(T) ||
        throw(ArgumentError("The equinoctial elements are singular at i = π."))
    return nothing
end

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

# See the docstring of `EquinoctialElements` for the description of the conversions.
function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, ee::EquinoctialElements
) where {Tepoch, T}
    return EquinoctialElements{Tepoch, T}(
        ee.epoch, ee.semi_major_axis, ee.h, ee.k, ee.p, ee.q, ee.mean_longitude
    )
end

function Base.convert(::Type{EquinoctialElements}, aee::AlternateEquinoctialElements)
    return _alternate_equinoctial_to_equinoctial(aee)
end

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}}, aee::AlternateEquinoctialElements
) where {Tepoch, T}
    return convert(
        EquinoctialElements{Tepoch, T}, _alternate_equinoctial_to_equinoctial(aee)
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

# == To Alternate Equinoctial Elements =====================================================

# See the docstring of `AlternateEquinoctialElements` for the description of the
# conversions.
function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, aee::AlternateEquinoctialElements
) where {Tepoch, T}
    return AlternateEquinoctialElements{Tepoch, T}(
        aee.epoch, aee.semi_major_axis, aee.h, aee.k, aee.p, aee.q, aee.mean_longitude
    )
end

function Base.convert(::Type{AlternateEquinoctialElements}, ee::EquinoctialElements)
    return _equinoctial_to_alternate_equinoctial(ee)
end

function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, ee::EquinoctialElements
) where {Tepoch, T}
    return convert(
        AlternateEquinoctialElements{Tepoch, T}, _equinoctial_to_alternate_equinoctial(ee)
    )
end

function Base.convert(::Type{AlternateEquinoctialElements}, ke::KeplerianElements)
    return _keplerian_to_alternate_equinoctial(ke)
end

function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, ke::KeplerianElements
) where {Tepoch, T}
    return convert(
        AlternateEquinoctialElements{Tepoch, T}, _keplerian_to_alternate_equinoctial(ke)
    )
end

function Base.convert(
    ::Type{AlternateEquinoctialElements}, sv::OrbitStateVector{Tepoch, T}
) where {Tepoch, T}
    return convert(AlternateEquinoctialElements{Tepoch, T}, sv)
end

function Base.convert(
    ::Type{AlternateEquinoctialElements{Tepoch, T}}, sv::OrbitStateVector
) where {Tepoch, T}
    return convert(AlternateEquinoctialElements{Tepoch, T}, sv_to_kepler(sv))
end

# == To Keplerian Elements =================================================================

# See the docstring of `KeplerianElements` for the description of the conversions.
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

# The conversions from both equinoctial sets share the same structure.
for (Torbit, helper) in (
    (:EquinoctialElements, :_equinoctial_to_keplerian),
    (:AlternateEquinoctialElements, :_alternate_equinoctial_to_keplerian),
)
    @eval begin
        function Base.convert(
            ::Type{KeplerianElements}, orbit::$Torbit{Tepoch, T}
        ) where {Tepoch, T}
            return convert(KeplerianElements{TrueAnomaly, Tepoch, T}, orbit)
        end

        function Base.convert(
            ::Type{KeplerianElements{Tanomaly}}, orbit::$Torbit{Tepoch, T}
        ) where {Tanomaly, Tepoch, T}
            return convert(KeplerianElements{Tanomaly, Tepoch, T}, orbit)
        end

        function Base.convert(
            ::Type{KeplerianElements{Tanomaly, Tepoch, T}}, orbit::$Torbit
        ) where {Tanomaly, Tepoch, T}
            return convert(KeplerianElements{Tanomaly, Tepoch, T}, $helper(orbit))
        end
    end
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

# See the docstring of `OrbitStateVector` for the description of the conversions.
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

# The conversions from both equinoctial sets go through the Keplerian elements.
for Torbit in (:EquinoctialElements, :AlternateEquinoctialElements)
    @eval begin
        function Base.convert(
            ::Type{OrbitStateVector}, orbit::$Torbit{Tepoch, T}
        ) where {Tepoch, T}
            return convert(OrbitStateVector{Tepoch, T}, orbit)
        end

        function Base.convert(
            ::Type{OrbitStateVector{Tepoch, T}}, orbit::$Torbit
        ) where {Tepoch, T}
            ke = convert(KeplerianElements{TrueAnomaly, Tepoch, T}, orbit)
            return convert(OrbitStateVector{Tepoch, T}, ke)
        end
    end
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
    i = 2atan(hypot(ee.p, ee.q))
    return _equinoctial_like_to_keplerian(ee, i)
end

"""
    _alternate_equinoctial_to_keplerian(aee::AlternateEquinoctialElements{Tepoch, T}) -> KeplerianElements{MeanAnomaly, Tepoch, T}

Convert the alternate equinoctial elements `aee` to Keplerian elements storing the mean
anomaly. The RAAN, the argument of periapsis, and the mean anomaly are returned in the
interval [0, 2π). The conversion fails if `p² + q² > 1`, which does not represent an orbit.

# Extended help

## Throws

- `ArgumentError`: If `p² + q² > 1` beyond the floating-point rounding error.
"""
function _alternate_equinoctial_to_keplerian(
    aee::AlternateEquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    sin_io2 = hypot(aee.p, aee.q)

    # `sin(i / 2)` cannot exceed 1. We tolerate the rounding error of the conversion from
    # the Keplerian elements of a retrograde equatorial orbit, where `sin(i / 2) = 1`.
    sin_io2 ≤ 1 + 10eps(T) ||
        throw(ArgumentError("The alternate equinoctial elements must satisfy p² + q² ≤ 1."))

    i = 2asin(min(sin_io2, one(T)))
    return _equinoctial_like_to_keplerian(aee, i)
end

"""
    _equinoctial_like_to_keplerian(orbit::Union{EquinoctialElements{Tepoch, T}, AlternateEquinoctialElements{Tepoch, T}}, i::T) -> KeplerianElements{MeanAnomaly, Tepoch, T}

Convert the elements `h`, `k`, `p`, `q`, and `mean_longitude` of `orbit`, together with the
inclination `i` [rad] already recovered from `p` and `q`, to Keplerian elements storing the
mean anomaly. The RAAN, the argument of periapsis, and the mean anomaly are returned in the
interval [0, 2π).
"""
function _equinoctial_like_to_keplerian(
    orbit::Union{EquinoctialElements{Tepoch, T}, AlternateEquinoctialElements{Tepoch, T}},
    i::T,
) where {Tepoch, T}
    h = orbit.h
    k = orbit.k
    p = orbit.p
    q = orbit.q
    λ = orbit.mean_longitude

    e = hypot(h, k)
    Ω = _wrap_to_2π(atan(p, q))
    ω = _wrap_to_2π(atan(h, k) - Ω)
    M = _wrap_to_2π(λ - Ω - ω)

    return KeplerianElements{MeanAnomaly, Tepoch, T}(
        orbit.epoch, orbit.semi_major_axis, e, i, Ω, ω, M
    )
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
    h, k, λ, sin_Ω, cos_Ω = _keplerian_to_equinoctial_common(ke)
    tan_io2 = tan(ke.inclination / 2)

    # The elements `p` and `q` are singular at i = π. In floating point, `tan(i / 2)` does
    # not overflow at `i = π`, but it exceeds `1 / eps(T)`, where `p` and `q` lose all the
    # fractional precision. We use this threshold to detect the singularity.
    _check_equinoctial_singularity(tan_io2)

    p = tan_io2 * sin_Ω
    q = tan_io2 * cos_Ω

    return EquinoctialElements{Tepoch, T}(ke.epoch, ke.semi_major_axis, h, k, p, q, λ)
end

"""
    _keplerian_to_alternate_equinoctial(ke::KeplerianElements{Tanomaly, Tepoch, T}) -> AlternateEquinoctialElements{Tepoch, T}

Convert the Keplerian elements `ke`, with any anomaly type, to alternate equinoctial
elements.
"""
function _keplerian_to_alternate_equinoctial(
    ke::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    h, k, λ, sin_Ω, cos_Ω = _keplerian_to_equinoctial_common(ke)
    sin_io2 = sin(ke.inclination / 2)

    p = sin_io2 * sin_Ω
    q = sin_io2 * cos_Ω

    return AlternateEquinoctialElements{Tepoch, T}(
        ke.epoch, ke.semi_major_axis, h, k, p, q, λ
    )
end

"""
    _keplerian_to_equinoctial_common(ke::KeplerianElements{Tanomaly, Tepoch, T}) -> T, T, T, T, T

Compute the elements shared by both equinoctial sets from the Keplerian elements `ke`.

# Returns

- `T`: Element `h = e * sin(ω + Ω)` [-].
- `T`: Element `k = e * cos(ω + Ω)` [-].
- `T`: Mean longitude `λ = Ω + ω + M` [rad].
- `T`: `sin(Ω)` [-].
- `T`: `cos(Ω)` [-].
"""
function _keplerian_to_equinoctial_common(ke::KeplerianElements)
    e = ke.eccentricity
    Ω = ke.raan
    ω = ke.argument_of_periapsis
    M = mean_anomaly(ke)

    sin_Ω₊ω, cos_Ω₊ω = sincos(Ω + ω)
    sin_Ω, cos_Ω     = sincos(Ω)

    h = e * sin_Ω₊ω
    k = e * cos_Ω₊ω
    λ = Ω + ω + M

    return h, k, λ, sin_Ω, cos_Ω
end

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

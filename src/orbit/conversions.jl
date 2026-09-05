## Description #############################################################################
#
# Conversion between the orbit representations using Julia built-in system.
#
# `convert` takes no options, so the conversions between Keplerian elements and orbit state
# vectors use the default central body (Earth). Call `kepler_to_sv` or `sv_to_kepler` with
# the keyword `μ` for an orbit around another body.
#
############################################################################################

# == Equinoctial Elements => Equinoctial Elements ==========================================

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}},
    ee::EquinoctialElements
) where {Tepoch, T}
    return EquinoctialElements{Tepoch, T}(
        ee.epoch,
        ee.semi_major_axis,
        ee.h,
        ee.k,
        ee.p,
        ee.q,
        ee.longitude
    )
end

# == Equinoctial Elements => Keplerian Elements ============================================

function Base.convert(
    ::Type{KeplerianElements{Tanomaly}},
    ee::EquinoctialElements{Tepoch, T}
) where {Tanomaly, Tepoch, T}
    t = ee.epoch
    a = ee.semi_major_axis
    h = ee.h
    k = ee.k
    p = ee.p
    q = ee.q
    l = ee.longitude

    e = hypot(h, k)
    Ω = atan(p, q)
    i = 2atan(hypot(p, q))
    ω = atan(h, k) - Ω
    M = l - Ω - ω

    return convert(
        KeplerianElements{Tanomaly, Tepoch, T},
        KeplerianElements{MeanAnomaly, Tepoch, T}(t, a, e, i, Ω, ω, M)
    )
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly, Tepoch, T}},
    ee::EquinoctialElements
) where {Tanomaly, Tepoch, T}
    t = ee.epoch
    a = ee.semi_major_axis
    h = ee.h
    k = ee.k
    p = ee.p
    q = ee.q
    l = ee.longitude

    e = hypot(h, k)
    Ω = atan(p, q)
    i = 2atan(hypot(p, q))
    ω = atan(h, k) - Ω
    M = l - Ω - ω

    return convert(
        KeplerianElements{Tanomaly, Tepoch, T},
        KeplerianElements{MeanAnomaly, Tepoch, T}(t, a, e, i, Ω, ω, M)
    )
end

# == Equinoctial Elements => Orbit State Vector ============================================

function Base.convert(
    ::Type{OrbitStateVector},
    ee::EquinoctialElements{Tepoch, T}
) where {Tepoch, T}
    k = convert(KeplerianElements{TrueAnomaly, Tepoch, T}, ee)
    return convert(OrbitStateVector{Tepoch, T}, k)
end

function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}},
    ee::EquinoctialElements
) where {Tepoch, T}
    k = convert(KeplerianElements{TrueAnomaly, Tepoch, T}, ee)
    return convert(OrbitStateVector{Tepoch, T}, k)
end

# == Keplerian Elements => Equinoctial Elements ============================================

function Base.convert(
    ::Type{EquinoctialElements},
    ke::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    t = ke.epoch
    a = ke.semi_major_axis
    e = ke.eccentricity
    i = ke.inclination
    Ω = ke.raan
    ω = ke.argument_of_periapsis
    M = mean_anomaly(ke)

    sin_Ω₊ω, cos_Ω₊ω = sincos(Ω + ω)
    sin_Ω, cos_Ω     = sincos(Ω)
    tan_io2          = tan(i / 2)

    h = e * sin_Ω₊ω
    k = e * cos_Ω₊ω
    p = tan_io2 * sin_Ω
    q = tan_io2 * cos_Ω
    l = Ω + ω + M

    return EquinoctialElements{Tepoch, T}(t, a, h, k, p, q, l)
end

function Base.convert(
    ::Type{EquinoctialElements{Tepoch, T}},
    ke::KeplerianElements
) where {Tepoch, T}
    t = ke.epoch
    a = ke.semi_major_axis
    e = ke.eccentricity
    i = ke.inclination
    Ω = ke.raan
    ω = ke.argument_of_periapsis
    M = mean_anomaly(ke)

    sin_Ω₊ω, cos_Ω₊ω = sincos(Ω + ω)
    sin_Ω, cos_Ω     = sincos(Ω)
    tan_io2          = tan(i / 2)

    h = e * sin_Ω₊ω
    k = e * cos_Ω₊ω
    p = tan_io2 * sin_Ω
    q = tan_io2 * cos_Ω
    l = Ω + ω + M

    return EquinoctialElements{Tepoch, T}(t, a, h, k, p, q, l)
end

# == Keplerian Elements => Keplerian Elements ==============================================

function Base.convert(
    ::Type{KeplerianElements{EccentricAnomaly}},
    k::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return Base.convert(KeplerianElements{EccentricAnomaly, Tepoch, T}, k)
end

function Base.convert(
    ::Type{KeplerianElements{EccentricAnomaly, Tepoch, T}},
    k::KeplerianElements
) where {Tepoch, T}
    return KeplerianElements{EccentricAnomaly, Tepoch, T}(
        k.epoch,
        k.semi_major_axis,
        k.eccentricity,
        k.inclination,
        k.raan,
        k.argument_of_periapsis,
        eccentric_anomaly(k)
    )
end

function Base.convert(
    ::Type{KeplerianElements{MeanAnomaly}},
    k::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return Base.convert(KeplerianElements{MeanAnomaly, Tepoch, T}, k)
end

function Base.convert(
    ::Type{KeplerianElements{MeanAnomaly, Tepoch, T}},
    k::KeplerianElements
) where {Tepoch, T}
    return KeplerianElements{MeanAnomaly, Tepoch, T}(
        k.epoch,
        k.semi_major_axis,
        k.eccentricity,
        k.inclination,
        k.raan,
        k.argument_of_periapsis,
        mean_anomaly(k)
    )
end

function Base.convert(
    ::Type{KeplerianElements{TrueAnomaly}},
    k::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return Base.convert(KeplerianElements{TrueAnomaly, Tepoch, T}, k)
end

function Base.convert(
    ::Type{KeplerianElements{TrueAnomaly, Tepoch, T}},
    k::KeplerianElements
) where {Tepoch, T}
    return KeplerianElements{TrueAnomaly, Tepoch, T}(
        k.epoch,
        k.semi_major_axis,
        k.eccentricity,
        k.inclination,
        k.raan,
        k.argument_of_periapsis,
        true_anomaly(k)
    )
end

# == Keplerian Elements => Orbit State Vector ==============================================

function Base.convert(
    ::Type{KeplerianElements},
    sv::OrbitStateVector{Tepoch, T}
) where {Tepoch, T}
    return Base.convert(KeplerianElements{TrueAnomaly, Tepoch, T}, sv)
end

function Base.convert(
    ::Type{KeplerianElements{Tanomaly}},
    sv::OrbitStateVector{Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return Base.convert(KeplerianElements{Tanomaly, Tepoch, T}, sv)
end

function Base.convert(
    KT::Type{KeplerianElements{Tanomaly, Tepoch, T}},
    sv::OrbitStateVector
) where {Tanomaly, Tepoch, T}
    k = sv_to_kepler(sv)
    return convert(KT, k)
end

# == Orbit State Vector => Keplerian Elements ==============================================

function Base.convert(
    ::Type{OrbitStateVector},
    k::KeplerianElements{Tanomaly, Tepoch, T}
) where {Tanomaly, Tepoch, T}
    return Base.convert(OrbitStateVector{Tepoch, T}, k)
end

function Base.convert(
    ST::Type{OrbitStateVector{Tepoch, T}},
    k::KeplerianElements
) where {Tepoch, T}
    sv = kepler_to_sv(k)
    return convert(ST, sv)
end

function Base.convert(
    ::Type{OrbitStateVector{Tepoch, T}},
    sv::OrbitStateVector
) where {Tepoch, T}
    return OrbitStateVector{Tepoch, T}(sv.t, sv.r, sv.v, sv.a)
end


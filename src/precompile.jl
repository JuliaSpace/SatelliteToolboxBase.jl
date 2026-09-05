## Description #############################################################################
#
# Precompilation.
#
############################################################################################

import PrecompileTools

PrecompileTools.@compile_workload begin

    # == Ellipsoids ========================================================================

    Ellipsoid(6378137.0,   1 / 298.257223563)
    Ellipsoid(6378137.0f0, 1 / 298.257223563f0)

    # == Orbit =============================================================================

    # -- Keplerian Elements ----------------------------------------------------------------

    ke = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
           0.0001111,
          98.405 |> deg2rad,
         200.000 |> deg2rad,
          90.000 |> deg2rad,
         123.456 |> deg2rad,
    )

    ke_f32 = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
           0.0001111f0,
          98.405f0 |> deg2rad,
         200.000f0 |> deg2rad,
          90.000f0 |> deg2rad,
         123.456f0 |> deg2rad,
    )

    ke_E     = convert(KeplerianElements{EccentricAnomaly}, ke)
    ke_E_f32 = convert(KeplerianElements{EccentricAnomaly}, ke_f32)
    ke_M     = convert(KeplerianElements{MeanAnomaly}, ke)
    ke_M_f32 = convert(KeplerianElements{MeanAnomaly}, ke_f32)

    for k in (ke, ke_f32, ke_E, ke_E_f32, ke_M, ke_M_f32)
        show(IOBuffer(), k)
        show(IOBuffer(), MIME("text/plain"), k)
        show(IOContext(IOBuffer(), :color => true), MIME("text/plain"), k)

        true_anomaly(k)
        eccentric_anomaly(k)
        mean_anomaly(k)

        convert(KeplerianElements{TrueAnomaly}, k)
        convert(KeplerianElements{EccentricAnomaly}, k)
        convert(KeplerianElements{MeanAnomaly}, k)

        kepler_to_rv(k)
        kepler_to_sv(k)
        convert(OrbitStateVector, k)
    end

    # -- Equinoctial Elements --------------------------------------------------------------

    ee     = convert(EquinoctialElements, ke)
    ee_f32 = convert(EquinoctialElements, ke_f32)

    for e in (ee, ee_f32)
        show(IOBuffer(), e)
        show(IOBuffer(), MIME("text/plain"), e)

        convert(KeplerianElements, e)
        convert(KeplerianElements{TrueAnomaly}, e)
        convert(KeplerianElements{EccentricAnomaly}, e)
        convert(KeplerianElements{MeanAnomaly}, e)
        convert(OrbitStateVector, e)
    end

    # -- Orbit State Vector ----------------------------------------------------------------

    sv = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107e3,  1.954e6, 6.110e6],
        [ 6.337e3, -1.470e3, 3.684e3]
    )

    sv_f32 = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107f3,  1.954f6, 6.110f6],
        [ 6.337f3, -1.470f3, 3.684f3]
    )

    for s in (sv, sv_f32)
        show(IOBuffer(), s)
        show(IOBuffer(), MIME("text/plain"), s)

        rv_to_kepler(s.r, s.v)
        rv_to_kepler(s.r, s.v, 0.0)
        sv_to_kepler(s)

        convert(KeplerianElements, s)
        convert(KeplerianElements{MeanAnomaly}, s)
        convert(EquinoctialElements, s)
    end

    # == Time ==============================================================================

    jd_to_gmst(2448855.009722) * 180 / π
    date_to_jd(1986, 06, 19, 21, 35, 22)
    date_to_jd(1986, 06, 19, 21, 35, 22.0)
    date_to_jd(Date(2020, 8, 14))
    date_to_jd(DateTime(2020, 8, 14, 12, 4, 1))
    date_to_jd(DateTime(2020, 8, 14, 12, 4, 1, 500))
    jd_to_date(2.451545e6 + 1 / 1000 / 86400)
    jd_to_date(Int, 2446601.399560)
    jd_to_date(Date, 2446601.399560)
end

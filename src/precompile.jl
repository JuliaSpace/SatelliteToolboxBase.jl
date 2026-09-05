## Description #############################################################################
#
# Precompilation.
#
############################################################################################

import PrecompileTools

# The formatter does not honor the `#! format: off` markers inside the workload block, so
# the entire block is excluded from formatting to keep the hand-aligned numeric columns.
#! format: off
PrecompileTools.@compile_workload begin

    # == Ellipsoids ========================================================================

    # Construction with `Float64` and `Float32` inputs.
    Ellipsoid(6378137.0,   1 / 298.257223563)
    Ellipsoid(6378137.0f0, 1 / 298.257223563f0)

    # == Orbit =============================================================================

    # -- Keplerian Elements ----------------------------------------------------------------

    # Construction with `Float64` and `Float32` elements.
    ke_f64 = KeplerianElements(
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

    # Conversion between the anomaly types.
    ke_E     = convert(KeplerianElements{EccentricAnomaly}, ke_f64)
    ke_E_f32 = convert(KeplerianElements{EccentricAnomaly}, ke_f32)
    ke_M     = convert(KeplerianElements{MeanAnomaly}, ke_f64)
    ke_M_f32 = convert(KeplerianElements{MeanAnomaly}, ke_f32)

    # Printing, anomaly getters, anomaly conversions, and conversion to the Cartesian state
    # for each anomaly type and element type.
    for ke in (ke_f64, ke_f32, ke_E, ke_E_f32, ke_M, ke_M_f32)
        show(IOBuffer(), ke)
        show(IOBuffer(), MIME("text/plain"), ke)
        show(IOContext(IOBuffer(), :color => true), MIME("text/plain"), ke)

        true_anomaly(ke)
        eccentric_anomaly(ke)
        mean_anomaly(ke)

        convert(KeplerianElements{TrueAnomaly}, ke)
        convert(KeplerianElements{EccentricAnomaly}, ke)
        convert(KeplerianElements{MeanAnomaly}, ke)

        kepler_to_rv(ke)
        kepler_to_sv(ke)
        convert(OrbitStateVector, ke)
        convert(EquinoctialElements, ke)
        convert(AlternateEquinoctialElements, ke)
    end

    # -- Equinoctial Elements --------------------------------------------------------------

    # Conversion from the Keplerian elements.
    ee_f64  = convert(EquinoctialElements, ke_f64)
    ee_f32  = convert(EquinoctialElements, ke_f32)

    # Printing and conversions to the Keplerian elements, to the alternate equinoctial
    # elements, and to the orbit state vector.
    for ee in (ee_f64, ee_f32)
        show(IOBuffer(), ee)
        show(IOBuffer(), MIME("text/plain"), ee)

        convert(KeplerianElements, ee)
        convert(KeplerianElements{TrueAnomaly}, ee)
        convert(KeplerianElements{EccentricAnomaly}, ee)
        convert(KeplerianElements{MeanAnomaly}, ee)
        convert(AlternateEquinoctialElements, ee)
        convert(OrbitStateVector, ee)
    end

    # -- Alternate Equinoctial Elements ----------------------------------------------------

    # Conversion from the Keplerian elements.
    aee_f64 = convert(AlternateEquinoctialElements, ke_f64)
    aee_f32 = convert(AlternateEquinoctialElements, ke_f32)

    # Printing and conversions to the Keplerian elements, to the equinoctial elements, and
    # to the orbit state vector.
    for aee in (aee_f64, aee_f32)
        show(IOBuffer(), aee)
        show(IOBuffer(), MIME("text/plain"), aee)

        convert(KeplerianElements, aee)
        convert(KeplerianElements{TrueAnomaly}, aee)
        convert(KeplerianElements{EccentricAnomaly}, aee)
        convert(KeplerianElements{MeanAnomaly}, aee)
        convert(EquinoctialElements, aee)
        convert(OrbitStateVector, aee)
    end

    # -- Orbit State Vector ----------------------------------------------------------------

    # Construction with `Float64` and `Float32` elements.
    sv_f64 = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107e3,  1.954e6, 6.110e6],
        [ 6.337e3, -1.470e3, 3.684e3],
    )

    sv_f32 = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107f3,  1.954f6, 6.110f6],
        [ 6.337f3, -1.470f3, 3.684f3],
    )

    # Printing and conversions to the Keplerian and equinoctial elements.
    for sv in (sv_f64, sv_f32)
        show(IOBuffer(), sv)
        show(IOBuffer(), MIME("text/plain"), sv)

        rv_to_kepler(sv.r, sv.v)
        rv_to_kepler(sv.r, sv.v, 0.0)
        sv_to_kepler(sv)

        convert(KeplerianElements, sv)
        convert(KeplerianElements{MeanAnomaly}, sv)
        convert(EquinoctialElements, sv)
        convert(AlternateEquinoctialElements, sv)
    end

    # == Time ==============================================================================

    # Greenwich mean sidereal time.
    jd_to_gmst(2448855.009722) * 180 / π

    # Conversion from date to Julian Day with integer and floating-point seconds, `Date`,
    # and `DateTime` with and without milliseconds.
    date_to_jd(1986, 06, 19, 21, 35, 22)
    date_to_jd(1986, 06, 19, 21, 35, 22.0)
    date_to_jd(Date(2020, 8, 14))
    date_to_jd(DateTime(2020, 8, 14, 12, 4, 1))
    date_to_jd(DateTime(2020, 8, 14, 12, 4, 1, 500))

    # Conversion from Julian Day to the date tuple, `Date`, and `DateTime`.
    jd_to_date(2.451545e6 + 1 / 1000 / 86400)
    jd_to_date(Int, 2446601.399560)
    jd_to_date(Date, 2446601.399560)
    jd_to_date(DateTime, 2446601.399560)
end
#! format: on

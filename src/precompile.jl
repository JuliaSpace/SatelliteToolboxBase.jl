# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Precompilation.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import PrecompileTools

PrecompileTools.@compile_workload begin

    ########################################################################################
    #                                      Ellipsoids
    ########################################################################################

    Ellipsoid(6378137.0,   1 / 298.257223563)
    Ellipsoid(6378137.0f0, 1 / 298.257223563f0)

    ########################################################################################
    #                                        Orbit
    ########################################################################################

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

    show(IOBuffer(), ke)
    show(IOBuffer(), MIME("text/plain"), ke)
    show(IOBuffer(), ke_f32)
    show(IOBuffer(), MIME("text/plain"), ke_f32)

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

    show(IOBuffer(), sv)
    show(IOBuffer(), MIME("text/plain"), sv)
    show(IOBuffer(), sv_f32)
    show(IOBuffer(), MIME("text/plain"), sv_f32)

    # Conversions
    # ======================================================================================

    kepler_to_rv(ke)
    kepler_to_rv(ke_f32)
    rv_to_kepler(sv.r, sv.v)
    rv_to_kepler(sv.r, sv.v, 0.0)
    rv_to_kepler(sv_f32.r, sv_f32.v)
    rv_to_kepler(sv_f32.r, sv_f32.v, 0.0)

    kepler_to_sv(ke)
    kepler_to_sv(ke_f32)
    sv_to_kepler(sv)
    sv_to_kepler(sv_f32)

    ########################################################################################
    #                                         Time
    ########################################################################################

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

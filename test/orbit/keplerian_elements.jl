# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to the orbit representation using Keplerian elements.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Construction" begin
    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
           0.0001111,
          98.405 |> deg2rad,
         200.000 |> deg2rad,
          90.000 |> deg2rad,
         123.456 |> deg2rad,
    )

    @test orb isa KeplerianElements{Float64, Float64}

    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
           0.0001111f0,
          98.405f0 |> deg2rad,
         200.000f0 |> deg2rad,
          90.000f0 |> deg2rad,
         123.456f0 |> deg2rad,
    )

    @test orb isa KeplerianElements{Float64, Float32}

    orb = KeplerianElements(
        Int64(2451545),
        7130.982f3,
           0.0001111f0,
          98.405f0 |> deg2rad,
         200.000f0 |> deg2rad,
          90.000f0 |> deg2rad,
         123.456f0 |> deg2rad,
    )

    @test orb isa KeplerianElements{Int64, Float32}
end

@testset "Show" begin
    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
           0.0001111,
          98.405 |> deg2rad,
         200.000 |> deg2rad,
          90.000 |> deg2rad,
         123.456 |> deg2rad,
    )

    orb_f32 = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
           0.0001111f0,
          98.405f0 |> deg2rad,
         200.000f0 |> deg2rad,
          90.000f0 |> deg2rad,
         123.456f0 |> deg2rad,
    )

    expected = "KeplerianElements{Float64, Float64}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, orb)
    @test str == expected

    expected = "KeplerianElements{Float64, Float32}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, orb_f32)
    @test str == expected

    expected = """
KeplerianElements{Float64, Float64}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7130.98      km
    Eccentricity :    0.0001111
     Inclination :   98.405     °
            RAAN :  200.0       °
 Arg. of Perigee :   90.0       °
    True Anomaly :  123.456     °"""
    str = sprint(show, MIME("text/plain"), orb)
    @test str == expected

    expected = """
KeplerianElements{Float64, Float32}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7130.98      km
    Eccentricity :    0.0001111
     Inclination :   98.405     °
            RAAN :  200.0       °
 Arg. of Perigee :   90.0       °
    True Anomaly :  123.456     °"""
    str = sprint(show, MIME("text/plain"), orb_f32)
    @test str == expected
end

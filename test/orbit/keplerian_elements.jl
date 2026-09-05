## Description #############################################################################
#
# Tests related to the orbit representation using Keplerian elements.
#
############################################################################################

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

    @test orb isa KeplerianElements{TrueAnomaly, Float64, Float64}

    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
           0.0001111f0,
          98.405f0 |> deg2rad,
         200.000f0 |> deg2rad,
          90.000f0 |> deg2rad,
         123.456f0 |> deg2rad,
    )

    @test orb isa KeplerianElements{TrueAnomaly, Float64, Float32}

    orb = KeplerianElements(
        Int64(2451545),
        7130.982f3,
           0.0001111f0,
          98.405f0 |> deg2rad,
         200.000f0 |> deg2rad,
          90.000f0 |> deg2rad,
         123.456f0 |> deg2rad,
    )

    @test orb isa KeplerianElements{TrueAnomaly, Int64, Float32}

    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130000,
        0,
        98.405 |> deg2rad,
        0,
        0,
        0
    )

    @test orb isa KeplerianElements{TrueAnomaly, Float64, Float64}

    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130000,
        0,
        98.405f0 |> deg2rad,
        0,
        0,
        0
    )

    @test orb isa KeplerianElements{TrueAnomaly, Float64, Float32}

    # Integer inputs must be promoted to float.
    orb = KeplerianElements(1, 2, 3, 4, 5, 6, 7)
    @test orb isa KeplerianElements{TrueAnomaly, Int64, Float64}

    # == Anomaly Types =====================================================================

    for Tanomaly in (TrueAnomaly, EccentricAnomaly, MeanAnomaly)
        orb = KeplerianElements{Tanomaly}(
            date_to_jd(1986, 6, 19, 18, 35, 0),
            7130.982e3,
               0.0001111,
              98.405 |> deg2rad,
             200.000 |> deg2rad,
              90.000 |> deg2rad,
             123.456 |> deg2rad,
        )

        @test orb isa KeplerianElements{Tanomaly, Float64, Float64}
        @test orb.anomaly ≈ 123.456 |> deg2rad

        orb = KeplerianElements{Tanomaly}(Int64(2451545), 7130.982f3, 0, 0, 0, 0, 0)
        @test orb isa KeplerianElements{Tanomaly, Int64, Float32}

        orb = KeplerianElements{Tanomaly, Float64, Float32}(1, 2, 3, 4, 5, 6, 7)
        @test orb isa KeplerianElements{Tanomaly, Float64, Float32}
        @test orb.epoch === 1.0
        @test orb.anomaly === 7.0f0
    end

    # `KeplerianElements{Tanomaly, Tepoch, T}` requires `Tanomaly <: AbstractAnomaly`.
    @test_throws TypeError KeplerianElements{Float64, Float64}
end

@testset "Property Aliases" begin
    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
           0.0001111,
          98.405 |> deg2rad,
         200.000 |> deg2rad,
          90.000 |> deg2rad,
         123.456 |> deg2rad,
    )

    @test orb.t === orb.epoch
    @test orb.a === orb.semi_major_axis
    @test orb.e === orb.eccentricity
    @test orb.i === orb.inclination
    @test orb.Ω === orb.raan
    @test orb.ω === orb.argument_of_periapsis
    @test orb.f === orb.anomaly

    @test :t in propertynames(orb)
    @test :f in propertynames(orb)
    @test :anomaly in propertynames(orb)

    # `f` must always return the true anomaly, regardless of the stored anomaly.
    orb_E = convert(KeplerianElements{EccentricAnomaly}, orb)
    orb_M = convert(KeplerianElements{MeanAnomaly}, orb)

    @test orb_E.f ≈ orb.anomaly
    @test orb_M.f ≈ orb.anomaly
    @test orb_E.f != orb_E.anomaly
    @test orb_M.f != orb_M.anomaly
end

@testset "Anomaly Getters" begin
    # Values from the Vallado example 2-1 (see ./anomalies.jl): M = 235.4°, e = 0.4.
    e = 0.4
    M = 235.4 |> deg2rad
    E = 220.512_074_767_522 |> deg2rad
    f = 207.163_991_769_213_96 |> deg2rad

    orb_M = KeplerianElements{MeanAnomaly}(0.0, 8000e3, e, 0.1, 0.2, 0.3, M)
    orb_E = KeplerianElements{EccentricAnomaly}(0.0, 8000e3, e, 0.1, 0.2, 0.3, E)
    orb_f = KeplerianElements{TrueAnomaly}(0.0, 8000e3, e, 0.1, 0.2, 0.3, f)

    for orb in (orb_M, orb_E, orb_f)
        @test mean_anomaly(orb)      ≈ M atol = 1e-14
        @test eccentric_anomaly(orb) ≈ E atol = 1e-14
        @test true_anomaly(orb)      ≈ f atol = 1e-14

        @test mean_anomaly(orb)      isa Float64
        @test eccentric_anomaly(orb) isa Float64
        @test true_anomaly(orb)      isa Float64
    end

    # The getters must return the stored field without conversion when possible.
    @test mean_anomaly(orb_M)      === orb_M.anomaly
    @test eccentric_anomaly(orb_E) === orb_E.anomaly
    @test true_anomaly(orb_f)      === orb_f.anomaly

    # Float32.
    orb_M32 = KeplerianElements{MeanAnomaly}(0.0, 8000f3, Float32(e), 0.1f0, 0.2f0, 0.3f0, Float32(M))
    @test eccentric_anomaly(orb_M32) isa Float32
    @test true_anomaly(orb_M32)      isa Float32
    @test eccentric_anomaly(orb_M32) ≈ E atol = 1e-6
    @test true_anomaly(orb_M32)      ≈ f atol = 1e-6

    # == Keywords Forwarded to the Newton-Raphson Solver ===================================

    # With a single iteration the solution is not converged yet.
    E₁ = eccentric_anomaly(orb_M; max_iterations = 1)
    @test abs(E₁ - E) > 1e-6
    @test eccentric_anomaly(orb_M; max_iterations = 10) ≈ E atol = 1e-14
    @test true_anomaly(orb_M; max_iterations = 10)      ≈ f atol = 1e-14

    # A loose tolerance must stop at the first iteration that satisfies it.
    @test eccentric_anomaly(orb_M; tol = 1e-1) == eccentric_anomaly(orb_M; max_iterations = 1)

    # Keywords are accepted (and ignored) by the other getters.
    @test mean_anomaly(orb_M; tol = 1e-3)      === orb_M.anomaly
    @test true_anomaly(orb_f; tol = 1e-3)      === orb_f.anomaly
    @test eccentric_anomaly(orb_E; tol = 1e-3) === orb_E.anomaly
    @test mean_anomaly(orb_f; max_iterations = 2) ≈ M atol = 1e-14
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

    expected = "KeplerianElements{TrueAnomaly, Float64, Float64}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, orb)
    @test str == expected

    expected = "KeplerianElements{TrueAnomaly, Float64, Float32}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, orb_f32)
    @test str == expected

    expected = """
KeplerianElements{TrueAnomaly, Float64, Float64}:
             Epoch :    2.4466e6 (1986-06-19T18:35:00)
   Semi-major axis : 7130.98      km
      Eccentricity :    0.0001111
       Inclination :   98.405     °
              RAAN :  200.0       °
 Arg. of Periapsis :   90.0       °
      True Anomaly :  123.456     °"""
    str = sprint(show, MIME("text/plain"), orb)
    @test str == expected

    expected = """
KeplerianElements{TrueAnomaly, Float64, Float32}:
             Epoch :    2.4466e6 (1986-06-19T18:35:00)
   Semi-major axis : 7130.98      km
      Eccentricity :    0.0001111
       Inclination :   98.405     °
              RAAN :  200.0       °
 Arg. of Periapsis :   90.0       °
      True Anomaly :  123.456     °"""
    str = sprint(show, MIME("text/plain"), orb_f32)
    @test str == expected

    # == Other Anomalies ===================================================================

    orb_E = convert(KeplerianElements{EccentricAnomaly}, orb)

    expected = "KeplerianElements{EccentricAnomaly, Float64, Float64}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, orb_E)
    @test str == expected

    expected = """
KeplerianElements{EccentricAnomaly, Float64, Float64}:
             Epoch :    2.4466e6 (1986-06-19T18:35:00)
   Semi-major axis : 7130.98      km
      Eccentricity :    0.0001111
       Inclination :   98.405     °
              RAAN :  200.0       °
 Arg. of Periapsis :   90.0       °
 Eccentric Anomaly :  123.451     °"""
    str = sprint(show, MIME("text/plain"), orb_E)
    @test str == expected

    orb_M = convert(KeplerianElements{MeanAnomaly}, orb)

    expected = "KeplerianElements{MeanAnomaly, Float64, Float64}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, orb_M)
    @test str == expected

    expected = """
KeplerianElements{MeanAnomaly, Float64, Float64}:
             Epoch :    2.4466e6 (1986-06-19T18:35:00)
   Semi-major axis : 7130.98      km
      Eccentricity :    0.0001111
       Inclination :   98.405     °
              RAAN :  200.0       °
 Arg. of Periapsis :   90.0       °
      Mean Anomaly :  123.445     °"""
    str = sprint(show, MIME("text/plain"), orb_M)
    @test str == expected

    # == Color =============================================================================

    str = sprint(show, MIME("text/plain"), orb; context = :color => true)
    @test occursin("\e[1m", str)
    @test occursin("\e[22m", str)
end

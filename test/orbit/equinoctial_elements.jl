## Description #############################################################################
#
# Tests related to the orbit representation using equinoctial elements.
#
############################################################################################

@testset "Construction" begin
    ee = EquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
        -0.0001044,
         3.79984e-5,
        -0.396269,
        -1.08874,
         413.445 |> deg2rad
    )

    @test ee isa EquinoctialElements{Float64, Float64}
    @test ee.epoch           ≈ date_to_jd(1986, 6, 19, 18, 35, 0)
    @test ee.semi_major_axis ≈ 7130.982e3
    @test ee.h               ≈ -0.0001044
    @test ee.k               ≈ 3.79984e-5
    @test ee.p               ≈ -0.396269
    @test ee.q               ≈ -1.08874
    @test ee.mean_longitude  ≈ 413.445 |> deg2rad

    ee = EquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
        -0.0001044f0,
         3.79984f-5,
        -0.396269f0,
        -1.08874f0,
         413.445f0 |> deg2rad
    )

    @test ee isa EquinoctialElements{Float64, Float32}

    ee = EquinoctialElements(Int64(2451545), 7130.982f3, 0, 0, 0, 0, 0)
    @test ee isa EquinoctialElements{Int64, Float32}

    # Integer inputs must be promoted to float.
    ee = EquinoctialElements(1, 2, 3, 4, 5, 6, 7)
    @test ee isa EquinoctialElements{Int64, Float64}

    ee = EquinoctialElements{Float64, Float32}(1, 2, 3, 4, 5, 6, 7)
    @test ee isa EquinoctialElements{Float64, Float32}
    @test ee.epoch === 1.0
    @test ee.mean_longitude === 7.0f0

    @test propertynames(ee) == (:epoch, :semi_major_axis, :h, :k, :p, :q, :mean_longitude)
end

@testset "Show" begin
    ee = EquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
        -0.0001044,
         3.79984e-5,
        -0.396269,
        -1.08874,
         413.445 |> deg2rad
    )

    ee_f32 = EquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
        -0.0001044f0,
         3.79984f-5,
        -0.396269f0,
        -1.08874f0,
         413.445f0 |> deg2rad
    )

    expected = "EquinoctialElements{Float64, Float64}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, ee)
    @test str == expected

    expected = "EquinoctialElements{Float64, Float32}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, ee_f32)
    @test str == expected

    expected = """
EquinoctialElements{Float64, Float64}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7130.98       km
               h :   -0.0001044
               k :    3.79984e-5
               p :   -0.396269
               q :   -1.08874
  Mean Longitude :  413.445      °"""
    str = sprint(show, MIME("text/plain"), ee)
    @test str == expected

    expected = """
EquinoctialElements{Float64, Float32}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7130.98       km
               h :   -0.0001044
               k :    3.79984e-5
               p :   -0.396269
               q :   -1.08874
  Mean Longitude :  413.445      °"""
    str = sprint(show, MIME("text/plain"), ee_f32)
    @test str == expected

    # A value without decimal point must not break the alignment.
    ee_nan = EquinoctialElements(date_to_jd(1986, 6, 19, 18, 35, 0), 7000e3, NaN, 1, 2, 3, 4)

    expected = """
EquinoctialElements{Float64, Float64}:
           Epoch :    2.4466e6 (1986-06-19T18:35:00)
 Semi-major axis : 7000.0   km
               h :  NaN
               k :    1.0
               p :    2.0
               q :    3.0
  Mean Longitude :  229.183 °"""
    str = sprint(show, MIME("text/plain"), ee_nan)
    @test str == expected

    # == Color =============================================================================

    str = sprint(show, MIME("text/plain"), ee; context = :color => true)
    @test occursin("\e[1m", str)
    @test occursin("\e[22m", str)
end

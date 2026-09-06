## Description #############################################################################
#
# Tests related to the orbit representation using alternate equinoctial elements.
#
############################################################################################

@testset "Construction" begin
    #! format: off
    aee = AlternateEquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
        -0.0001044,
         3.79984e-5,
        -0.258917,
        -0.711369,
         413.445 |> deg2rad
    )
    #! format: on

    @test aee isa AlternateEquinoctialElements{Float64, Float64}
    @test aee isa AbstractEquinoctialElements{Float64, Float64}
    @test aee isa Orbit{Float64, Float64}
    #! format: off
    @test aee.epoch           ≈ date_to_jd(1986, 6, 19, 18, 35, 0)
    @test aee.semi_major_axis ≈ 7130.982e3
    @test aee.h               ≈ -0.0001044
    @test aee.k               ≈ 3.79984e-5
    @test aee.p               ≈ -0.258917
    @test aee.q               ≈ -0.711369
    @test aee.mean_longitude  ≈ 413.445 |> deg2rad
    #! format: on

    aee = AlternateEquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
        -0.0001044f0,
        3.79984f-5,
        -0.258917f0,
        -0.711369f0,
        413.445f0 |> deg2rad,
    )

    @test aee isa AlternateEquinoctialElements{Float64, Float32}

    aee = AlternateEquinoctialElements(Int64(2451545), 7130.982f3, 0, 0, 0, 0, 0)
    @test aee isa AlternateEquinoctialElements{Int64, Float32}

    # Integer inputs must be promoted to float.
    aee = AlternateEquinoctialElements(1, 2, 3, 4, 5, 6, 7)
    @test aee isa AlternateEquinoctialElements{Int64, Float64}

    aee = AlternateEquinoctialElements{Float64, Float32}(1, 2, 3, 4, 5, 6, 7)
    @test aee isa AlternateEquinoctialElements{Float64, Float32}
    @test aee.epoch === 1.0
    @test aee.mean_longitude === 7.0f0

    @test propertynames(aee) == (:epoch, :semi_major_axis, :h, :k, :p, :q, :mean_longitude)
end

@testset "Show" begin
    aee = AlternateEquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
        -0.0001044,
        3.79984e-5,
        -0.258917,
        -0.711369,
        413.445 |> deg2rad,
    )

    aee_f32 = AlternateEquinoctialElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982f3,
        -0.0001044f0,
        3.79984f-5,
        -0.258917f0,
        -0.711369f0,
        413.445f0 |> deg2rad,
    )

    expected = "AlternateEquinoctialElements{Float64, Float64}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, aee)
    @test str == expected

    expected = "AlternateEquinoctialElements{Float64, Float32}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, aee_f32)
    @test str == expected

    expected = """
AlternateEquinoctialElements{Float64, Float64}:
  Epoch           : 2.4466e6 (1986-06-19T18:35:00)
  Semi-Major Axis : 7130.982 km
  h               : -0.0001044
  k               : 3.79984e-5
  p               : -0.258917
  q               : -0.711369
  Mean Longitude  : 413.445°"""
    str = sprint(show, MIME("text/plain"), aee)
    @test str == expected

    expected = """
AlternateEquinoctialElements{Float64, Float32}:
  Epoch           : 2.4466e6 (1986-06-19T18:35:00)
  Semi-Major Axis : 7130.98 km
  h               : -0.0001044
  k               : 3.79984e-5
  p               : -0.258917
  q               : -0.711369
  Mean Longitude  : 413.445°"""
    str = sprint(show, MIME("text/plain"), aee_f32)
    @test str == expected

    # == Color =============================================================================

    str = sprint(show, MIME("text/plain"), aee; context = :color => true)
    @test occursin("\e[1m", str)
    @test occursin("\e[22m", str)
end

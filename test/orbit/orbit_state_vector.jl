## Description #############################################################################
#
# Tests related to the orbit representation using state vector.
#
############################################################################################

@testset "Construction" begin
    sv = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107e3,  1.954e6, 6.110e6],
        [ 6.337e3, -1.470e3, 3.684e3]
    )

    @test sv isa OrbitStateVector{Float64, Float64}
    @test sv.a == SVector{3, Float64}(0, 0, 0)

    sv = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107f3,  1.954f6, 6.110f6],
        [ 6.337e3, -1.470e3, 3.684e3]
    )

    @test sv isa OrbitStateVector{Float64, Float64}
    @test sv.a == SVector{3, Float64}(0, 0, 0)

    sv = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107f3,  1.954f6, 6.110f6],
        [ 6.337f3, -1.470f3, 3.684f3]
    )

    @test sv isa OrbitStateVector{Float64, Float32}
    @test sv.a == SVector{3, Float64}(0, 0, 0)

    sv = OrbitStateVector(
        Int64(2451545),
        [-3.107f3,  1.954f6, 6.110f6],
        [ 6.337f3, -1.470f3, 3.684f3],
        [1, 2, 3]
    )

    @test sv isa OrbitStateVector{Int64, Float32}
    @test sv.a == SVector{3, Float32}(1, 2, 3)

    # Integer inputs must be promoted to float.
    sv = OrbitStateVector(Int64(123), [1, 2, 3], [4, 5, 6])
    @test sv isa OrbitStateVector{Int64, Float64}
    @test sv.r == SVector{3, Float64}(1, 2, 3)

    sv = OrbitStateVector(Int64(123), [1, 2, 3], [4, 5, 6], [7, 8, 9])
    @test sv isa OrbitStateVector{Int64, Float64}
    @test sv.a == SVector{3, Float64}(7, 8, 9)

    v  = @SVector [1, 2, 3]
    sv = OrbitStateVector(Int64(123), v, v, v)
    @test sv isa OrbitStateVector{Int64, Float64}
end

@testset "Property Aliases" begin
    sv = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107e3,  1.954e6, 6.110e6],
        [ 6.337e3, -1.470e3, 3.684e3]
    )

    @test sv.t === sv.epoch
    @test sv.epoch == date_to_jd(1986, 6, 19, 18, 35, 0)
    @test propertynames(sv) == (:epoch, :r, :v, :a, :t)
end

@testset "Show" begin
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

    expected = "OrbitStateVector{Float64, Float64}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, sv)
    @test str == expected

    expected = "OrbitStateVector{Float64, Float32}: Epoch = 2.4466e6 (1986-06-19T18:35:00)"
    str = sprint(print, sv_f32)
    @test str == expected

    expected = """
OrbitStateVector{Float64, Float64}:
  epoch : 2.4466e6 (1986-06-19T18:35:00)
      r : [-3.107, 1954.0, 6110.0]  km
      v : [6.337, -1.47, 3.684]     km/s"""
    str = sprint(show, MIME("text/plain"), sv)
    @test str == expected

    expected = """
OrbitStateVector{Float64, Float32}:
  epoch : 2.4466e6 (1986-06-19T18:35:00)
      r : Float32[-3.107, 1954.0, 6110.0]  km
      v : Float32[6.337, -1.47, 3.684]     km/s"""
    str = sprint(show, MIME("text/plain"), sv_f32)
    @test str == expected

    # == Color =============================================================================

    str = sprint(show, MIME("text/plain"), sv; context = :color => true)
    @test occursin("\e[1m", str)
    @test occursin("\e[22m", str)
end

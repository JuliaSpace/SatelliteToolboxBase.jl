## Description #############################################################################
#
# Tests related to interfaces.
#
############################################################################################

@testset "Iterator Interface" begin
    # == Keplerian Elements ================================================================

    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
           0.0001111,
          98.405 |> deg2rad,
         200.000 |> deg2rad,
          90.000 |> deg2rad,
         123.456 |> deg2rad,
    )

    @test eltype(orb) === KeplerianElements{Float64, Float64}
    @test length(orb) === 1
    @test iterate(orb) === (orb, nothing)
    @test iterate(orb, nothing) === nothing

    # == Orbit State Vector ================================================================

    sv = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107e3,  1.954e6, 6.110e6],
        [ 6.337e3, -1.470e3, 3.684e3]
    )

    @test eltype(sv) === OrbitStateVector{Float64, Float64}
    @test length(sv) === 1
    @test iterate(sv) === (sv, nothing)
    @test iterate(sv, nothing) === nothing
end

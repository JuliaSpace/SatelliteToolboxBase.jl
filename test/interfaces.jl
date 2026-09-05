## Description #############################################################################
#
# Tests related to interfaces.
#
############################################################################################

@testset "Iterator Interface" begin
    # == Keplerian Elements ================================================================

    #! format: off
    orb = KeplerianElements(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        7130.982e3,
           0.0001111,
          98.405 |> deg2rad,
         200.000 |> deg2rad,
          90.000 |> deg2rad,
         123.456 |> deg2rad,
    )
    #! format: on

    @test eltype(orb) === KeplerianElements{TrueAnomaly, Float64, Float64}
    @test length(orb) === 1
    @test iterate(orb) === (orb, nothing)
    @test iterate(orb, nothing) === nothing

    orb_M = convert(KeplerianElements{MeanAnomaly}, orb)

    @test eltype(orb_M) === KeplerianElements{MeanAnomaly, Float64, Float64}
    @test length(orb_M) === 1
    @test iterate(orb_M) === (orb_M, nothing)

    # == Equinoctial Elements ==============================================================

    ee = convert(EquinoctialElements, orb)

    @test eltype(ee) === EquinoctialElements{Float64, Float64}
    @test length(ee) === 1
    @test iterate(ee) === (ee, nothing)
    @test iterate(ee, nothing) === nothing

    # == Alternate Equinoctial Elements ====================================================

    aee = convert(AlternateEquinoctialElements, orb)

    @test eltype(aee) === AlternateEquinoctialElements{Float64, Float64}
    @test length(aee) === 1
    @test iterate(aee) === (aee, nothing)
    @test iterate(aee, nothing) === nothing

    # == Orbit State Vector ================================================================

    #! format: off
    sv = OrbitStateVector(
        date_to_jd(1986, 6, 19, 18, 35, 0),
        [-3.107e3,  1.954e6, 6.110e6],
        [ 6.337e3, -1.470e3, 3.684e3]
    )
    #! format: on

    @test eltype(sv) === OrbitStateVector{Float64, Float64}
    @test length(sv) === 1
    @test iterate(sv) === (sv, nothing)
    @test iterate(sv, nothing) === nothing

    # Broadcasting treats an orbit as a collection with one element.
    @test true_anomaly.(orb) == [true_anomaly(orb)]
    @test mean_anomaly.(ee |> x -> convert(KeplerianElements{MeanAnomaly}, x)) ==
        [mean_anomaly(orb_M)]
end

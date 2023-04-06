# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to the issues.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Issue #1 - Define OrbitStateVector using SVector" begin
    v = @SVector [1.0, 1.0, 1.0]
    sv = OrbitStateVector(1.0, v, v, v)

    @test sv.t == 1.0
    @test sv.r == v
    @test sv.v == v
    @test sv.a == v
end

# Old issues from SatelliteToolbox.jl
# ==========================================================================================

@testset "Issue #72 - Bug with elliptical and equatorial orbit" begin
    a = 6674.790266053491 * 1000
    e = 0.0055622826070485095
    i = 0.0 |> deg2rad
    Ω = 0.0 |> deg2rad
    ω = 330.27258118831503 |> deg2rad
    f = 42.80749332919855 |> deg2rad

    rr, vv = kepler_to_rv(KeplerianElements(0, a, e, i, Ω, ω, f))
    ke = rv_to_kepler(rr, vv, 0)

    @test ke.a ≈ a atol = 1e-7
    @test ke.e ≈ e atol = 1e-7
    @test ke.i ≈ i atol = 1e-7
    @test ke.Ω ≈ Ω atol = 1e-7
    @test ke.ω ≈ ω atol = 1e-7
    @test ke.f ≈ f atol = 1e-7
end

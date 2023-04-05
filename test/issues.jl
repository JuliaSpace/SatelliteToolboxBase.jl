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

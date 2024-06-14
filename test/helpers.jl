## Description #############################################################################
#
# Tests related to helpers.
#
############################################################################################

@testset "Helpers" begin
    i₀, i₁ = SatelliteToolboxBase.get_partition(1, 1:1:10, 3)
    @test i₀ == 1
    @test i₁ == 4

    i₀, i₁ = SatelliteToolboxBase.get_partition(2, 1:1:10, 3)
    @test i₀ == 5
    @test i₁ == 7

    i₀, i₁ = SatelliteToolboxBase.get_partition(3, 1:1:10, 3)
    @test i₀ == 8
    @test i₁ == 10

    for i in 1:10
        i₀, i₁ = SatelliteToolboxBase.get_partition(i, 1:1:10, 100)
        @test i₀ == i
        @test i₁ == i
    end

    for i in 11:100
        i₀, i₁ = SatelliteToolboxBase.get_partition(i, 1:1:10, 100)
        @test i₀ == 10
        @test i₁ == 10
    end
end

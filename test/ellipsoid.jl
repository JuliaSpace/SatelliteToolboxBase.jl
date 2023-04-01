# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to ellipsoids.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Construction" begin
    wgs84 = Ellipsoid(6378137.0, 1 / 298.257223563)

    @test wgs84 isa Ellipsoid{Float64}
    @test wgs84.a   == 6378137.0
    @test wgs84.f    ≈ 0.0033528106647474805
    @test wgs84.b    ≈ 6.356752314245179e6
    @test wgs84.e²   ≈ 0.08181919084262149^2
    @test wgs84.el²  ≈ 0.08209443794969568^2

    wgs84 = Ellipsoid(6378137.0f0, 1 / 298.257223563f0)

    @test wgs84 isa Ellipsoid{Float32}
    @test wgs84.a   == 6378137.0f0
    @test wgs84.f    ≈ 0.0033528106647474805f0
    @test wgs84.b    ≈ 6.356752314245179f6
    @test wgs84.e²   ≈ 0.08181919084262149f0^2
    @test wgs84.el²  ≈ 0.08209443794969568f0^2
end

@testset "Construction [ERRORS]" begin
    @test_throws ArgumentError Ellipsoid(0.0, 0.01)
    @test_throws ArgumentError Ellipsoid(6378137.0, 1.0)
end

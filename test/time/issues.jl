# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to reported issues.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

@testset "Issue SatelliteToolbox.jl / #19" begin
    year_i = rand(1900:2100)

    year, month, day, hour, min, sec = jd_to_date(
        date_to_jd(year_i, 12, 31, 23, 59, 59)
    )

    @test year  == year_i
    @test month == 12
    @test day   == 31
    @test hour  == 23
    @test min   == 59
    @test sec    ≈ 59 rtol = 1e-5

    year, month, day, hour, min, sec = jd_to_date(
        date_to_jd(year_i, 1, 1, 0, 0, 0)
    )

    @test year  == year_i
    @test month == 1
    @test day   == 1
    @test hour  == 0
    @test min   == 0
    @test sec    ≈ 0 rtol = 1e-5

    date_time_1 = jd_to_date(DateTime, date_to_jd(year_i, 12, 31, 23, 59, 59))
    date_time_2 = DateTime(year_i, 12, 31, 23, 59, 59)

    @test date_time_1 === date_time_2
end

@testset "Issue SatelliteToolbox.jl / #30" begin
    year, month, day, h, m, s = jd_to_date(Int, 2.45754095833333e6)

    @test year  == 2016
    @test month == 6
    @test day   == 1
    @test h     == 11
    @test m     == 0
    @test s     == 0
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to date.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==========================================================================================
#
#   [1] http://aa.usno.navy.mil/data/docs/JulianDate.php
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# File: ./src/time/julian_day.jl
# ==========================================================================================

# Function date_to_jd
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Data obtained from [1]:
#
#   ╔═════════════════════╦════════════════╗
#   ║    Gregorian Day    ║   Julian Day   ║
#   ╠═════════════════════╬════════════════╣
#   ║ 1986-06-19 21:35:22 ║ 2446601.399560 ║
#   ║ 1987-05-19 04:00:00 ║ 2446934.666667 ║
#   ║ 2018-04-16 20:19:37 ║ 2458225.346956 ║
#   ║ 1822-09-07 12:00:00 ║ 2386781.000000 ║
#   ║ 1900-01-01 00:00:00 ║ 2415020.500000 ║
#   ║ 2000-01-01 00:00:00 ║ 2451544.500000 ║
#   ║ 2013-10-19 22:00:00 ║ 2456585.416667 ║
#   ╚═════════════════════╩════════════════╝
#
############################################################################################

@testset "Function date_to_jd" begin
    @test date_to_jd(1986, 06, 19, 21, 35, 22) ≈ 2446601.399560 atol=1e-6
    @test date_to_jd(1987, 05, 19, 04, 00, 00) ≈ 2446934.666667 atol=1e-6
    @test date_to_jd(2018, 04, 16, 20, 19, 37) ≈ 2458225.346956 atol=1e-6
    @test date_to_jd(1822, 09, 07, 12, 00, 00) ≈ 2386781.000000 atol=1e-6
    @test date_to_jd(1900, 01, 01, 00, 00, 00) ≈ 2415020.500000 atol=1e-6
    @test date_to_jd(2000, 01, 01, 00, 00, 00) ≈ 2451544.500000 atol=1e-6
    @test date_to_jd(2013, 10, 19, 22, 00, 00) ≈ 2456585.416667 atol=1e-6
end

@testset "Function date_to_jd(::Date)" begin
    jd_date    = date_to_jd(Date(2020, 8, 14))
    jd_numbers = date_to_jd(2020, 8, 14, 0, 0, 0)
    @test jd_date == jd_numbers
end

@testset "Function date_to_jd(::DateTime)" begin
    jd_datetime = date_to_jd(DateTime(2020, 8, 14, 12, 4, 1))
    jd_numbers  = date_to_jd(2020, 8, 14, 12, 4, 1)
    @test jd_datetime == jd_numbers

    jd_datetime_ms      = date_to_jd(DateTime(2020, 8, 14, 12, 4, 1, 500))
    jd_numbers_ms       = date_to_jd(2020, 8, 14, 12, 4, 1.5)
    jd_datetime_back_ms = jd_to_date(DateTime, jd_numbers_ms)

    @test jd_datetime_ms ≈ jd_numbers_ms atol = 6e-9
    @test jd_datetime_back_ms == DateTime(2020, 8, 14, 12, 4, 1, 500)
end

@testset "Function date_to_jd [ERRORS]" begin
    # Error in the month.
    @test_throws ArgumentError date_to_jd(2023,  0,  1)
    @test_throws ArgumentError date_to_jd(2023, 13,  1)

    # Error in the day.
    @test_throws ArgumentError date_to_jd(2023,  1,  0)
    @test_throws ArgumentError date_to_jd(2023,  1, 32)

    @test_throws ArgumentError date_to_jd(2023,  1, 32)
    @test_throws ArgumentError date_to_jd(2023,  2, 30)
    @test_throws ArgumentError date_to_jd(2023,  3, 32)
    @test_throws ArgumentError date_to_jd(2023,  4, 31)
    @test_throws ArgumentError date_to_jd(2023,  5, 32)
    @test_throws ArgumentError date_to_jd(2023,  6, 31)
    @test_throws ArgumentError date_to_jd(2023,  7, 32)
    @test_throws ArgumentError date_to_jd(2023,  8, 32)
    @test_throws ArgumentError date_to_jd(2023,  9, 31)
    @test_throws ArgumentError date_to_jd(2023, 10, 32)
    @test_throws ArgumentError date_to_jd(2023, 11, 31)
    @test_throws ArgumentError date_to_jd(2023, 12, 32)

    # Leap years.
    @test_throws ArgumentError date_to_jd(2023,  2, 29)
    @test date_to_jd(2020, 2, 29) == 2.4589085e6
end

# Function jd_to_date
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Data obtained from [1]:
#
#   ╔═════════════════════╦════════════════╗
#   ║    Gregorian Day    ║   Julian Day   ║
#   ╠═════════════════════╬════════════════╣
#   ║ 1986-06-19 21:35:22 ║ 2446601.399560 ║
#   ║ 1987-05-19 04:00:00 ║ 2446934.666667 ║
#   ║ 2018-04-16 20:19:37 ║ 2458225.346956 ║
#   ║ 1822-09-07 12:00:00 ║ 2386781.000000 ║
#   ║ 1900-01-01 00:00:00 ║ 2415020.500000 ║
#   ║ 2000-01-01 00:00:00 ║ 2451544.500000 ║
#   ║ 2013-10-19 22:00:00 ║ 2456585.416667 ║
#   ╚═════════════════════╩════════════════╝
#
############################################################################################

@testset "Function jd_to_date" begin
    # 1 ms after J2000 epoch.
    year, month, day, h, m, s = jd_to_date(2.451545e6 + 1 / 1000 / 86400)

    @test year   == 2000
    @test month  == 1
    @test day    == 1
    @test h      == 12
    @test m      == 0
    @test s       ≈ 0.001 atol = 1e-5
end

@testset "Function jd_to_date(::Int, ...)" begin
    @test jd_to_date(Int, 2446601.399560) == (1986, 06, 19, 21, 35, 22)
    @test jd_to_date(Int, 2446934.666667) == (1987, 05, 19, 04, 00, 00)
    @test jd_to_date(Int, 2458225.346956) == (2018, 04, 16, 20, 19, 37)
    @test jd_to_date(Int, 2386781.000000) == (1822, 09, 07, 12, 00, 00)
    @test jd_to_date(Int, 2415020.500000) == (1900, 01, 01, 00, 00, 00)
    @test jd_to_date(Int, 2451544.500000) == (2000, 01, 01, 00, 00, 00)
    @test jd_to_date(Int, 2456585.416667) == (2013, 10, 19, 22, 00, 00)
end

@testset "Function jd_to_date(::Date..)" begin
    @test jd_to_date(Date, 2446601.399560) == Date(1986, 06, 19)
    @test jd_to_date(Date, 2446934.666667) == Date(1987, 05, 19)
    @test jd_to_date(Date, 2458225.346956) == Date(2018, 04, 16)
    @test jd_to_date(Date, 2386781.000000) == Date(1822, 09, 07)
    @test jd_to_date(Date, 2415020.500000) == Date(1900, 01, 01)
    @test jd_to_date(Date, 2451544.500000) == Date(2000, 01, 01)
    @test jd_to_date(Date, 2456585.416667) == Date(2013, 10, 19)
end

# Function is_leap_year
# ------------------------------------------------------------------------------------------

@testset "Function is_leap_year" begin
    @test is_leap_year(2017) == false
    @test is_leap_year(2020) == true
    @test is_leap_year(2200) == false
    @test is_leap_year(2400) == true
end

@testset "Function is_leap_year [ERRORS]" begin
    @test_throws ArgumentError is_leap_year(-1)
end

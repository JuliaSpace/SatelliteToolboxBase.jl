# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions related to Time scales and conversions.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==============================================================================
#
#   [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
#       Microcosm Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export jd_ut1_to_utc, jd_utc_to_ut1
export jd_utc_to_tt,  jd_tt_to_utc
export get_Δat
export diff_tt_utc, hms_to_h

############################################################################################
#                                        Functions
############################################################################################

"""
    get_Δat(JD::Number)

Get the accumulated leap seconds (ΔAT) [s] between UTC and International Atomic
Time (TAI) in the given `JD`. This function search for ΔAT in the array
`ΔAT_Data`.

# Remarks

If `JD` is before `ΔAT_Data[1, 1]`, then 10 will be returned. **Notice that this
can lead to errors.**

If `JD` is after `ΔAT_Data[end, 1]`, then `ΔAT_Data[end, 2]` will be returned,
because it is not possible yet to predict when leap seconds will be added.
"""
function get_Δat(JD::Number)
    # If `JD` is before `ΔAT_Data[1,1]`, then return 10.0.
    @inbounds if JD < ΔAT_Data[1, 1]
        return 10.0
    else
        for i = 2:size(ΔAT_Data, 1)
            (JD < ΔAT_Data[i, 1]) && return ΔAT_Data[i - 1, 2]
        end
    end

    # In this case, `JD` is after `ΔAT_Data[end,1]`.
    return @inbounds ΔAT_Data[end, 2]
end

"""
    jd_utc_to_ut1(JD_UTC::Number, ΔUT1::Number)

Convert the Julian Day in UTC `JD_UTC` to the Julian Day in UT1 using the
accumulated difference `ΔUT1`, which is provided by IERS EOP Data.
"""
jd_utc_to_ut1(JD_UTC::Number, ΔUT1::Number) = JD_UTC + ΔUT1 / 86400

"""
    jd_ut1_to_utc(JD_UT1::Number, ΔUT1::Number)

Convert the Julian Day in UT1 `JD_UT1` to the Julian Day in UTC using the
accumulated difference `ΔUT1`, which is provided by IERS EOP Data.
"""
jd_ut1_to_utc(JD_UT1::Number, ΔUT1::Number) = JD_UT1 - ΔUT1 / 86400

"""
    jd_utc_to_ut1(JD_UTC::Number, eop::Union{EOPData_IAU1980,EOPData_IAU2000A})

Convert the Julian Day in UTC `JD_UTC` to the Julian Day in UT1 using the
accumulated difference given by the EOP Data `eop` (see `get_iers_eop`). Notice
that the accumulated difference will be interpolated.
"""
function jd_utc_to_ut1(JD_UTC::Number, eop::Union{EOPData_IAU1980, EOPData_IAU2000A})
	return jd_utc_to_ut1(JD_UTC, eop.UT1_UTC(JD_UTC))
end

"""
    jd_utc_to_ut1(JD_UTC::Number, eop::Union{EOPData_IAU1980,EOPData_IAU2000A})

Convert the Julian Day in UT1 `JD_UT1` to the Julian Day in UTC using the
accumulated difference given by the EOP Data `eop` (see `get_iers_eop`). Notice
that the accumulated difference will be interpolated.

"""
function jd_ut1_to_utc(JD_UT1::Number, eop::Union{EOPData_IAU1980, EOPData_IAU2000A})
	return jd_ut1_to_utc(JD_UT1, eop.UT1_UTC(JD_UT1))
end

"""
    jd_utc_to_tt(JD_UTC::Number [, ΔAT::Number])

Convert the Julian Day in UTC `JD_UTC` to the Julian Day in TT (Terrestrial
Time) using the accumulated difference `ΔAT` between UTC and the International
Atomic Time (TAI). If no value is provided, then the leap seconds will be
obtained from the table `ΔAT_Data`. **Notice that, in this case, if a date
previous to 1973 is provided, then a fixed value of 10 will be used, leading to
wrong computations.**

"""
jd_utc_to_tt(JD_UTC::Number, ΔAT::Number) = JD_UTC + (ΔAT + 32.184) / 86400

function jd_utc_to_tt(JD_UTC::Number)
    ΔAT = get_Δat(JD_UTC)
    return jd_utc_to_tt(JD_UTC,ΔAT)
end

"""
    jd_tt_to_utc(JD_TT::Number, ΔAT::Number = 37)

Convert the Julian Day in TT `JD_TT` (Terrestrial Time) to the Julian Day in UTC
(Terrestrial Time) using the accumulated difference `ΔAT` between UTC and the
International Atomic Time (TAI). If no value is provided, then the leap seconds
will be obtained from the table `ΔAT_Data`. **Notice that, in this case, if a
date previous to 1973 is provided, then a fixed value of 10 will be used,
leading to wrong computations.**

"""
jd_tt_to_utc(JD_TT::Number, ΔAT::Number) = JD_TT - (ΔAT + 32.184) / 86400

function jd_tt_to_utc(JD_UTC::Number)
    ΔAT = get_Δat(JD_UTC)
    return jd_tt_to_utc(JD_UTC, ΔAT)
end

"""
    diff_tt_utc(year::Integer)

Difference between terrestrial time and universal time: TT-UT (terrestrial time - universal time), in seconds;

# Remarks

This algorithm was based on the source: https://ui.adsabs.harvard.edu/abs/2012SoEn...86.1323G/abstract.

"""
function diff_tt_utc(year::Integer)
    return ( 96.4 + 0.567 * (year - 2061) );
end

"""
    hms_to_h(h::Integer, m::Integer, s::Number)

Converts hours `h`, minutes `m` and seconds `s` into fractional hours;

"""
function hms_to_h(h::Integer, m::Integer, s::Number)
    return h + m/60.0 + s/3600.0;
end

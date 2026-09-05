## Description #############################################################################
#
# Compute the Greenwich Mean Sidereal Time (GMST).
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
# [2] http://www.navipedia.net/index.php/CEP_to_ITRF, accessed 2015-12-01.
#
############################################################################################

export j2000_to_gmst, jd_to_gmst

"""
    j2000_to_gmst(j2000_ut1::Number) -> Float64

Compute the Greenwich Mean Sidereal Time (GMST) [rad] given the instant `j2000_ut1` [days]
elapsed since the J2000.0 epoch in the UT1 time scale.

!!! note

    The algorithm is based on **[2]**.

# References

- **[2]** http://www.navipedia.net/index.php/CEP_to_ITRF, accessed 2015-12-01.
"""
function j2000_to_gmst(j2000_ut1::Number)
    # Julian centuries elapsed from the epoch J2000.0.
    t_ut1 = j2000_ut1 / 36525

    # Greenwich Mean Sidereal Time at t_ut1 [s].
    θ_gmst = @evalpoly(
        t_ut1, + 67310.54841, + 876600.0 * 3600 + 8640184.812866, + 0.093104, - 6.2e-6
    )

    # Reduce to the interval [0, 86400]s.
    θ_gmst = mod(θ_gmst, 86400)

    # Convert to radian and return.
    return θ_gmst * π / 43200
end

"""
    jd_to_gmst(jd_ut1::Number) -> Float64

Compute the Greenwich Mean Sidereal Time (GMST) [rad] for the Julian Day `jd_ut1` in the UT1
time scale.

!!! note

    The algorithm is based on **[1]** (p. 188).

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
    Microcosm Press, Hawthorn, CA, USA, p. 188.
"""
jd_to_gmst(jd_ut1::Number) = j2000_to_gmst(jd_ut1 - JD_J2000)

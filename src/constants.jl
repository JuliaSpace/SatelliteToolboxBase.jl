# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Constants for the SatelliteToolbox.jl ecosystem.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export ASTRONOMICAL_UNIT, GM_EARTH, EARTH_ANGULAR_SPEED, EARTH_EQUATORIAL_RADIUS
export EARTH_ORBIT_MEAN_MOTION, EARTH_POLAR_RADIUS
export WGS84_ELLIPSOID, WGS84_ELLIPSOID_F32
export EGM08_J2, EGM08_J3, EGM08_J4
export SUN_RADIUS
export JD_J2000

############################################################################################
#                         General Parameters Related to the Earth
############################################################################################

"""
    const ASTRONOMICAL_UNIT

The approximate distance between the Earth and the Sun [m].
"""
const ASTRONOMICAL_UNIT = 1.495978707e11

"""
    const GM_EARTH

Earth's standard gravitational parameter [m³ / s²].
"""
const GM_EARTH = 3.986004418e14

"""
    const EARTH_ANGULAR_SPEED

Earth's angular speed [rad / s] without LOD correction.
"""
const EARTH_ANGULAR_SPEED = 7.292_115_146_706_979e-5

"""
    const EARTH_EQUATORIAL_RADIUS

Earth's equatorial radius [m] (WGS-84).
"""
const EARTH_EQUATORIAL_RADIUS = 6378137.0

"""
    const EARTH_ORBIT_MEAN_MOTION

Earth's orbit mean motion [rad / s].
"""
const EARTH_ORBIT_MEAN_MOTION = deg2rad(360.0 / 365.2421897) / 86400

"""
    const EARTH_POLAR_RADIUS

Earth's polar radius [m] (WGS-84).
"""
const EARTH_POLAR_RADIUS = 6356752.3142

############################################################################################
#                                        Ellipsoids
############################################################################################

"""
    const WGS84_ELLIPSOID

WGS84 ellipsoid represented using `Float64`.
"""
const WGS84_ELLIPSOID = Ellipsoid(6378137.0, 1 / 298.257223563)

"""
    const WGS84_ELLIPSOID_F32

WGS84 ellipsoid represented using `Float32`.
"""
const WGS84_ELLIPSOID_F32 = Ellipsoid(6378137.0f0, 1 / 298.257223563f0)

############################################################################################
#                                    Perturbation Terms
############################################################################################

"""
    const EGM08_J2

J2 perturbation term obtained from EGM-08 model (`J₂ = -C₂`) [1].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
    Microcosm Press, Hawthorne, CA.
"""
const EGM08_J2 = +1.08262617385222e-3

"""
    const EGM08_J3

J3 perturbation term obtained from EGM-08 model (`J₃ = -C₃`) [1].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
    Microcosm Press, Hawthorne, CA.
"""
const EGM08_J3 = -2.53241051856772e-6

"""
    const EGM08_J4

J3 perturbation term obtained from EGM-08 model (`J₄ = -C₄`) [1].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
    Microcosm Press, Hawthorne, CA.
"""
const EGM08_J4 = -1.61989759991697e-6

############################################################################################
#                          General Parameters Related to the Sun
############################################################################################

"""
    const SUN_RADIUS

Sun radius [m] as obtained by **[1]** using measurements from the SOHO spacecraft.

# References

- **[1]** Emilio, M., Kuhn, J. R., Bush, R. I., Scholl, I. F (2012). Measuring the Solar
    Radius From Space During the 2003 and 2006 Mercury Transits. The Astrophysical Journal,
    v. 750, no. 2.
"""
const SUN_RADIUS = 6.96342e8

############################################################################################
#                                           Time
############################################################################################

"""
    const JD_J2000

Julian Day of J2000.0 epoch (2000-01-01T12:00:00.000).
"""
const JD_J2000 = 2451545.0

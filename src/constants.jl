# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Constants for the SatelliteToolbox.jl ecosystem.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export ASTRONOMICAL_UNIT, GM_EARTH, EARTH_ANGULAR_SPEED, EARTH_ORBIT_MEAN_MOTION
export WGS84_ELLIPSOID, WGS84_ELLIPSOID_F32
export EGM08_J2, EGM08_J3, EGM08_J4
export JD_J2000, ΔAT_Data

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
    const EARTH_ORBIT_MEAN_MOTION

Earth's orbit mean motion [rad / s].
"""
const EARTH_ORBIT_MEAN_MOTION = deg2rad(360.0 / 365.2421897) / 86400

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
#                                           Time
############################################################################################

"""
    const JD_J2000

Julian Day of J2000.0 epoch (2000-01-01T12:00:00.000).
"""
const JD_J2000 = 2451545.0

"""
    Table containing the leap seconds between UTC and the International Atomic Time (TAI).
"""
# Notice that only the dates in which an increment in the leap
# seconds occurred should be added to this table.
const ΔAT_Data = [
#   Julian Day          ΔAT [s]
    2441499.500000     11.0
    2441683.500000     12.0
    2442048.500000     13.0
    2442413.500000     14.0
    2442778.500000     15.0
    2443144.500000     16.0
    2443509.500000     17.0
    2443874.500000     18.0
    2444239.500000     19.0
    2444786.500000     20.0
    2445151.500000     21.0
    2445516.500000     22.0
    2446247.500000     23.0
    2447161.500000     24.0
    2447892.500000     25.0
    2448257.500000     26.0
    2448804.500000     27.0
    2449169.500000     28.0
    2449534.500000     29.0
    2450083.500000     30.0
    2450630.500000     31.0
    2451179.500000     32.0
    2453736.500000     33.0
    2454832.500000     34.0
    2456109.500000     35.0
    2457204.500000     36.0
    2457754.500000     37.0
]

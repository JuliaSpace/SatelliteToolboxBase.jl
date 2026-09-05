## Description #############################################################################
#
# Constants for the SatelliteToolbox.jl ecosystem.
#
############################################################################################

export ASTRONOMICAL_UNIT, GM_EARTH, EARTH_ANGULAR_SPEED, EARTH_EQUATORIAL_RADIUS
export EARTH_ORBIT_MEAN_MOTION, EARTH_POLAR_RADIUS
export WGS84_ELLIPSOID, WGS84_ELLIPSOID_F32
export EGM_1996_J2, EGM_1996_J3, EGM_1996_J4
export EGM_2008_J2, EGM_2008_J3, EGM_2008_J4
export SUN_RADIUS
export JD_J2000

############################################################################################
#                         General Parameters Related to the Earth                          #
############################################################################################

"""
    const ASTRONOMICAL_UNIT

The approximate distance between the Earth and the Sun [m].
"""
const ASTRONOMICAL_UNIT = 1.495978707e11

"""
    const GM_EARTH

Earth's standard gravitational parameter (EGM-2008) [m³/s²].
"""
const GM_EARTH = 3.986004415e14

"""
    const EARTH_ANGULAR_SPEED

Earth's angular speed [rad/s] without LOD correction.
"""
const EARTH_ANGULAR_SPEED = 7.292_115_146_706_979e-5

"""
    const EARTH_EQUATORIAL_RADIUS

Earth's equatorial radius [m] (WGS-84).
"""
const EARTH_EQUATORIAL_RADIUS = 6_378_137.0

"""
    const EARTH_ORBIT_MEAN_MOTION

Earth's orbit mean motion [rad/s].
"""
const EARTH_ORBIT_MEAN_MOTION = deg2rad(360.0 / 365.2421897) / 86400

"""
    const EARTH_POLAR_RADIUS

Earth's polar radius [m] (WGS-84).
"""
const EARTH_POLAR_RADIUS = 6_356_752.3142

############################################################################################
#                                        Ellipsoids                                        #
############################################################################################

"""
    const WGS84_ELLIPSOID

WGS84 ellipsoid represented using `Float64`.
"""
const WGS84_ELLIPSOID = Ellipsoid(6_378_137.0, 1 / 298.257223563)

"""
    const WGS84_ELLIPSOID_F32

WGS84 ellipsoid represented using `Float32`.
"""
const WGS84_ELLIPSOID_F32 = Ellipsoid(6_378_137.0f0, 1 / 298.257223563f0)

############################################################################################
#                                    Perturbation Terms                                    #
############################################################################################

"""
    const EGM_1996_J2

J₂ perturbation term obtained from the EGM-1996 model (`J₂ = -C₂,₀ * √5`) **[1]**.

# References

- **[1]** Lemoine, F. G., Kenyon, S. C., Factor, J. K., Trimmer, R. G., Pavlis, N. K.,
    Chinn, D. S., Cox, C. M., Klosko, S. M., Luthcke, S. B., Torrence, M. H., Wang, Y. M.,
    Williamson, R. G., Pavlis, E. C., Rapp, R. H., Olson, T. R (1998). The Development of
    the Joint NASA GSFC and the National Imagery and Mapping Agency (NIMA) Geopotential
    Model EGM96. NASA/TP-1998-206861.
"""
const EGM_1996_J2 = 1.0826266835531513e-3

"""
    const EGM_1996_J3

J₃ perturbation term obtained from the EGM-1996 model (`J₃ = -C₃,₀ * √7`) **[1]**.

# References

- **[1]** Lemoine, F. G., Kenyon, S. C., Factor, J. K., Trimmer, R. G., Pavlis, N. K.,
    Chinn, D. S., Cox, C. M., Klosko, S. M., Luthcke, S. B., Torrence, M. H., Wang, Y. M.,
    Williamson, R. G., Pavlis, E. C., Rapp, R. H., Olson, T. R (1998). The Development of
    the Joint NASA GSFC and the National Imagery and Mapping Agency (NIMA) Geopotential
    Model EGM96. NASA/TP-1998-206861.
"""
const EGM_1996_J3 = -2.5326564853322355e-6

"""
    const EGM_1996_J4

J₄ perturbation term obtained from the EGM-1996 model (`J₄ = -C₄,₀ * √9`) **[1]**.

# References

- **[1]** Lemoine, F. G., Kenyon, S. C., Factor, J. K., Trimmer, R. G., Pavlis, N. K.,
    Chinn, D. S., Cox, C. M., Klosko, S. M., Luthcke, S. B., Torrence, M. H., Wang, Y. M.,
    Williamson, R. G., Pavlis, E. C., Rapp, R. H., Olson, T. R (1998). The Development of
    the Joint NASA GSFC and the National Imagery and Mapping Agency (NIMA) Geopotential
    Model EGM96. NASA/TP-1998-206861.
"""
const EGM_1996_J4 = -1.619621591367e-6

"""
    const EGM_2008_J2

J₂ perturbation term obtained from the EGM-2008 model (`J₂ = -C₂,₀ * √5`) **[1]**.

# References

- **[1]** Pavlis, N. K., Holmes, S. A., Kenyon, S. C., Factor, J. K (2012). The development
    and evaluation of the Earth Gravitational Model 2008 (EGM2008). Journal of Geophysical
    Research, v. 117, B04406.
"""
const EGM_2008_J2 = +1.0826261738522227e-3

"""
    const EGM_2008_J3

J₃ perturbation term obtained from the EGM-2008 model (`J₃ = -C₃,₀ * √7`) **[1]**.

# References

- **[1]** Pavlis, N. K., Holmes, S. A., Kenyon, S. C., Factor, J. K (2012). The development
    and evaluation of the Earth Gravitational Model 2008 (EGM2008). Journal of Geophysical
    Research, v. 117, B04406.
"""
const EGM_2008_J3 = -2.5324105185677225e-6

"""
    const EGM_2008_J4

J₄ perturbation term obtained from the EGM-2008 model (`J₄ = -C₄,₀ * √9`) **[1]**.

# References

- **[1]** Pavlis, N. K., Holmes, S. A., Kenyon, S. C., Factor, J. K (2012). The development
    and evaluation of the Earth Gravitational Model 2008 (EGM2008). Journal of Geophysical
    Research, v. 117, B04406.
"""
const EGM_2008_J4 = -1.6198975999169731e-6

############################################################################################
#                          General Parameters Related to the Sun                           #
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
#                                           Time                                           #
############################################################################################

"""
    const JD_J2000

Julian Day of J2000.0 epoch (2000-01-01T12:00:00.000).
"""
const JD_J2000 = 2451545.0

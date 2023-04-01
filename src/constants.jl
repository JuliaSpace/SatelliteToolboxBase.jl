# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Constants for the SatelliteToolbox.jl ecosystem.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export WGS84_ELLIPSOID, WGS84_ELLIPSOID_F32
export EGM08_J2, EGM08_J3, EGM08_J4
export JD_J2000

################################################################################
#                                  Ellipsoids
################################################################################

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

################################################################################
#                              Perturbation terms
################################################################################

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

################################################################################
#                                     Time
################################################################################

"""
    const JD_J2000

Julian Day of J2000.0 epoch (2000-01-01T12:00:00.000).
"""
const JD_J2000 = 2451545.0

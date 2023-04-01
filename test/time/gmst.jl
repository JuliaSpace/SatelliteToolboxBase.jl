# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Tests related to the Greenwich mean sidereal time (GMST).
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

# File: ./src/time/gmst.jl
# ==============================================================================

# Function jd_to_gmst
# ------------------------------------------------------------------------------

################################################################################
#                                 Test Results
################################################################################
#
# Scenario 01
# ==============================================================================
#
# Example 3-5: Finding GMST and LST (Method 1) [1, p. 188].
#
# Considering the Julian Day [UT1] 2448855.009722, the Greenwich Mean Sideral
# Time was computed as 152.578787810°.
#
# Using SatelliteToolbox, the following was obtained:
#
#   julia> jd_to_gmst(2448855.009722)*180/pi
#   152.57870762832462
#
# NOTE: The difference was also found by replicating the algorithm in MATLAB.
#
################################################################################

@testset "Function jd_to_gmst" begin
    θ_gmst = jd_to_gmst(2448855.009722) * 180 / π
    @test θ_gmst ≈ 152.578787810 atol = 1e-4
end

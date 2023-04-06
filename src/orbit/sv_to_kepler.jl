# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Conversion from the Keplerian elements to orbit state vector.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export sv_to_kepler

"""
    sv_to_kepler(sv::OrbitStateVector) -> KeplerianElements

Convert the orbit state vector `sv` to Keplerian elements.
"""
function sv_to_kepler(sv::OrbitStateVector)
    return rv_to_kepler(sv.r, sv.v, sv.t)
end

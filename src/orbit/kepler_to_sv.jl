## Description #############################################################################
#
# Conversion from orbit state vector to Keplerian elements.
#
############################################################################################

export kepler_to_sv

"""
    kepler_to_sv(ke::KeplerianElements) -> OrbitStateVector

Convert the Keplerian elements `ke` to the orbit state vector.

!!! note

    The acceleration in the orbit state vector will be set to 0.
"""
function kepler_to_sv(ke::KeplerianElements)
    r_i, v_i = kepler_to_rv(ke)
    return OrbitStateVector(ke.t, r_i, v_i)
end

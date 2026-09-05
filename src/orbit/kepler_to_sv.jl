## Description #############################################################################
#
# Conversion from orbit state vector to Keplerian elements.
#
############################################################################################

export kepler_to_sv

"""
    kepler_to_sv(ke::KeplerianElements; μ::Number = GM_EARTH) -> OrbitStateVector

Convert the Keplerian elements `ke` to the orbit state vector.

!!! note

    The acceleration in the orbit state vector will be set to 0.

# Keywords

- `μ::Number`: Standard gravitational parameter of the central body [m³ / s²].
    (**Default** = `GM_EARTH`)
"""
function kepler_to_sv(ke::KeplerianElements; μ::Number = GM_EARTH)
    r_i, v_i = kepler_to_rv(ke; μ)
    return OrbitStateVector(ke.epoch, r_i, v_i)
end

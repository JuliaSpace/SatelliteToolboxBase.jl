## Description #############################################################################
#
# Conversion from orbit state vector to Keplerian elements.
#
############################################################################################

export kepler_to_sv

"""
    kepler_to_sv(ke::KeplerianElements{Tanomaly, Tepoch, T}; kwargs...) -> OrbitStateVector{Tepoch, T}

Convert the Keplerian elements `ke` to the orbit state vector. The eccentricity of `ke` must
be in the interval [0, 1).

!!! note

    The acceleration in the orbit state vector will be set to 0.

# Keywords

- `μ::Number`: Standard gravitational parameter of the central body [m³/s²].
    (**Default**: `GM_EARTH`)
"""
function kepler_to_sv(ke::KeplerianElements; μ::Number = GM_EARTH)
    r_i, v_i = kepler_to_rv(ke; μ)
    return OrbitStateVector(ke.epoch, r_i, v_i)
end

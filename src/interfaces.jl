## Description #############################################################################
#
# Interfaces with Julia APIs.
#
############################################################################################

############################################################################################
#                                    Iterator Interface                                    #
############################################################################################

# These functions treat an orbit as a collection with a single element, allowing broadcast
# when using the orbit propagators. See the docstrings of the orbit representations.

Base.iterate(orb::Orbit) = (orb, nothing)
Base.iterate(::Orbit, ::Nothing) = nothing
Base.length(::Orbit) = 1
Base.eltype(::T) where {T <: Orbit} = T

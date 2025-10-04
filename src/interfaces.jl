## Description #############################################################################
#
# Interfaces with Julia APIs.
#
############################################################################################

############################################################################################
#                                    Iterator Interface                                    #
############################################################################################

# There functions allow broadcast when using the orbit propagators.
Base.iterate(orb::Orbit) = (orb, nothing)
Base.iterate(::Orbit, ::Nothing) = nothing
Base.length(::Orbit) = 1
Base.eltype(::T) where T<:Orbit = T

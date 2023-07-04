# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Interfaces with Julia APIs.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

############################################################################################
#                                    Iterator Interface
############################################################################################

# There functions allow broadcast when using the orbit propagators.
iterate(orb::Orbit) = (orb, nothing)
iterate(orb::Orbit, ::Nothing) = nothing
length(orb::Orbit) = 1
eltype(orbp::T) where T<:Orbit = T

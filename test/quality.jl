## Description #############################################################################
#
# Quality tests using Aqua.jl and JET.jl.
#
############################################################################################

@testset "Aqua" begin
    Aqua.test_all(SatelliteToolboxBase)
end

# JET.jl depends on Julia internals and is updated after each Julia release. Hence, we skip
# it on prerelease versions to avoid false alarms in the nightly CI.
if isempty(VERSION.prerelease)
    @testset "JET" begin
        JET.test_package(SatelliteToolboxBase; target_modules = (SatelliteToolboxBase,))
    end
end

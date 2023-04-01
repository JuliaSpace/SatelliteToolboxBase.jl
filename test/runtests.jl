using Test

using Dates
using SatelliteToolboxBase
using StaticArrays

@testset "Ellipsoids" verbose = true begin
    include("./ellipsoid.jl")
end

@testset "Orbit" verbose = true begin
    @testset "Keplerian elements" verbose = true begin
        include("./orbit/keplerian_elements.jl")
    end

    @testset "Orbit state vector" verbose = true begin
        include("./orbit/orbit_state_vector.jl")
    end
end

@testset "Time" verbose = true begin
    @testset "Julian day" verbose = true begin
        include("./time/julian_day.jl")
    end

    @testset "Greenwich mean sidereal time (GMST)" verbose = true begin
        include("./time/gmst.jl")
    end

    @testset "Issues" verbose = true begin
        include("./time/issues.jl")
    end
end

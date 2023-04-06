using Test

using Dates
using SatelliteToolboxBase
using StaticArrays

@testset "Ellipsoids" verbose = true begin
    include("./ellipsoid.jl")
end

@testset "Orbit" verbose = true begin
    @testset "Keplerian Elements" verbose = true begin
        include("./orbit/keplerian_elements.jl")
    end

    @testset "Orbit State Vector" verbose = true begin
        include("./orbit/orbit_state_vector.jl")
    end

    @testset "Conversions" verbose = true begin
        include("./orbit/conversions.jl")
    end
end

@testset "Time" verbose = true begin
    @testset "Julian Day" verbose = true begin
        include("./time/julian_day.jl")
    end

    @testset "Greenwich Mean Sidereal Time (GMST)" verbose = true begin
        include("./time/gmst.jl")
    end

    @testset "Issues" verbose = true begin
        include("./time/issues.jl")
    end
end

@testset "Issues" verbose = true begin
    include("./issues.jl")
end

## Description #############################################################################
#
# Tests related to conversion between the orbit anomalies.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

# == File: ./src/orbit/anomalies.jl ========================================================

# -- Functions: mean_to_eccentric_anomaly and eccentric_to_mean_anomaly --------------------

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# Example 2-1: Using Kepler's Equation [1, p. 66].
#
# According to this example, if:
#
#   M = 235.4°
#   e = 0.4
#
# then
#
#   E = 220.512_074_767_522°
#
############################################################################################

@testset "Functions mean_to_eccentric_anomaly and eccentric_to_mean_anomaly" begin
    M = 235.4 |> deg2rad
    e = 0.4

    E = mean_to_eccentric_anomaly(e, M)
    @test E ≈ 220.512_074_767_522 |> deg2rad atol = 1e-14

    @test_throws ArgumentError mean_to_eccentric_anomaly(e, M; max_iterations = 0)
    @test_throws ArgumentError mean_to_eccentric_anomaly(e, M; max_iterations = -1)

    E = 220.512_074_767_522 |> deg2rad

    M = eccentric_to_mean_anomaly(e, E)
    @test M ≈ 235.4 |> deg2rad atol = 1e-14

    # == Types =============================================================================

    E = mean_to_eccentric_anomaly(0, 0.5)
    @test E isa Float64
    E = mean_to_eccentric_anomaly(0.0, 0)
    @test E isa Float64
    E = mean_to_eccentric_anomaly(0, 0.5f0)
    @test E isa Float32
    E = mean_to_eccentric_anomaly(0.0f0, 0)
    @test E isa Float32

    M = eccentric_to_mean_anomaly(0, 0.5)
    @test M isa Float64
    M = eccentric_to_mean_anomaly(0.0, 0)
    @test M isa Float64
    M = eccentric_to_mean_anomaly(0, 0.5f0)
    @test M isa Float32
    M = eccentric_to_mean_anomaly(0.0f0, 0)
    @test M isa Float32
end

# -- Functions: mean_to_true_anomaly and true_to_mean_anomaly ------------------------------

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# Values obtained from the old, validated code in SatelliteToolbox.jl.
#
# If we have:
#
#   M = 235.4°
#   e = 0.4
#
# then
#
#   f = 207.163_991_769_213_96°
#
############################################################################################

@testset "Functions mean_to_true_anomaly and true_to_mean_anomaly" begin
    M = 235.4 |> deg2rad
    e = 0.4

    f = mean_to_true_anomaly(e, M)
    @test f ≈ 207.163_991_769_213_96 |> deg2rad atol = 1e-14

    @test_throws ArgumentError mean_to_true_anomaly(e, M; max_iterations = 0)
    @test_throws ArgumentError mean_to_true_anomaly(e, M; max_iterations = -1)

    f = 207.163_991_769_213_96 |> deg2rad

    M = true_to_mean_anomaly(e, f)
    @test M ≈ 235.4 |> deg2rad atol = 1e-14

    # == Types =============================================================================

    f = mean_to_true_anomaly(0, 0.5)
    @test f isa Float64
    f = mean_to_true_anomaly(0.0, 0)
    @test f isa Float64
    f = mean_to_true_anomaly(0, 0.5f0)
    @test f isa Float32
    f = mean_to_true_anomaly(0.0f0, 0)
    @test f isa Float32

    M = true_to_mean_anomaly(0, 0.5)
    @test M isa Float64
    M = true_to_mean_anomaly(0.0, 0)
    @test M isa Float64
    M = true_to_mean_anomaly(0, 0.5f0)
    @test M isa Float32
    M = true_to_mean_anomaly(0.0f0, 0)
    @test M isa Float32
end

# -- Functions: eccentric_to_true_anomaly and true_to_eccentric_anomaly --------------------

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# Values obtained from the old, validated code in SatelliteToolbox.jl.
#
# If we have:
#
#   E = 235.4°
#   e = 0.4
#
# then
#
#   f = 217.935_779_687_955_03°
#
############################################################################################

@testset "Functions eccentric_to_true_anomaly and true_to_eccentric_anomaly" begin
    E = 235.4 |> deg2rad
    e = 0.4

    f = eccentric_to_true_anomaly(e, E)
    @test f ≈ 217.935_779_687_955_03 |> deg2rad atol = 1e-14

    f = 217.935_779_687_955_03 |> deg2rad

    E = true_to_eccentric_anomaly(e, f)
    @test E ≈ 235.4 |> deg2rad atol = 1e-14

    # == Types =============================================================================

    f = eccentric_to_true_anomaly(0, 0.5)
    @test f isa Float64
    f = eccentric_to_true_anomaly(0.0, 0)
    @test f isa Float64
    f = eccentric_to_true_anomaly(0, 0.5f0)
    @test f isa Float32
    f = eccentric_to_true_anomaly(0.0f0, 0)
    @test f isa Float32

    E = true_to_eccentric_anomaly(0, 0.5)
    @test E isa Float64
    E = true_to_eccentric_anomaly(0.0, 0)
    @test E isa Float64
    E = true_to_eccentric_anomaly(0, 0.5f0)
    @test E isa Float32
    E = true_to_eccentric_anomaly(0.0f0, 0)
    @test E isa Float32
end

# -- Newton-Raphson Solver: Robustness and Keywords ----------------------------------------

@testset "Kepler's Equation Solver (Robustness)" begin
    # Round trip `M -> E -> M` over a grid of eccentricities and mean anomalies, including
    # highly eccentric orbits.
    for e in (0, 1e-4, 0.1, 0.5, 0.9, 0.99), M in 0:0.25:2π
        E = mean_to_eccentric_anomaly(e, M)
        @test 0 ≤ E < 2π
        @test eccentric_to_mean_anomaly(e, E) ≈ mod(M, 2π) atol = 1e-13

        f = mean_to_true_anomaly(e, M)
        @test 0 ≤ f < 2π
        @test true_to_mean_anomaly(e, f) ≈ mod(M, 2π) atol = 1e-12
    end

    # Float32.
    for e in (0.0f0, 0.1f0, 0.9f0), M in 0.0f0:0.5f0:Float32(2π)
        E = mean_to_eccentric_anomaly(e, M)
        @test E isa Float32
        @test 0 ≤ E < 2π
        @test eccentric_to_mean_anomaly(e, E) ≈ mod(M, Float32(2π)) atol = 1e-5
    end

    # The mean anomaly is reduced to [0, 2π) before solving.
    E_ref = deg2rad(220.512_074_767_522)
    @test mean_to_eccentric_anomaly(0.4, deg2rad(235.4) + 4π) ≈ E_ref atol = 1e-14
    @test mean_to_eccentric_anomaly(0.4, deg2rad(235.4) - 2π) ≈ E_ref atol = 1e-14

    # Circular orbits: all anomalies are equal.
    @test mean_to_eccentric_anomaly(0, 1.5) == 1.5
    @test eccentric_to_true_anomaly(0, 1.5) ≈ 1.5
    @test true_to_eccentric_anomaly(0, 1.5) ≈ 1.5
end

@testset "Kepler's Equation Solver (Keywords)" begin
    e = 0.4
    M = 235.4 |> deg2rad
    E = 220.512_074_767_522 |> deg2rad

    # `max_iterations` limits the number of Newton-Raphson steps.
    E₁ = mean_to_eccentric_anomaly(e, M; max_iterations = 1)
    @test abs(E₁ - E) > 1e-6
    @test mean_to_eccentric_anomaly(e, M; max_iterations = 20) ≈ E atol = 1e-14

    # A loose tolerance stops at the first step that satisfies it.
    @test mean_to_eccentric_anomaly(e, M; tol = 1e-1) == E₁

    # An explicit tolerance is respected.
    E_tol = mean_to_eccentric_anomaly(e, M; tol = 1e-6)
    @test abs(E_tol - e * sin(E_tol) - M) ≤ 1e-6

    # Keywords are forwarded by `mean_to_true_anomaly`.
    f₁ = mean_to_true_anomaly(e, M; max_iterations = 1)
    @test f₁ == eccentric_to_true_anomaly(e, E₁)
end

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to conversions between the orbir representations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==========================================================================================
#
#   [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
#       Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Files: ./src/orbit/kepler_to_rv.jl and ./src/orbit/rv_to_kepler.jl
# ==========================================================================================

# Functions: kepler_to_rv and rv_to_kepler
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       TEST RESULTS
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 2-5: Finding position and velocity vectors (COE2RV Test Case) [1, p. 119-120].
#
# Cartesian representation:
#
#     r = 6525.344    I + 6861.535    J + 6449.125    K km
#     v =    4.902276 I +    5.533124 J -    1.975709 K km
#
# Orbit elements
#
#     ╔═════════════════╦══════════════╗
#     ║    Parameter    ║    Values    ║
#     ╠═════════════════╬══════════════╣
#     ║ p               ║ 11067.790 km ║
#     ║ Eccentricity    ║ 0.83285      ║
#     ║ Inclination     ║ 87.87°       ║
#     ║ RAAN            ║ 227.89°      ║
#     ║ Arg. of Perigee ║ 53.38°       ║
#     ║ True Anomaly    ║ 92.335°      ║
#     ╚═════════════════╩══════════════╝
#
############################################################################################

@testset "Function kepler_to_rv" begin

    # Float64
    # ======================================================================================

    let
        p    = 11067.790 * 1000
        e    = 0.83285
        i    = 87.87  * π / 180
        RAAN = 227.89 * π / 180
        w    = 53.38  * π / 180
        f    = 92.335 * π / 180
        a    = p / (1 - e^2)

        r_i, v_i = kepler_to_rv(KeplerianElements(0, a, e, i, RAAN, w, f))

        @test r_i[1] / 1000 ≈ +6525.344 atol = 5e-2
        @test r_i[2] / 1000 ≈ +6861.535 atol = 5e-2
        @test r_i[3] / 1000 ≈ +6449.125 atol = 5e-2
        @test eltype(r_i) == Float64

        @test v_i[1] / 1000 ≈ +4.902276 atol = 1e-4
        @test v_i[2] / 1000 ≈ +5.533124 atol = 1e-4
        @test v_i[3] / 1000 ≈ -1.975709 atol = 1e-4
        @test eltype(v_i) == Float64
    end

    # Float32
    # ======================================================================================

    let
        p    = 11067.790f0 * 1000
        e    = 0.83285f0
        i    = 87.87f0  * Float32(π / 180)
        RAAN = 227.89f0 * Float32(π / 180)
        w    = 53.38f0  * Float32(π / 180)
        f    = 92.335f0 * Float32(π / 180)
        a    = p / (1 - e^2)

        r_i, v_i = kepler_to_rv(KeplerianElements(0, a, e, i, RAAN, w, f))

        @test r_i[1] / 1000 ≈ +6525.344 atol = 5e-2
        @test r_i[2] / 1000 ≈ +6861.535 atol = 5e-2
        @test r_i[3] / 1000 ≈ +6449.125 atol = 5e-2
        @test eltype(r_i) == Float32

        @test v_i[1] / 1000 ≈ +4.902276 atol = 1e-4
        @test v_i[2] / 1000 ≈ +5.533124 atol = 1e-4
        @test v_i[3] / 1000 ≈ -1.975709 atol = 1e-4
        @test eltype(v_i) == Float32
    end
end

@testset "Function rv_to_kepler" begin

    # Float64
    # ======================================================================================

    let
        r_i = [6525.344; 6861.535; 6449.125] * 1000
        v_i = [4.902276; 5.533124; -1.975709] * 1000

        ke = rv_to_kepler(r_i, v_i)

        a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
        p = a * (1 - e^2)

        @test p / 1000       ≈ 11067.790 atol = 5e-2
        @test e              ≈ 0.83285   atol = 1e-5
        @test i    * 180 / π ≈ 87.87     atol = 1e-2
        @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
        @test w    * 180 / π ≈ 53.38     atol = 1e-2
        @test f    * 180 / π ≈ 92.335    atol = 1e-3
        @test ke isa KeplerianElements{Float64, Float64}
    end

    # Float32
    # ======================================================================================

    let
        r_i = [6525.344f0; 6861.535f0; 6449.125f0]  * 1000
        v_i = [4.902276f0; 5.533124f0; -1.975709f0] * 1000

        ke = rv_to_kepler(r_i, v_i)

        a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
        p = a * (1 - e^2)

        @test p / 1000       ≈ 11067.790 atol = 5e-2
        @test e              ≈ 0.83285   atol = 1e-5
        @test i * 180 / π    ≈ 87.87     atol = 1e-2
        @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
        @test w * 180 / π    ≈ 53.38     atol = 1e-2
        @test f * 180 / π    ≈ 92.335    atol = 1e-3
        @test ke isa KeplerianElements{Float64, Float32}
    end
end

@testset "Function rv_to_kepler (Special Cases)" begin
    # We will use the conversion:
    #
    #   Keplerian elements => Cartesian position => Keplerian elements
    #
    # to test the special cases. We can do this because the first conversion is validated at
    # this point.

    # Equatorial
    # ======================================================================================

    # Equatorial and elliptical
    # --------------------------------------------------------------------------------------

    ke = KeplerianElements(
        123,
        8000e3,
        0.01,
        0.0,
        30 |> deg2rad,
        20 |> deg2rad,
        10 |> deg2rad
    )

    r, v = kepler_to_rv(ke)
    kec  = rv_to_kepler(r, v, ke.t)

    @test kec.t ≈ ke.t
    @test kec.a ≈ ke.a
    @test kec.e ≈ ke.e
    @test kec.i ≈ ke.i
    @test kec.Ω ≈ 0
    @test kec.ω ≈ ke.Ω + ke.ω
    @test kec.f ≈ ke.f

    # Equatorial and circular
    # --------------------------------------------------------------------------------------

    ke = KeplerianElements(
        123,
        8000e3,
        0.0,
        0.0,
        30 |> deg2rad,
        20 |> deg2rad,
        10 |> deg2rad
    )

    r, v = kepler_to_rv(ke)
    kec  = rv_to_kepler(r, v, ke.t)

    @test kec.t ≈ ke.t
    @test kec.a ≈ ke.a
    @test kec.e ≈ ke.e atol = 1e-15
    @test kec.i ≈ ke.i
    @test kec.Ω ≈ 0
    @test kec.ω ≈ 0
    @test kec.f ≈ ke.Ω + ke.ω + ke.f

    # Inclined
    # ======================================================================================

    # Inclined and circular
    # --------------------------------------------------------------------------------------

    ke = KeplerianElements(
        123,
        8000e3,
        0.0,
        90 |> deg2rad,
        30 |> deg2rad,
        20 |> deg2rad,
        10 |> deg2rad
    )

    r, v = kepler_to_rv(ke)
    kec  = rv_to_kepler(r, v, ke.t)

    @test kec.t ≈ ke.t
    @test kec.a ≈ ke.a
    @test kec.e ≈ ke.e atol = 1e-15
    @test kec.i ≈ ke.i
    @test kec.Ω ≈ ke.Ω
    @test kec.ω ≈ 0
    @test kec.f ≈ ke.ω + ke.f
end

@testset "Function rv_to_kepler [ERRORS]" begin
    r_i = [6525.344; 6861.535; 6449.125] * 1000
    v_i = [49.02276; 55.33124; -19.75709] * 1000
    @test_throws ArgumentError rv_to_kepler(r_i, v_i)
end

# Files: ./src/orbit/kepler_to_sv.jl and ./src/orbit/sv_to_kepler.jl
# ==========================================================================================

# Functions: kepler_to_sv and sv_to_kepler
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       TEST RESULTS
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 2-5: Finding position and velocity vectors (COE2RV Test Case) [1, p. 119-120].
#
# Cartesian representation:
#
#     r = 6525.344    I + 6861.535    J + 6449.125    K km
#     v =    4.902276 I +    5.533124 J -    1.975709 K km
#
# Orbit elements
#
#     ╔═════════════════╦══════════════╗
#     ║    Parameter    ║    Values    ║
#     ╠═════════════════╬══════════════╣
#     ║ p               ║ 11067.790 km ║
#     ║ Eccentricity    ║ 0.83285      ║
#     ║ Inclination     ║ 87.87°       ║
#     ║ RAAN            ║ 227.89°      ║
#     ║ Arg. of Perigee ║ 53.38°       ║
#     ║ True Anomaly    ║ 92.335°      ║
#     ╚═════════════════╩══════════════╝
#
############################################################################################

@testset "Function kepler_to_sv" begin

    # Float64
    # ======================================================================================

    let
        p    = 11067.790 * 1000
        e    = 0.83285
        i    = 87.87  * π / 180
        RAAN = 227.89 * π / 180
        w    = 53.38  * π / 180
        f    = 92.335 * π / 180
        a    = p / (1 - e^2)

        sv = kepler_to_sv(KeplerianElements(0.0, a, e, i, RAAN, w, f))

        @test sv.r[1] / 1000 ≈ +6525.344 atol = 5e-2
        @test sv.r[2] / 1000 ≈ +6861.535 atol = 5e-2
        @test sv.r[3] / 1000 ≈ +6449.125 atol = 5e-2
        @test sv.v[1] / 1000 ≈ +4.902276 atol = 1e-4
        @test sv.v[2] / 1000 ≈ +5.533124 atol = 1e-4
        @test sv.v[3] / 1000 ≈ -1.975709 atol = 1e-4
        @test sv isa OrbitStateVector{Float64, Float64}
    end

    # Float32
    # ======================================================================================

    let
        p    = 11067.790f0 * 1000
        e    = 0.83285f0
        i    = 87.87f0  * Float32(π / 180)
        RAAN = 227.89f0 * Float32(π / 180)
        w    = 53.38f0  * Float32(π / 180)
        f    = 92.335f0 * Float32(π / 180)
        a    = p / (1 - e^2)

        sv = kepler_to_sv(KeplerianElements(0.0, a, e, i, RAAN, w, f))

        @test sv.r[1] / 1000 ≈ +6525.344 atol = 5e-2
        @test sv.r[2] / 1000 ≈ +6861.535 atol = 5e-2
        @test sv.r[3] / 1000 ≈ +6449.125 atol = 5e-2
        @test sv.v[1] / 1000 ≈ +4.902276 atol = 1e-4
        @test sv.v[2] / 1000 ≈ +5.533124 atol = 1e-4
        @test sv.v[3] / 1000 ≈ -1.975709 atol = 1e-4
        @test sv isa OrbitStateVector{Float64, Float32}

        sv = kepler_to_sv(KeplerianElements(0.0f0, a, e, i, RAAN, w, f))

        @test sv.r[1] / 1000 ≈ +6525.344 atol = 5e-2
        @test sv.r[2] / 1000 ≈ +6861.535 atol = 5e-2
        @test sv.r[3] / 1000 ≈ +6449.125 atol = 5e-2
        @test sv.v[1] / 1000 ≈ +4.902276 atol = 1e-4
        @test sv.v[2] / 1000 ≈ +5.533124 atol = 1e-4
        @test sv.v[3] / 1000 ≈ -1.975709 atol = 1e-4
        @test sv isa OrbitStateVector{Float32, Float32}
    end
end

@testset "Function sv_to_kepler" begin

    # Float64
    # ======================================================================================

    let
        r_i = [6525.344; 6861.535; 6449.125] * 1000
        v_i = [4.902276; 5.533124; -1.975709] * 1000
        sv  = OrbitStateVector(0.0, r_i, v_i)
        ke  = sv_to_kepler(sv)

        a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
        p = a * (1 - e^2)

        @test p / 1000       ≈ 11067.790 atol = 5e-2
        @test e              ≈ 0.83285   atol = 1e-5
        @test i    * 180 / π ≈ 87.87     atol = 1e-2
        @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
        @test w    * 180 / π ≈ 53.38     atol = 1e-2
        @test f    * 180 / π ≈ 92.335    atol = 1e-3
        @test ke isa KeplerianElements{Float64, Float64}
    end

    # Float32
    # ======================================================================================

    let
        r_i = [6525.344f0; 6861.535f0; 6449.125f0] * 1000
        v_i = [4.902276f0; 5.533124f0; -1.975709f0] * 1000
        sv  = OrbitStateVector(0.0, r_i, v_i)
        ke  = sv_to_kepler(sv)

        a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
        p = a * (1 - e^2)

        @test p / 1000       ≈ 11067.790 atol = 5e-2
        @test e              ≈ 0.83285   atol = 1e-5
        @test i * 180 / π    ≈ 87.87     atol = 1e-2
        @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
        @test w * 180 / π    ≈ 53.38     atol = 1e-2
        @test f * 180 / π    ≈ 92.335    atol = 1e-3
        @test ke isa KeplerianElements{Float64, Float32}

        sv = OrbitStateVector(0.0f0, r_i, v_i)
        ke = sv_to_kepler(sv)

        a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
        p = a * (1 - e^2)

        @test p / 1000       ≈ 11067.790 atol = 5e-2
        @test e              ≈ 0.83285   atol = 1e-5
        @test i * 180 / π    ≈ 87.87     atol = 1e-2
        @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
        @test w * 180 / π    ≈ 53.38     atol = 1e-2
        @test f * 180 / π    ≈ 92.335    atol = 1e-3
        @test ke isa KeplerianElements{Float32, Float32}
    end
end

# Files: ./src/orbit/conversions.jl
# ==========================================================================================

@testset "Conversions using Julia Built-in System" verbose = true begin
    @testset "KeplerianElements => KeplerianElements" begin
        ke  = KeplerianElements(1, 2, 3, 4, 5, 6, 7)
        kec = convert(KeplerianElements{Float64, Float32}, ke)

        @test kec isa KeplerianElements{Float64, Float32}
        @test ke.t ≈ 1
        @test ke.a ≈ 2
        @test ke.e ≈ 3
        @test ke.i ≈ 4
        @test ke.Ω ≈ 5
        @test ke.ω ≈ 6
        @test ke.f ≈ 7
    end

    @testset "KeplerianElements => OrbitStateVector" begin
        p    = 11067.790 * 1000
        e    = 0.83285
        i    = 87.87  * π / 180
        RAAN = 227.89 * π / 180
        w    = 53.38  * π / 180
        f    = 92.335 * π / 180
        a    = p / (1 - e^2)

        ke = KeplerianElements(Int64(123), a, e, i, RAAN, w, f)
        sv = convert(OrbitStateVector, ke)

        @test sv.r[1] / 1000 ≈ +6525.344 atol = 5e-2
        @test sv.r[2] / 1000 ≈ +6861.535 atol = 5e-2
        @test sv.r[3] / 1000 ≈ +6449.125 atol = 5e-2
        @test sv.v[1] / 1000 ≈ +4.902276 atol = 1e-4
        @test sv.v[2] / 1000 ≈ +5.533124 atol = 1e-4
        @test sv.v[3] / 1000 ≈ -1.975709 atol = 1e-4
        @test sv isa OrbitStateVector{Int64, Float64}

        ke = KeplerianElements(Int64(123), a, e, i, RAAN, w, f)
        sv = convert(OrbitStateVector{Float64, Float32}, ke)

        @test sv.r[1] / 1000 ≈ +6525.344 atol = 5e-2
        @test sv.r[2] / 1000 ≈ +6861.535 atol = 5e-2
        @test sv.r[3] / 1000 ≈ +6449.125 atol = 5e-2
        @test sv.v[1] / 1000 ≈ +4.902276 atol = 1e-4
        @test sv.v[2] / 1000 ≈ +5.533124 atol = 1e-4
        @test sv.v[3] / 1000 ≈ -1.975709 atol = 1e-4
        @test sv isa OrbitStateVector{Float64, Float32}
    end

    @testset "OrbitStateVector => OrbitStateVector" begin
        sv  = OrbitStateVector(Int64(123), [1, 2, 3], [4, 5, 6])
        svc = convert(OrbitStateVector{Float64, Float32}, sv)

        @test svc isa OrbitStateVector{Float64, Float32}
        @test sv.r[1] ≈ 1
        @test sv.r[2] ≈ 2
        @test sv.r[3] ≈ 3
        @test sv.v[1] ≈ 4
        @test sv.v[2] ≈ 5
        @test sv.v[3] ≈ 6
    end

    @testset "OrbitStateVector => KeplerianElements" begin
        r_i = [6525.344; 6861.535; 6449.125] * 1000
        v_i = [4.902276; 5.533124; -1.975709] * 1000

        sv  = OrbitStateVector(Int64(123), r_i, v_i)
        ke  = convert(KeplerianElements, sv)

        a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
        p = a * (1 - e^2)

        @test p / 1000       ≈ 11067.790 atol = 5e-2
        @test e              ≈ 0.83285   atol = 1e-5
        @test i    * 180 / π ≈ 87.87     atol = 1e-2
        @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
        @test w    * 180 / π ≈ 53.38     atol = 1e-2
        @test f    * 180 / π ≈ 92.335    atol = 1e-3
        @test ke isa KeplerianElements{Int64, Float64}

        ke = convert(KeplerianElements{Float64, Float32}, sv)

        a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
        p = a * (1 - e^2)

        @test p / 1000       ≈ 11067.790 atol = 5e-2
        @test e              ≈ 0.83285   atol = 1e-5
        @test i    * 180 / π ≈ 87.87     atol = 1e-2
        @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
        @test w    * 180 / π ≈ 53.38     atol = 1e-2
        @test f    * 180 / π ≈ 92.335    atol = 1e-3
        @test ke isa KeplerianElements{Float64, Float32}
    end
end

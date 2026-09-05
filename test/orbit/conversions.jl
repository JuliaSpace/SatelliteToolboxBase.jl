## Description #############################################################################
#
# Tests related to conversions between the orbit representations.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

# == Files: ./src/orbit/kepler_to_rv.jl and ./src/orbit/rv_to_kepler.jl ====================

# -- Functions: kepler_to_rv and rv_to_kepler ----------------------------------------------

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
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

# Helper that checks the Cartesian state against the Scenario 01 values.
function _test_scenario_01_rv(r_i, v_i)
    @test r_i[1] / 1000 ≈ +6525.344 atol = 5e-2
    @test r_i[2] / 1000 ≈ +6861.535 atol = 5e-2
    @test r_i[3] / 1000 ≈ +6449.125 atol = 5e-2
    @test v_i[1] / 1000 ≈ +4.902276 atol = 1e-4
    @test v_i[2] / 1000 ≈ +5.533124 atol = 1e-4
    @test v_i[3] / 1000 ≈ -1.975709 atol = 1e-4
    return nothing
end

# Helper that checks the Keplerian elements against the Scenario 01 values.
function _test_scenario_01_kepler(ke::KeplerianElements)
    a, e, i, RAAN, w, f = ke.a, ke.e, ke.i, ke.Ω, ke.ω, ke.f
    p = a * (1 - e^2)

    #! format: off
    @test p / 1000       ≈ 11067.790 atol = 5e-2
    @test e              ≈ 0.83285   atol = 1e-5
    @test i    * 180 / π ≈ 87.87     atol = 1e-2
    @test RAAN * 180 / π ≈ 227.89    atol = 1e-2
    @test w    * 180 / π ≈ 53.38     atol = 1e-2
    @test f    * 180 / π ≈ 92.335    atol = 1e-3
    #! format: on
    return nothing
end

# Keplerian elements of the Scenario 01 with element type `T`.
function _scenario_01_kepler(::Type{T}, epoch = zero(T)) where {T}
    p    = T(11067.790) * 1000
    e    = T(0.83285)
    i    = T(87.87) * T(π / 180)
    RAAN = T(227.89) * T(π / 180)
    w    = T(53.38) * T(π / 180)
    f    = T(92.335) * T(π / 180)
    a    = p / (1 - e^2)

    return KeplerianElements(epoch, a, e, i, RAAN, w, f)
end

# Cartesian state of the Scenario 01 with element type `T`.
function _scenario_01_rv(::Type{T}) where {T}
    r_i = T[6525.344; 6861.535; 6449.125] * 1000
    v_i = T[4.902276; 5.533124; -1.975709] * 1000
    return r_i, v_i
end

@testset "Function kepler_to_rv" begin

    # == Float64 ===========================================================================

    r_i, v_i = kepler_to_rv(_scenario_01_kepler(Float64, 0))
    _test_scenario_01_rv(r_i, v_i)
    @test eltype(r_i) == Float64
    @test eltype(v_i) == Float64

    # == Float32 ===========================================================================

    r_i, v_i = kepler_to_rv(_scenario_01_kepler(Float32, 0))
    _test_scenario_01_rv(r_i, v_i)
    @test eltype(r_i) == Float32
    @test eltype(v_i) == Float32

    # == Other Anomalies ===================================================================

    ke = _scenario_01_kepler(Float64)
    r_f, v_f = kepler_to_rv(ke)

    for Tanomaly in (EccentricAnomaly, MeanAnomaly)
        r_i, v_i = kepler_to_rv(convert(KeplerianElements{Tanomaly}, ke))
        @test r_i ≈ r_f rtol = 1e-12
        @test v_i ≈ v_f rtol = 1e-12
    end

    # == Errors ============================================================================

    @test_throws ArgumentError kepler_to_rv(KeplerianElements(0, 8000e3, 1.0, 0, 0, 0, 0))
    @test_throws ArgumentError kepler_to_rv(KeplerianElements(0, 8000e3, -0.1, 0, 0, 0, 0))
end

@testset "Function rv_to_kepler" begin

    # == Float64 ===========================================================================

    r_i, v_i = _scenario_01_rv(Float64)
    ke = rv_to_kepler(r_i, v_i)
    _test_scenario_01_kepler(ke)
    @test ke isa KeplerianElements{TrueAnomaly, Float64, Float64}

    # == Float32 ===========================================================================

    r_i, v_i = _scenario_01_rv(Float32)
    ke = rv_to_kepler(r_i, v_i)
    _test_scenario_01_kepler(ke)
    @test ke isa KeplerianElements{TrueAnomaly, Float64, Float32}

    # == Epoch =============================================================================

    r_i, v_i = _scenario_01_rv(Float64)
    ke = rv_to_kepler(r_i, v_i, Int64(123))
    @test ke isa KeplerianElements{TrueAnomaly, Float64, Float64}
    @test ke.epoch == 123.0

    ke = rv_to_kepler(r_i, v_i, 123.0f0)
    @test ke isa KeplerianElements{TrueAnomaly, Float32, Float64}

    # == Static Vectors ====================================================================

    ke = rv_to_kepler(SVector{3}(r_i), SVector{3}(v_i))
    _test_scenario_01_kepler(ke)
end

@testset "Function rv_to_kepler (Special Cases)" begin
    # We will use the conversion:
    #
    #   Keplerian elements => Cartesian position => Keplerian elements
    #
    # to test the special cases. We can do this because the first conversion is validated at
    # this point.

    # == Equatorial ========================================================================

    # -- Equatorial and Elliptical ---------------------------------------------------------

    ke = KeplerianElements(
        123, 8000e3, 0.01, 0.0, 30 |> deg2rad, 20 |> deg2rad, 10 |> deg2rad
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

    # -- Equatorial and Circular -----------------------------------------------------------

    ke = KeplerianElements(
        123, 8000e3, 0.0, 0.0, 30 |> deg2rad, 20 |> deg2rad, 10 |> deg2rad
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

    # == Inclined ==========================================================================

    # -- Inclined and Circular -------------------------------------------------------------

    ke = KeplerianElements(
        123, 8000e3, 0.0, 90 |> deg2rad, 30 |> deg2rad, 20 |> deg2rad, 10 |> deg2rad
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

    @test_throws DimensionMismatch rv_to_kepler([1.0, 2.0], [1.0, 2.0, 3.0])
    @test_throws DimensionMismatch rv_to_kepler([1.0, 2.0, 3.0], [1.0, 2.0, 3.0, 4.0])
end

@testset "Functions kepler_to_rv and rv_to_kepler (Custom Central Body)" begin
    # A circular orbit has a constant speed of √(μ / a). We use that identity as the
    # reference, so the test does not depend on the central body being the Earth. The orbit
    # here is around the Moon, whose standard gravitational parameter is 4.902800118e12
    # m³ / s² (DE440).
    μ = 4.902800118e12

    # == Float64 ===========================================================================

    let
        a  = 1837.4e3
        ke = KeplerianElements(0.0, a, 0.0, 85 |> deg2rad, 30 |> deg2rad, 0.0, 0.0)

        r_i, v_i = kepler_to_rv(ke; μ)

        @test norm(v_i) ≈ √(μ / a)
        @test rv_to_kepler(r_i, v_i, ke.t; μ).a ≈ a
    end

    # == Float32 ===========================================================================

    let
        a  = 1837.4f3
        ke = KeplerianElements(0.0f0, a, 0.0f0, 85.0f0 |> deg2rad, 0.0f0, 0.0f0, 0.0f0)

        _, v_i = kepler_to_rv(ke; μ)

        @test norm(v_i) ≈ √(Float32(μ) / a)
        @test eltype(v_i) == Float32
    end
end

# == Files: ./src/orbit/kepler_to_sv.jl and ./src/orbit/sv_to_kepler.jl ====================

# -- Functions: kepler_to_sv and sv_to_kepler ----------------------------------------------

@testset "Function kepler_to_sv" begin

    # == Float64 ===========================================================================

    sv = kepler_to_sv(_scenario_01_kepler(Float64))
    _test_scenario_01_rv(sv.r, sv.v)
    @test sv isa OrbitStateVector{Float64, Float64}
    @test sv.a == SVector{3, Float64}(0, 0, 0)

    # == Float32 ===========================================================================

    sv = kepler_to_sv(_scenario_01_kepler(Float32, 0.0))
    _test_scenario_01_rv(sv.r, sv.v)
    @test sv isa OrbitStateVector{Float64, Float32}

    sv = kepler_to_sv(_scenario_01_kepler(Float32))
    _test_scenario_01_rv(sv.r, sv.v)
    @test sv isa OrbitStateVector{Float32, Float32}

    # == Epoch =============================================================================

    ke = _scenario_01_kepler(Float64, 2451545.0)
    sv = kepler_to_sv(ke)
    @test sv.epoch == ke.epoch

    # == Other Anomalies ===================================================================

    ke = _scenario_01_kepler(Float64)
    sv = kepler_to_sv(convert(KeplerianElements{MeanAnomaly}, ke))
    _test_scenario_01_rv(sv.r, sv.v)
end

@testset "Function sv_to_kepler" begin

    # == Float64 ===========================================================================

    r_i, v_i = _scenario_01_rv(Float64)
    sv = OrbitStateVector(0.0, r_i, v_i)
    ke = sv_to_kepler(sv)
    _test_scenario_01_kepler(ke)
    @test ke isa KeplerianElements{TrueAnomaly, Float64, Float64}

    # == Float32 ===========================================================================

    r_i, v_i = _scenario_01_rv(Float32)
    sv = OrbitStateVector(0.0, r_i, v_i)
    ke = sv_to_kepler(sv)
    _test_scenario_01_kepler(ke)
    @test ke isa KeplerianElements{TrueAnomaly, Float64, Float32}

    sv = OrbitStateVector(0.0f0, r_i, v_i)
    ke = sv_to_kepler(sv)
    _test_scenario_01_kepler(ke)
    @test ke isa KeplerianElements{TrueAnomaly, Float32, Float32}

    # == Epoch =============================================================================

    r_i, v_i = _scenario_01_rv(Float64)
    sv = OrbitStateVector(2451545.0, r_i, v_i)
    ke = sv_to_kepler(sv)
    @test ke.epoch == sv.epoch
end

@testset "Functions kepler_to_sv and sv_to_kepler (Custom Central Body)" begin
    μ  = 4.902800118e12
    a  = 1837.4e3
    ke = KeplerianElements(0.0, a, 0.0, 85 |> deg2rad, 30 |> deg2rad, 0.0, 0.0)

    sv = kepler_to_sv(ke; μ)

    @test sv.v ≈ last(kepler_to_rv(ke; μ))
    @test sv_to_kepler(sv; μ).a ≈ a
end

# == Files: ./src/orbit/conversions.jl =====================================================

@testset "Conversions using Julia Built-in System" verbose = true begin
    @testset "KeplerianElements => KeplerianElements (Types)" begin
        ke  = KeplerianElements(1, 2, 3, 4, 5, 6, 7)
        kec = convert(KeplerianElements{TrueAnomaly, Float64, Float32}, ke)

        @test kec isa KeplerianElements{TrueAnomaly, Float64, Float32}
        @test kec.t ≈ 1
        @test kec.a ≈ 2
        @test kec.e ≈ 3
        @test kec.i ≈ 4
        @test kec.Ω ≈ 5
        @test kec.ω ≈ 6
        @test kec.f ≈ 7

        # Identity conversions must return the same object.
        @test convert(KeplerianElements, ke) === ke
        @test convert(KeplerianElements{TrueAnomaly}, ke) === ke
        @test convert(typeof(ke), ke) === ke
    end

    @testset "KeplerianElements => KeplerianElements (Anomalies)" begin
        # Values from the Vallado example 2-1: M = 235.4°, e = 0.4.
        e = 0.4
        M = 235.4 |> deg2rad
        E = 220.512_074_767_522 |> deg2rad
        f = 207.163_991_769_213_96 |> deg2rad

        ke_M = KeplerianElements{MeanAnomaly}(Int64(123), 8000e3, e, 0.1, 0.2, 0.3, M)
        ke_E = KeplerianElements{EccentricAnomaly}(Int64(123), 8000e3, e, 0.1, 0.2, 0.3, E)
        ke_f = KeplerianElements{TrueAnomaly}(Int64(123), 8000e3, e, 0.1, 0.2, 0.3, f)

        for ke in (ke_M, ke_E, ke_f)
            kec = convert(KeplerianElements{MeanAnomaly}, ke)
            @test kec isa KeplerianElements{MeanAnomaly, Int64, Float64}
            @test kec.anomaly ≈ M atol = 1e-14

            kec = convert(KeplerianElements{EccentricAnomaly}, ke)
            @test kec isa KeplerianElements{EccentricAnomaly, Int64, Float64}
            @test kec.anomaly ≈ E atol = 1e-14

            kec = convert(KeplerianElements{TrueAnomaly}, ke)
            @test kec isa KeplerianElements{TrueAnomaly, Int64, Float64}
            @test kec.anomaly ≈ f atol = 1e-14

            # The other elements must be copied unchanged.
            #! format: off
            @test kec.epoch                 === ke.epoch
            @test kec.semi_major_axis       === ke.semi_major_axis
            @test kec.eccentricity          === ke.eccentricity
            @test kec.inclination           === ke.inclination
            @test kec.raan                  === ke.raan
            #! format: on
            @test kec.argument_of_periapsis === ke.argument_of_periapsis

            # Changing the anomaly and the numeric types at once.
            kec = convert(KeplerianElements{MeanAnomaly, Float64, Float32}, ke)
            @test kec isa KeplerianElements{MeanAnomaly, Float64, Float32}
            @test kec.anomaly ≈ M atol = 1e-6
            @test kec.epoch === 123.0
        end
    end

    @testset "KeplerianElements => OrbitStateVector" begin
        ke = _scenario_01_kepler(Float64, Int64(123))
        sv = convert(OrbitStateVector, ke)

        _test_scenario_01_rv(sv.r, sv.v)
        @test sv isa OrbitStateVector{Int64, Float64}
        @test sv.epoch === Int64(123)

        sv = convert(OrbitStateVector{Float64, Float32}, ke)

        _test_scenario_01_rv(sv.r, sv.v)
        @test sv isa OrbitStateVector{Float64, Float32}

        # Other anomalies.
        for Tanomaly in (EccentricAnomaly, MeanAnomaly)
            sv = convert(OrbitStateVector, convert(KeplerianElements{Tanomaly}, ke))
            _test_scenario_01_rv(sv.r, sv.v)
            @test sv isa OrbitStateVector{Int64, Float64}
        end
    end

    @testset "OrbitStateVector => OrbitStateVector" begin
        sv  = OrbitStateVector(Int64(123), [1, 2, 3], [4, 5, 6])
        svc = convert(OrbitStateVector{Float64, Float32}, sv)

        @test svc isa OrbitStateVector{Float64, Float32}
        @test svc.epoch === 123.0
        @test svc.r == SVector{3, Float32}(1, 2, 3)
        @test svc.v == SVector{3, Float32}(4, 5, 6)
        @test svc.a == SVector{3, Float32}(0, 0, 0)

        @test convert(OrbitStateVector, sv) === sv
        @test convert(typeof(sv), sv) === sv
    end

    @testset "OrbitStateVector => KeplerianElements" begin
        r_i, v_i = _scenario_01_rv(Float64)

        sv = OrbitStateVector(Int64(123), r_i, v_i)
        ke = convert(KeplerianElements, sv)

        _test_scenario_01_kepler(ke)
        @test ke isa KeplerianElements{TrueAnomaly, Int64, Float64}
        @test ke.epoch === Int64(123)

        ke = convert(KeplerianElements{TrueAnomaly, Float64, Float32}, sv)

        _test_scenario_01_kepler(ke)
        @test ke isa KeplerianElements{TrueAnomaly, Float64, Float32}

        # Other anomalies.
        ke_f = convert(KeplerianElements{TrueAnomaly}, sv)

        for Tanomaly in (EccentricAnomaly, MeanAnomaly)
            ke = convert(KeplerianElements{Tanomaly}, sv)
            @test ke isa KeplerianElements{Tanomaly, Int64, Float64}
            @test true_anomaly(ke) ≈ ke_f.anomaly

            ke = convert(KeplerianElements{Tanomaly, Float64, Float32}, sv)
            @test ke isa KeplerianElements{Tanomaly, Float64, Float32}
            @test true_anomaly(ke) ≈ ke_f.anomaly rtol = 1e-5
        end
    end

    @testset "KeplerianElements => EquinoctialElements" begin
        # == Reference Values ==============================================================

        #! format: off
        ke = KeplerianElements(
            date_to_jd(1986, 6, 19, 18, 35, 0),
            7130.982e3,
               0.0001111,
              98.405 |> deg2rad,
             200.000 |> deg2rad,
              90.000 |> deg2rad,
             123.456 |> deg2rad,
        )
        #! format: on

        e = ke.eccentricity
        i = ke.inclination
        Ω = ke.raan
        ω = ke.argument_of_periapsis
        M = mean_anomaly(ke)

        ee = convert(EquinoctialElements, ke)

        @test ee isa EquinoctialElements{Float64, Float64}
        #! format: off
        @test ee.epoch           === ke.epoch
        @test ee.semi_major_axis === ke.semi_major_axis
        @test ee.h               ≈ e * sin(ω + Ω)
        @test ee.k               ≈ e * cos(ω + Ω)
        @test ee.p               ≈ tan(i / 2) * sin(Ω)
        @test ee.q               ≈ tan(i / 2) * cos(Ω)
        @test ee.mean_longitude  ≈ Ω + ω + M
        #! format: on

        # The result must not depend on the anomaly type of the input.
        for Tanomaly in (EccentricAnomaly, MeanAnomaly)
            eec = convert(EquinoctialElements, convert(KeplerianElements{Tanomaly}, ke))
            #! format: off
            @test eec.h              ≈ ee.h
            @test eec.k              ≈ ee.k
            @test eec.p              ≈ ee.p
            @test eec.q              ≈ ee.q
            #! format: on
            @test eec.mean_longitude ≈ ee.mean_longitude
        end

        # == Types =========================================================================

        ee = convert(EquinoctialElements{Float64, Float32}, ke)
        @test ee isa EquinoctialElements{Float64, Float32}
        @test ee.h ≈ e * sin(ω + Ω) rtol = 1e-6

        ke_f32 = KeplerianElements(1.0, 7130.982f3, 0.1f0, 0.5f0, 0.3f0, 0.2f0, 0.1f0)
        ee     = convert(EquinoctialElements, ke_f32)
        @test ee isa EquinoctialElements{Float64, Float32}

        ee = convert(
            EquinoctialElements,
            KeplerianElements(Int64(1), 7130.982e3, 0.1, 0.5, 0.3, 0.2, 0.1),
        )
        @test ee isa EquinoctialElements{Int64, Float64}

        # == Special Cases =================================================================

        # Circular orbit: h = k = 0.
        ee = convert(
            EquinoctialElements, KeplerianElements(0.0, 8000e3, 0.0, 0.5, 0.3, 0.2, 0.1)
        )
        @test ee.h == 0
        @test ee.k == 0
        @test ee.mean_longitude ≈ 0.3 + 0.2 + 0.1

        # Equatorial orbit: p = q = 0.
        ee = convert(
            EquinoctialElements, KeplerianElements(0.0, 8000e3, 0.1, 0.0, 0.3, 0.2, 0.1)
        )
        @test ee.p == 0
        @test ee.q == 0

        # Retrograde equatorial orbit is singular.
        @test_throws ArgumentError convert(
            EquinoctialElements, KeplerianElements(0.0, 8000e3, 0.1, π, 0.3, 0.2, 0.1)
        )
        @test_throws ArgumentError convert(
            EquinoctialElements,
            KeplerianElements(0.0f0, 8000.0f3, 0.1f0, Float32(π), 0.3f0, 0.2f0, 0.1f0),
        )

        # Retrograde but not equatorial is fine.
        ee = convert(
            EquinoctialElements,
            KeplerianElements(0.0, 8000e3, 0.1, 179 |> deg2rad, 0.3, 0.2, 0.1),
        )
        @test isfinite(ee.p)
        @test isfinite(ee.q)
    end

    @testset "EquinoctialElements => KeplerianElements" begin
        # == Round Trip over a Grid ========================================================

        angles = deg2rad.((10, 170, 190, 350))

        for e in (0, 0.1, 0.7),
            i in deg2rad.((0, 45, 179)), Ω in angles, ω in angles,
            f in angles

            ke = KeplerianElements(Int64(123), 8000e3, e, i, Ω, ω, f)
            ee = convert(EquinoctialElements, ke)

            # -- True Anomaly --------------------------------------------------------------

            kec = convert(KeplerianElements, ee)
            @test kec isa KeplerianElements{TrueAnomaly, Int64, Float64}

            @test kec.epoch === ke.epoch
            @test kec.semi_major_axis ≈ ke.semi_major_axis
            #! format: off
            @test kec.eccentricity    ≈ ke.eccentricity atol = 1e-12
            @test kec.inclination     ≈ ke.inclination  atol = 1e-12
            #! format: on

            # All the angles must be in [0, 2π).
            @test 0 ≤ kec.raan < 2π
            @test 0 ≤ kec.argument_of_periapsis < 2π
            @test 0 ≤ kec.anomaly < 2π

            Ω_c = kec.raan
            ω_c = kec.argument_of_periapsis
            f_c = kec.anomaly

            if e == 0 && i == 0
                # Circular and equatorial: only the true longitude is defined.
                @test mod(Ω_c + ω_c + f_c, 2π) ≈ mod(Ω + ω + f, 2π) atol = 1e-9
            elseif e == 0
                # Circular and inclined: only the argument of latitude is defined.
                @test Ω_c ≈ Ω
                @test mod(ω_c + f_c, 2π) ≈ mod(ω + f, 2π) atol = 1e-9
            elseif i == 0
                # Elliptical and equatorial: only the longitude of periapsis is defined.
                @test mod(Ω_c + ω_c, 2π) ≈ mod(Ω + ω, 2π) atol = 1e-9
                @test f_c ≈ f atol = 1e-9
            else
                @test Ω_c ≈ Ω atol = 1e-9
                @test ω_c ≈ ω atol = 1e-9
                @test f_c ≈ f atol = 1e-9
            end

            # -- Mean and Eccentric Anomaly ------------------------------------------------

            kec_M = convert(KeplerianElements{MeanAnomaly}, ee)
            @test kec_M isa KeplerianElements{MeanAnomaly, Int64, Float64}
            @test 0 ≤ kec_M.anomaly < 2π
            @test kec_M.anomaly ≈ mean_anomaly(kec) atol = 1e-9

            kec_E = convert(KeplerianElements{EccentricAnomaly}, ee)
            @test kec_E isa KeplerianElements{EccentricAnomaly, Int64, Float64}
            @test kec_E.anomaly ≈ eccentric_anomaly(kec) atol = 1e-9
        end

        # == Types =========================================================================

        ee = convert(
            EquinoctialElements,
            KeplerianElements(Int64(1), 8000e3, 0.1, 0.5, 0.3, 0.2, 0.1),
        )

        kec = convert(KeplerianElements{MeanAnomaly, Float64, Float32}, ee)
        @test kec isa KeplerianElements{MeanAnomaly, Float64, Float32}
        @test kec.epoch === 1.0
        @test kec.raan ≈ 0.3 atol = 1e-6

        ee_f32 = convert(EquinoctialElements{Float64, Float32}, ee)
        kec    = convert(KeplerianElements, ee_f32)
        @test kec isa KeplerianElements{TrueAnomaly, Float64, Float32}

        # == Angle Wrapping ================================================================

        # Angles that would be negative when computed with `atan` must be wrapped.
        ke = KeplerianElements(
            0.0, 8000e3, 0.1, 30 |> deg2rad, 300 |> deg2rad, 300 |> deg2rad, 300 |> deg2rad
        )
        kec = convert(KeplerianElements, convert(EquinoctialElements, ke))
        @test kec.raan ≈ 300 |> deg2rad
        @test kec.argument_of_periapsis ≈ 300 |> deg2rad
        @test kec.anomaly ≈ 300 |> deg2rad
    end

    @testset "EquinoctialElements => EquinoctialElements" begin
        ee  = EquinoctialElements(1, 2, 3, 4, 5, 6, 7)
        eec = convert(EquinoctialElements{Float64, Float32}, ee)

        @test eec isa EquinoctialElements{Float64, Float32}
        @test eec.epoch === 1.0
        @test eec.semi_major_axis === 2.0f0
        #! format: off
        @test eec.h               === 3.0f0
        @test eec.k               === 4.0f0
        @test eec.p               === 5.0f0
        @test eec.q               === 6.0f0
        @test eec.mean_longitude  === 7.0f0
        #! format: on

        @test convert(EquinoctialElements, ee) === ee
        @test convert(typeof(ee), ee) === ee
    end

    @testset "EquinoctialElements => OrbitStateVector" begin
        ke = _scenario_01_kepler(Float64, Int64(123))
        ee = convert(EquinoctialElements, ke)

        sv = convert(OrbitStateVector, ee)
        _test_scenario_01_rv(sv.r, sv.v)
        @test sv isa OrbitStateVector{Int64, Float64}
        @test sv.epoch === Int64(123)

        sv = convert(OrbitStateVector{Float64, Float32}, ee)
        _test_scenario_01_rv(sv.r, sv.v)
        @test sv isa OrbitStateVector{Float64, Float32}
    end

    @testset "OrbitStateVector => EquinoctialElements" begin
        r_i, v_i = _scenario_01_rv(Float64)
        sv = OrbitStateVector(Int64(123), r_i, v_i)

        # The conversion must go through the Keplerian elements.
        ee_ref = convert(EquinoctialElements, sv_to_kepler(sv))

        ee = convert(EquinoctialElements, sv)
        @test ee isa EquinoctialElements{Int64, Float64}
        @test ee.epoch === Int64(123)
        @test ee.semi_major_axis == ee_ref.semi_major_axis
        #! format: off
        @test ee.h               == ee_ref.h
        @test ee.k               == ee_ref.k
        @test ee.p               == ee_ref.p
        @test ee.q               == ee_ref.q
        @test ee.mean_longitude  == ee_ref.mean_longitude
        #! format: on

        # The Vallado example values are rounded, so we use a loose tolerance here.
        ee_vallado = convert(EquinoctialElements, _scenario_01_kepler(Float64, Int64(123)))
        @test ee.semi_major_axis ≈ ee_vallado.semi_major_axis rtol = 1e-4
        #! format: off
        @test ee.h               ≈ ee_vallado.h               atol = 1e-4
        @test ee.k               ≈ ee_vallado.k               atol = 1e-4
        @test ee.p               ≈ ee_vallado.p               atol = 1e-4
        @test ee.q               ≈ ee_vallado.q               atol = 1e-4
        @test ee.mean_longitude  ≈ ee_vallado.mean_longitude  atol = 1e-4
        #! format: on

        ee = convert(EquinoctialElements{Float64, Float32}, sv)
        @test ee isa EquinoctialElements{Float64, Float32}
        @test ee.epoch === 123.0
        @test ee.h ≈ ee_ref.h atol = 1e-5

        # Round trip through the state vector.
        svc = convert(OrbitStateVector, convert(EquinoctialElements, sv))
        @test svc.r ≈ sv.r rtol = 1e-9
        @test svc.v ≈ sv.v rtol = 1e-9
    end
end

@testset "Conversions with AlternateEquinoctialElements" verbose = true begin
    @testset "KeplerianElements => AlternateEquinoctialElements" begin
        # == Reference Values ==============================================================

        #! format: off
        ke = KeplerianElements(
            date_to_jd(1986, 6, 19, 18, 35, 0),
            7130.982e3,
               0.0001111,
              98.405 |> deg2rad,
             200.000 |> deg2rad,
              90.000 |> deg2rad,
             123.456 |> deg2rad,
        )
        #! format: on

        e = ke.eccentricity
        i = ke.inclination
        Ω = ke.raan
        ω = ke.argument_of_periapsis
        M = mean_anomaly(ke)

        aee = convert(AlternateEquinoctialElements, ke)

        @test aee isa AlternateEquinoctialElements{Float64, Float64}
        #! format: off
        @test aee.epoch           === ke.epoch
        @test aee.semi_major_axis === ke.semi_major_axis
        @test aee.h               ≈ e * sin(ω + Ω)
        @test aee.k               ≈ e * cos(ω + Ω)
        @test aee.p               ≈ sin(i / 2) * sin(Ω)
        @test aee.q               ≈ sin(i / 2) * cos(Ω)
        @test aee.mean_longitude  ≈ Ω + ω + M
        #! format: on

        # The result must not depend on the anomaly type of the input.
        for Tanomaly in (EccentricAnomaly, MeanAnomaly)
            aeec = convert(
                AlternateEquinoctialElements, convert(KeplerianElements{Tanomaly}, ke)
            )
            #! format: off
            @test aeec.h              ≈ aee.h
            @test aeec.k              ≈ aee.k
            @test aeec.p              ≈ aee.p
            @test aeec.q              ≈ aee.q
            @test aeec.mean_longitude ≈ aee.mean_longitude
            #! format: on
        end

        # == Types =========================================================================

        aee = convert(AlternateEquinoctialElements{Float64, Float32}, ke)
        @test aee isa AlternateEquinoctialElements{Float64, Float32}
        @test aee.p ≈ sin(i / 2) * sin(Ω) rtol = 1e-6

        ke_f32 = KeplerianElements(1.0, 7130.982f3, 0.1f0, 0.5f0, 0.3f0, 0.2f0, 0.1f0)
        aee    = convert(AlternateEquinoctialElements, ke_f32)
        @test aee isa AlternateEquinoctialElements{Float64, Float32}

        # == Special Cases =================================================================

        # Circular orbit: h = k = 0.
        aee = convert(
            AlternateEquinoctialElements,
            KeplerianElements(0.0, 8000e3, 0.0, 0.5, 0.3, 0.2, 0.1),
        )
        @test aee.h == 0
        @test aee.k == 0

        # Equatorial orbit: p = q = 0.
        aee = convert(
            AlternateEquinoctialElements,
            KeplerianElements(0.0, 8000e3, 0.1, 0.0, 0.3, 0.2, 0.1),
        )
        @test aee.p == 0
        @test aee.q == 0

        # Retrograde equatorial orbit is finite, with p² + q² = 1.
        aee = convert(
            AlternateEquinoctialElements,
            KeplerianElements(0.0, 8000e3, 0.1, π, 0.3, 0.2, 0.1),
        )
        @test hypot(aee.p, aee.q) ≈ 1
        @test aee.p ≈ sin(0.3)
        @test aee.q ≈ cos(0.3)
    end

    @testset "AlternateEquinoctialElements => KeplerianElements" begin
        # == Round Trip over a Grid ========================================================

        angles = deg2rad.((10, 170, 190, 350))

        for e in (0, 0.1, 0.7),
            i in deg2rad.((0, 45, 179, 180)), Ω in angles, ω in angles,
            f in angles

            ke  = KeplerianElements(Int64(123), 8000e3, e, i, Ω, ω, f)
            aee = convert(AlternateEquinoctialElements, ke)
            kec = convert(KeplerianElements, aee)

            @test kec isa KeplerianElements{TrueAnomaly, Int64, Float64}
            @test kec.epoch === ke.epoch
            @test kec.semi_major_axis ≈ ke.semi_major_axis
            @test kec.eccentricity ≈ ke.eccentricity atol = 1e-12
            @test kec.inclination ≈ ke.inclination atol = 1e-8

            # All the angles must be in [0, 2π).
            @test 0 ≤ kec.raan < 2π
            @test 0 ≤ kec.argument_of_periapsis < 2π
            @test 0 ≤ kec.anomaly < 2π

            # The Cartesian state must be recovered regardless of the degenerate angles.
            r_ke, v_ke = kepler_to_rv(ke)
            r_kec, v_kec = kepler_to_rv(kec)
            @test r_kec ≈ r_ke atol = 1e-6
            @test v_kec ≈ v_ke atol = 1e-9

            # -- Mean and Eccentric Anomaly ------------------------------------------------

            kec_M = convert(KeplerianElements{MeanAnomaly}, aee)
            @test kec_M isa KeplerianElements{MeanAnomaly, Int64, Float64}
            @test kec_M.anomaly ≈ mean_anomaly(kec) atol = 1e-9

            kec_E = convert(KeplerianElements{EccentricAnomaly}, aee)
            @test kec_E isa KeplerianElements{EccentricAnomaly, Int64, Float64}
            @test kec_E.anomaly ≈ eccentric_anomaly(kec) atol = 1e-9
        end

        # == Types =========================================================================

        aee = convert(
            AlternateEquinoctialElements,
            KeplerianElements(Int64(1), 8000e3, 0.1, 0.5, 0.3, 0.2, 0.1),
        )

        kec = convert(KeplerianElements{MeanAnomaly, Float64, Float32}, aee)
        @test kec isa KeplerianElements{MeanAnomaly, Float64, Float32}
        @test kec.epoch === 1.0
        @test kec.raan ≈ 0.3 atol = 1e-6

        # == Errors ========================================================================

        # p² + q² > 1 does not represent an orbit.
        aee = AlternateEquinoctialElements(0.0, 8000e3, 0.0, 0.0, 0.8, 0.8, 1.0)
        @test_throws ArgumentError convert(KeplerianElements, aee)
        @test_throws ArgumentError convert(OrbitStateVector, aee)
    end

    @testset "AlternateEquinoctialElements <=> EquinoctialElements" begin
        angles = deg2rad.((10, 170, 190, 350))

        for e in (0, 0.1, 0.7), i in deg2rad.((0, 45, 179)), Ω in angles, ω in angles
            ke  = KeplerianElements(Int64(123), 8000e3, e, i, Ω, ω, 0.5)
            ee  = convert(EquinoctialElements, ke)
            aee = convert(AlternateEquinoctialElements, ke)

            # The direct conversions must match the ones through the Keplerian elements.
            aeec = convert(AlternateEquinoctialElements, ee)
            @test aeec isa AlternateEquinoctialElements{Int64, Float64}
            @test aeec.epoch === ee.epoch
            @test aeec.semi_major_axis === ee.semi_major_axis
            @test aeec.h === ee.h
            @test aeec.k === ee.k
            @test aeec.mean_longitude === ee.mean_longitude
            @test aeec.p ≈ aee.p atol = 1e-14
            @test aeec.q ≈ aee.q atol = 1e-14

            # The scaling by `1 / cos(i / 2)` amplifies the rounding error near i = π.
            eec = convert(EquinoctialElements, aee)
            @test eec isa EquinoctialElements{Int64, Float64}
            @test eec.p ≈ ee.p atol = 1e-12 rtol = 1e-10
            @test eec.q ≈ ee.q atol = 1e-12 rtol = 1e-10
        end

        # == Types =========================================================================

        ee = convert(
            EquinoctialElements,
            KeplerianElements(Int64(1), 8000e3, 0.1, 0.5, 0.3, 0.2, 0.1),
        )

        aee = convert(AlternateEquinoctialElements{Float64, Float32}, ee)
        @test aee isa AlternateEquinoctialElements{Float64, Float32}
        @test aee.epoch === 1.0

        eec = convert(EquinoctialElements{Float64, Float32}, aee)
        @test eec isa EquinoctialElements{Float64, Float32}
        @test eec.p ≈ ee.p rtol = 1e-6

        # == Errors ========================================================================

        # Retrograde equatorial orbit is singular in the equinoctial elements.
        aee = convert(
            AlternateEquinoctialElements,
            KeplerianElements(0.0, 8000e3, 0.1, π, 0.3, 0.2, 0.1),
        )
        @test_throws ArgumentError convert(EquinoctialElements, aee)
    end

    @testset "AlternateEquinoctialElements <=> OrbitStateVector" begin
        ke  = _scenario_01_kepler(Float64, Int64(123))
        aee = convert(AlternateEquinoctialElements, ke)

        sv = convert(OrbitStateVector, aee)
        _test_scenario_01_rv(sv.r, sv.v)
        @test sv isa OrbitStateVector{Int64, Float64}
        @test sv.epoch === Int64(123)

        sv = convert(OrbitStateVector{Float64, Float32}, aee)
        _test_scenario_01_rv(sv.r, sv.v)
        @test sv isa OrbitStateVector{Float64, Float32}

        r_i, v_i = _scenario_01_rv(Float64)
        sv = OrbitStateVector(Int64(123), r_i, v_i)

        # The conversion must go through the Keplerian elements.
        aee_ref = convert(AlternateEquinoctialElements, sv_to_kepler(sv))
        aee     = convert(AlternateEquinoctialElements, sv)
        @test aee isa AlternateEquinoctialElements{Int64, Float64}
        @test aee.epoch === Int64(123)
        @test aee.semi_major_axis == aee_ref.semi_major_axis
        @test aee.h == aee_ref.h
        @test aee.k == aee_ref.k
        @test aee.p == aee_ref.p
        @test aee.q == aee_ref.q
        @test aee.mean_longitude == aee_ref.mean_longitude

        aee = convert(AlternateEquinoctialElements{Float64, Float32}, sv)
        @test aee isa AlternateEquinoctialElements{Float64, Float32}
        @test aee.epoch === 123.0

        # Round trip through the state vector.
        svc = convert(OrbitStateVector, convert(AlternateEquinoctialElements, sv))
        @test svc.r ≈ sv.r rtol = 1e-9
        @test svc.v ≈ sv.v rtol = 1e-9
    end
end

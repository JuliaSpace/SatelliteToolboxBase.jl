# Repository Guide

SatelliteToolboxBase.jl holds the constants, types, and base functions shared by the SatelliteToolbox.jl ecosystem: orbit representations and their conversions, anomaly conversions, Julian Day and GMST functions, ellipsoids, and a lower triangular storage type.

## Package Structure

- Single package. Requires Julia 1.10 or newer (`[compat] julia = "1.10"`).
- `src/SatelliteToolboxBase.jl` is the module entrypoint and holds every `using`/`import` plus the `include` order: `types/` first, then `constants.jl`, then `helpers.jl`, `interfaces.jl`, `storage.jl`, `orbit/`, `show/`, `time/`, and `precompile.jl` last. New code may only reference symbols defined in files included before it.
- `src/precompile.jl` holds a `PrecompileTools.@compile_workload`; extend it when adding a public code path. The whole block sits under `#! format: off` to keep its hand-aligned numeric columns.
- Runtime dependencies (`[deps]`): Dates, LinearAlgebra, PrecompileTools, ReferenceFrameRotations, StaticArrays, StyledStrings. Test-only dependencies are declared in `[extras]` + `[targets]` of `Project.toml`: `Test`, `Aqua`, and `JET`. There is no `test/Project.toml`.
- No package extensions (`ext/`), no `deps/build.jl`, no committed `Manifest.toml`.
- Tests are included unconditionally from `test/runtests.jl`, one nested `@testset "Name" verbose = true` per file. The layout does not mirror `src/` one-to-one: `test/orbit/{keplerian,equinoctial,alternate_equinoctial}_elements.jl` and `test/orbit/orbit_state_vector.jl` cover the types in `src/types/orbit.jl` and the `show` methods in `src/show/orbit.jl`; `test/orbit/conversions.jl` covers `src/orbit/{conversions,kepler_to_rv,kepler_to_sv,rv_to_kepler,sv_to_kepler}.jl`; `test/orbit/anomalies.jl` covers `src/orbit/anomalies.jl` and `src/orbit/getters.jl` is covered by the Keplerian elements tests. `src/constants.jl` and `src/types/jacobian.jl` have no dedicated tests. Regression tests for reported issues live in `test/issues.jl` and `test/time/issues.jl`. `test/quality.jl` runs `Aqua.test_all` and `JET.test_package` (JET is skipped on prerelease Julia).

## Commands

- Instantiate: `julia --project=. -e 'using Pkg; Pkg.instantiate()'`
- Full test suite: `julia --project=. -e 'using Pkg; Pkg.test()'` (about one minute; the first run precompiles and prints little, so use generous timeouts).
- Focused test file: `julia --project=. -e 'using SatelliteToolboxBase, Test, Dates, LinearAlgebra, StaticArrays; include("test/orbit/conversions.jl")'` (this `using` list matches `test/runtests.jl` and is enough for every test file). There is no test-name selector.
- CI (`.github/workflows/ci.yml`) builds with `julia-actions/julia-buildpkg` and then runs the tests on Julia 1.10 and the latest stable 1.x, on Ubuntu x64, macOS arm64, and Windows x64, and uploads coverage to Codecov. `ci-nightly.yml` runs the same matrix on Julia nightly. `Pkg.test()` alone reproduces CI.
- Quality checks (Aqua and JET) run inside `Pkg.test()`; they are test-only dependencies, so a plain `--project=.` session cannot load them. To run only `test/quality.jl`, use TestEnv.jl from the default environment: `julia --project=. -e 'using TestEnv; TestEnv.activate(); using SatelliteToolboxBase, Test, Aqua, JET; include("test/quality.jl")'`.

## Code Style

- Code follows Blue Style with the project extensions. `.JuliaFormatter.toml` at the repo root (`style = "blue"`, aligned assignments/fields/pairs/matrices, `whitespace_in_kwargs = true`, `whitespace_typedefs = true`) is the source of truth. Line width is 92 columns.
- Format: `julia -e 'using JuliaFormatter; format(".")'` (no `--project=.`; JuliaFormatter must be in the default environment). `format(".")` returns `true` when nothing changed; a check is to run it and then `git diff --exit-code`. Apply it in its own `:art:` commit before finishing.
- CI does not run a format check.
- The formatter never wraps `abstract type X <: Y end` lines and leaves `atol=1e-6` inside `@test` untouched: wrap such definitions by hand inside `#! format: off` / `#! format: on` and write `atol = 1e-6` yourself. Hand-aligned numeric columns in tests are also protected with those markers.
- Every `.jl` file starts with a `## Description ###...` header filled to column 92 (plus `## References` with numbered entries for literature algorithms); section separators are `# == Title ===...` (level 2), `# -- Title ---...` (level 3), and `# .. Title ...` (level 4), all filled to column 92 counting indentation; private functions sit at the end of the file under a `Private Functions` box and start with `_`.
- Every function, macro, and struct has a docstring, including private ones: the first line is the signature indented four spaces, ending in `-> Type`, without `where` clauses; keywords go in `# Keywords` with `(**Default**: value)` on its own line; failures go in `## Throws` under `# Extended help`; units in brackets after every quantity (`[m]`, `[rad]`, `[Julian Day]`, `[-]`).
- Comments are complete English sentences ending in a period; only `TODO:`, `NOTE:`, `FIXME:`, and `HACK:` markers.
- Commits: one topic per commit, message `:<gitmoji>: Capitalized imperative summary` up to 50 characters (`:sparkles:` feature, `:bug:` fix, `:package:` refactor, `:books:` docs, `:art:` formatting, `:rotating_light:` tests, `:wrench:` general, `:lipstick:` cosmetic, `:racehorse:` performance), `::warning:` appended for breaking changes, optional body wrapped at 72 columns. Do not bump the version in `Project.toml`; the maintainer does it.
- Every user-visible change gets an entry in `CHANGELOG.md` under the current unreleased version, in its own `:books:` commit, using the badge references defined at the bottom of the file (order Breaking, Deprecation, Feature, Enhancement, Bugfix, Info; imperative sentence ending in a period; wrapped at 92 columns).

## Behavioral Constraints

- Units are SI: distances in meters, velocities in m/s, angles in radians, epochs in Julian Days (no time scale conversion is performed; the caller's scale is kept). Never change these conventions or the `GM_EARTH` default of the conversions.
- Numeric code is generic over the element type: use `float(promote_type(...))`, never hard-code `Float64`; `Float32` inputs must give `Float32` results (the tests check it). Autodiff scalars are `Number` but not `AbstractFloat`, so constrain on `Number`.
- The orbit hot paths (`kepler_to_rv`, `rv_to_kepler`, `kepler_to_sv`, `sv_to_kepler`, the anomaly solvers, and every `convert` between orbit representations) are allocation-free and type-stable; verify with `@allocated` and `Base.return_types` after touching them. `@inbounds`, `@inline`, and similar pragmas need a justifying comment.
- Conversions between different orbit representations are computed in `promote_type` of the input and target element types (see `_promote_element_type` in `src/orbit/conversions.jl`); identity conversions are left to `Base.convert(::Type{T}, ::T)`, so never define a `convert` that would be ambiguous with it (the Aqua ambiguity check in the test suite catches it).
- `KeplerianElements{Tanomaly, Tepoch, T}` stores one anomaly selected by `Tanomaly`; use `true_anomaly`, `eccentric_anomaly`, or `mean_anomaly` instead of reading `anomaly` when the type is not known. The property aliases `t`, `a`, `e`, `i`, `Ω`, `ω`, `f` (Keplerian) and `t` (state vector) are kept for backward compatibility and must keep working.
- `rv_to_kepler` keeps its absolute special-case thresholds (`1e-6` on the node vector norm and on the eccentricity); do not change them without a maintainer decision.
- Input validation uses guard clauses throwing `ArgumentError` (or `DimensionMismatch` for vector sizes) with complete sentences; no `error()` and no `@assert`.
- The `show` tests compare exact strings; changing any printed layout requires updating `test/orbit/*.jl` and the README examples, which are generated by running the code, not typed by hand.
- Match the existing test style: nested `@testset` blocks, reference values from the literature cited in the file header (Vallado examples), and `Float32` variants of every numeric test.

## Not Configured

- No Documenter build (`docs/` holds only the logo), no linter, no pre-commit hooks, and no format check in CI; do not invent them.

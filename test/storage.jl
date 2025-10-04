## Description #############################################################################
#
# Tests related to the storage types.
#
############################################################################################

@testset "Constructors" begin
    L = LowerTriangularStorage(3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float64
    @test eltype(L.data) == Float64
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3

    L = LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor}(3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float64
    @test eltype(L.data) == Float64
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3

    L = LowerTriangularStorage{SatelliteToolboxBase.RowMajor}(3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float64
    @test eltype(L.data) == Float64
    @test SatelliteToolboxBase._axes_to_index(L, 2, 2) == 3

    L = LowerTriangularStorage{Float32}(3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float32
    @test eltype(L.data) == Float32
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3

    L = LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float32}(3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float32
    @test eltype(L.data) == Float32
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3

    L = LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float32}(3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float32
    @test eltype(L.data) == Float32
    @test SatelliteToolboxBase._axes_to_index(L, 2, 2) == 3
end

@testset "Conversion" begin
    L = LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float32}(3)

    element = 1
    for (i, j) in eachindex(L)
        L[i, j] = element
        element += 1
    end

    M = convert(Matrix, L)

    expected = Float32[
        1 0 0
        2 3 0
        4 5 6
    ]

    @test eltype(M) == Float32
    @test M == expected

    M = convert(Matrix{Float64}, L)

    expected = Float64[
        1 0 0
        2 3 0
        4 5 6
    ]

    @test eltype(M) == Float64
    @test M == expected
end

@testset "Data Ordering" begin
    # == Column Major ======================================================================

    L = LowerTriangularStorage{Float64}(3)

    element = 1
    for j in 1:3, i in 1:3
        j > i && continue
        L[i, j] = element
        element += 1
    end

    for i in 1:6
        @test L.data[i] == i
    end

    L = LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float64}(3)

    element = 1
    for j in 1:3, i in 1:3
        j > i && continue
        L[i, j] = element
        element += 1
    end

    for i in 1:6
        @test L.data[i] == i
    end

    # == Row Major =========================================================================

    L = LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float64}(3)

    element = 1
    for (i, j) in eachindex(L)
        j > i && continue
        L[i, j] = element
        element += 1
    end

    for i in 1:6
        @test L.data[i] == i
    end
end

@testset "Initialization" begin
    L = zeros(LowerTriangularStorage, 3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float64
    @test eltype(L.data) == Float64
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3
    @test L.data == zeros(6)

    L = zeros(LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor}, 3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float64
    @test eltype(L.data) == Float64
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3
    @test L.data == zeros(6)

    L = zeros(LowerTriangularStorage{SatelliteToolboxBase.RowMajor}, 3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float64
    @test eltype(L.data) == Float64
    @test SatelliteToolboxBase._axes_to_index(L, 2, 2) == 3
    @test L.data == zeros(6)

    L = zeros(LowerTriangularStorage{Float32}, 3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float32
    @test eltype(L.data) == Float32
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3
    @test L.data == zeros(Float32, 6)

    L = zeros(LowerTriangularStorage{SatelliteToolboxBase.ColumnMajor, Float32}, 3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float32
    @test eltype(L.data) == Float32
    @test SatelliteToolboxBase._axes_to_index(L, 3, 1) == 3
    @test L.data == zeros(Float32, 6)

    L = zeros(LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float32}, 3)
    @test size(L) == (3, 3)
    @test length(L.data) == 6
    @test eltype(L) == Float32
    @test eltype(L.data) == Float32
    @test SatelliteToolboxBase._axes_to_index(L, 2, 2) == 3
    @test L.data == zeros(Float32, 6)
end

@testset "Printing" begin
    L = LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float64}(3)

    element = 1
    for (i, j) in eachindex(L)
        L[i, j] = element
        element += 1
    end

    result = sprint(show, MIME("text/plain"), L)

    expected = """
3×3 LowerTriangularStorage{SatelliteToolboxBase.RowMajor, Float64}:
 1.0    ×       ×
 2.0    3.0     ×
 4.0    5.0     6.0"""

    @test result == expected
end

## Description #############################################################################
#
# Tests related to the public helpers that print the rich and the compact representations.
#
############################################################################################

@testset "Show Helpers" verbose = true begin
    @testset "align_on_decimal" begin
        a, b, c = SatelliteToolboxBase.align_on_decimal("7130.98", "0.0001111", "12")

        # The decimal points must be at the same column, and strings without a decimal
        # point are treated as if the point were right after the last character.
        @test a == "7130.98"
        @test b == "   0.0001111"
        @test c == "  12"
    end

    @testset "append_unit" begin
        @test SatelliteToolboxBase.append_unit("7130.98", 10, "km") == "7130.98    km"
        @test SatelliteToolboxBase.append_unit("7130.98", 7, "km") == "7130.98 km"
    end

    @testset "compact_string" begin
        io = IOBuffer()
        @test SatelliteToolboxBase.compact_string(io, 1 / 3) == "0.333333"
        @test SatelliteToolboxBase.compact_string(
            IOContext(io, :compact => false), 1 / 3
        ) == "0.3333333333333333"
    end

    @testset "print_compact" begin
        str = sprint(SatelliteToolboxBase.print_compact, "MyOrbit", 2.4466e6)
        @test str == "MyOrbit: Epoch = 2.4466e6 (1986-06-18T12:00:00)"
    end

    @testset "print_elements" begin
        expected = """
MyType:
            Epoch :    2.4466e6 (1986-06-18T12:00:00)
  Semi-major axis : 7130.98      km
     Eccentricity :    0.0001111
             Name : SGP4"""

        str = sprint(
            SatelliteToolboxBase.print_elements,
            "MyType",
            2.4466e6,
            ("Semi-major axis", "Eccentricity", "Name"),
            ("7130.98", "0.0001111", "SGP4"),
            ("km", "", "");
        )
        @test str == expected

        # Without the decimal alignment, the values are printed as they are.
        expected = """
MyType:
  Epoch : 2.4466e6 (1986-06-18T12:00:00)
      A : 1.5  m
      B : 12.5 s"""

        str = sprint() do io
            SatelliteToolboxBase.print_elements(
                io,
                "MyType",
                2.4466e6,
                ("A", "B"),
                ("1.5", "12.5"),
                ("m", "s");
                align_decimal = false,
            )
        end
        @test str == expected

        # The labels must be highlighted when the output supports colors.
        str_color = sprint(
            SatelliteToolboxBase.print_elements,
            "MyType",
            2.4466e6,
            ("A",),
            ("1.5",),
            ("m",);
            context = :color => true,
        )
        @test occursin("\e[1m", str_color)
    end

    @testset "println_field and print_field" begin
        @test sprint(SatelliteToolboxBase.println_field, "Label : ", 1, " m") ==
            "Label : 1 m\n"
        @test sprint(SatelliteToolboxBase.print_field, "Label : ", 1, " m") == "Label : 1 m"

        str_color = sprint(
            SatelliteToolboxBase.print_field, "L : ", 1; context = :color => true
        )
        @test str_color == "\e[1mL : \e[22m1"
    end
end

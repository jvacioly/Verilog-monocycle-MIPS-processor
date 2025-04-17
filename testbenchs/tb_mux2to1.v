// ==================================================
// Testbench para o MUX 2:1
// ==================================================
`timescale 1ns / 1ps

module MUX2to1_tb;
    parameter WIDTH = 32;

    reg [WIDTH-1:0] in0;
    reg [WIDTH-1:0] in1;
    reg sel;

    wire [WIDTH-1:0] out;

    MUX2to1 #(WIDTH) uut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        // Initialize Inputs
        in0 = 32'hAAAAAAAA;
        in1 = 32'h55555555;
        sel = 0;

        #100;

        // Test case 1: sel = 0
        sel = 0;
        #10;
        $display("sel = %b, out = %h (expected: %h)", sel, out, in0);

        // Test case 2: sel = 1
        sel = 1;
        #10;
        $display("sel = %b, out = %h (expected: %h)", sel, out, in1);

        // Test case 3: Change inputs and test
        in0 = 32'h12345678;
        in1 = 32'h87654321;
        sel = 0;
        #10;
        $display("sel = %b, out = %h (expected: %h)", sel, out, in0);

        // Test case 4
        sel = 1;
        #10;
        $display("sel = %b, out = %h (expected: %h)", sel, out, in1);

        $finish;
    end

endmodule
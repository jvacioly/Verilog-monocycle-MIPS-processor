// ==================================================
// Testbench para o Sign Extender
// ==================================================
`timescale 1ns / 1ps

module SignExtend_tb;
    reg [15:0] in;

    wire [31:0] out;

    SignExtend uut (
        .in(in),
        .out(out)
    );

    initial begin
        in = 16'b0;

        #100;

        // Test case 1: Positive number
        in = 16'b0000000000001010; 
        #10;
        $display("Input: %b, Output: %b", in, out);
        $display("Expected Output: 00000000000000000000000000001010\n");

        // Test case 2: Negative number (two's complement)
        in = 16'b1111111111111010;
        #10;
        $display("Input: %b, Output: %b", in, out);
        $display("Expected Output: 11111111111111111111111111111010\n");

        // Test case 3: Largest positive number
        in = 16'b0111111111111111;
        #10;
        $display("Input: %b, Output: %b", in, out);
        $display("Expected Output: 00000000000000000111111111111111\n");

        // Test case 4: Largest negative number
        in = 16'b1000000000000000; 
        #10;
        $display("Input: %b, Output: %b", in, out);
        $display("Expected Output: 11111111111111111000000000000000\n");

        $finish;
    end
endmodule
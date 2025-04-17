// ==================================================
// Testbench para o Program Counter
// ==================================================
`timescale 1ns / 1ps

module ProgramCounter_tb;
    reg clk;
    reg reset;
    reg [31:0] nextPC;

    wire [31:0] currentPC;

    ProgramCounter uut (
        .clk(clk),
        .reset(reset),
        .nextPC(nextPC),
        .currentPC(currentPC)
    );

    initial begin
        clk = 0;
        reset = 0;
        nextPC = 0;

        #100;

        // Test case 1: Apply reset
        reset = 1;
        #10;
        $display("Reset applied, currentPC = %h (expected: 00000000)", currentPC);
        reset = 0;

        // Test case 2: Normal operation
        nextPC = 32'h00000004;
        #10; 
        $display("nextPC = %h, currentPC = %h (expected: %h)", nextPC, currentPC, nextPC);

        nextPC = 32'h00000008;
        #10; 
        $display("nextPC = %h, currentPC = %h (expected: %h)", nextPC, currentPC, nextPC);

        // Test case 3: Apply reset again
        reset = 1;
        #10;
        $display("Reset applied again, currentPC = %h (expected: 00000000)", currentPC);
        reset = 0;

        nextPC = 32'h00000010;
        #10;
        $display("nextPC = %h, currentPC = %h (expected: %h)", nextPC, currentPC, nextPC);

        $finish;
    end

    always #5 clk = ~clk;

endmodule










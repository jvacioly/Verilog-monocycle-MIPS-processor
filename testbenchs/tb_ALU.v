// ==================================================
// Testbench para a ALU
// ==================================================
`timescale 1ns / 1ps

module ALU_tb;
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALUControl;

    wire [31:0] Result;
    wire Zero;

    ALU uut (
        .A(A), 
        .B(B), 
        .ALUControl(ALUControl), 
        .Result(Result), 
        .Zero(Zero)
    );

    initial begin
        #100;
        
        // Test AND
        A = 32'hFFFF0000; B = 32'h0F0F0F0F; ALUControl = 4'b0000; #10;
        if (Result == (A & B)) $display("Test Successful for: AND\n");

        // Test OR
        A = 32'hFFFF0000; B = 32'h0F0F0F0F; ALUControl = 4'b0001; #10;
        if (Result == (A | B)) $display("Test Successful for: OR\n");

        // Test ADD
        A = 32'h00000001; B = 32'h00000001; ALUControl = 4'b0010; #10;
        if (Result == (A + B)) $display("Test Successful for: ADD\n");

        // Test SUB
        A = 32'h00000002; B = 32'h00000001; ALUControl = 4'b0110; #10;
        if (Result == (A - B)) $display("Test Successful for: SUB\n");

        // Test SLT
        A = 32'h00000001; B = 32'h00000002; ALUControl = 4'b0111; #10;
        if (Result == 1) $display("Test Successful for: SLT (A < B)\n");

        A = 32'h00000002; B = 32'h00000001; ALUControl = 4'b0111; #10;
        if (Result == 0) $display("Test Successful for: SLT (A >= B)\n");

        // Test NOR
        A = 32'hFFFF0000; B = 32'h0F0F0F0F; ALUControl = 4'b1100; #10;
        if (Result == ~(A | B)) $display("Test Successful for: NOR\n");

        // Test LUI
        B = 32'h00001234; ALUControl = 4'b0011; #10;
        if (Result == (B << 16)) $display("Test Successful for: LUI\n");

        // Test Zero flag
        A = 32'h00000001; B = 32'h00000001; ALUControl = 4'b0110; #10;
      if (Result == 1'b0) $display("Test Successful for: Zero flag (A - B = 0)\n");

        A = 32'h00000002; B = 32'h00000001; ALUControl = 4'b0110; #10;
      if (Result == 1'b1) $display("Test Successful for: Zero flag (A - B != 0)\n");

        $finish;
    end

    initial begin
      $monitor("\nTime = %0t, A = %h, B = %h, ALUControl = %b, Result = %h, Zero = %b", 
                 $time, A, B, ALUControl, Result, Zero);
    end
endmodule
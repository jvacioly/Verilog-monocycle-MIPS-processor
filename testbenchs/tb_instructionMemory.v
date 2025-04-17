// ==================================================
// Testbench para a Memória de Instruções
// ==================================================
`timescale 1ns / 1ps

module InstructionMemory_tb;
    reg [31:0] address;
    wire [31:0] instruction;

    InstructionMemory uut (
        .address(address),
        .instruction(instruction)
    );

    initial begin
        // Initialize Inputs
        address = 0;

        // Initialize instruction memory
        uut.memory[0] = 8'hDE;
        uut.memory[1] = 8'hAD;
        uut.memory[2] = 8'hBE;
        uut.memory[3] = 8'hEF;

        uut.memory[4] = 8'hCA;
        uut.memory[5] = 8'hFE;
        uut.memory[6] = 8'hBA;
        uut.memory[7] = 8'hBE;

        uut.memory[8] = 8'h12;
        uut.memory[9] = 8'h34;
        uut.memory[10] = 8'h56;
        uut.memory[11] = 8'h78;

        #100;

        address = 0;
        #20;
        $display("Instruction at address %d: %h", address, instruction);

        address = 4;
        #20;
        $display("Instruction at address %d: %h", address, instruction);

        address = 8;
        #20;
        $display("Instruction at address %d: %h", address, instruction);

        $finish;
    end

endmodule
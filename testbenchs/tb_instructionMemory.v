// ==================================================
// Testbench para a Memória de Instruções
// ==================================================
module tb_instruction_memory;
    reg [31:0] pc;
    wire [31:0] instruction;
    
    instruction_memory uut (pc, instruction);
    
    initial begin
        $display("\n=== [TESTBENCH] Memória de Instruções ===");
        
        pc = 0;
        #1 $display("Endereço 0x%08h: Instrução = 0x%08h (addi $t0, $zero, 1)", pc, instruction);
        
        pc = 4;
        #1 $display("Endereço 0x%08h: Instrução = 0x%08h (addi $t1, $t0, 2)", pc, instruction);
        
        $finish;
    end
endmodule
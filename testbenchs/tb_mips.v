`timescale 1ns/1ps

module tb_mips_integrado;
    reg clk, reset;
    mips uut (clk, reset);
    
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("mips_integrado.vcd");
        $dumpvars(0, tb_mips_integrado);
        
        $display("=== Teste de Integração do MIPS ===");
        clk = 0; reset = 1;
        #10 reset = 0;
        
        // Monitorar registradores e PC
        $monitor("Time = %0t: PC = 0x%08h | $t0 = %d", $time, uut.pc, uut.reg_file.registers[8]);
        
        // Executar por 100 ns
        #100 $finish;
    end
endmodule
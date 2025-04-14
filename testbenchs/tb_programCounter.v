// ==================================================
// Testbench para o Program Counter
// ==================================================
module tb_program_counter;
    reg clk, reset;
    wire [31:0] pc;
    
    program_counter uut (
        .clk(clk),
        .reset(reset),
        .pc_next(pc + 4),  // Próximo PC = PC atual + 4
        .pc(pc)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        $display("\n=== [TESTBENCH] Program Counter ===");
        clk = 0; reset = 1;
        #10 reset = 0;
        
        $display("Reset: PC = 0x%08h", pc);
        
        // Verifica 3 incrementos
        repeat (3) begin
            #10;
            $display("Clock %0d: PC = 0x%08h", ($time/10), pc);
        end
        
        $finish;
    end
endmodule










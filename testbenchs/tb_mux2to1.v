// ==================================================
// Testbench para o MUX 2:1
// ==================================================
module tb_mux2to1;
    reg [31:0] in0, in1;
    reg sel;
    wire [31:0] out;
    
    mux2to1 uut (in0, in1, sel, out);
    
    initial begin
        $display("\n=== [TESTBENCH] MUX 2:1 ===");
        
        in0 = 32'hAAAA_AAAA; in1 = 32'h5555_5555;
        
        sel = 0;
        #10 $display("Sel = %b: Entrada0 = 0x%08h -> Saída = 0x%08h", sel, in0, out);
        
        sel = 1;
        #10 $display("Sel = %b: Entrada1 = 0x%08h -> Saída = 0x%08h", sel, in1, out);
        
        $finish;
    end
endmodule

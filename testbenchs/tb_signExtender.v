// ==================================================
// Testbench para o Sign Extender
// ==================================================
module tb_sign_extender;
    reg [15:0] in;
    wire [31:0] out;
    
    sign_extender uut (in, out);
    
    initial begin
        $display("\n=== [TESTBENCH] Sign Extender ===");
        
        in = 16'h7FFF;  // Positivo
        #10 $display("Entrada: 0x%04h -> Saída: 0x%08h", in, out);
        
        in = 16'h8000;  // Negativo
        #10 $display("Entrada: 0x%04h -> Saída: 0x%08h", in, out);
        
        $finish;
    end
endmodule
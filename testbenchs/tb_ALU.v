// ==================================================
// Testbench para a ALU
// ==================================================
module tb_alu;
    reg [31:0] a, b;
    reg [2:0] alu_control;
    wire [31:0] result;
    wire zero;
    
    alu uut (a, b, alu_control, result, zero);
    
    initial begin
        $display("\n=== [TESTBENCH] ALU ===");
        
        // Teste AND
        a = 32'hFFFF_FFFF; b = 32'hFF00_FF00; alu_control = 3'b000;
        #10 $display("AND: 0x%08h & 0x%08h = 0x%08h (Zero = %b)", a, b, result, zero);
        
        // Teste OR
        a = 32'h0000_FFFF; b = 32'hFFFF_0000; alu_control = 3'b001;
        #10 $display("OR:  0x%08h | 0x%08h = 0x%08h (Zero = %b)", a, b, result, zero);
        
        // Teste ADD
        a = 32'd100; b = 32'd50; alu_control = 3'b010;
        #10 $display("ADD: %d + %d = %d (Zero = %b)", a, b, result, zero);
        
        // Teste SUB
        a = 32'd75; b = 32'd100; alu_control = 3'b110;
        #10 $display("SUB: %d - %d = %d (Zero = %b)", a, b, result, zero);
        
        // Teste SLT
        a = 32'd10; b = 32'd20; alu_control = 3'b111;
        #10 $display("SLT: %d < %d = %d (Zero = %b)", a, b, result, zero);
        
        $finish;
    end
endmodule
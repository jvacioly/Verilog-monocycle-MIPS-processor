// ==================================================
// Testbench para o Register File
// ==================================================
module tb_register_file;
    reg clk, we;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;
    
    register_file uut (clk, we, read_reg1, read_reg2, write_reg, write_data, read_data1, read_data2);
    
    always #5 clk = ~clk;
    
    initial begin
        $display("\n=== [TESTBENCH] Register File ===");
        clk = 0; we = 0;
        
        // Escrita no registrador 5
        we = 1; write_reg = 5; write_data = 32'hCAFE_BABE;
        #10 $display("Escrita: reg[5] = 0x%08h", write_data);
        
        // Leitura do registrador 5
        we = 0; read_reg1 = 5;
        #10 $display("Leitura: reg[5] = 0x%08h", read_data1);
        
        // Tentativa de escrita no registrador 0
        we = 1; write_reg = 0; write_data = 32'hDEAD_BEEF;
        #10 $display("Tentativa de escrita em reg[0]: reg[0] = 0x%08h", uut.registers[0]);
        
        $finish;
    end
endmodule
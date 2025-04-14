// ==================================================
// Testbench para a Memória de Dados
// ==================================================
module tb_data_memory;
    reg clk, mem_read, mem_write;
    reg [31:0] address, write_data;
    wire [31:0] read_data;
    
    data_memory uut (clk, address, write_data, mem_read, mem_write, read_data);
    
    always #5 clk = ~clk;
    
    initial begin
        $display("\n=== [TESTBENCH] Data Memory ===");
        clk = 0; mem_read = 0; mem_write = 0;
        
        // Escrita
        address = 32'h4; write_data = 32'h1234_5678; mem_write = 1;
        #10 $display("Escrita: [0x%08h] = 0x%08h", address, write_data);
        
        // Leitura
        mem_write = 0; mem_read = 1;
        #10 $display("Leitura: [0x%08h] = 0x%08h", address, read_data);
        
        $finish;
    end
endmodule
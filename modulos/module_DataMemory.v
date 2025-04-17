module data_memory (
    input wire clk,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire mem_read,
    input wire mem_write,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255]; // Data memory with 256 entries
  
    initial begin
      integer i;
      // Initialize all data memory to 0
      for (i = 0; i < 256; i = i + 1) begin
          memory[i] = 32'h00000000;
      end

      // Optionally, set specific memory locations for testing
      memory[0] = 32'hAABBCCDD; // Example data at Mem[0]
  end

    // Handle memory write
    always @(posedge clk) begin
        if (mem_write) memory[address[9:2]] <= write_data;
    end

    // Handle memory read
    always @(*) begin
        if (mem_read)
            read_data = memory[address[9:2]];
        else
            read_data = 32'd0;
    end
endmodule

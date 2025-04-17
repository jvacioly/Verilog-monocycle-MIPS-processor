module register_file (
    input wire clk,
    input wire we,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2,
    output wire [31:0] registers [0:31]
);

    reg [31:0] reg_file [31:0];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) reg_file[i] = 32'd0;
    end

    always @(posedge clk) begin
        if (we && (write_reg != 0)) reg_file[write_reg] <= write_data;
    end

    assign read_data1 = (read_reg1 == 0) ? 32'd0 : reg_file[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'd0 : reg_file[read_reg2];
    assign registers = reg_file; // Expose all registers
endmodule
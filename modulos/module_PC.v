module program_counter (
    input wire clk,
    input wire reset,
    input wire [31:0] pc_next,
    output reg [31:0] pc
);
    // Program Counter Update Logic
    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'd0; // Reset PC to 0
        else pc <= pc_next;     // Update PC with the next value
    end
endmodule
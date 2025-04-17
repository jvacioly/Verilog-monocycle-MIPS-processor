module ALU_Control (
  input [1:0] alu_op,
  input [5:0] opcode,
  input [5:0] funct,
  output reg [3:0] alu_ctrl
);

always @(*) begin
  case (alu_op)
    2'b00: alu_ctrl = 4'b0010; // ADD (/lw/sw)
    2'b01: alu_ctrl = 4'b0110; // SUB (beq/bne)
    2'b10: begin // Tipo R
      case (funct)
        6'b100000: alu_ctrl = 4'b0010; // ADD
        6'b100010: alu_ctrl = 4'b0110; // SUB
        6'b100100: alu_ctrl = 4'b0000; // AND
        6'b100101: alu_ctrl = 4'b0001; // OR
        6'b100110: alu_ctrl = 4'b0011; // XOR
        6'b100111: alu_ctrl = 4'b1100; // NOR
        6'b101010: alu_ctrl = 4'b0111; // SLT
        default:   alu_ctrl = 4'b0010; // ADD padrão
      endcase
    end
    2'b11: begin // Tipo I com Zero-Extend
      case (opcode)
        6'b001000: alu_ctrl = 4'b0010; //addi
        6'b001010: alu_ctrl = 4'b0111; //slti
        6'b001100: alu_ctrl = 4'b0000; //andi
        6'b001101: alu_ctrl = 4'b0001; //ori
        6'b001110: alu_ctrl = 4'b0011; //xori
        default: alu_ctrl = 4'b0010; // ADD para casos não especificados
      endcase
    end
    default: alu_ctrl = 4'b0010; // Fallback
  endcase
end

endmodule

module ALU (
  input [31:0] A, B,
  input [3:0] alu_ctrl,
  output reg [31:0] alu_result,
  output zero_flag
);

assign zero_flag = (alu_result == 32'd0); // Flag Zero

always @(*) begin
  case (alu_ctrl)
    4'b0000: alu_result = A & B; // AND
    4'b0001: alu_result = A | B; // OR
    4'b0010: alu_result = A + B; // ADD
    4'b0011: alu_result = A ^ B; // XOR
    4'b0110: alu_result = A - B; // SUB
    4'b0111: alu_result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
    4'b1100: alu_result = ~(A | B); // NOR
    default: alu_result = 32'd0; // Default
  endcase
end

endmodule

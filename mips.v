// ==================================================
// Program Counter (PC)
// ==================================================
`timescale 1ns / 1ps // escala de tempo de 1 ns com precisão de 1 pico segundo
module program_counter (
    input wire clk,
    input wire reset,
    input wire [31:0] pc_next,
    output reg [31:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'd0;
        else pc <= pc_next;
    end
endmodule

// ==================================================
// Memória de Instrução (ROM)
// ==================================================
module instruction_memory (
    input wire [31:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:15];
    
    initial begin
        memory[0]  = 32'h20080001; // addi $t0, $zero, 1
        memory[1]  = 32'h21090002; // addi $t1, $t0, 2
        memory[2]  = 32'h012A4020; // add  $t0, $t1, $t2
        memory[3]  = 32'h00000000; // nop
        memory[4]  = 32'h8C0B0000; // lw   $t3, 0($zero)
        memory[5]  = 32'hAC0C0000; // sw   $t4, 0($zero)
        memory[6]  = 32'h08000008; // j    0x20 (endereço 8 << 2)
        memory[7]  = 32'h00000000; // nop
        memory[8]  = 32'h340A00FF; // ori  $t2, $zero, 0xFF
        memory[9]  = 32'h00000000; // nop
        memory[10] = 32'h00000000; // nop
        memory[11] = 32'h00000000; // nop
        memory[12] = 32'h00000000; // nop
        memory[13] = 32'h00000000; // nop
        memory[14] = 32'h00000000; // nop
        memory[15] = 32'h00000000; // nop
    end
    assign instruction = memory[pc[5:2]]; //memoria de leitura apenas (ROM)
endmodule

// ==================================================
// Memória de Dados
// ==================================================
module data_memory (
    input wire clk,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire mem_read,
    input wire mem_write,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255];
    
    always @(posedge clk) begin
        if (mem_write) memory[address[9:2]] <= write_data;
    end
    
    always @(*) begin
        read_data = (mem_read) ? memory[address[9:2]] : 32'd0;
    end
endmodule

// ==================================================
// Mux 2:1 com Parâmetro de Largura
// ==================================================
module mux2to1 #(
    parameter WIDTH = 32
)(
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire sel,
    output wire [WIDTH-1:0] out
);
    assign out = sel ? in1 : in0;
endmodule

// ==================================================
// Extensor de Sinal
// ==================================================
module sign_extender (
    input  wire [15:0] in,
    output wire [31:0] out
);
    assign out = {{16{in[15]}}, in};
endmodule

// ==================================================
// Unidade de Controle Principal (Atualizada para ori)
// ==================================================
module control_unit (
    input wire [5:0] opcode,
    output reg reg_dst,
    output reg alu_src,
    output reg mem_to_reg,
    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg branch,
    output reg [1:0] alu_op,
    output reg jump
);
    always @(*) begin
        reg_dst = 0; alu_src = 0; mem_to_reg = 0; reg_write = 0;
        mem_read = 0; mem_write = 0; branch = 0; alu_op = 2'b00; jump = 0;

        case (opcode)
            6'b000000: begin // R-type
                reg_dst = 1; reg_write = 1; alu_op = 2'b10;
            end
            6'b100011: begin // lw
                alu_src = 1; mem_to_reg = 1; reg_write = 1; mem_read = 1;
            end
            6'b101011: begin // sw
                alu_src = 1; mem_write = 1;
            end
            6'b000100: begin // beq
                branch = 1; alu_op = 2'b01;
            end
            6'b001000: begin // addi
                alu_src = 1; reg_write = 1;
            end
            6'b001101: begin // ori
                alu_src = 1; reg_write = 1; alu_op = 2'b00;
            end
            6'b000010: begin // j
                jump = 1;
            end
        endcase
    end
endmodule

// ==================================================
// Unidade de Controle da ALU (Atualizada para OR)
// ==================================================
module alu_control (
    input wire [1:0] alu_op,
    input wire [5:0] funct,
    output reg [2:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 3'b001; // OR (para ori)
            2'b01: alu_ctrl = 3'b110; // SUB (beq)
            2'b10: begin // R-type
                case (funct)
                    6'b100000: alu_ctrl = 3'b010; // ADD
                    6'b100010: alu_ctrl = 3'b110; // SUB
                    6'b100100: alu_ctrl = 3'b000; // AND
                    6'b100101: alu_ctrl = 3'b001; // OR
                    6'b101010: alu_ctrl = 3'b111; // SLT
                    default:   alu_ctrl = 3'b010;
                endcase
            end
            default: alu_ctrl = 3'b010;
        endcase
    end
endmodule

// ==================================================
// ALU com Operação OR
// ==================================================
module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] alu_control,
    output reg [31:0] result,
    output reg zero
);
    always @(*) begin
        case (alu_control)
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b010: result = a + b;
            3'b110: result = a - b;
            3'b111: result = (a < b) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
        zero = (result == 32'd0);
    end
endmodule

// ==================================================
// Banco de Registradores (Registrador $zero fixo)
// ==================================================
module register_file (
    input wire clk,
    input wire we,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] registers [31:0];
    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) registers[i] = 32'd0;
    end

    always @(posedge clk) begin
        if (we && (write_reg != 0)) registers[write_reg] <= write_data;
    end

    assign read_data1 = (read_reg1 == 0) ? 32'd0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 32'd0 : registers[read_reg2];
endmodule

// ==================================================
// Módulo Top-Level (MIPS Completo)
// ==================================================
module mips (
    input wire clk,
    input wire reset
);
    wire [31:0] pc, instruction, read_data1, read_data2;
    wire [4:0] write_reg;
    wire [31:0] write_data, alu_result, sign_extended;
    wire alu_zero, reg_dst, alu_src, mem_to_reg, reg_write;
    wire mem_read, mem_write, branch, jump;
    wire [1:0] alu_op;
    wire [2:0] alu_ctrl;
    wire [31:0] alu_operand2, mem_read_data;

    // Cálculo do próximo PC
    wire [31:0] pc_plus_4 = pc + 32'd4;
    wire [31:0] branch_target = pc_plus_4 + (sign_extended << 2);
    wire [31:0] jump_target = {pc_plus_4[31:28], instruction[25:0] << 2};
    wire branch_taken = branch & alu_zero;
    wire [31:0] pc_branch, pc_next;

    // Instanciações
    program_counter pc_module (clk, reset, pc_next, pc);
    instruction_memory imem (pc, instruction);
    control_unit ctrl (instruction[31:26], reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, alu_op, jump);
    alu_control alu_ctrl_unit (alu_op, instruction[5:0], alu_ctrl);
    register_file reg_file (clk, reg_write, instruction[25:21], instruction[20:16], write_reg, write_data, read_data1, read_data2);
    
    mux2to1 #(5) mux_reg_dst (instruction[20:16], instruction[15:11], reg_dst, write_reg);
    sign_extender sign_ext (instruction[15:0], sign_extended);
    mux2to1 mux_alu_src (read_data2, sign_extended, alu_src, alu_operand2);
    alu alu_unit (read_data1, alu_operand2, alu_ctrl, alu_result, alu_zero);
    data_memory dmem (clk, alu_result, read_data2, mem_read, mem_write, mem_read_data);
    mux2to1 mux_mem_to_reg (alu_result, mem_read_data, mem_to_reg, write_data);
    mux2to1 mux_branch (pc_plus_4, branch_target, branch_taken, pc_branch);
    mux2to1 mux_jump (pc_branch, jump_target, jump, pc_next);
endmodule

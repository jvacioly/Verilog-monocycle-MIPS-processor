// ==================================================
// Program Counter (PC)
// ==================================================
`timescale 1ns / 1ps // Time scale of 1 ns with precision of 1 ps
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

// ==================================================
// Instruction Memory (ROM)
// ==================================================
module instruction_memory (
    input wire [31:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:15];
    
    initial begin
    memory[0]  = 32'h20080001; // addi $t0, $zero, 1      ; $t0 = 1
    memory[1]  = 32'h21090002; // addi $t1, $t0, 2        ; $t1 = $t0 + 2 = 3
    memory[2]  = 32'h012A4020; // add  $t0, $t1, $t2      ; $t0 = $t1 + $t2
    memory[3]  = 32'hAC080004; // sw   $t0, 4($zero)      ; Store $t0 into memory[1]
    memory[4]  = 32'h8C0B0004; // lw   $t3, 4($zero)      ; Load memory[1] into $t3
    memory[5]  = 32'hAC090008; // sw   $t1, 8($zero)      ; Store $t1 into memory[2]
    memory[6]  = 32'h8C0C0008; // lw   $t4, 8($zero)      ; Load memory[2] into $t4
    memory[7]  = 32'h08000010; // j    0x40               ; Jump to address 0x40 (infinite loop)
    memory[8]  = 32'h340A00FF; // ori  $t2, $zero, 0xFF   ; $t2 = 0xFF (not executed due to jump)
    memory[9]  = 32'h00000000; // nop                     ; Extra no-op for alignment
    memory[10] = 32'h00000000; // nop                     ; Extra no-op for alignment
    memory[11] = 32'h00000000; // nop                     ; Extra no-op for alignment
    memory[12] = 32'h00000000; // nop                     ; Extra no-op for alignment
memory[15] = 32'h0800000F; // j    0xF                ; Infinite loop
    end
    
    assign instruction = memory[pc[5:2]]; // memoria de leitura (rom)
    
endmodule

// ==================================================
// Data Memory
// ==================================================
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

// ==================================================
// 2-to-1 Multiplexer with Parameterized Width
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
// Sign Extender
// ==================================================
module sign_extender (
    input wire [15:0] in,
    output wire [31:0] out
);
    assign out = {{16{in[15]}}, in};
endmodule

// ==================================================
// Control Unit
// ==================================================
module control_unit (
    input wire [5:0] opcode, // Opcode from the instruction
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
        // Default values for all control signals (NOP behavior)
        reg_dst    = 0;
        alu_src    = 0;
        mem_to_reg = 0;
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        branch     = 0;
        alu_op     = 2'b00;
        jump       = 0;

        case (opcode)
            6'b000000: begin // R-type
                reg_dst    = 1;
                reg_write  = 1;
                alu_op     = 2'b10;
            end
            6'b100011: begin // lw
                alu_src    = 1;
                mem_to_reg = 1;
                reg_write  = 1;
                mem_read   = 1;
            end
            6'b101011: begin // sw
                alu_src    = 1;
                mem_write  = 1;
            end
            6'b000100: begin // beq
                branch     = 1;
                alu_op     = 2'b01;
            end
            6'b001000: begin // addi
                alu_src    = 1;
                reg_write  = 1;
            end
            6'b001101: begin // ori
                alu_src    = 1;
                reg_write  = 1;
                alu_op     = 2'b00;
            end
            6'b000010: begin // j
                jump       = 1;
            end
            default: begin
                // Default NOP behavior
            end
        endcase
    end
endmodule

// ==================================================
// ALU Control Unit
// ==================================================
module alu_control (
    input wire [1:0] alu_op,
    input wire [5:0] funct,
    output reg [2:0] alu_ctrl
);

    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 3'b001; // OR
            2'b01: alu_ctrl = 3'b110; // SUB
            2'b10: begin // R-type
                case (funct)
                    6'b100000: alu_ctrl = 3'b010; // ADD
                    6'b100010: alu_ctrl = 3'b110; // SUB
                    6'b100100: alu_ctrl = 3'b000; // AND
                    6'b100101: alu_ctrl = 3'b001; // OR
                    6'b101010: alu_ctrl = 3'b111; // SLT
                    default:   alu_ctrl = 3'b010; // Default ADD
                endcase
            end
            default: alu_ctrl = 3'b010; // Default ADD
        endcase
    end
endmodule

// ==================================================
// Arithmetic Logic Unit (ALU)
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
// Register File
// ==================================================
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

// ==================================================
// Top-Level MIPS Module
// ==================================================
module mips (
    input wire clk,
    input wire reset,
    output wire [31:0] pc,
    output wire reg_write,
    output wire alu_src,
  	output wire [31:0] registers [0:31]
);

    // Internal signals
    wire [31:0] instruction, read_data1, read_data2;
    wire [4:0] write_reg;
    wire [31:0] write_data, alu_result, sign_extended;
    wire alu_zero, reg_dst, mem_to_reg;
    wire mem_read, mem_write, branch, jump;
    wire [1:0] alu_op;
    wire [2:0] alu_ctrl;
    wire [31:0] alu_operand2, mem_read_data;

    wire [31:0] pc_plus_4 = pc + 32'd4;
    wire [31:0] branch_target = pc_plus_4 + (sign_extended << 2);
    wire [31:0] jump_target = {pc_plus_4[31:28], instruction[25:0] << 2};
    wire branch_taken = branch & alu_zero;
    wire [31:0] pc_branch, pc_next;

    // Module Instantiations
    program_counter pc_module (clk, reset, pc_next, pc);
    instruction_memory imem (pc, instruction);
    control_unit ctrl (instruction[31:26], reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, alu_op, jump);
    alu_control alu_ctrl_unit (alu_op, instruction[5:0], alu_ctrl);
    register_file reg_file (
        .clk(clk),
        .we(reg_write),
        .read_reg1(instruction[25:21]),
        .read_reg2(instruction[20:16]),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .registers(registers)
    );
    
    mux2to1 #(5) mux_reg_dst (instruction[20:16], instruction[15:11], reg_dst, write_reg);
    sign_extender sign_ext (instruction[15:0], sign_extended);
    mux2to1 mux_alu_src (read_data2, sign_extended, alu_src, alu_operand2);
    alu alu_unit (read_data1, alu_operand2, alu_ctrl, alu_result, alu_zero);
    data_memory dmem (clk, alu_result, read_data2, mem_read, mem_write, mem_read_data);
    mux2to1 mux_mem_to_reg (alu_result, mem_read_data, mem_to_reg, write_data);
    mux2to1 mux_branch (pc_plus_4, branch_target, branch_taken, pc_branch);
    mux2to1 mux_jump (pc_branch, jump_target, jump, pc_next);
endmodule

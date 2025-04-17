`timescale 1ns / 1ps

// ==================================================
// ALU Control
// ==================================================
module ALU_Control (
    input  wire [1:0] alu_op,
    input  wire [5:0] opcode,
    input  wire [5:0] funct,
    output reg  [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // ADD (lw/sw)
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
                    default:   alu_ctrl = 4'b0010; // Default = ADD
                endcase
            end
            2'b11: begin // Tipo I
                case (opcode)
                    6'b001000: alu_ctrl = 4'b0010; // addi (treated as ADD)
                    6'b001010: alu_ctrl = 4'b0111; // slti
                    6'b001100: alu_ctrl = 4'b0000; // andi
                    6'b001101: alu_ctrl = 4'b0001; // ori
                    6'b001110: alu_ctrl = 4'b0011; // xori
                    default:    alu_ctrl = 4'b0010; // Default = ADD
                endcase
            end
            default: alu_ctrl = 4'b0010; //Fallback
        endcase
    end
endmodule

// ==================================================
// ALU
// ==================================================
module ALU (
    input  wire [31:0] A, // Primeira Entrada
    input  wire [31:0] B, // Segunda Entrada
    input  wire [3:0]  alu_ctrl, // Controle da Operação Lógica/Aritmética
    output reg  [31:0] alu_result, // Resultado da ALU
    output wire        zero_flag // Booleano do Caso Zero
);
    assign zero_flag = (alu_result == 32'd0); // Checagem contínua do caso zero
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

// ==================================================
// Program Counter
// ==================================================
module program_counter (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);
    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'd0;
        else       pc <= pc_next;
    end
endmodule

// ==================================================
// Instruction Memory (ROM)
// ==================================================
module instruction_memory (
    input  wire [31:0] pc,
    output wire [31:0] instruction
);
    // Memória para armazenar 16 instruções (ou mais)
    reg [31:0] memory [0:15];
    integer i;

    initial begin
        // Inicializa memória com NOPs
        for (i = 0; i < 16; i = i + 1) begin
            memory[i] = 32'h00000000; // NOP
        end

        // Carrega o novo programa
        memory[0] = 32'h20080002; // 0x00: addi $t0, $zero, 2
        memory[1] = 32'h200A0001; // 0x04: addi $t2, $zero, 1
        memory[2] = 32'h010A4822; // 0x08: sub  $t1, $t0, $t2
        memory[3] = 32'hAC090004; // 0x0C: sw   $t1, 4($zero)
        memory[4] = 32'h8C0B0004; // 0x10: lw   $t3, 4($zero)
        memory[5] = 32'h11680001; // 0x14: beq  $t3, $t0, +1 (Target: 0x1C)
        memory[6] = 32'h08000008; // 0x18: j    skip_move (Target: 0x20)
        memory[7] = 32'h01601820; // 0x1C: add  $3, $t3, $zero (do_move label)
        memory[8] = 32'h08000008; // 0x20: j    skip_move (skip_move label / halt)
        // Posições 9 a 15 contêm NOPs
    end

    assign instruction = memory[pc[5:2]];

endmodule

// ==================================================
// Data Memory
// ==================================================
module data_memory (
    input  wire        clk,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    input  wire        mem_read,
    input  wire        mem_write,
    output reg  [31:0] read_data
);
    reg [31:0] memory [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'd0;
    end
    always @(posedge clk) begin
        if (mem_write) memory[address[9:2]] <= write_data;
    end
    always @(*) begin
        if (mem_read) read_data = memory[address[9:2]];
        else          read_data = 32'd0;
    end
endmodule

// ==================================================
// 2-to-1 Mux (parametrizado)
// ==================================================
module mux2to1 #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire             sel,
    output wire [WIDTH-1:0] out
);
    assign out = sel ? in1 : in0;
endmodule

// ==================================================
// Sign Extender
// ==================================================
module sign_extender (
    input  wire [15:0] in,
    output wire [31:0] out
);
    assign out = {{16{in[15]}}, in};
endmodule

// ==================================================
// Register File
// ==================================================
module register_file (
    input  wire        clk,
    input  wire        we,
    input  wire [4:0]  read_reg1,
    input  wire [4:0]  read_reg2,
    input  wire [4:0]  write_reg,
    input  wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] rf [0:31];
    integer i;
    initial for (i=0; i<32; i=i+1) rf[i]=32'd0;
    always @(posedge clk) begin
        if (we && write_reg != 0)
            rf[write_reg] <= write_data;
    end
    assign read_data1 = (read_reg1==0) ? 32'd0 : rf[read_reg1];
    assign read_data2 = (read_reg2==0) ? 32'd0 : rf[read_reg2];
endmodule

// ==================================================
// Control Unit (updated for ALU_Control)
// ==================================================
module control_unit (
    input  wire [5:0] opcode,
    output reg        reg_dst,
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg [1:0]  alu_op,
    output reg        jump
);
    always @(*) begin
        // defaults = NOP
        reg_dst    = 0;
        alu_src    = 0;
        mem_to_reg = 0;
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        branch     = 0;
        jump       = 0;
        alu_op     = 2'b00;
        case (opcode)
            6'b000000: begin          // R-type
                reg_dst   = 1;
                reg_write = 1;
                alu_op    = 2'b10;
            end
            6'b100011: begin          // lw
                alu_src    = 1;
                mem_to_reg = 1;
                reg_write  = 1;
                mem_read   = 1;
                alu_op     = 2'b00;
            end
            6'b101011: begin          // sw
                alu_src   = 1;
                mem_write = 1;
                alu_op    = 2'b00;
            end
            6'b000100: begin          // beq
                branch  = 1;
                alu_op  = 2'b01;
            end
            6'b001000: begin          // addi
                alu_src   = 1;
                reg_write = 1;
                alu_op    = 2'b00;
            end
            6'b001101: begin          // ori
                alu_src   = 1;
                reg_write = 1;
                alu_op    = 2'b11;
            end
            6'b000010: begin          // j
                jump = 1;
            end
        endcase
    end
endmodule

// ==================================================
// Top-Level MIPS
// ==================================================
module mips (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc,
    output wire        reg_write,
    output wire        alu_src
);
    wire [31:0] inst, rd1, rd2, wd, alu_res, sext, dm_rd;
    wire [4:0]  wr_reg;
    wire        zf, rd, wr, br, jp, mtoreg;
    wire [1:0]  aop;
    wire [3:0]  actrl;
    wire [31:0] alu_b, pc4, br_tgt, j_tgt, pcb, pcn;
  	wire reg_dst;

    assign pc4   = pc + 4;
    assign br_tgt= pc4 + (sext << 2);
    assign j_tgt = {pc4[31:28], inst[25:0],2'b00};
    assign pcb   = br & zf ? br_tgt : pc4;
    assign pcn   = jp         ? j_tgt  : pcb;

    program_counter    PC   (.clk(clk),.reset(reset),.pc_next(pcn),.pc(pc));
    instruction_memory IM   (.pc(pc),.instruction(inst));
    control_unit       CU   (.opcode(inst[31:26]),
                             .reg_dst(reg_dst),.alu_src(alu_src),
                             .mem_to_reg(mtoreg),.reg_write(reg_write),
                             .mem_read(rd),.mem_write(wr),
                             .branch(br),.alu_op(aop),.jump(jp));
    ALU_Control        AC   (.alu_op(aop),.opcode(inst[31:26]),.funct(inst[5:0]),.alu_ctrl(actrl));
    register_file      RF   (.clk(clk),.we(reg_write),
                             .read_reg1(inst[25:21]),.read_reg2(inst[20:16]),
                             .write_reg(wr_reg),.write_data(wd),
                             .read_data1(rd1),.read_data2(rd2));
    mux2to1 #(.WIDTH(5)) M1(.in0(inst[20:16]),.in1(inst[15:11]),.sel(reg_dst),.out(wr_reg));
    sign_extender      SE   (.in(inst[15:0]),.out(sext));
    mux2to1           M2    (.in0(rd2),.in1(sext),.sel(alu_src),.out(alu_b));
    ALU               ALU0  (.A(rd1),.B(alu_b),.alu_ctrl(actrl),.alu_result(alu_res),.zero_flag(zf));
    data_memory       DM    (.clk(clk),.address(alu_res),.write_data(rd2),.mem_read(rd),.mem_write(wr),.read_data(dm_rd));
    mux2to1           M3    (.in0(alu_res),.in1(dm_rd),.sel(mtoreg),.out(wd));
endmodule

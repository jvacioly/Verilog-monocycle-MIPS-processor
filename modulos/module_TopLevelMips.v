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
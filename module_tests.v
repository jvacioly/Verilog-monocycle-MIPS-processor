`timescale 1ns/1ps

module tb_mips;
    // Sinais para o PC e Memória de Instrução
    reg clk;
    reg reset;
    wire [31:0] pc;
    wire [31:0] instruction;
    
    // Sinais para a ALU
    reg [31:0] alu_a, alu_b;
    reg [2:0] alu_control;
    wire [31:0] alu_result;
    wire alu_zero;
    
    // Sinais para o MUX 2:1
    reg [31:0] mux_in0, mux_in1;
    reg mux_sel;
    wire [31:0] mux_out;
    
    // Sinais para o Sign Extender
    reg [15:0] se_in;
    wire [31:0] se_out;
    
    // Sinais para o MUX 4:1
    reg [31:0] mux4_in0, mux4_in1, mux4_in2, mux4_in3;
    reg [1:0] mux4_sel;
    wire [31:0] mux4_out;
    
    // Instancia dos módulos já implementados:
    program_counter uut_pc (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );
    
    instruction_memory uut_mem (
        .pc(pc),
        .instruction(instruction)
    );
    
    alu uut_alu (
        .a(alu_a),
        .b(alu_b),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );
    
    mux2to1 uut_mux (
        .in0(mux_in0),
        .in1(mux_in1),
        .sel(mux_sel),
        .out(mux_out)
    );
    
    sign_extender uut_se (
        .in(se_in),
        .out(se_out)
    );
    
    mux4to1 uut_mux4 (
        .in0(mux4_in0),
        .in1(mux4_in1),
        .in2(mux4_in2),
        .in3(mux4_in3),
        .sel(mux4_sel),
        .out(mux4_out)
    );
    
    // Geração do clock (período de 10 ns)
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("mips_test.vcd");
        $dumpvars(0, tb_mips);
        
        // ==================================================
        // Teste do PC e Memória de Instrução
        // ==================================================
        $display("===== Teste do PC e Memória de Instrução =====");
        clk = 0;
        reset = 1;
        #10;
        reset = 0;  // Desativa reset após 10 ns
        
        repeat (10) begin
            #10;
            $display("PC = 0x%08h, Instruction = 0x%08h", pc, instruction);
        end
        
        // ==================================================
        // Teste da ALU
        // ==================================================
        $display("\n===== Teste da ALU =====");
        alu_a = 32'd10;
        alu_b = 32'd5;
        
        // Operação AND
        alu_control = 3'b000;
        #10;
        
        // Operação OR
        alu_control = 3'b001;
        #10;
        
        // Operação de Soma (ADD)
        alu_control = 3'b010;
        #10;
        
        // Operação de Subtração (SUB)
        alu_control = 3'b110;
        #10;
        
        // Operação SLT (Set Less Than)
        alu_control = 3'b111;
        #10;
        
        // ==================================================
        // Teste do MUX 2:1
        // ==================================================
        $display("\n===== Teste do MUX 2:1 =====");
        mux_in0 = 32'hAAAAAAAA;
        mux_in1 = 32'h55555555;
        
        mux_sel = 0;
        #10;
        $display("MUX 2:1 - Sel = %b, Output = 0x%08h", mux_sel, mux_out);
        
        mux_sel = 1;
        #10;
        $display("MUX 2:1 - Sel = %b, Output = 0x%08h", mux_sel, mux_out);

        // ==================================================
        // Teste do MUX 4:1
        // ==================================================
        $display("\n===== Teste do MUX 4:1 =====");
        mux4_in0 = 32'h11111111;
        mux4_in1 = 32'h22222222;
        mux4_in2 = 32'h33333333;
        mux4_in3 = 32'h44444444;
        
        mux4_sel = 2'b00;
        #10;
        $display("MUX 4:1 - Sel = %b, Output = 0x%08h", mux4_sel, mux4_out);
        
        mux4_sel = 2'b01;
        #10;
        $display("MUX 4:1 - Sel = %b, Output = 0x%08h", mux4_sel, mux4_out);
        
        mux4_sel = 2'b10;
        #10;
        $display("MUX 4:1 - Sel = %b, Output = 0x%08h", mux4_sel, mux4_out);
        
        mux4_sel = 2'b11;
        #10;
        $display("MUX 4:1 - Sel = %b, Output = 0x%08h", mux4_sel, mux4_out);

        // ==================================================
        // Teste do Sign Extender
        // ==================================================
        $display("\n===== Teste do Sign Extender =====");
        // Teste com número positivo (bit de sinal = 0)
        se_in = 16'h1234;
        #10;
        $display("Sign Extender - Entrada: 0x%04h, Saída: 0x%08h", se_in, se_out);
        
        // Teste com número negativo (bit de sinal = 1)
        se_in = 16'hF234;
        #10;
        $display("Sign Extender - Entrada: 0x%04h, Saída: 0x%08h", se_in, se_out);
        
        
        $finish;
    end
endmodule

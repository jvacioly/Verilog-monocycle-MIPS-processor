//Definir unidade de clock
// ==================================================
// Program Counter (PC)
// ==================================================
module program_counter (
    input wire clk, // Clock
    input wire reset, // Reset
    output reg [31:0] pc // Registrador do PC
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'd0; // Se resetado, PC volta a 0
        else
            pc <= pc + 32'd4; // Incremento de 4 a cada ciclo
    end
endmodule
// ==================================================

// ==================================================
// Memória de Instrução (ROM)
// ==================================================
module instruction_memory (
    input wire [31:0] pc, // Endereço da instrução
    output reg [31:0] instruction // Instrução correspondente
);
    reg [31:0] memory [0:15]; // Memória de 16 instruções 
    
    initial begin
        // Carregando algumas instruções
        memory[0]  = 32'h20080001; // addi $t0, $zero, 1
        memory[1]  = 32'h21090002; // addi $t1, $t0, 2
        memory[2]  = 32'h012A4020; // add  $t0, $t1, $t2
        memory[3]  = 32'h00000000; // nop
        memory[4]  = 32'h8C0B0000; // lw   $t3, 0($zero)
        memory[5]  = 32'hAC0C0000; // sw   $t4, 0($zero)
        memory[6]  = 32'h08000002; // j    0x8
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
    
    always @(*) begin
        instruction = memory[pc[5:2]]; // Endereçamento alinhado de 4 em 4 bytes
    end
endmodule
// ==================================================

// ==================================================
// ALU
// ==================================================
module alu (
    input wire [31:0] a, // Operando A
    input wire [31:0] b, // Operando B
    input wire [2:0] alu_control, // Código da operação
    output reg [31:0] result, // Resultado da operação
    output reg zero // Flag que indica se o resultado é zero
);
    always @(*) begin
        case (alu_control)
            3'b000: begin
                result = a & b; // Operação AND
                $display("AND: %d & %d = %d", a, b, result);
            end
            3'b001: begin
                result = a | b; // Operação OR
                $display("OR: %d | %d = %d", a, b, result);
            end
            3'b010: begin
                result = a + b; // Soma
                $display("SOMA: %d + %d = %d", a, b, result);
            end
            3'b110: begin
                result = a - b; // Subtração
                $display("SUBTRAÇÃO: %d - %d = %d", a, b, result);
            end
            3'b111: begin
                result = (a < b) ? 32'd1 : 32'd0; // Menor que (SLT - Set Less Than)
                $display("SLT: %d < %d = %d", a, b, result);
            end
            default: begin
                result = 32'd0; // Caso padrão (NOP)
                $display("NOP");
            end
        endcase
        
        // Define a flag zero
        if (result == 32'd0)
            zero = 1;
        else
            zero = 0;
    end
endmodule
// ==================================================

// ==================================================
// Mux 2:1
// ==================================================
module mux2to1(
    input wire [31:0] in0,  // Primeira entrada de 32 bits
    input wire [31:0] in1,  // Segunda entrada de 32 bits
    input wire sel,         // Sinal de seleção (1 bit)
    output wire [31:0] out  // Saída de 32 bits
);
    // Se 'sel' for 1, 'out' recebe 'in1'; caso contrário, recebe 'in0'
    assign out = sel ? in1 : in0;
endmodule
// ==================================================

// ==================================================
// Mux 4:1
// ==================================================
module mux4to1 #(
    parameter WIDTH = 32       // Largura dos dados (32 bits por padrão)
)(
    input  wire [WIDTH-1:0] in0,  // Primeira entrada
    input  wire [WIDTH-1:0] in1,  // Segunda entrada
    input  wire [WIDTH-1:0] in2,  // Terceira entrada
    input  wire [WIDTH-1:0] in3,  // Quarta entrada
    input  wire [1:0] sel,        // Sinal de seleção (2 bits)
    output wire [WIDTH-1:0] out   // Saída selecionada
);
    // Se 'sel' for 00, escolhe in0; 01, escolhe in1; 10, escolhe in2; 11, escolhe in3.
    assign out = (sel == 2'b00) ? in0 :
                 (sel == 2'b01) ? in1 :
                 (sel == 2'b10) ? in2 : in3;
endmodule
// ==================================================

// ==================================================
// Extensor de Sinal
// ==================================================
module sign_extender (
    input  wire [15:0] in,      // Imediato de 16 bits
    output wire [31:0] out      // Imediato estendido para 32 bits
);
    // Replicação do bit de sinal (in[15]) por 16 vezes, seguido do valor original de 16 bits.
    assign out = {{16{in[15]}}, in};
endmodule
// ==================================================

// ==================================================
// Banco de registradores
// ==================================================
module register_file (
    input wire clk,
    input wire we,                     // Write Enable
    input wire [4:0] read_reg1,        // Endereço do primeiro registrador a ser lido
    input wire [4:0] read_reg2,        // Endereço do segundo registrador a ser lido
    input wire [4:0] write_reg,        // Endereço do registrador a ser escrito
    input wire [31:0] write_data,      // Dados a serem escritos
    output wire [31:0] read_data1,     // Saída dos dados do registrador 1
    output wire [31:0] read_data2      // Saída dos dados do registrador 2
);

    reg [31:0] registers [31:0];

    integer i;
    // Inicializa os registradores (opcional)
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'd0;
    end

    // Escrita no registrador
    always @(posedge clk) begin
        if (we)
            registers[write_reg] <= write_data;
    end

    // Leitura dos registradores
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

endmodule
// ==================================================

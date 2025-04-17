// Definições para os códigos das instruções

// Instrução do tipo R (tipo registrador)
`define R_TYPE  6'b000000

// Instruções específicas do tipo R
`define JUMP    6'b000010
`define JR      6'b001000
`define ADDU    6'b100001
`define SUB     6'b100010

// Instruções do tipo I (imediato)
`define LUI     6'b001111
`define ORI     6'b001101
`define ADDI    6'b001000
`define ADDIU   6'b001001
`define BEQ     6'b000100
`define LW      6'b100011
`define SW      6'b101011

// Instrução do tipo J (jump)
`define JAL     6'b000011

module ALU (
    input [31:0] A,            // Primeiro operando (32 bits)
    input [31:0] B,            // Segundo operando (32 bits)
    input [3:0] ALUControl,    // Sinal de controle da ALU (4 bits) definido pelo ALUControlUnit
    output reg [31:0] Result,  // Resultado da operação da ALU (32 bits)
    output Zero                // Flag que indica se o resultado é zero (útil para instruções de branch)
);
    // Bloco combinacional: calcula o resultado baseado no sinal ALUControl
    always @(*) begin
        case (ALUControl)
            4'b0000: Result = A & B;             // Operação AND bit a bit
            4'b0001: Result = A | B;             // Operação OR bit a bit
            4'b0010: Result = A + B;             // Operação de adição
            4'b0110: Result = A - B;             // Operação de subtração
            4'b0111: Result = (A < B) ? 1 : 0;     // Comparação: resultado 1 se A < B, senão 0
            4'b1100: Result = ~(A | B);          // Operação NOR: negação do OR
            4'b0011: Result = B << 16;           // Operação LUI: desloca o operando B 16 bits à esquerda
            default: Result = 0;                 // Caso padrão: resultado zero
        endcase
    end

    // Atribuição contínua para a flag Zero: ativa quando o resultado é 0
    assign Zero = (Result == 0);
endmodule
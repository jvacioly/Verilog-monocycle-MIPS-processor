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

// MODULO v

module ALUControlUnit (
    input [1:0] ALUOp,          // Sinal de controle principal para a ALU (2 bits)
    input [5:0] Funct,          // Campo "Funct" presente em instruções R-type (6 bits)
    output reg [3:0] ALUControl // Sinal de controle específico da ALU (4 bits)
);
    // Bloco combinacional: reage a qualquer mudança em ALUOp ou Funct
    always @(*) begin
        case (ALUOp)
            2'b00: 
                // Caso ALUOp == 00: operações de adição usadas em ADD, LW, SW, ADDI, ADDIU
                ALUControl = 4'b0010;
            2'b01: 
                // Caso ALUOp == 01: operações de subtração, utilizadas em SUB e BEQ
                ALUControl = 4'b0110;
            2'b10: begin
                // Para ALUOp == 10: a operação depende do campo Funct (instruções R-type)
                case (Funct)
                    `ADDU: ALUControl = 4'b0010; // ADDU: operação de adição
                    `SUB:  ALUControl = 4'b0110; // SUB: operação de subtração
                    `JR:   ALUControl = 4'b0000; // JR: operação definida como 0 (pode não afetar a ALU)
                    default: ALUControl = 4'b0000; // Valor padrão para Funct não reconhecido
                endcase
            end
            2'b11: begin
                // Para ALUOp == 11: operações específicas para certas instruções do tipo I
                case (Funct)
                    `LUI: ALUControl = 4'b0011; // LUI: Load Upper Immediate (deslocamento de 16 bits)
                    `ORI: ALUControl = 4'b0001; // ORI: operação OR com imediato
                    default: ALUControl = 4'b0000; // Valor padrão
                endcase
            end
            default: 
                // Valor padrão se ALUOp não corresponder a nenhum caso
                ALUControl = 4'b0000;
        endcase
    end
endmodule
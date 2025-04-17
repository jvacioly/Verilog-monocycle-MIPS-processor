// Definições para os códigos das instruções
// Módulo responsável por gerar os sinais de controle 
// para o processador MIPS com base no OpCode da instrução.

// Instrução do tipo R (registrador)
`define R_TYPE  6'b000000

// Instruções específicas do tipo R
`define JUMP    6'b000010  // Instrução de salto incondicional (JUMP)
`define JR      6'b001000  // Salto para endereço contido em um registrador (JR)
`define ADDU    6'b100001  // Adição sem sinal (ADDU)
`define SUB     6'b100010  // Subtração (SUB)

// Instruções do tipo I (imediato)
`define LUI     6'b001111  // Carrega imediato na metade superior (LUI)
`define ORI     6'b001101  // Operação OR com imediato (ORI)
`define ADDI    6'b001000  // Adição com imediato (ADDI)
`define ADDIU   6'b001001  // Adição sem sinal com imediato (ADDIU)
`define BEQ     6'b000100  // Branch se igual (BEQ)
`define LW      6'b100011  // Carrega palavra da memória (LW)
`define SW      6'b101011  // Armazena palavra na memória (SW)

// Instrução do tipo J (jump)
`define JAL     6'b000011  // Salto e link (JAL)

module ControlUnit (
    input [5:0] OpCode,         // Campo de operação (OpCode) da instrução (6 bits)
    output reg RegDst,          // Sinal que seleciona o destino do registrador
    output reg ALUSrc,          // Sinal que define a fonte do segundo operando da ALU
    output reg MemToReg,        // Sinal que seleciona entre dados da memória ou resultado da ALU para escrever no registrador
    output reg RegWrite,        // Sinal que habilita a escrita no registrador
    output reg MemRead,         // Sinal que habilita a leitura da memória de dados
    output reg MemWrite,        // Sinal que habilita a escrita na memória de dados
    output reg Branch,          // Sinal que indica uma instrução de branch (ex: BEQ)
    output reg Jump,            // Sinal que indica uma instrução de salto (JUMP ou JAL)
    output reg [1:0] ALUOp      // Sinal de controle para a ALU, enviado para o ALUControlUnit (2 bits)
);
    // Bloco combinacional que avalia os sinais de controle
    always @(*) begin
        // Seleção dos sinais com base no OpCode
        case (OpCode)
            // Caso de instruções do tipo R (registrador)
            `R_TYPE: begin
                RegDst   = 1;     // Seleciona o campo rd (destino é o registrador de destino)
                ALUSrc   = 0;     // Segundo operando vem do registrador (não imediato)
                MemToReg = 0;     // Valor a ser escrito no registrador vem da ALU (não da memória)
                RegWrite = 1;     // Habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b10; // ALUOp definida para instruções R-type, o que requer análise do campo Funct
            end
            // Caso da instrução LW (load word)
            `LW: begin
                RegDst   = 0;     // O destino do registrador é especificado pelo campo rt (não rd)
                ALUSrc   = 1;     // Segundo operando vem do imediato (endereço offset)
                MemToReg = 1;     // Valor a ser escrito no registrador vem da memória
                RegWrite = 1;     // Habilita a escrita no registrador
                MemRead  = 1;     // Habilita a leitura da memória de dados
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b00; // ALUOp definida para realizar uma adição para calcular o endereço
            end
            // Caso da instrução SW (store word)
            `SW: begin
                RegDst   = 0;     // Não há escrita em registrador para SW
                ALUSrc   = 1;     // Segundo operando vem do imediato (offset para endereço)
                MemToReg = 0;     // Não é relevante, pois não há escrita no registrador
                RegWrite = 0;     // Não habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 1;     // Habilita a escrita na memória de dados
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b00; // ALUOp definida para adição, para calcular o endereço de memória
            end
            // Caso da instrução BEQ (branch if equal)
            `BEQ: begin
                RegDst   = 0;     // Não há escrita em registrador para BEQ
                ALUSrc   = 0;     // Ambos os operandos vêm dos registradores
                MemToReg = 0;     // Não é relevante, pois não há escrita em registrador
                RegWrite = 0;     // Não habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 1;     // Ativa o sinal de branch para permitir a decisão de desvio
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b01; // ALUOp definida para subtração (comparação para BEQ)
            end
            // Caso da instrução JUMP (salto incondicional)
            `JUMP: begin
                RegDst   = 0;     // Não há escrita em registrador
                ALUSrc   = 0;     // Não é utilizada a ALU para cálculo de endereço
                MemToReg = 0;     // Não há transferência de dado da memória para registrador
                RegWrite = 0;     // Não habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 1;     // Ativa o sinal de salto
                ALUOp    = 2'b00; // ALUOp não é relevante para JUMP
            end
            // Caso da instrução JAL (jump and link)
            `JAL: begin
                RegDst   = 0;     // Para JAL, o destino da escrita geralmente é o registrador $ra
                ALUSrc   = 0;     // Não utiliza operando imediato para a ALU
                MemToReg = 0;     // Valor a ser escrito (geralmente o endereço de retorno) não vem da memória
                RegWrite = 1;     // Habilita a escrita, pois o endereço de retorno é salvo
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch tradicional
                Jump     = 1;     // Ativa o sinal de salto
                ALUOp    = 2'b00; // ALUOp não é relevante para JAL
            end
            // Caso da instrução LUI (load upper immediate)
            `LUI: begin
                RegDst   = 0;     // O destino do registrador é especificado pelo campo rt
                ALUSrc   = 1;     // Utiliza o imediato para formar o valor (deslocado 16 bits)
                MemToReg = 0;     // O valor escrito vem do resultado da ALU (operador LUI implementado nela)
                RegWrite = 1;     // Habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b11; // ALUOp definida para operações específicas (LUI)
            end
            // Caso da instrução ORI (OR com imediato)
            `ORI: begin
                RegDst   = 0;     // O destino do registrador é o campo rt
                ALUSrc   = 1;     // Utiliza o imediato como operando
                MemToReg = 0;     // O valor a ser escrito vem do resultado da ALU
                RegWrite = 1;     // Habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b11; // ALUOp definida para operações específicas (ORI)
            end
            // Caso da instrução ADDI (adição com imediato)
            `ADDI: begin
                RegDst   = 0;     // Destino é o campo rt
                ALUSrc   = 1;     // Segundo operando vem do imediato
                MemToReg = 0;     // Valor escrito vem do resultado da ALU
                RegWrite = 1;     // Habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b00; // ALUOp definida para adição
            end
            // Caso da instrução ADDIU (adição sem sinal com imediato)
            `ADDIU: begin
                RegDst   = 0;     // Destino é o campo rt
                ALUSrc   = 1;     // Utiliza o imediato como operando
                MemToReg = 0;     // Valor escrito vem do resultado da ALU
                RegWrite = 1;     // Habilita a escrita no registrador
                MemRead  = 0;     // Não realiza leitura da memória
                MemWrite = 0;     // Não realiza escrita na memória
                Branch   = 0;     // Não é uma instrução de branch
                Jump     = 0;     // Não é uma instrução de salto
                ALUOp    = 2'b00; // ALUOp definida para adição
            end
            // Caso default: quando o OpCode não corresponde a nenhuma instrução prevista
            default: begin
                RegDst   = 0;
                ALUSrc   = 0;
                MemToReg = 0;
                RegWrite = 0;
                MemRead  = 0;
                MemWrite = 0;
                Branch   = 0;
                Jump     = 0;
                ALUOp    = 2'b00;
            end
        endcase
    end
endmodule
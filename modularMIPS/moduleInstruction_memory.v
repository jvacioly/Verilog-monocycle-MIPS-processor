// As definições abaixo não são utilizadas diretamente neste módulo,
// mas são mantidas para referência e compatibilidade com outros módulos.
`define R_TYPE  6'b000000

`define JUMP    6'b000010
`define JR      6'b001000
`define ADDU    6'b100001
`define SUB     6'b100010

`define LUI     6'b001111
`define ORI     6'b001101
`define ADDI    6'b001000
`define ADDIU   6'b001001
`define BEQ     6'b000100
`define LW      6'b100011
`define SW      6'b101011

`define JAL     6'b000011

module InstructionMemory (
    input [31:0] address,          // Endereço da instrução a ser lida (deve ser um múltiplo de 4)
    output [31:0] instruction      // Instrução completa (32 bits) formada pela concatenação de 4 bytes
);
    // Declaração de uma memória com 1024 posições, onde cada posição armazena 8 bits (um byte)
    reg [7:0] memory [1023:0];

    // Atribuição contínua que forma a instrução de 32 bits
    // a partir da concatenação de 4 bytes consecutivos da memória:
    // - memory[address]     : byte mais significativo (bits 31:24)
    // - memory[address + 1] : próximo byte (bits 23:16)
    // - memory[address + 2] : próximo byte (bits 15:8)
    // - memory[address + 3] : byte menos significativo (bits 7:0)
    assign instruction = {memory[address], memory[address + 1], memory[address + 2], memory[address + 3]};

endmodule
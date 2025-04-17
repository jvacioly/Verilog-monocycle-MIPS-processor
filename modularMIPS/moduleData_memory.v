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

module DataMemory (
    input clk,                   // Clock do sistema - sincroniza a escrita na memória.
    input memWrite,              // Sinal que habilita a escrita na memória.
    input [31:0] address,        // Endereço base (32 bits) para acesso à memória.
    input [31:0] writeData,      // Dados de 32 bits que serão escritos na memória (se memWrite estiver ativo).
    output [31:0] readData       // Dados lidos da memória (32 bits).
);
    // Declaração de uma memória com 1024 posições, cada posição com 32 bits.
    // Apesar de cada posição ser de 32 bits, o acesso é feito byte a byte.
    reg [31:0] memory [1023:0];

    // Atribuição contínua que forma um dado de 32 bits a partir de 4 bytes consecutivos.
    // Os bytes são concatenados na ordem: byte mais significativo primeiro.
    // Nota: No código fornecido, a atribuição utiliza o sinal "read_data" em vez de "readData".
    // É importante manter a consistência dos nomes. Aqui, mantemos conforme o código fornecido.
    assign read_data = {memory[address], memory[address+1], memory[address+2], memory[address+3]};

    // Bloco sempre sensível à borda de subida do clock (clock síncrono).
    // Quando memWrite estiver ativo, escreve os dados em 4 posições consecutivas na memória.
    always @(posedge clk) begin
        if (memWrite) begin
            // Divide o writeData (32 bits) em 4 bytes e os armazena em endereços consecutivos.
            // A parte mais significativa (bits 31:24) é armazenada em memory[address],
            // e assim por diante, formando uma palavra de 32 bits.
            memory[address  ] <= writeData[31:24];
            memory[address+1] <= writeData[23:16];
            memory[address+2] <= writeData[15:8];
            memory[address+3] <= writeData[7:0];

            // Exibe no console, para depuração, a posição de memória escrita
            // e o valor armazenado na posição address+3 (o byte menos significativo).
            $display("posição: %d, valor: %d", address, memory[address+3]);
        end
    end

endmodule
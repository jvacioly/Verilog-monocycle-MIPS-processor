// Módulo de multiplexador 2-para-1 parametrizado.
// Este módulo seleciona entre duas entradas de largura parametrizável (default de 32 bits)
// com base no sinal de seleção 'sel'. Se 'sel' for 0, a saída será 'in0';
// se for 1, a saída será 'in1'.


module MUX2to1 #(parameter WIDTH = 32) (
    input [WIDTH-1:0] in0, // Entrada 0: valor utilizado quando sel = 0
    input [WIDTH-1:0] in1, // Entrada 1: valor utilizado quando sel = 1
    input sel,             // Sinal de seleção: determina qual entrada será encaminhada à saída
    output [WIDTH-1:0] out // Saída: valor selecionado dentre as duas entradas
);

    // Atribuição contínua: utiliza o operador ternário para selecionar a saída com base no sinal 'sel'
    // Se 'sel' for verdadeiro (1), 'out' recebe in1; caso contrário, recebe in0.
    assign out = sel ? in1 : in0;

endmodule

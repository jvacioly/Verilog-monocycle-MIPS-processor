module SignExtend (
    input [15:0] in,      // Entrada de 16 bits (imediato ou valor curto)
    output [31:0] out     // Saída de 32 bits com sinal estendido
);
    // Atribuição contínua que forma a saída de 32 bits:
    // {{16{in[15]}}, in} cria um vetor de 32 bits onde:
    // - {16{in[15]}}: Repete 16 vezes o bit mais significativo (bit 15) da entrada.
    //   Isso garante que o valor estendido mantenha o mesmo sinal (0 para positivo, 1 para negativo).
    // - in: Concatena os 16 bits originais.
    // O resultado é um valor de 32 bits com a extensão de sinal apropriada.
    assign out = {{16{in[15]}}, in};

endmodule
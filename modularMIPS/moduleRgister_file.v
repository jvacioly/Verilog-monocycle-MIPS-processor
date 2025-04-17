module ProgramCounter (
    input clk,                   // Sinal de clock que sincroniza a atualização do PC.
    input reset,                 // Sinal de reset; quando ativo, o PC é zerado.
    input [31:0] nextPC,         // Próximo endereço de instrução a ser carregado.
    output reg [31:0] currentPC  // Endereço atual da instrução (contador de programa).
);
    // Bloco sempre sensível à borda de subida do clock ou do reset.
    // Utiliza-se o reset com borda de subida para permitir um reset assíncrono.
    always @(posedge clk or posedge reset) begin
        if (reset)
            // Se o reset estiver ativo, zera o PC (inicialização do contador).
            currentPC <= 0;
        else
            // Caso contrário, atualiza o PC com o valor de nextPC.
            currentPC <= nextPC;
    end

endmodule
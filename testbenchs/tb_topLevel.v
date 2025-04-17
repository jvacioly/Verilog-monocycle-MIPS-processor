// ==================================================
// Testbench para modulo Top Level (processador CPU)
// ==================================================
// Testbench para simulação do processador CPU
// Esse arquivo instância o módulo CPU, gera o clock, aplica o reset,
// inicializa as memórias de dados (dm) e instruções (im) e executa a simulação do processador.

// Definição para instrução JAL (não é usada diretamente aqui, mas mantida para referência)
`define JAL     6'b000011

module cpu_tb;

  // Declaração das entradas para a CPU
  reg clk;
  reg reset;
  integer i; // Variável para contagem do loop de simulação

  // Instanciação do módulo CPU (testado como cpu)
  CPU cpu (
    .clk(clk),
    .reset(reset)
  );

  // Bloco inicial para configurar e iniciar a simulação
  initial begin
    // Gera o arquivo de dump para visualização dos sinais (VCD)
    $dumpfile("dump.vcd");
    $dumpvars();
    
    // Inicializa o clock e aplica reset inicial
    clk = 0;
    reset = 1;

    // Aguarda 100 unidades de tempo para estabilizar o reset
    #100;
    reset = 0; // Libera o reset após 100 unidades de tempo

    // Inicialização da memória de dados (Data Memory) do processador:
    // Cada grupo de 4 bytes (8 bits cada) forma uma palavra de 32 bits.
    cpu.dm.memory[0] = 8'b00000000;
    cpu.dm.memory[1] = 8'b00000000;
    cpu.dm.memory[2] = 8'b00000000;
    cpu.dm.memory[3] = 8'b00000001; // Palavra 1: valor 1

    cpu.dm.memory[4] = 8'b00000000;
    cpu.dm.memory[5] = 8'b00000000;
    cpu.dm.memory[6] = 8'b00000000;
    cpu.dm.memory[7] = 8'b00000010; // Palavra 2: valor 2

    cpu.dm.memory[8] = 8'b00000000;
    cpu.dm.memory[9] = 8'b00000000;
    cpu.dm.memory[10] = 8'b00000000;
    cpu.dm.memory[11] = 8'b00000011; // Palavra 3: valor 3

    cpu.dm.memory[12] = 8'b00000000;
    cpu.dm.memory[13] = 8'b00000000;
    cpu.dm.memory[14] = 8'b00000000;
    cpu.dm.memory[15] = 8'b00000100; // Palavra 4: valor 4

    cpu.dm.memory[16] = 8'b00000000;
    cpu.dm.memory[17] = 8'b00000000;
    cpu.dm.memory[18] = 8'b00000000;
    cpu.dm.memory[19] = 8'b00000101; // Palavra 5: valor 5

    cpu.dm.memory[20] = 8'b00000000;
    cpu.dm.memory[21] = 8'b00000000;
    cpu.dm.memory[22] = 8'b00000000;
    cpu.dm.memory[23] = 8'b00000110; // Palavra 6: valor 6

    cpu.dm.memory[24] = 8'b00000000;
    cpu.dm.memory[25] = 8'b00000000;
    cpu.dm.memory[26] = 8'b00000000;
    cpu.dm.memory[27] = 8'b00000111; // Palavra 7: valor 7

    cpu.dm.memory[28] = 8'b00000000;
    cpu.dm.memory[29] = 8'b00000000;
    cpu.dm.memory[30] = 8'b00000000;
    cpu.dm.memory[31] = 8'b00001000; // Palavra 8: valor 8

    // Inicialização da memória de instruções (Instruction Memory)
    // A sequência de bytes representa a montagem das instruções em formato binário.
    // Cada instrução possui 32 bits, sendo escrita em 4 bytes consecutivos.
    // baseada na sintaxe MIPS.

    // Instrução: la $t0, musics
    cpu.im.memory[0] = 8'b00111100;
    cpu.im.memory[1] = 8'b00000001;
    cpu.im.memory[2] = 8'b00010000;
    cpu.im.memory[3] = 8'b00000001;

    cpu.im.memory[4] = 8'b00110100;
    cpu.im.memory[5] = 8'b00101000;
    cpu.im.memory[6] = 8'b00000000;
    cpu.im.memory[7] = 8'b00000000;

    // Instrução: la $t1, msc1
    cpu.im.memory[8] = 8'b00111100;
    cpu.im.memory[9] = 8'b00000001;
    cpu.im.memory[10] = 8'b00010000;
    cpu.im.memory[11] = 8'b00000001;

    cpu.im.memory[12] = 8'b00110100;
    cpu.im.memory[13] = 8'b00101001;
    cpu.im.memory[14] = 8'b00000000;
    cpu.im.memory[15] = 8'b00100000;

    // Instrução: sw $t1, 0($t0)
    cpu.im.memory[16] = 8'b10101101;
    cpu.im.memory[17] = 8'b00001001;
    cpu.im.memory[18] = 8'b00000000;
    cpu.im.memory[19] = 8'b00000000;

    // Instrução: la $t1, msc2
    cpu.im.memory[20] = 8'b00111100;
    cpu.im.memory[21] = 8'b00000001;
    cpu.im.memory[22] = 8'b00010000;
    cpu.im.memory[23] = 8'b00000001;

    cpu.im.memory[24] = 8'b00110100;
    cpu.im.memory[25] = 8'b00101001;
    cpu.im.memory[26] = 8'b00000000;
    cpu.im.memory[27] = 8'b00100100;

    // Instrução: sw $t1, 4($t0)
    cpu.im.memory[28] = 8'b10101101;
    cpu.im.memory[29] = 8'b00001001;
    cpu.im.memory[30] = 8'b00000000;
    cpu.im.memory[31] = 8'b00000100;

    // Instrução: la $t1, msc3
    cpu.im.memory[32] = 8'b00111100;
    cpu.im.memory[33] = 8'b00000001;
    cpu.im.memory[34] = 8'b00010000;
    cpu.im.memory[35] = 8'b00000001;

    cpu.im.memory[36] = 8'b00110100;
    cpu.im.memory[37] = 8'b00101001;
    cpu.im.memory[38] = 8'b00000000;
    cpu.im.memory[39] = 8'b00101000;

    // Instrução: sw $t1, 8($t0)
    cpu.im.memory[40] = 8'b10101101;
    cpu.im.memory[41] = 8'b00001001;
    cpu.im.memory[42] = 8'b00000000;
    cpu.im.memory[43] = 8'b00001000;

    // Instrução: la $t1, msc4
    cpu.im.memory[44] = 8'b00111100;
    cpu.im.memory[45] = 8'b00000001;
    cpu.im.memory[46] = 8'b00010000;
    cpu.im.memory[47] = 8'b00000001;

    cpu.im.memory[48] = 8'b00110100;
    cpu.im.memory[49] = 8'b00101001;
    cpu.im.memory[50] = 8'b00000000;
    cpu.im.memory[51] = 8'b00101100;

    // Instrução: sw $t1, 12($t0)
    cpu.im.memory[52] = 8'b10101101;
    cpu.im.memory[53] = 8'b00001001;
    cpu.im.memory[54] = 8'b00000000;
    cpu.im.memory[55] = 8'b00001100;

    // Instrução: la $t1, msc5
    cpu.im.memory[56] = 8'b00111100;
    cpu.im.memory[57] = 8'b00000001;
    cpu.im.memory[58] = 8'b00010000;
    cpu.im.memory[59] = 8'b00000001;

    cpu.im.memory[60] = 8'b00110100;
    cpu.im.memory[61] = 8'b00101001;
    cpu.im.memory[62] = 8'b00000000;
    cpu.im.memory[63] = 8'b00110000;

    // Instrução: sw $t1, 16($t0)
    cpu.im.memory[64] = 8'b10101101;
    cpu.im.memory[65] = 8'b00001001;
    cpu.im.memory[66] = 8'b00000000;
    cpu.im.memory[67] = 8'b00010000;

    // Instrução: la $t1, msc6
    cpu.im.memory[68] = 8'b00111100;
    cpu.im.memory[69] = 8'b00000001;
    cpu.im.memory[70] = 8'b00010000;
    cpu.im.memory[71] = 8'b00000001;

    cpu.im.memory[72] = 8'b00110100;
    cpu.im.memory[73] = 8'b00101001;
    cpu.im.memory[74] = 8'b00000000;
    cpu.im.memory[75] = 8'b00110100;

    // Instrução: sw $t1, 20($t0)
    cpu.im.memory[76] = 8'b10101101;
    cpu.im.memory[77] = 8'b00001001;
    cpu.im.memory[78] = 8'b00000000;
    cpu.im.memory[79] = 8'b00010100;

    // Instrução: la $t1, msc7
    cpu.im.memory[80] = 8'b00111100;
    cpu.im.memory[81] = 8'b00000001;
    cpu.im.memory[82] = 8'b00010000;
    cpu.im.memory[83] = 8'b00000001;

    cpu.im.memory[84] = 8'b00110100;
    cpu.im.memory[85] = 8'b00101001;
    cpu.im.memory[86] = 8'b00000000;
    cpu.im.memory[87] = 8'b00111000;

    // Instrução: sw $t1, 24($t0)
    cpu.im.memory[88] = 8'b10101101;
    cpu.im.memory[89] = 8'b00001001;
    cpu.im.memory[90] = 8'b00000000;
    cpu.im.memory[91] = 8'b00011000;

    // Instrução: la $t1, msc8
    cpu.im.memory[92] = 8'b00111100;
    cpu.im.memory[93] = 8'b00000001;
    cpu.im.memory[94] = 8'b00010000;
    cpu.im.memory[95] = 8'b00000001;

    cpu.im.memory[96] = 8'b00110100;
    cpu.im.memory[97] = 8'b00101001;
    cpu.im.memory[98] = 8'b00000000;
    cpu.im.memory[99] = 8'b00111100;

    // Instrução: sw $t1, 28($t0)
    cpu.im.memory[100] = 8'b10101101;
    cpu.im.memory[101] = 8'b00001001;
    cpu.im.memory[102] = 8'b00000000;
    cpu.im.memory[103] = 8'b00011100;

    // Instrução: li $t2, 4 (carrega o valor 4 em $t2)
    cpu.im.memory[104] = 8'b00100100;
    cpu.im.memory[105] = 8'b00001010;
    cpu.im.memory[106] = 8'b00000000;
    cpu.im.memory[107] = 8'b00000100;

    // Instrução: li $t3, 0 (inicializa o índice em 0)
    cpu.im.memory[108] = 8'b00100100;
    cpu.im.memory[109] = 8'b00001011;
    cpu.im.memory[110] = 8'b00000000;
    cpu.im.memory[111] = 8'b00000000;

    // Instrução: li $t4, 1 (seta flag 'over' como 1)
    cpu.im.memory[112] = 8'b00100100;
    cpu.im.memory[113] = 8'b00001100;
    cpu.im.memory[114] = 8'b00000000;
    cpu.im.memory[115] = 8'b00000001;

    // Instrução: lw $s0, musics($t3) (carrega a música atual em $s0)
    cpu.im.memory[116] = 8'b00111100;
    cpu.im.memory[117] = 8'b00000001;
    cpu.im.memory[118] = 8'b00010000;
    cpu.im.memory[119] = 8'b00000001;

    cpu.im.memory[120] = 8'b00000000;
    cpu.im.memory[121] = 8'b00101011;
    cpu.im.memory[122] = 8'b00001000;
    cpu.im.memory[123] = 8'b00100001;

    cpu.im.memory[124] = 8'b10001100;
    cpu.im.memory[125] = 8'b00110000;
    cpu.im.memory[126] = 8'b00000000;
    cpu.im.memory[127] = 8'b00000000;

    // Instrução: li $t5, 28 (índice da última música)
    cpu.im.memory[128] = 8'b00100100;
    cpu.im.memory[129] = 8'b00001101;
    cpu.im.memory[130] = 8'b00000000;
    cpu.im.memory[131] = 8'b00011100;

    // Instrução: lw $s1, musics($t5) (carrega a última música em $s1)
    cpu.im.memory[132] = 8'b00111100;
    cpu.im.memory[133] = 8'b00000001;
    cpu.im.memory[134] = 8'b00010000;
    cpu.im.memory[135] = 8'b00000001;

    cpu.im.memory[136] = 8'b00000000;
    cpu.im.memory[137] = 8'b00101101;
    cpu.im.memory[138] = 8'b00001000;
    cpu.im.memory[139] = 8'b00100001;

    cpu.im.memory[140] = 8'b10001100;
    cpu.im.memory[141] = 8'b00110001;
    cpu.im.memory[142] = 8'b00000000;
    cpu.im.memory[143] = 8'b00000000;

    // Instrução: beq $t4, $zero, exit (se $t4 for zero, termina o loop)
    cpu.im.memory[144] = 8'b00010001;
    cpu.im.memory[145] = 8'b10000000;
    cpu.im.memory[146] = 8'b00000000;
    cpu.im.memory[147] = 8'b00001111;

    // Instrução: subi $t2, $t2, 1 (decrementa o tempo da música)
    cpu.im.memory[148] = 8'b00100000;
    cpu.im.memory[149] = 8'b00000001;
    cpu.im.memory[150] = 8'b00000000;
    cpu.im.memory[151] = 8'b00000001;

    // Instrução: (alguma operação ou comentário relacionado à simulação)
    cpu.im.memory[152] = 8'b00000001;
    cpu.im.memory[153] = 8'b01000001;
    cpu.im.memory[154] = 8'b01010000;
    cpu.im.memory[155] = 8'b00100010;

    // Instrução: beq $t2, $zero, change_music (se tempo zerar, muda a música)
    cpu.im.memory[156] = 8'b00010001;
    cpu.im.memory[157] = 8'b01000000;
    cpu.im.memory[158] = 8'b00000000;
    cpu.im.memory[159] = 8'b00000001;

    // Instrução: j loop (salta para o início do laço)
    cpu.im.memory[160] = 8'b00001000;
    cpu.im.memory[161] = 8'b00010000;
    cpu.im.memory[162] = 8'b00000000;
    cpu.im.memory[163] = 8'b00100100;

    // Instrução: jal get_index (chama a sub-rotina para obter o próximo índice)
    cpu.im.memory[164] = 8'b00001100;
    cpu.im.memory[165] = 8'b00010000;
    cpu.im.memory[166] = 8'b00000000;
    cpu.im.memory[167] = 8'b00110000;

    // Instrução: move $t3, $a0 (atualiza o índice com o valor retornado)
    cpu.im.memory[168] = 8'b00000000;
    cpu.im.memory[169] = 8'b00000100;
    cpu.im.memory[170] = 8'b01011000;
    cpu.im.memory[171] = 8'b00100001;

    // Instrução: lw $s0, musics($t3) (carrega a música atual em $s0)
    cpu.im.memory[172] = 8'b00111100;
    cpu.im.memory[173] = 8'b00000001;
    cpu.im.memory[174] = 8'b00010000;
    cpu.im.memory[175] = 8'b00000001;

    cpu.im.memory[176] = 8'b00000000;
    cpu.im.memory[177] = 8'b00101011;
    cpu.im.memory[178] = 8'b00001000;
    cpu.im.memory[179] = 8'b00100001;

    cpu.im.memory[180] = 8'b10001100;
    cpu.im.memory[181] = 8'b00110000;
    cpu.im.memory[182] = 8'b00000000;
    cpu.im.memory[183] = 8'b00000000;

    // Instrução: li $t2, 4 (reinicia o tempo da música)
    cpu.im.memory[184] = 8'b00100100;
    cpu.im.memory[185] = 8'b00001010;
    cpu.im.memory[186] = 8'b00000000;
    cpu.im.memory[187] = 8'b00000100;

    // Instrução: beq $s0, $s1, change_over (se a música atual for a última, muda o flag)
    cpu.im.memory[188] = 8'b00010010;
    cpu.im.memory[189] = 8'b00010001;
    cpu.im.memory[190] = 8'b00000000;
    cpu.im.memory[191] = 8'b00000011;

    // Instrução: addi $t3, $t3, 4 (incrementa o índice)
    cpu.im.memory[192] = 8'b00100001;
    cpu.im.memory[193] = 8'b01101011;
    cpu.im.memory[194] = 8'b00000000;
    cpu.im.memory[195] = 8'b00000100;

    // Instrução: move $a0, $t3 (passa o índice para $a0)
    cpu.im.memory[196] = 8'b00000000;
    cpu.im.memory[197] = 8'b00001011;
    cpu.im.memory[198] = 8'b00100000;
    cpu.im.memory[199] = 8'b00100001;

    // Instrução: jr $ra (retorna da sub-rotina)
    cpu.im.memory[200] = 8'b00000011;
    cpu.im.memory[201] = 8'b11100000;
    cpu.im.memory[202] = 8'b00000000;
    cpu.im.memory[203] = 8'b00001000;

    // Instrução: li $t4, 1 (seta $t4 para 1)
    cpu.im.memory[204] = 8'b00100100;
    cpu.im.memory[205] = 8'b00001100;
    cpu.im.memory[206] = 8'b00000000;
    cpu.im.memory[207] = 8'b00000001;

    // Instrução: li $v0, 10 (serviço de saída para terminar o programa)
    cpu.im.memory[208] = 8'b00100100;
    cpu.im.memory[209] = 8'b00000010;
    cpu.im.memory[210] = 8'b00000000;
    cpu.im.memory[211] = 8'b00001010;

    // Instrução: syscall (executa a chamada do sistema para terminar a simulação)
    cpu.im.memory[212] = 8'b00000000;
    cpu.im.memory[213] = 8'b00000000;
    cpu.im.memory[214] = 8'b00000000;
    cpu.im.memory[215] = 8'b00001100;

    // Loop de simulação: aguarda 500 iterações (20 unidades de tempo cada)
    for (i = 0; i < 500; i = i + 1) begin
      #20; 
    end

    $finish; // Finaliza a simulação
  end

  // Geração do clock: inverte o sinal a cada 10 unidades de tempo
  always #10 clk = ~clk;

endmodule // fim do módulo cpu_tb
module cpu_tb;
    reg clk;
    reg reset;
    integer i;
    integer file;
    integer value;
    integer instruction_count;  // Variável para contar o número de instruções

    // Instanciação da CPU
    CPU cpu (
         .clk(clk),
         .reset(reset)
    );

    initial begin
        // Inicialização do clock e reset
        clk = 0;
        reset = 1;
        #50;
        reset = 0;

        // Abrindo o arquivo de instruções em hexadecimal
        file = $fopen("instructions.hex", "r");
        if (file == 0) begin
            $display("Falha ao abrir o arquivo de instruções!");
            $finish;
        end

        // Inicializando o contador de instruções
        instruction_count = 0;

        // Monitorar os sinais de pc, instruction e writeData
        $monitor("pc: %h, instruction: %h, writeData: %h", cpu.pc, cpu.instruction, cpu.writeData);

        // Lendo o arquivo até o final
        while (!$feof(file)) begin
            // Lê o próximo valor hexadecimal no arquivo
            $fscanf(file, "%h\n", value);
            
            // Armazena os 4 bytes da instrução na memória (assumindo que o arquivo tem instruções de 32 bits)
            cpu.im.memory[instruction_count*4]   = value[31:24];
            cpu.im.memory[instruction_count*4+1] = value[23:16];
            cpu.im.memory[instruction_count*4+2] = value[15:8];
            cpu.im.memory[instruction_count*4+3] = value[7:0];
            
            // Incrementa o contador de instruções
            instruction_count = instruction_count + 1;
        end

        // Fechando o arquivo
        $fclose(file);

        // Deixe a simulação rodar por um tempo suficiente para a CPU executar o programa
        for (i = 0; i < 100; i = i + 1) begin
            #10;
        end

        $finish;
    end

    // Gera o clock: alterna a cada 5 unidades de tempo
    always #5 clk = ~clk;

endmodule
        # Programa de Teste para o Processador MIPS
        
        # Carrega os valores imediatos em registradores:
        addi   $t0, $zero, 5        # $t0 = 5
        addi   $t1, $zero, 10       # $t1 = 10
        
        # Realiza uma soma entre $t0 e $t1:
        addu   $t2, $t0, $t1        # $t2 = $t0 + $t1 = 15
        
        # Armazena o resultado (15) na Data Memory na posição 0:
        sw     $t2, 0($zero)        # Memory[0] = 15
        
        # Instrução de branch: se $t2 == $t1, salta para "label" 
        # (neste caso 15 <> 10 → branch não é tomada)
        beq    $t2, $t1, label
        
        # Se o branch não for tomado, executa esta instrução:
        addi   $t3, $zero, 1        # $t3 = 1
        
label:  # Instrução na label "label"
        sub    $t4, $t2, $t1        # $t4 = $t2 - $t1 = 15 - 10 = 5
        
        # Utiliza LUI e ORI para carregar um valor no $v0:
        lui    $v0, 1               # $v0 = 0x00010000
        ori    $v0, $v0, 32         # $v0 = 0x00010020
        
        # Salta para a label "halt" para terminar a execução (halt):
        j      halt
        
halt:  # Label "halt": cria um laço infinito para simular a parada do programa
        j      halt
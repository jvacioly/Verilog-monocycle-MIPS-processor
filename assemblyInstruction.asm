    addi $2, $zero, 4      # $2 = 4
    sw   $2, 4($zero)      # Mem[4] = $2
    lw   $8, 4($zero)      # $8 = Mem[4]
    addi $9, $8, 5         # $9 = $8 + 5 = 9
    sw   $9, 4($zero)      # Mem[4] = $9
    beq  $2, $2, 1         # se $2 == $2, pula próxima instrução (vai para linha 7)
    addi $3, $zero, 7      # (não executa)
    bne  $6, $8, 1         # se $6 ≠ $8, pula próxima instrução (vai para linha 9)
    addi $6, $zero, 10     # (não executa)
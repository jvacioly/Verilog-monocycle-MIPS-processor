// Carrega o novo programa
        memory[0] = 32'h20080002; // 0x00: addi $t0, $zero, 2
        memory[1] = 32'h200A0001; // 0x04: addi $t2, $zero, 1
        memory[2] = 32'h010A4822; // 0x08: sub  $t1, $t0, $t2
        memory[3] = 32'hAC090004; // 0x0C: sw   $t1, 4($zero)
        memory[4] = 32'h8C0B0004; // 0x10: lw   $t3, 4($zero)
        memory[5] = 32'h11680001; // 0x14: beq  $t3, $t0, +1 (Target: 0x1C)
        memory[6] = 32'h08000008; // 0x18: j    skip_move (Target: 0x20)
        memory[7] = 32'h01601820; // 0x1C: add  $3, $t3, $zero (do_move label)
        memory[8] = 32'h08000008; // 0x20: j    skip_move (skip_move label / halt)
        // Posições 9 a 15 contêm NOPs
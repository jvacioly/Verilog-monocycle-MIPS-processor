// Program: Sum two numbers, store result, load result
         // Memory Address (Word) | Byte Address | Hex Code    | Assembly Instruction      ; Description
         memory[0]  = 32'h20080005; // 0x00      | 20080005    | addi $t0, $zero, 5        ; $t0 = 5 ($8 = 0 + 5)
         memory[1]  = 32'h2009000A; // 0x04      | 2009000A    | addi $t1, $zero, 10       ; $t1 = 10 ($9 = 0 + 10)
         memory[2]  = 32'h01095020; // 0x08      | 01095020    | add  $t2, $t0, $t1        ; $t2 = $t0 + $t1 = 15 ($10 = $8 + $9)
         memory[3]  = 32'hAC0A0010; // 0x0C      | AC0A0010    | sw   $t2, 16($zero)       ; Store $t2 into Data Memory at address 0x10 (offset 16 from $zero)
         memory[4]  = 32'h8C0B0010; // 0x10      | 8C0B0010    | lw   $t3, 16($zero)       ; Load word from Data Memory at address 0x10 into $t3 ($11)
         memory[5]  = 32'h08000005; // 0x14      | 08000005    | j    0x00000014           ; Jump to address 0x14 (this instruction) -> Infinite loop
 
         // memory[6] to memory[15] remain NOPs from the initial loop
# Verilog-monocycle-MIPS-processor
Verilog implementation of 32-bit MIPS processor supporting the instructions add, sub, and, or, slt, lw, sw, beq.

## How to Run

**Required Packages:** ```iverilog (sudo apt install iverilog)```

## Supported Instructions

Instruction | Opcode | Funct | Syntax | Explanation
------------|--------|-------|--------|---------
add         |000000  |100000 |add $1, $2, $3 | $3 = $1 + $2
sub         |000000  |100010 |sub $1, $2, $3 | $3 = $1 - $2
and         |000000  |100100 |and $1, $2, $3 | $3 = $1 & $2
or          |000000  |100101 |or $1, $2, $3  | $3 = $1 \| $2
slt         |101010  |101010 |slt $1, $2, $3 | $3 = ($1 < $2)
lw          |100011  |       |lw $1 4($2)    | $1 = load($2 + 4)
sw          |101011  |       |sw $2 5($3)    | $2 = load($3 + 5)
beq         |000100  |       |beq $1, $2, 4  | jumps 4 instructions ahead if $1 == $2
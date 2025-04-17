// Módulo principal que representa o processador CPU.
// Esse módulo integra os principais componentes do processador MIPS,
// incluindo PC, memória de instruções, unidade de controle, banco de registradores,
// ALU, memória de dados e os multiplexadores necessários para selecionar os sinais.

// Definições para instruções (mantidas para referência)
`define R_TYPE  6'b000000
`define JUMP    6'b000010
`define JR      6'b001000
`define ADDU    6'b100001
`define SUB     6'b100010

`define LUI     6'b001111
`define ORI     6'b001101
`define ADDI    6'b001000
`define ADDIU   6'b001001
`define BEQ     6'b000100
`define LW      6'b100011
`define SW      6'b101011

`define JAL     6'b000011

module CPU (
    input clk,    // Clock do sistema
    input reset   // Sinal de reset (sincronizado)
);
    // Declaração de fios (wires) para interligar os módulos internos:
    wire [31:0] pc, nextPC, instruction;       // PC atual, próximo PC e instrução lida
    wire [31:0] readData1, readData2, writeData, aluResult, readData;
    wire [31:0] signExtended, aluSrcB, pcBranch, jumpAddr;
    wire [4:0] writeReg;                       // Registrador destino para escrita
    wire [3:0] aluControl;                     // Sinal de controle para a ALU
    wire [1:0] aluOp;                          // Sinal ALUOp vindo do ControlUnit
    wire zero;                                 // Flag que indica se o resultado da ALU é zero
    wire regDst, aluSrc, memToReg, regWrite, memRead, memWrite, branch, jump;

    // Instanciação do Program Counter (PC)
    ProgramCounter PC (
        .clk(clk),
        .reset(reset),
        .nextPC(nextPC),
        .currentPC(pc)
    );

    // Instanciação da memória de instruções (Instruction Memory)
    InstructionMemory im (
        .address(pc),
        .instruction(instruction)
    );

    // Instanciação da unidade de controle (Control Unit)
    // O ControlUnit gera os sinais de controle com base nos 6 bits do OpCode da instrução.
    ControlUnit CU (
        .OpCode(instruction[31:26]),
        .RegDst(regDst),
        .ALUSrc(aluSrc),
        .MemToReg(memToReg),
        .RegWrite(regWrite),
        .MemRead(memRead),
        .MemWrite(memWrite),
        .Branch(branch),
        .Jump(jump),
        .ALUOp(aluOp)
    );

    // MUX para selecionar o registrador destino (rt ou rd)
    // Se RegDst = 1, seleciona o campo rd (instrução[15:11]); caso contrário, rt (instrução[20:16])
    MUX2to1 #(.WIDTH(5)) MuxRegDst (
        .in0(instruction[20:16]),
        .in1(instruction[15:11]),
        .sel(regDst),
        .out(writeReg)
    );

    // Instanciação do banco de registradores (Register File)
    RegisterFile RF (
        .clk(clk),
        .regWrite(regWrite),
        .readReg1(instruction[25:21]),  // Fonte 1: registrador rs
        .readReg2(instruction[20:16]),  // Fonte 2: registrador rt
        .writeReg(writeReg),           // Destino: determinado pelo MUX acima
        .writeData(writeData),
        .readData1(readData1),
        .readData2(readData2)
    );

    // Instanciação do módulo de extensão de sinal (Sign Extend)
    // Converte o imediato de 16 bits (instrução[15:0]) para 32 bits.
    SignExtend SE (
        .in(instruction[15:0]),
        .out(signExtended)
    );

    // MUX para selecionar a fonte do segundo operando da ALU
    // Se aluSrc = 0, usa o valor lido do banco de registradores; se = 1, usa o imediato estendido.
    MUX2to1 MuxALUSrc (
        .in0(readData2),
        .in1(signExtended),
        .sel(aluSrc),
        .out(aluSrcB)
    );

    // Instanciação da unidade de controle da ALU (ALUControlUnit)
    // Converte o sinal ALUOp e o campo Funct da instrução para o sinal de controle final da ALU.
    ALUControlUnit ALUCU (
        .ALUOp(aluOp),
        .Funct(instruction[5:0]),
        .ALUControl(aluControl)
    );

    // Instanciação da ALU
    // Realiza operações aritméticas e lógicas com base no sinal de controle.
    ALU ALU (
        .A(readData1),
        .B(aluSrcB),
        .ALUControl(aluControl),
        .Result(aluResult),
        .Zero(zero)
    );

    // Instanciação da memória de dados (Data Memory)
    // Realiza operações de leitura e escrita na memória.
    DataMemory dm (
        .clk(clk),
        .memWrite(memWrite),
        .address(aluResult),
        .writeData(readData2),
        .readData(readData)
    );

    // MUX para selecionar o valor a ser escrito no banco de registradores
    // Se memToReg = 1, escreve o dado lido da memória; caso contrário, o resultado da ALU.
    MUX2to1 MuxMemToReg (
        .in0(aluResult),
        .in1(readData),
        .sel(memToReg),
        .out(writeData)
    );

    // Cálculo do endereço para branch:
    // pcBranch = pc + 4 + (imediato estendido << 2)
    assign pcBranch = pc + 4 + (signExtended << 2);
    
    // Cálculo do endereço para jump:
    // jumpAddr = concatenação dos 4 bits superiores do pc, 26 bits da instrução e 2 bits 0
    assign jumpAddr = {pc[31:28], instruction[25:0], 2'b00};

    // Seleção do próximo PC:
    // Se jump = 1, usa jumpAddr; senão, se branch ativado e zero = 1, usa pcBranch; caso contrário, pc + 4.
    assign nextPC = (jump) ? jumpAddr :
                    (branch & zero) ? pcBranch : pc + 4;

endmodule
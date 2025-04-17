// Instruction R-type
`define R_TYPE  6'b000000
`define JUMP    6'b000010
`define JR      6'b001000
`define ADDU    6'b100001
`define SUB     6'b100010

// Instruction I-type
`define LUI     6'b001111
`define ORI     6'b001101
`define ADDI    6'b001000
`define ADDIU   6'b001001
`define BEQ     6'b000100
`define LW      6'b100011
`define SW      6'b101011

// Instruction J-type
`define JAL     6'b000011

module CPU (
    input clk,
    input reset
);
    // Declaração de fios para interligar os módulos
    wire [31:0] pc, nextPC, instruction;
    wire [31:0] readData1, readData2, writeData, aluResult, readData, signExtended, aluSrcB, pcBranch, jumpAddr;
    wire [4:0] writeReg;
    wire [3:0] aluControl;
    wire [1:0] aluOp;
    wire zero, regDst, aluSrc, memToReg, regWrite, memRead, memWrite, branch, jump;

    ProgramCounter PC (
        .clk(clk),
        .reset(reset),
        .nextPC(nextPC),
        .currentPC(pc)
    );

    InstructionMemory im (
        .address(pc),
        .instruction(instruction)
    );

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

    MUX2to1 #(.WIDTH(5)) MuxRegDst (
        .in0(instruction[20:16]),
        .in1(instruction[15:11]),
        .sel(regDst),
        .out(writeReg)
    );

    RegisterFile RF (
        .clk(clk),
        .regWrite(regWrite),
        .readReg1(instruction[25:21]),
        .readReg2(instruction[20:16]),
        .writeReg(writeReg),
        .writeData(writeData),
        .readData1(readData1),
        .readData2(readData2)
    );

    SignExtend SE (
        .in(instruction[15:0]),
        .out(signExtended)
    );

    MUX2to1 MuxALUSrc (
        .in0(readData2),
        .in1(signExtended),
        .sel(aluSrc),
        .out(aluSrcB)
    );

    ALUControlUnit ALUCU (
        .ALUOp(aluOp),
        .Funct(instruction[5:0]),
        .ALUControl(aluControl)
    );

    ALU ALU (
        .A(readData1),
        .B(aluSrcB),
        .ALUControl(aluControl),
        .Result(aluResult),
        .Zero(zero)
    );

    DataMemory dm (
        .clk(clk),
        .memWrite(memWrite),
        .address(aluResult),
        .writeData(readData2),
        .readData(readData)
    );

    MUX2to1 MuxMemToReg (
        .in0(aluResult),
        .in1(readData),
        .sel(memToReg),
        .out(writeData)
    );

    assign pcBranch = pc + 4 + (signExtended << 2);
    assign jumpAddr = {pc[31:28], instruction[25:0], 2'b00};
    assign nextPC = (jump) ? jumpAddr :
                    (branch & zero) ? pcBranch : pc + 4;
                    
endmodule

module ALUControlUnit (
    input [1:0] ALUOp,
    input [5:0] Funct,
    output reg [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010;
            2'b01: ALUControl = 4'b0110;
            2'b10: begin
                case (Funct)
                    `ADDU: ALUControl = 4'b0010;
                    `SUB: ALUControl = 4'b0110;
                    `JR: ALUControl = 4'b0000;
                    default: ALUControl = 4'b0000;
                endcase
            end
            2'b11: begin
                case (Funct)
                    `LUI: ALUControl = 4'b0011;
                    `ORI: ALUControl = 4'b0001; 
                    default: ALUControl = 4'b0000;
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule

module ALU (
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALUControl,
    output reg [31:0] Result,
    output Zero
);
    always @(*) begin
        case (ALUControl)
            4'b0000: Result = A & B;
            4'b0001: Result = A | B;
            4'b0010: Result = A + B;
            4'b0110: Result = A - B;
            4'b0111: Result = (A < B) ? 1 : 0;
            4'b1100: Result = ~(A | B);
            4'b0011: Result = B << 16;
            default: Result = 0;
        endcase
        // Monitor ALU operation
        $display("Time: %t | ALU Operation: %b | A: %d, B: %d, Result: %d", $time, ALUControl, A, B, Result);
    end
    assign Zero = (Result == 0);
endmodule


module ControlUnit (
    input [5:0] OpCode,
    output reg RegDst,
    output reg ALUSrc,
    output reg MemToReg,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg Branch,
    output reg Jump,
    output reg [1:0] ALUOp
);
    always @(*) begin
        case (OpCode)
            `R_TYPE: begin
                RegDst = 1;
                ALUSrc = 0;
                MemToReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b10;
            end
            `LW: begin
                RegDst = 0;
                ALUSrc = 1;
                MemToReg = 1;
                RegWrite = 1;
                MemRead = 1;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
            `SW: begin
                RegDst = 0;
                ALUSrc = 1;
                MemToReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 1;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
            `BEQ: begin
                RegDst = 0;
                ALUSrc = 0;
                MemToReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 1;
                Jump = 0;
                ALUOp = 2'b01;
            end
            `JUMP: begin
                RegDst = 0;
                ALUSrc = 0;
                MemToReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 1;
                ALUOp = 2'b00;
            end
            `JAL: begin
                RegDst = 0;
                ALUSrc = 0;
                MemToReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 1;
                ALUOp = 2'b00;
            end
            `LUI: begin
                RegDst = 0;
                ALUSrc = 1;
                MemToReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b11;
            end
            `ORI: begin
                RegDst = 0;
                ALUSrc = 1;
                MemToReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b11;
            end
            `ADDI: begin
                RegDst = 0;
                ALUSrc = 1;
                MemToReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
            `ADDIU: begin
                RegDst = 0;
                ALUSrc = 1;
                MemToReg = 0;
                RegWrite = 1;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
            default: begin
                RegDst = 0;
                ALUSrc = 0;
                MemToReg = 0;
                RegWrite = 0;
                MemRead = 0;
                MemWrite = 0;
                Branch = 0;
                Jump = 0;
                ALUOp = 2'b00;
            end
        endcase
    // Monitor control signals
        $display("Time: %t | Control Signals | RegDst: %b, ALUSrc: %b, MemToReg: %b, RegWrite: %b, MemRead: %b, MemWrite: %b, Branch: %b, Jump: %b, ALUOp: %b", 
                 $time, RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Jump, ALUOp);
    end
endmodule


module DataMemory (
    input clk,
    input memWrite,
    input [31:0] address,
    input [31:0] writeData,
    output [31:0] readData
);
    reg [31:0] memory [1023:0];

    // Inicializa as posições de memória com 0
    integer j;
    initial begin
        for (j = 0; j < 1024; j = j + 1)
            memory[j] = 0;
    end

    assign readData = {memory[address], memory[address+1], memory[address+2], memory[address+3]};

    always @(posedge clk) begin
        if (memWrite) begin
            memory[address  ] <= writeData[31:24];
            memory[address+1] <= writeData[23:16];
            memory[address+2] <= writeData[15:8];
            memory[address+3] <= writeData[7:0];
            // Monitor memory write
            $display("Time: %t | Memory Write at address: %d, Data: %d", $time, address, writeData);
        end
    end
endmodule



module InstructionMemory (
    input [31:0] address,
    output [31:0] instruction
);
    reg [7:0] memory [0:1023];
    initial begin
        // Carrega o programa do arquivo .hex
        $readmemh("D:\\Victor\\Faculdade\\Projetos\\Verilog-monocycle-MIPS-processor\\assemblyInstruction.hex", memory);
    end
    assign instruction = {memory[address], memory[address+1], memory[address+2], memory[address+3]};
endmodule

module MUX2to1 #(parameter WIDTH = 32) (
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,
    input sel,
    output [WIDTH-1:0] out
);
    assign out = sel ? in1 : in0;
endmodule

module ProgramCounter (
    input clk,
    input reset,
    input [31:0] nextPC,
    output reg [31:0] currentPC
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            currentPC <= 0;
        end else begin
            currentPC <= nextPC;
            // Monitor Program Counter update
            $display("Time: %t | ProgramCounter updated to: %d", $time, currentPC);
        end
    end
endmodule


module RegisterFile (
    input clk,
    input regWrite,
    input [4:0] readReg1,
    input [4:0] readReg2,
    input [4:0] writeReg,
    input [31:0] writeData,
    output [31:0] readData1,
    output [31:0] readData2
);
    reg [31:0] registers [31:0];
    
    // Inicializa todos os registradores com 0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 0;
    end
    
    // Leitura contínua dos registradores
    assign readData1 = registers[readReg1];
    assign readData2 = registers[readReg2];
    
    // Escrita síncrona: se regWrite estiver ativo, escreve writeData no registrador
    always @(posedge clk) begin
        if (regWrite) begin
            registers[writeReg] <= writeData;
            // Monitor register write
            $display("Time: %t | Register[%d] written with value: %d", $time, writeReg, writeData);
        end
    end
endmodule

module SignExtend (
    input [15:0] in,
    output [31:0] out
);
    assign out = {{16{in[15]}}, in};
endmodule

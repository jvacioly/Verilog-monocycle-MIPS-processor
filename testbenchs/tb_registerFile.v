// ==================================================
// Testbench para o Register File
// ==================================================
`timescale 1ns / 1ps

module RegisterFile_tb;
    reg clk;
    reg regWrite;
    reg [4:0] readReg1;
    reg [4:0] readReg2;
    reg [4:0] writeReg;
    reg [31:0] writeData;

    wire [31:0] readData1;
    wire [31:0] readData2;

    RegisterFile uut (
        .clk(clk),
        .regWrite(regWrite),
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(writeReg),
        .writeData(writeData),
        .readData1(readData1),
        .readData2(readData2)
    );

    initial begin
        clk = 0;
        regWrite = 0;
        readReg1 = 0;
        readReg2 = 0;
        writeReg = 0;
        writeData = 0;

        #100;

        // Test case 1: Write and read back from register 1
        writeReg = 5'd1;
        writeData = 32'h12345678;
        regWrite = 1;
        #10;
        regWrite = 0;

        readReg1 = 5'd1;
        #10;
        $display("Read register 1: readData1 = %h (expected: 12345678)", readData1);

        // Test case 2: Write and read back from register 2
        writeReg = 5'd2;
        writeData = 32'h87654321;
        regWrite = 1;
        #10;
        regWrite = 0;

        readReg2 = 5'd2;
        #10;
        $display("Read register 2: readData2 = %h (expected: 87654321)", readData2);

        // Test case 3: Simultaneous read from two different registers
        readReg1 = 5'd1;
        readReg2 = 5'd2;
        #10;
        $display("Read register 1: readData1 = %h (expected: 12345678)", readData1);
        $display("Read register 2: readData2 = %h (expected: 87654321)", readData2);

        // Test case 4: Write to and read from the same register
        writeReg = 5'd3;
        writeData = 32'hAABBCCDD;
        regWrite = 1;
        #10;
        regWrite = 0;

        readReg1 = 5'd3;
        #10;
        $display("Read register 3: readData1 = %h (expected: AABBCCDD)", readData1);

        $finish;
    end

    always #5 clk = ~clk;

endmodule
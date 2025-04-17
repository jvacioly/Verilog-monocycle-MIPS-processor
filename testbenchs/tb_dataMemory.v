// ==================================================
// Testbench para a Memória de Dados
// ==================================================
`timescale 1ns / 1ps

module DataMemory_tb;
    reg clk;
    reg memWrite;
    reg [31:0] address;
    reg [31:0] writeData;

    wire [31:0] readData;

    DataMemory uut (
        .clk(clk),
        .memWrite(memWrite),
        .address(address),
        .writeData(writeData),
        .readData(readData)
    );

    initial begin
        clk = 0;
        memWrite = 0;
        address = 0;
        writeData = 0;

        #100;

        // Test case 1: Write and read from address 0
        address = 0;
        writeData = 32'hAABBCCDD;
        memWrite = 1;
        #10;
        memWrite = 0;
        #10;
        $display("Test case 1 - Address: %h, Write Data: %h, Read Data: %h", address, writeData, readData);

        // Test case 2: Write and read from address 4
        address = 4;
        writeData = 32'h11223344;
        memWrite = 1;
        #10;
        memWrite = 0;
        #10;
        $display("Test case 2 - Address: %h, Write Data: %h, Read Data: %h", address, writeData, readData);

        // Test case 3: Write and read from address 8
        address = 8;
        writeData = 32'h55667788;
        memWrite = 1;
        #10;
        memWrite = 0;
        #10;
        $display("Test case 3 - Address: %h, Write Data: %h, Read Data: %h", address, writeData, readData);

        $finish;
    end

    always #5 clk = ~clk;

endmodule
`timescale 1ns / 1ps

module tb_mips;
    // Clock & reset
    reg clk;
    reg reset;

    // Instantiate the processor
    wire [31:0] pc;
    wire        reg_write;
    wire        alu_src;
    mips uut (
        .clk      (clk),
        .reset    (reset),
        .pc       (pc),
        .reg_write(reg_write),
        .alu_src  (alu_src)
    );

    // Cycle counter
    integer cycle_count = 0;
    integer i, j;

    // Generate clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Apply reset then release
    initial begin
        reset = 1;
        #12;     // hold reset for a bit more than one full cycle
        reset = 0;
    end

    // Dump waveforms
    initial begin
        $dumpfile("tb_mips.vcd");
        $dumpvars(0, tb_mips);
    end

    // On each rising edge, display PC, registers and data memory
    always @(posedge clk) begin
        if (!reset) begin
            cycle_count = cycle_count + 1;
            $display("=== Cycle %0d ===", cycle_count);
            $display("PC = 0x%08h", uut.pc);

            // Display non-zero registers
            $display("Registers:");
            for (i = 0; i < 32; i = i + 1) begin
                if (uut.RF.rf[i] !== 32'd0)
                    $display("  $%0d = 0x%08h", i, uut.RF.rf[i]);
            end

            // Display non-zero data memory entries
            $display("Data Memory (non-zero):");
            for (j = 0; j < 256; j = j + 1) begin
                if (uut.DM.memory[j] !== 32'd0)
                    $display("  Mem[%0d] = 0x%08h", j, uut.DM.memory[j]);
            end

            $display("");
        end
    end

    // Stop simulation after a fixed number of cycles
    initial begin
        #1000;
        $display("Simulation finished.");
        $finish;
end
endmodule

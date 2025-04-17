`timescale 1ns / 1ps

module mips_testbench;
    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [31:0] pc;
    wire reg_write;
    wire alu_src;
    wire [31:0] instruction; // Add wire for the current instruction
    wire [31:0] registers [0:31];
    wire [31:0] data_memory [0:255]; // Add wire for the data memory

    // Instantiate the MIPS processor
    mips uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .registers(registers)
    );

    // Connect instruction memory to fetch the current instruction
    instruction_memory imem (
        .pc(pc),
        .instruction(instruction) // Fetch the instruction at the current PC
    );

    // Connect the data memory to observe changes
    data_memory dmem (
        .clk(clk),
        .address(uut.alu_result), // Use ALU result as the address
        .write_data(uut.read_data2),
        .mem_read(uut.mem_read),
        .mem_write(uut.mem_write),
        .read_data(data_memory) // Expose all data memory
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Stimulus
    initial begin
        // Initialize reset
        reset = 1;
        #10; // Wait 10ns
        reset = 0;

        // Wait for the simulation to run for a specific duration
        #1000; // Run for sufficient time to execute instructions
        
        $stop; // Terminate the simulation
    end

    // Detect infinite loop and terminate simulation
    always @(posedge clk) begin
        if (pc == 32'h3C) begin // Check if PC has reached the infinite loop address (e.g., "j 0xF" -> PC = 0x3C)
            $display("Infinite loop detected at PC = %h. Terminating simulation.", pc);
            $stop;
        end
    end

    // Display contents on every clock edge (Horizontal format)
    always @(posedge clk) begin
        $write("PC: %h | Instruction: %h | ", pc, instruction);
        $write("$zero: %h | $t0: %h | $t1: %h | $t2: %h | $t3: %h | $t4: %h | ", 
               registers[0], registers[8], registers[9], registers[10], registers[11], registers[12]);
        
        // Display data memory changes
        for (int i = 0; i < 256; i = i + 1) begin
            if (dmem.memory[i] !== 32'h00000000) begin
                $write("Mem[%0d]: %h | ", i, dmem.memory[i]);
            end
        end 
        
        $write("\n");
    end
endmodule

module bram_with_init_v #(
    parameter ADDR_WIDTH = 13,                // Address width (2^ADDR_WIDTH locations)
//    parameter ADDR_WIDTH = 2,                // Address width (2^ADDR_WIDTH locations)
    parameter DATA_WIDTH = 32,                // Data width
    parameter INIT_FILE  = "memory_init.hex"  // Initialization file
)(
    input                   clk,             // Clock
    input                   we,              // Write enable
    input  [ADDR_WIDTH-1:0] addr,            // Address
    input  [DATA_WIDTH-1:0] din,             // Data input
    output reg [DATA_WIDTH-1:0] dout         // Data output
);

    // Declare the RAM array
    reg [DATA_WIDTH-1:0] ram [(2**ADDR_WIDTH)-1:0];

    // Initialize the RAM from the memory file
    initial begin
        $readmemh(INIT_FILE, ram, 0, (2**ADDR_WIDTH)-1);  // Use $readmemh for hex format, or $readmemb for binary format
	 end

    // Synchronous RAM operations: Write and Read
    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= din;       // Write data to the RAM at the given address
        end
        dout <= ram[addr/4];          // Read data from the RAM at the given address
//	 dout <= 32'hdeadbeef;
    end

endmodule

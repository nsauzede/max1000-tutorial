module dut #(
    parameter integer SHIFT = 23, // Counter shift to increment the address
    parameter integer BOARD_CK = 32000000,
    parameter INIT_FILE = "mem.hex"
) (
    input rx,
    output tx,
    output [3:0] leds,
    input reset,
    input clk
);
    localparam integer ADDR_WIDTH = 13;
    reg [31:0] count = 32'b0;
    reg we = 1'b0;
    reg [ADDR_WIDTH-1:0] addr = {ADDR_WIDTH{1'b0}};
    reg [31:0] din = 32'b0;
    wire [31:0] dout;
    always @(*) begin
//        addr[1:0] = count[1+SHIFT:SHIFT];
//        addr[ADDR_WIDTH-1:2] = {ADDR_WIDTH-2{1'b0}};
        addr = count[ADDR_WIDTH-1:0];
    end
    assign tx = rx;
    assign leds[2:0] = dout[6:4];
    assign leds[3] = (count < (BOARD_CK / 2)) ? 1'b1 : 1'b0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 32'b0;
        end else begin
            if (count >= BOARD_CK) begin
                count <= 32'b0;
            end else begin
                count <= count + 4;
            end
        end
    end
    bram_with_init_v #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(32),
        .INIT_FILE(INIT_FILE)
    ) u_bram (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );
endmodule

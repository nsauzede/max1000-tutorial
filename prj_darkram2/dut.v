module dut #(
    parameter integer BOARD_CK = 32000000,
//    parameter INIT_FILE = "../darkriscv/src/darksocv_padded.hex"
    parameter INIT_FILE = "../darkriscv/src/four.mem"
) (
    input rx,
    output tx,
    output [7:0] leds,
    input reset,
    input clk
);
    reg [31:0] count = 32'b0;
    reg [31:0] addr = 0;

    wire [31:0] IADDR;
    wire [31:0] IDATA;
    wire IDACK;
    wire [31:0] XATAO;
    wire XDACK;

//    assign IADDR[1:0] = 2'b0;
//    assign IADDR[3:2] = addr;
//    assign IADDR[31:4] = 0;
//      assign IADDR = count;
//    assign IADDR = addr;
    assign IADDR = addr[1:0];
//    assign IADDR = {addr[1:0], 2'b0};
    assign tx = rx;
    assign leds[7:0] = IDATA[7:0];
//    assign leds[7:0] = addr[7:0];
//    assign leds[6:0] = IDATA[7:0];    // 44
//    assign leds[6:0] = IDATA[15:8];   // 33
//    assign leds[6:0] = IDATA[23:16];  // 22
//    assign leds[6:0] = IDATA[31:24];  // 11
//    assign leds[7] = 1'b1;
`define BOARD_CK 32000000
    reg [31:0] BLINK = 0;
    always@(posedge clk)
    begin
        BLINK <= reset ? 0 : BLINK ? BLINK-1 : `BOARD_CK;
    end
//    assign leds[7]      = (BLINK < (`BOARD_CK/2)) ? -1 : 0;

//    assign leds[6:0] = IDATA[6:0];
//    assign leds[7] = (count < (BOARD_CK / 2)) ? 1'b1 : 1'b0;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 32'b0;
            addr <= 0;
        end else begin
            if (count >= BOARD_CK) begin
                count <= 32'b0;
                addr <= addr + 1;
            end else begin
                count <= count + 1;
            end
        end
    end

    darkram #(.INIT_FILE(INIT_FILE)) u_bram (
        .CLK    (clk),
        .RES    (reset),
        .HLT    (1'b0),

        .IDREQ  (1'b0),
        .IADDR  (IADDR),
        .IDATA  (IDATA),
        .IDACK  (IDACK),

        .XDREQ  (1'b0),
        .XRD    (1'b0),
        .XWR    (1'b0),
        .XBE    (4'hf),
        .XADDR  (0),
        .XATAI  (0),
        .XATAO  (XATAO),
        .XDACK  (XDACK)
    );
endmodule

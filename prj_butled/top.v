`define BOARD_CK 12000000
module top (
	input CLK12M,
	input USER_BTN,
	output [7:0] LED,
	inout [8:1] PIO,
	
	inout [5:0] BDBUS,
	inout [14:0] D
);
wire tx;
wire rx;
wire nreset;
wire clk;
reg [31:0] BLINK = 0;
wire [3:0] leds;
wire [3:0] buttons;

assign nreset = USER_BTN;
//assign nreset = USER_BTN & ~buttons[3];
assign clk = CLK12M;
assign rx = BDBUS[0]; // BDBUS[0] is USB UART TX (FPGA RX)
assign BDBUS[1] = tx; // BDBUS[1] is USB UART RX (FPGA TX)

assign LED = (BLINK < (`BOARD_CK/2)) ? -1 : 0;
assign tx = rx;
assign leds = (BLINK < (`BOARD_CK/2)) ? -1 : 0;

pmodbutled pmodbutled1(
    .pio(PIO),
    .buttons(buttons),
    .leds(leds)
);

always @(posedge CLK12M) begin
	BLINK <= ~nreset ? 0 : BLINK ? BLINK-1 : `BOARD_CK;
end

endmodule

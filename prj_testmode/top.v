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

assign nreset = USER_BTN;
assign clk = CLK12M;
assign rx = BDBUS[0]; // BDBUS[0] is USB UART TX (FPGA RX)
assign BDBUS[1] = tx; // BDBUS[1] is USB UART RX (FPGA TX)

assign LED = (BLINK < (`BOARD_CK/2)) ? -1 : 0;
assign tx = rx;

always @(posedge CLK12M) begin
	BLINK <= ~nreset ? 0 : BLINK ? BLINK-1 : `BOARD_CK;
end

endmodule

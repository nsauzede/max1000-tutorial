module dut #(
    parameter integer BOARD_CK = 32000000,
    parameter INIT_FILE = "../darkriscv/src/darksocv_padded.hex"
) (
    input rx,
    output tx,
    output [7:0] leds,
    input reset,
    input clk
);

	 darksocv soc0 (
		.XCLK(clk),      // external clock
		.XRES(reset),      // external reset

		.UART_RXD(rx),  // UART receive line
		.UART_TXD(tx),  // UART transmit line

		.LED(leds[3:0]),       // on-board leds
		.DEBUG(leds[7:4])      // osciloscope
	);

endmodule

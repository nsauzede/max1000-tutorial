module top #(
`ifdef SIMULATION
    parameter simulation = 1,
`else
    parameter simulation = 0,
`endif
    parameter integer BOARD_CK = 32000000
) (
        input CLK12M,
        input USER_BTN,
        output [7:0] LED,
        inout [8:1] PIO,

        inout [5:0] BDBUS,
        inout [14:0] D
);
wire tx;
wire rx;
wire reset;
wire clk;
wire [7:0] leds;

assign LED = leds;
assign reset = ~USER_BTN;
assign rx = BDBUS[0]; // BDBUS[0] is USB UART TX (FPGA RX)
assign BDBUS[1] = tx; // BDBUS[1] is USB UART RX (FPGA TX)

generate
	if (simulation == 1) begin
		assign clk = CLK12M;
	end else begin
 	pll pll0 (
		.inclk0(CLK12M),
		.c0(clk)
	);
	end
endgenerate
    dut #(.BOARD_CK(BOARD_CK)) dut1 (
        .rx(rx),
        .tx(tx),
        .leds(leds),
        .reset(reset),
        .clk(clk)
    );
endmodule

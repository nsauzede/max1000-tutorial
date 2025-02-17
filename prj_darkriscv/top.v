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

        input SEN_SDO,
        output SEN_SDI,
        output SEN_CS,
        output SEN_SPC,

        inout [5:0] BDBUS,
        inout [14:0] D
);
wire tx;
wire rx;
wire reset;
wire clk;
wire [7:0] leds;

//assign LED = leds;
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

wire nrst;
assign nrst = USER_BTN;
wire [31:0] spi_mosi_data;
wire [31:0] spi_miso_data;
wire [5:0] spi_nbits;
wire spi_request;
wire spi_ready;

sequencer U1 (
        .clk_in(CLK12M),
        .nrst(nrst),

        .spi_mosi_data(spi_mosi_data),
        .spi_miso_data(spi_miso_data),
        .spi_nbits(spi_nbits),

        .spi_request(spi_request),
        .spi_ready(spi_ready),

        .led_out(LED)
);
spi_master U2 (
        .clk_in(CLK12M),
        .nrst(nrst),

        .spi_sck(SEN_SPC),
        .spi_mosi(SEN_SDI),
        .spi_miso(SEN_SDO),
        .spi_csn(SEN_CS),

        .mosi_data(spi_mosi_data),
        .miso_data(spi_miso_data),
        .nbits(spi_nbits),

        .request(spi_request),
        .ready(spi_ready)
);


endmodule

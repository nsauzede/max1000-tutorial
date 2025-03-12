module dut #(parameter integer SPI_DIV_COEF = 0) (
`ifdef SIMULATION
    input wire x_l_flag,
    output [15:0] x_l_response,
`endif
    input rx,
    output tx,
    input spi_miso,
    output spi_mosi,
    output spi_csn,
    output spi_sck,
    output [7:0] leds,
    input reset,
    input clk
);

    wire RD;
    wire WR;
    wire [3:0] BE;
    wire [31:0] DATAI;
    wire [31:0] DATAO;
    wire IRQ;
    wire SCK;
    wire CSN;
    reg ESIMACK;
    wire [3:0] DEBUG;
    assign tx = 1;
darkspisequencer darkspisequencer1 (
`ifdef SIMULATION
    .x_l_flag(x_l_flag),
    .x_l_response(x_l_response),
`endif
    .clk_in(clk),
    .nrst(~reset),
        .RD(RD),
        .WR(WR),
        .BE(BE),
        .DATAI(DATAI),
        .DATAO(DATAO),
        .IRQ(IRQ),
    .led_out(leds)
);
darkspi #(.DIV_COEF(SPI_DIV_COEF)) darkspi1 (
        .CLK(clk),
        .RES(reset),
        .RD(RD),
        .WR(WR),
        .BE(BE),
        .DATAI(DATAI),
        .DATAO(DATAO),
        .IRQ(IRQ),
`ifdef SIMULATION
        .ESIMACK(ESIMACK),
`endif
        .DEBUG(DEBUG),
        .SCK(spi_sck),
        .MOSI(spi_mosi),
        .MISO(spi_miso),
        .CSN(spi_csn)
);
endmodule

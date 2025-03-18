module top (
    input CLK12M,
    input USER_BTN,
    output [7:0] LED,
    output SEN_SDI,
    output SEN_SPC,
    output SEN_CS,
    input SEN_SDO
);
dut dut1 (
    .clk(CLK12M),
    .reset(~USER_BTN),
    .leds(LED),
    .spi_mosi(SEN_SDI),
    .spi_sck(SEN_SPC),
    .spi_csn(SEN_CS),
    .spi_miso(SEN_SDO)
);
endmodule

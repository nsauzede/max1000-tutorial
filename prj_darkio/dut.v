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
    wire [31:0] datai;
    wire [31:0] datao;

    wire CLK, RES;
    assign CLK = clk;
    assign RES = reset;
    wire [15:0] LED;     // on-board leds
    wire [3:0] DEBUG;   // osciloscope
    wire UART_RXD;      // UART receive line
    wire UART_TXD;      // UART transmit line
    reg HLT = 0;
    assign tx = UART_TXD;
    assign UART_RXD = rx;

    // darkbridge interface

    wire        XIRQ;
    wire        XDREQ;
    wire [31:0] XADDR;
    wire [31:0] XATAO;
    wire        XWR,
                XRD;
    wire [3:0]  XBE;
    wire [3:0]  XDREQMUX;

    assign XDREQMUX[0] = XDREQ && XADDR[31:30]==0;
    assign XDREQMUX[1] = XDREQ && XADDR[31:30]==1;
    assign XDREQMUX[2] = XDREQ && XADDR[31:30]==2;
    assign XDREQMUX[3] = XDREQ && XADDR[31:30]==3;

    wire [31:0] XATAIMUX [0:3];
    wire        XDACKMUX [0:3];

    // io block w/ CS==1

    wire [3:0] IODEBUG;

    assign XDREQ = 1'b1;
    assign XRD = rd;
    assign XWR = wr;
    assign XBE = be;
    assign XADDR = 32'h40000014;
    assign XATAO = datai;
    darkio #(.SPI_DIV_COEF(SPI_DIV_COEF)) darkio1 (
        .CLK(CLK),
        .RES(RES),
        .HLT(HLT),

`ifdef __INTERRUPT__
        .XIRQ    (XIRQ),
`endif

        .XDREQ  (XDREQMUX[1]),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),
        .XATAI  (XATAO),
        .XATAO  (XATAIMUX[1]),
        .XDACK  (XDACKMUX[1]),

        .RXD    (UART_RXD),
        .TXD    (UART_TXD),

        .LED    (LED),

`ifdef SPI
        .SCK(spi_sck),
        .MOSI(spi_mosi),
        .MISO(spi_miso),
        .CSN(spi_csn),
`endif

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (IODEBUG)
    );

    assign datao = XATAIMUX[1];
    wire rd, wr;
    wire [3:0] be;
    darkspisequencer darkspisequencer1 (
`ifdef SIMULATION
        .x_l_flag(x_l_flag),
        .x_l_response(x_l_response),
`endif
        .clk_in(CLK),
        .nrst(~RES),
        .RD(rd),
        .WR(wr),
        .BE(be),
        .DATAI(datai),
        .DATAO(datao),
`ifdef __INTERRUPT__
        .IRQ    (XIRQ),
`endif
        .led_out(leds)
    );

    assign DEBUG = IODEBUG;
endmodule

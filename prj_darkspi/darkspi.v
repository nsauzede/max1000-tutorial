/*
 * Copyright (c) 2025, Nicolas Sauzede <nicolas.sauzede@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
    Simple SPI Master wrapper for Darkriscv, based on Max1000 Tutorial spi_master.v
*/

`timescale 1ns / 1ps
//`include "../rtl/config.vh"

// SPI registers
// Only 16 and 24 bits SPI transfers are supported (resp. for 1 and 2 transfered data bytes).
// On write, higher 8 bits are the SPI address, lower bits are the SPI data written.
// On read, higher 8 bits are the SPI status, lower bits are the SPI data read.
//    BE
// W 0011 ADDR,DATA
// R 0011 STATUS,DATA
// W 1111 00,ADDR,DATAHI,DATALO
// R 1111 00,STATUS,DATAHI,DATALO
// R 1000 STATUS
// Where STATUS is: {6'b0, spi_ready, spi_busy}
//
// Examples below are for STMicro LIS3DH sensor SPI target.
// - One byte transfer:
// To read a single byte at address eg: 0x0f (WHO_AM_I), initiate a 16 bits write:
// *((short *)SPI_MMADDR) = 0x8f00; // 8f is addr with RnW=1, 00 is 8-bit resp placeholder
// Followed by a 16 bits read:
// short who_am_i = *((short *)SPI_MMADDR) & 0xff;
// To write a single byte at address eg: 0x20 (CTRL_REG1), initiate a 16 bits write:
// *((short *)SPI_MMADDR) = 0x2077; // 20 is addr, 77 is 8-bit data to write
// - Two bytes access (with automatic address increment):
// To read two bytes starting at address eg: 0x28 (OUT_X_L), initiate a 32 bits write:
// *((int *)SPI_MMADDR) = 0xe80000; // e8 is addr with RnW=1 & MnS=1, 0000 is 16-bit resp placeholder
// Followed by a 32 bits read:
// int swapped_out_x = *((int *)SPI_MMADDR) & 0xffff; // Note that the returned value is byte-swapped: 0xLOHI

module darkspi #(parameter integer DIV_COEF = 0) (
    input           CLK,            // clock
    input           RES,            // reset

    input           RD,             // bus read
    input           WR,             // bus write
    input  [ 3:0]   BE,             // byte enable
    input  [31:0]   DATAI,          // data input
    output [31:0]   DATAO,          // data output
    output          IRQ,            // interrupt req

    output          SCK,            // SPI clock output
    output         MOSI,            // SPI master data output, slave data input
    input          MISO,            // SPI master data input, slave data output
    output          CSN,            // SPI CSN output (active LOW)

`ifdef SIMULATION
    output reg    ESIMREQ = 0,
    input           ESIMACK,
`endif

    output [3:0]    DEBUG           // osc debug
);

    reg [31:0] spi_mosi_data = 0;
    wire [31:0] spi_miso_data;
    reg [5:0] spi_nbits = 0;
    reg spi_request = 0;
    wire spi_ready;
    wire [7:0] status;
    wire spi_busy = ~CSN;
    assign status = {6'b0, spi_ready & ~WR & ~spi_request, spi_busy};
    assign DATAO =
        BE == 4'b1000 ? {24'b0, status} :
        BE == 4'b0011 ? {16'b0, status, spi_miso_data[7:0]} :
        BE == 4'b1111 ? {8'b0, status, spi_miso_data[15:0]} :
        spi_miso_data;
`ifdef NO_SPI_IRQ
    assign IRQ = 0;
`else
    assign IRQ = spi_busy;
`endif
    always @(posedge CLK) begin
        if (RES) begin
            spi_mosi_data <= 0;
            spi_nbits <= 0;
            spi_request <= 0;
        end else begin
            if (WR) begin
                spi_request <= 1;
                if (BE == 4'b1111) begin
                    spi_nbits <= 6'd23;
                end else begin
                    spi_nbits <= 6'd15;
                end
                spi_mosi_data <= DATAI;
            end else begin
                spi_request <= 0;
            end
        end
    end

    spi_master #(.DIV_COEF(DIV_COEF)) spi_master1 (
        .clk_in(CLK),
        .nrst(~RES),

        .spi_sck(SCK),
        .spi_mosi(MOSI),
        .spi_miso(MISO),
        .spi_csn(CSN),

        .mosi_data(spi_mosi_data),
        .miso_data(spi_miso_data),
        .nbits(spi_nbits),

        .request(spi_request),
        .ready(spi_ready)
    );

    assign DEBUG = 0;
endmodule

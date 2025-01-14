`timescale 1ns / 1ps
`ifndef DUT_VCD
`define DUT_VCD "dut.vcd"
`endif
module dut_tb;
    // Parameters
    parameter integer SHIFT = 0; // Counter shift to increment the address
    parameter integer BOARD_CK = 32000000;
    parameter INIT_FILE = "../darkriscv/src/darksocv_padded.hex";

    localparam clk_period = 10;

    reg clk = 0;
    reg rx = 0;
    wire tx;
    reg reset = 0;
    wire [3:0] leds;

    dut #(.SHIFT(SHIFT), .BOARD_CK(BOARD_CK), .INIT_FILE(INIT_FILE)) dut1 (
        .rx(rx),
        .tx(tx),
        .leds(leds),
        .reset(reset),
        .clk(clk)
    );

    // Clock generation
    initial begin
        forever begin
            clk = 1'b0;
            #(clk_period / 2);
            clk = 1'b1;
            #(clk_period / 2);
        end
    end

    // Stimulus process
    initial begin
        $dumpfile(`DUT_VCD);
        $dumpvars(0, dut1);
        // Hold reset state for 100 ns
        #100;

        // Insert stimulus
        reset = 1'b1;
        #(clk_period * 2);
        reset = 1'b0;

        // Additional stimulus or waiting
        #(clk_period * 10);

        // Wait more and finish
`ifndef __ICARUS__
        #1000
`endif
        $finish;
    end
endmodule


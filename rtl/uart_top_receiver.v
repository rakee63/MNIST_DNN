`timescale 1ns / 1ps

// uart receiver top module

`include "parameter.v"
module uart_top_receiver(
    input clk,
    input rst_n,
    input rx,

    output [15:0] r_data,
    output out_valid
);

    wire tick;
    wire [7:0] dout;
    wire rx_done_tick;

    baud_rate_generator #(.MAX(`COUNT)) baud (
        // inputs
        .clk(clk),
        .rst_n(rst_n),
    
        // outputs
        .tick(tick)
    );

    uart_receiver #(.D_BIT(`D_BIT), .SB_TICK(`SB_TICK)) u_r (
        // inputs
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .s_tick(tick),
    
        // outputs
        .dout(dout),
        .rx_done_tick(rx_done_tick)
    );

    uart_interface u_i (
        // inputs
        .clk(clk),
        .rst_n(rst_n),
        .en(rx_done_tick),
        .d(dout),
    
        // outputs
        .data(r_data),
        .out_valid(out_valid)
    );


endmodule

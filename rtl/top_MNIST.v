`timescale 1ns / 1ps


module top_MNIST(
    input clock,
    input reset,
    input rx,

    output [6:0] segment,
    output [3:0] anode
);

    wire [15:0] data, out;
    wire out_valid;
    reg [3:0] result;
    wire [3:0] seg_in;
    
    uart_top_receiver uart (
        // inputs
        .clk(clock),
        .rst_n(~reset),
        .rx(rx),
        
        // outputs    
        .r_data(data),
        .out_valid(data_valid)
    );

    DNN dnn (
        // inputs
        .clk(clock),
        .reset(reset),
        .in_data_valid(data_valid),
        .in_data(data),
    
        // outputs
        .out(out),
        .out_valid(out_valid)
    );

    always @(posedge clock) begin
        if(reset) result <= 4'd0;
        else if(out_valid) result <= out[3:0];
    end
    
    assign seg_in = result;

    SevenSegment seg (
        .in(seg_in),
        
        .out(segment)
    );

    assign anode = 4'b1110;

endmodule

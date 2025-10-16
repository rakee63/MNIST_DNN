`timescale 1ns / 1ps

// baud rate generator


module baud_rate_generator #(parameter MAX = 54)(
    input clk,
    input rst_n,

    output reg tick
);

    reg [9:0] count;

    // parameter S0=2'b00, S1=2'b01, S2=2'b11;

    always @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            count <= 9'd0;
            tick <= 0;            
        end
        else begin
            if(count==MAX) begin
                count <= 9'd0;
                tick <= 1;
            end
            else begin
                count <= count + 9'd1;
                tick <= 0;
            end
        end
    end


endmodule

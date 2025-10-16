`timescale 1ns / 1ps

// interface circuit - FF and one word buffer


module uart_interface (
    input clk,
    input rst_n,
    input en,
    // input set_flag,
    // input clr_flag,
    input [7:0] d,

    output reg [15:0] data,
    output reg out_valid
);

    // reg flag;

    // always @(posedge clk, negedge rst_n) begin
    //     if(~rst_n) flag <= 0;
    //     else if(set_flag) flag <= 1;
    //     else if(clr_flag) flag <= 0;
    // end

    // always @(posedge clk, negedge rst_n) begin
    //     if(~rst_n) q <= 8'd0;
    //     else if(en) q <= d;
    // end

    // assign rx_empty = ~flag;

    localparam START=2'b00, BYTE1=2'b01, BYTE2=2'b11, DONE=2'b10;

    reg [1:0] state;

    always @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            state <= START;
            data <= 16'd0;
            out_valid <= 0;
        end
        else begin
            case(state)
                START: begin
                    state <= BYTE1;
                    out_valid <= 0;
                end
                BYTE1: begin
                    if(en) begin
                        state <= BYTE2;
                        data[7:0] <= d;
                    end
                end
                BYTE2: begin
                    if(en) begin
                        state <= DONE;
                        data[15:8] <= d;
                    end
                end
                DONE: begin
                    state <= START;                    
                    out_valid <= 1;
                end
            endcase
        end
    end



endmodule

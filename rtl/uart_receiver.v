`timescale 1ns / 1ps

// uart receiver


module uart_receiver #(parameter D_BIT=8, SB_TICK=16)(
    input clk,
    input rst_n,
    input rx,
    input s_tick,

    output reg [7:0] dout,
    output reg rx_done_tick
);


    localparam IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] state;

    reg [3:0] s;
    reg [$clog2(D_BIT)-1:0] n;

    always @(posedge clk, negedge rst_n) begin
        if(~rst_n)begin
            state <= IDLE;
            s <= 4'd0;
            n <= {$clog2(D_BIT){1'b0}};
            dout <= 8'd0;
            rx_done_tick <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    rx_done_tick <= 0;
                    if(rx==0) begin
                        state <= START;
                        s <= 4'd0;
                    end
                end
                START: begin
                    if(s_tick) begin
                        if(s==4'd7) begin
                            state <= DATA;
                            s <= 4'd0;
                            n <= {$clog2(D_BIT){1'b0}};
                        end
                        else s <= s + 4'd1;
                    end
                end
                DATA: begin
                    if(s_tick) begin
                        if(s==4'd15) begin
                            s <= 4'd0;
                            dout <= {rx, dout[7:1]};
                            if(n==D_BIT-1) state <= STOP;
                            else n <= n +1;
                        end
                        else s <= s + 1;
                    end
                end
                STOP: begin
                    if(s_tick) begin
                        if(s==SB_TICK-1) begin
                            rx_done_tick <= 1;
                            state <= IDLE;
                        end
                        else begin
                            s <= s + 1;
                            rx_done_tick <= 0;
                        end
                    end
                end
            endcase
        end
    end

endmodule

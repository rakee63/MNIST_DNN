`timescale 1ns / 1ps


`include "include.v"
module DNN (
    input clk,
    input reset,
    input in_data_valid,
    input [`dataWidth-1:0] in_data,

    output [31:0] out,
    output out_valid
);
    
    localparam IDLE = 'd0,
               SEND = 'd1;
    wire [`numNeuronLayer1-1:0] o1_valid;
    wire [`numNeuronLayer1*`dataWidth-1:0] x1_out;
    reg [`numNeuronLayer1*`dataWidth-1:0] holdData_1;
    reg [`dataWidth-1:0] out_data_1;
    reg data_out_valid_1;

    
    Layer_1 #(.NN(`numNeuronLayer1),.numWeight(`numWeightLayer1),.dataWidth(`dataWidth),.layerNum(1),.sigmoidSize(`sigmoidSize),.weightIntWidth(`weightIntWidth),.actType(`Layer1ActType)) l1(
        .clk(clk),
        .rst(reset),
        .weightValid(0),
        .biasValid(0),
        .weightValue(0),
        .biasValue(0),
        .config_layer_num(0),
        .config_neuron_num(0),
        .x_valid(in_data_valid),
        .x_in(in_data),
        .o_valid(o1_valid),
        .x_out(x1_out)
    );
    
    //State machine for data pipelining
    
    reg       state_1;
    integer   count_1;
    always @(posedge clk)
    begin
        if(reset)
        begin
            state_1 <= IDLE;
            count_1 <= 0;
            data_out_valid_1 <=0;
        end
        else
        begin
            case(state_1)
                IDLE: begin
                    count_1 <= 0;
                    data_out_valid_1 <=0;
                    if (o1_valid[0] == 1'b1)
                    begin
                        holdData_1 <= x1_out;
                        state_1 <= SEND;
                    end
                end
                SEND: begin
                    out_data_1 <= holdData_1[`dataWidth-1:0];
                    holdData_1 <= holdData_1>>`dataWidth;
                    count_1 <= count_1 +1;
                    data_out_valid_1 <= 1;
                    if (count_1 == `numNeuronLayer1)
                    begin
                        state_1 <= IDLE;
                        data_out_valid_1 <= 0;
                    end
                end
            endcase
        end
    end
    
    wire [`numNeuronLayer2-1:0] o2_valid;
    wire [`numNeuronLayer2*`dataWidth-1:0] x2_out;
    reg [`numNeuronLayer2*`dataWidth-1:0] holdData_2;
    reg [`dataWidth-1:0] out_data_2;
    reg data_out_valid_2;
    
    Layer_2 #(.NN(`numNeuronLayer2),.numWeight(`numWeightLayer2),.dataWidth(`dataWidth),.layerNum(2),.sigmoidSize(`sigmoidSize),.weightIntWidth(`weightIntWidth),.actType(`Layer2ActType)) l2(
        .clk(clk),
        .rst(reset),
        .weightValid(0),
        .biasValid(0),
        .weightValue(0),
        .biasValue(0),
        .config_layer_num(0),
        .config_neuron_num(0),
        .x_valid(data_out_valid_1),
        .x_in(out_data_1),
        .o_valid(o2_valid),
        .x_out(x2_out)
    );
    
    //State machine for data pipelining
    
    reg       state_2;
    integer   count_2;
    always @(posedge clk)
    begin
        if(reset)
        begin
            state_2 <= IDLE;
            count_2 <= 0;
            data_out_valid_2 <=0;
        end
        else
        begin
            case(state_2)
                IDLE: begin
                    count_2 <= 0;
                    data_out_valid_2 <=0;
                    if (o2_valid[0] == 1'b1)
                    begin
                        holdData_2 <= x2_out;
                        state_2 <= SEND;
                    end
                end
                SEND: begin
                    out_data_2 <= holdData_2[`dataWidth-1:0];
                    holdData_2 <= holdData_2>>`dataWidth;
                    count_2 <= count_2 +1;
                    data_out_valid_2 <= 1;
                    if (count_2 == `numNeuronLayer2)
                    begin
                        state_2 <= IDLE;
                        data_out_valid_2 <= 0;
                    end
                end
            endcase
        end
    end
    
    wire [`numNeuronLayer3-1:0] o3_valid;
    wire [`numNeuronLayer3*`dataWidth-1:0] x3_out;
    
    Layer_3 #(.NN(`numNeuronLayer3),.numWeight(`numWeightLayer3),.dataWidth(`dataWidth),.layerNum(3),.sigmoidSize(`sigmoidSize),.weightIntWidth(`weightIntWidth),.actType(`Layer3ActType)) l3(
        .clk(clk),
        .rst(reset),
        .weightValid(0),
        .biasValid(0),
        .weightValue(0),
        .biasValue(0),
        .config_layer_num(0),
        .config_neuron_num(0),
        .x_valid(data_out_valid_2),
        .x_in(out_data_2),
        .o_valid(o3_valid),
        .x_out(x3_out)
    );
    
    
    maxFinder #(.numInput(`numNeuronLayer3),.inputWidth(`dataWidth))
        mFind(
            .i_clk(clk),
            .i_data(x3_out),
            .i_valid(o3_valid),
            .reset(reset),

            .o_data(out),
            .o_data_valid(out_valid)
        );

endmodule
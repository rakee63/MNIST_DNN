module maxFinder #(parameter numInput=10,parameter inputWidth=16)(
    input           i_clk,
    input           reset,
    input [(numInput*inputWidth)-1:0]   i_data,
    input           i_valid,

    output reg [31:0]o_data,
    output  reg     o_data_valid
);

    reg [inputWidth-1:0] maxValue;
    reg [(numInput*inputWidth)-1:0] inDataBuffer;
    // integer counter;
    reg [3:0] counter;
    
    // always @(posedge i_clk)
    // begin
    //     o_data_valid <= 1'b0;
    //     if(i_valid)
    //     begin
    //         maxValue <= i_data[inputWidth-1:0];
    //         counter <= 1;
    //         inDataBuffer <= i_data;
    //         o_data <= 0;
    //     end
    //     else if(counter == numInput)
    //     begin
    //         counter <= 0;
    //         o_data_valid <= 1'b1;
    //     end
    //     else if(counter != 0)
    //     begin
    //         counter <= counter + 1;
    //         if(inDataBuffer[counter*inputWidth+:inputWidth] > maxValue)
    //         begin
    //             maxValue <= inDataBuffer[counter*inputWidth+:inputWidth];
    //             o_data <= counter;
    //         end
    //     end
    // end

    always @(posedge i_clk) begin
        if(reset) begin
            maxValue <= {inputWidth{1'b0}};
            inDataBuffer <= {(numInput*inputWidth){1'b0}};
            o_data_valid <= 1'b0;
            o_data <= 32'd0;
            counter <= 4'd0;
        end
        else if(i_valid) begin
            maxValue <= i_data[inputWidth-1:0];
            counter <= 4'd1;
            inDataBuffer <= i_data;
            o_data <= 32'd0;
            o_data_valid <= 1'b0;
        end
        else if(counter == numInput) begin
            counter <= 0;
            o_data_valid <= 1'b1;
        end
        else if(counter != 0) begin
            counter <= counter + 1;
            if(inDataBuffer[counter*inputWidth+:inputWidth] > maxValue)
            begin
                maxValue <= inDataBuffer[counter*inputWidth+:inputWidth];
                o_data <= counter;
            end
        end
    end

endmodule
`timescale 1ns / 1ps

`include "..\rtl\include.v"

`define MaxTestSamples 10

module tb_DNN();
    
    reg reset;
    reg clk;
    reg [`dataWidth-1:0] in;
    reg in_valid;
    reg [`dataWidth-1:0] in_mem [784:0];
    reg [`dataWidth-1:0] expected;

    wire [31:0] out;
    wire out_valid;
    wire out1_valid;
    
    integer right=0;
    
    DNN dut (
        .clk(clk),
        .reset(reset),
        .in_data_valid(in_valid),
        .in_data(in),
    
        .out(out),
        .out_valid(out_valid),
        .out1_valid(out1_valid)
    );
    
            
    initial begin
        clk = 1'b0;
    end
        
    always
        #5 clk = ~clk;
    
    function [7:0] to_ascii;
      input integer a;
      begin
        to_ascii = a+48;
      end
    endfunction



    integer i,j,layerNo=1,k;
    integer start;
    integer testDataCount;
    integer t;

    reg [1023:0] filename;   // packed array for filename text

    initial begin
        // $monitor("Time=%0t | out=%0x | out_valid=%b | out1_valid=%b", $time, out, out_valid, out1_valid);
        reset = 1;
        in_valid = 0;
        #100;
        reset = 0;
        start = $time;
        $display("Configuration completed at %0t ns", $time-start);
        start = $time;
    
        for (testDataCount = 0; testDataCount < `MaxTestSamples; testDataCount = testDataCount + 1) begin
    
            // Build filename: test_data_0001.txt ... test_data_9999.txt
            $sformat(filename, "test_data_%04d.txt", testDataCount);
    
//            $display("Reading file: %s", filename);
            $readmemb(filename, in_mem);

            // $display("File is read %04d", testDataCount+1);
    
            // Give some clocks before sending data
            repeat(3) @(posedge clk);
            for (t = 0; t < 784; t = t + 1) begin
                @(posedge clk);
                in       <= in_mem[t];
                in_valid <= 1;
            end 

            // $display("Data is tranferred is read");
            
            start = $time;
            @(posedge clk);
            in_valid <= 0;
            expected = in_mem[t];
            @(posedge out_valid);

            // $display("Result : %0x", out);

            if (out == expected) begin
                right = right+1;
                $display("%04d. Accuracy: %f, Detected number: %0x, Expected: %x, PASS",
                                     testDataCount+1, right*100.0/(testDataCount+1), out, expected);
            end
            else
                $display("%04d. Accuracy: %f, Detected number: %0x, Expected: %x, FAIL - X",
                                                 testDataCount+1, right*100.0/(testDataCount+1), out, expected);
                                                 

            // $display("Total execution time: %0t ns", $time-start);
            // j=0;
            // repeat(10) begin
            //     readAxi(20);
            //     $display("Output of Neuron %0d: %0x", j, axiRdData);
            //     j=j+1;
            // end
        end
    
        $display("Final Accuracy: %f", right*100.0/testDataCount);
        $stop;
    end


endmodule

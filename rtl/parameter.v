`define BAUD_RATE       115200
`define CLK             100
`define SAMPLING_RATE   16
`define COUNT           (`CLK*1000000)/(`SAMPLING_RATE*`BAUD_RATE)
// `define COUNT           4
`define D_BIT           8
`define SB_TICK         16
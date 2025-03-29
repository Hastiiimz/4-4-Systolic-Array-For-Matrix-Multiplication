module Activation (
  input  wire [7:0] data_in ,
  input  wire [7:0] thresh  ,
  output wire [7:0] data_out
);

  assign data_out = data_in < thresh ? 0 : data_in;

endmodule
module Quantization (
  input  wire [23:0] data_in ,
  output wire [ 7:0] data_out
);

  assign data_out = data_in < 255 ? data_in : 255;

endmodule
module MAC (
  input  wire        clk    ,
  input  wire        rst    ,
  input  wire [ 7:0] a_in   ,
  input  wire [ 7:0] w_in   ,
  input  wire [23:0] sum_in ,
  output reg  [23:0] sum_out,
  output wire [ 7:0] a_out  ,
  output wire [ 7:0] w_out
);


  reg [7:0] a_reg, w_reg;

  wire [23:0] sum    ;
  wire [15:0] product;

  assign product = a_reg * w_reg;
  assign sum     = sum_in + product;
  assign a_out   = a_reg;
  assign w_out   = w_reg;

  always @(posedge clk) begin
    a_reg   <= a_in;
    w_reg   <= w_in;
    sum_out <= sum;
  end


endmodule
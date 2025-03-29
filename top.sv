module top #(parameter N = 4) (
  input  wire           clk  ,
  input  wire           rst  ,
  input  wire           start,
  input  wire [8*N-1:0] a_in ,
  input  wire [8*N-1:0] w_in ,
  output wire [8*N-1:0] y_out,
  output wire           ready,
  output wire           done
);

  wire [7:0] a_in_vec [0:N-1];
  wire [7:0] w_in_vec [0:N-1];
  wire [7:0] y_out_vec[0:N-1];

  Array #(.N(N)) dut (
    .clk  (clk      ),
    .rst  (rst      ),
    .start(start    ),
    .a_in (a_in_vec ),
    .w_in (w_in_vec ),
    .y_out(y_out_vec),
    .ready(ready    ),
    .done (done     )
  );

  generate
    for (genvar i = 0; i < N; i = i+1) begin
      assign a_in_vec[i] = a_in[8*(i+1)-1:8*i];
      assign w_in_vec[i] = w_in[8*(i+1)-1:8*i];
      assign y_out[8*(i+1)-1:8*i] = y_out_vec[i];
    end
  endgenerate


endmodule

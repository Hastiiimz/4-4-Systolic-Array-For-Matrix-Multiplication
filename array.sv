module Array #(parameter N = 4) (
  input  wire       clk          ,
  input  wire       rst          ,
  input  wire       start        ,
  input  wire [7:0] a_in [0:N-1] ,
  input  wire [7:0] w_in [0:N-1] ,
  output wire [7:0] y_out [0:N-1],
  output wire       ready        ,
  output wire       done
);

  wire [ 7:0] mac_a_in   [0:N-1][0:N-1];
  wire [ 7:0] mac_w_in   [0:N-1][0:N-1];
  wire [23:0] mac_sum_in [0:N-1][0:N-1];
  wire [23:0] mac_sum_out[0:N-1][0:N-1];
  wire [ 7:0] mac_a_out  [0:N-1][0:N-1];
  wire [ 7:0] mac_w_out  [0:N-1][0:N-1];

  wire [7:0] quantization[0:N-1];
  wire [7:0] activation  [0:N-1];


  parameter IDLE         = 2'b00;
  parameter LOAD_WEIGHTS = 2'b01;
  parameter COMPUTE      = 2'b10;
  parameter DONE         = 2'b11;

  reg [ 1:0] state, next_state;
  reg [31:0] counter;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case (state)
      IDLE : begin
        next_state <= start ? LOAD_WEIGHTS : IDLE;
      end
      LOAD_WEIGHTS : begin
        next_state <= counter == N-1 ? COMPUTE : LOAD_WEIGHTS;
      end
      COMPUTE : begin
        next_state <= counter == 4*N-1 ? DONE : COMPUTE;
      end
      DONE : begin
        next_state <= IDLE;
      end
      default : next_state <= IDLE;
    endcase
  end

  assign ready = state == IDLE;
  assign done  = state == DONE;


  always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 0;
    end else begin
      if (state == IDLE) begin
        counter <= 0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  generate
    for (genvar i = 0; i < N; i = i + 1) begin
      for (genvar j = 0; j < N; j = j + 1) begin
        MAC mac_i_j (
          .clk(clk),
          .rst(rst),
          .a_in(mac_a_in[i][j]),
          .w_in(mac_w_in[i][j]),
          .sum_in(mac_sum_in[i][j]),
          .sum_out(mac_sum_out[i][j]),
          .a_out(mac_a_out[i][j]),
          .w_out(mac_w_out[i][j])
        );
        if (j != N-1) begin
          assign mac_a_in[i][j+1] = mac_a_out[i][j];
        end
        if (i != N-1) begin
          assign mac_sum_in[i+1][j] = mac_sum_out[i][j];
        end
        if (i > 0)
          assign mac_w_in[i][j] = state == LOAD_WEIGHTS ? mac_w_out[i-1][j] : mac_w_out[i][j];
      end
      assign mac_sum_in[0][i] = 0;
      assign mac_a_in[i][0]   = a_in[i];
      assign mac_w_in[0][i]   = state == LOAD_WEIGHTS ? w_in[i] : mac_w_out[0][i];
    end
  endgenerate

  generate
    for (genvar i = 0; i < N; i = i + 1) begin
      Quantization quantization_i (
        .data_in(mac_sum_out[N-1][i]),
        .data_out(quantization[i])
      );
      Activation activation_i (
        .data_in (quantization[i]),
        .thresh  (10             ),
        .data_out(activation[i]  )
      );
      assign y_out[i] = activation[i];
    end
  endgenerate

endmodule

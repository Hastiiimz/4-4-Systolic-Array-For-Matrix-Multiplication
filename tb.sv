`timescale 1ns/1ps
module tb ();

  parameter N = 4;

  reg clk;
  reg rst;

  reg  [7:0] a_in [0:N-1];
  reg  [7:0] w_in [0:N-1];
  wire [7:0] y_out[0:N-1];

  wire ready, done;
  reg  start;

  reg [7:0] a_mat[0:N-1][0:N-1] = '{
    '{4, 0, 2, 1},
    '{4, 3, 2, 0},
    '{4, 3, 0, 1},
    '{4, 3, 2, 1}
  };
  reg [7:0] w_mat[0:N-1][0:N-1] = '{
    '{1, 2, 3, 4},
    '{1, 2, 3, 4},
    '{1, 2, 3, 4},
    '{1, 2, 3, 4}
  };

  wire [7:0] a_fifo_data_in [0:N-1];
  reg        a_fifo_push    [0:N-1];
  reg        a_fifo_pop     [0:N-1];
  wire [7:0] a_fifo_data_out[0:N-1];
  wire       a_fifo_full    [0:N-1];
  wire       a_fifo_empty   [0:N-1];

  reg  [7:0] w_fifo_data_in [0:N-1];
  reg        w_fifo_push    [0:N-1];
  reg        w_fifo_pop     [0:N-1];
  wire [7:0] w_fifo_data_out[0:N-1];
  wire       w_fifo_full    [0:N-1];
  wire       w_fifo_empty   [0:N-1];


  reg [7:0] a_fifo_in[0:N-1];
  reg state;


  Array #(.N(N)) dut (
    .clk  (clk  ),
    .rst  (rst  ),
    .start(start),
    .a_in (a_in ),
    .w_in (w_in ),
    .y_out(y_out),
    .ready(ready),
    .done (done )
  );

  generate
    for (genvar i = 0; i < N; i = i + 1) begin
      FIFO #(.WIDTH(8), .HEIGHT(3*N)) a_fifo_i (
        .clk     (clk     ),
        .rst     (rst     ),
        .data_in (a_fifo_data_in[i] ),
        .push    (a_fifo_push[i]   ),
        .pop     (a_fifo_pop[i]     ),
        .data_out(a_fifo_data_out[i]),
        .full    (a_fifo_full[i]    ),
        .empty   (a_fifo_empty[i]   )
      );
      FIFO #(.WIDTH(8), .HEIGHT(N)) w_fifo_i (
        .clk     (clk               ),
        .rst     (rst               ),
        .data_in (w_fifo_data_in[i] ),
        .push    (w_fifo_push[i]    ),
        .pop     (w_fifo_pop[i]     ),
        .data_out(w_fifo_data_out[i]),
        .full    (w_fifo_full[i]    ),
        .empty   (w_fifo_empty[i]   )
      );
      assign a_in[i] = a_fifo_data_out[i];
      assign w_in[i] = w_fifo_data_out[i];
      assign a_fifo_data_in[i] = state ? y_out[i] : a_fifo_in[i];
    end

  endgenerate




  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk; //100 Mhz
  end


  initial begin
    for (int i  = 0;i < N ;i = i+1 ) begin
      a_fifo_pop[i] <= 0;
      a_fifo_push[i] <= 0;
      w_fifo_pop[i] <= 0;
      w_fifo_push[i] <= 0;
    end
    start <= 0;
    state <= 0;
    rst <= 1;
    #20;
    rst <= 0;
    for (int t = 0; t < N ; t = t+1) begin
      @(posedge clk);
      for (int row = 0; row < N ; row = row+1 ) begin
        a_fifo_push[row] <= 1;
        w_fifo_push[row] <= 1;
        a_fifo_in[row] <= 0;
        w_fifo_data_in[row] <= w_mat[row][N-1-t];
      end
    end
    for (int t = 0; t < 2*N ; t = t+1) begin
      @(posedge clk);
      for (int row = 0; row < N ; row = row+1 ) begin
        a_fifo_push[row] <= 1;
        if (t < row || t >= row + N) begin
          a_fifo_in[row] <= 0;
        end else begin
          a_fifo_in[row] <= a_mat[row][t-row];
        end
      end
    end
    for (int i  = 0;i < N ;i = i+1 ) begin
      a_fifo_push[i] <= 0;
      w_fifo_push[i] <= 0;
    end
    if (!ready) begin
      @(posedge ready);
    end
    @(posedge clk);
    start <= 1;
    state <= 1;
    @(posedge clk);
    start <= 0;
    for (int i  = 0;i < N ;i = i+1 ) begin
      a_fifo_pop[i] <= 1;
      w_fifo_pop[i] <= 1;
      a_fifo_push[i] <= 1;
    end

    @(posedge done)
      #100;
    $finish;
  end

endmodule
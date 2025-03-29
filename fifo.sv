module FIFO #(
  parameter WIDTH  = 8,
  parameter HEIGHT = 8
) (
  input  wire             clk     ,
  input  wire             rst     ,
  input  wire [WIDTH-1:0] data_in ,
  input  wire             push    ,
  input  wire             pop     ,
  output wire [WIDTH-1:0] data_out, //top
  output wire             full    ,
  output wire             empty
);

  reg [WIDTH-1:0] arr [0:HEIGHT];
  int             head, tail;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      head = 0;
      tail = 0;
    end else begin
      if (push && !full) begin
        arr[tail] = data_in;
        tail      = tail == HEIGHT ? 0 : tail+1;
      end 
      if (pop && !empty) begin
        head = head == HEIGHT ? 0 : head+1;
      end
    end
  end

  assign empty    = head == tail;
  assign full     = head == 0 ? tail == HEIGHT : (head - tail) == 1;
  assign data_out = arr[head];

endmodule
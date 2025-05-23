module lfsr(input clk, reset, en, output reg [7:0] q);
  always @(posedge clk or negedge reset) begin
    if (~reset)
      q <= 8'd1; // can be anything except zero
    else if (en)
      q <= {q[6:0], q[7] ^ q[5] ^ q[4] ^ q[3]}; // polynomial for maximal LFSR
  end
endmodule
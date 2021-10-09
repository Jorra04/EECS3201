module Lab2a(in, out);
	input [3:0] in;
	output [6:0] out;
	
	assign a = in[3];
	assign b = in[2];
	assign c = in[1];
	assign d = in[0];
	
	assign out[0] = (~a & ~b & ~c & ~d) | (~a & ~b & c & ~d) | (~a & ~b & c & d) | (~a & b & ~c & d) | (~a & b & c & ~d) | (~a & b & c & d) | (a & ~b & ~c & ~d)
							| (a & ~b & ~c & d) | (a & ~b & c & ~d) | (a & b & ~c & ~d) | (a & b & c & ~d) | (a & b & c & d);
							
	assign out[1] = (~a & ~b & ~c & ~d) | (~a & ~b & ~c & d) | (~a & ~b & c & ~d) | (~a & ~b & c & d) | (~a & b & ~c & ~d) | (~a & b & c & d) | (a & ~b & ~c & ~d)
						| (a & ~b & ~c & d)  |(a & ~b & c & ~d) | (a & b & ~c & d);
						
	assign out[2] = (~a & ~b & ~c & ~d) | (~a & ~b & ~c & d) | (~a & ~b & c & d) | (~a & b & ~c & ~d) | (a & b & c & d) | (a & b & c & d)  ;

	
	
endmodule
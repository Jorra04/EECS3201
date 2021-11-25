`timescale 1 ns/10ps

module test2_tb;

	reg clk,a;
	wire[3:0] r;
	
	test2 test2_test(
		.clk(clk),
		.a(a),
		.r(r)
	);
	
	
	always@(r) begin
		
		if(r == 0)
			$display("All outputs are zero");
			
	end
	
	
	
	always begin
		clk = 1'b0;
		#10;
		
		clk = 1'b1;
		#10;
	end
	
	initial begin
	
		a = 0;
		#100;
		
		a = 1;
		#200;
		
		a = 0;
		#300;
		
			
		$stop;
		
	end
	


endmodule
`timescale 1 ns/10ps

module test2_tb;

	reg clk,a;
	wire[3:0] r;
	reg allFalse = 1'b1;
	test2 test2_test(
		.clk(clk),
		.a(a),
		.r(r)
	);
	
	
	
	always begin
		clk = 1'b1;
		#10;
		
		clk = 1'b0;
		#10;
	end
	
	initial begin
	
		a = 0;
		#100;
		allFalse = allFalse && (r==0);
		
		a = 1;
		#200;
		allFalse = allFalse && (r==0);
		
		a = 0;
		allFalse = allFalse && (r == 0);
		
		if(allFalse)
			$display("All outputs are zero");
			
		$stop;
		
	end
	


endmodule
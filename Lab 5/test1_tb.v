`timescale 1 ns/10ps

module test1_tb;

	reg a,b,c;
	wire x,y;
	
	test1 test1_test(
		.a(a),
		.b(b),
		.c(c),
		.x(x),
		.y(y)
	);
	
	
	initial
		begin
			assign a = 0;
			assign b = 0;
			assign c = 0;
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			assign a = 0;
			assign b = 0;
			assign c = 1;	
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			assign a = 0;
			assign b = 1;
			assign c = 0;
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			assign a = 0;
			assign b = 1;
			assign c = 1;
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			assign a = 1;
			assign b = 0;
			assign c = 0;
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			assign a = 1;
			assign b = 0;
			assign c = 1;
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			assign a = 1;
			assign b = 1;
			assign c = 0;
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			assign a = 1;
			assign b = 1;
			assign c = 1;
			#20
			if(x == 0 && y == 0)
				$display("All outputs are zero");
			
			
			
			$stop;
			
		end


endmodule
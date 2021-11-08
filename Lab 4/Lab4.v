module Lab4(clkin, hexValue, hexValue2, s);
	
	input clkin, s;
	wire clkout;
//	reg[3:0] value = 4'b0100; 
//	reg[3:0] value2 = 4'b0010;

	reg[3:0] value, value2, origVal1, origVal2;

	output[6:0] hexValue, hexValue2;
	
	ClockDivider wrapper(
		.cin(clkin),
		.cout(clkout)
	);
	
	
	
	always@(*)
	begin
		if(s)
		begin	
			origVal1 <= 4'b0000;
			origVal2 <= 4'b0011;
		end
		else
		begin
			origVal1 <= 4'b0100;
			origVal2 <= 4'b0010;
		end
	end
	
	
	always @ (posedge clkout)
	begin
		
		if(value == 0 && value2 == 0)
		begin
			value <= origVal1;
			value2 <= origVal2;
		end
		else
		begin
			if(value == 0)
			begin
				value <= 9;
				value2 <= value2 - 4'b0001;
			end
			else
				value <= value - 4'b0001;
		
		end
		
		
		
		
	end
	
	
	Lab2 hex01(value, hexValue);
	Lab2 hex02(value2, hexValue2);
	
	
endmodule
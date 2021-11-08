module Lab4(clkin, s, reset, pause, hexValue, hexValue2);
	
	input clkin, s, reset, pause;
	wire clkout;

	reg[3:0] value;
	reg[3:0] value2;
	reg[3:0] origVal1, origVal2;
	output[6:0] hexValue, hexValue2;

	reg paused;
	
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
	

	always @(posedge pause)
	begin
		paused <= ~paused;
	end

	
	always @ (posedge clkout or negedge reset)
	begin
	
		if(~reset)
		begin
			value <= origVal1;
			value2 <= origVal2;
		end
	
		else if(~paused)
		begin
			if(value == 0 && value2 == 0)
			begin
			end
		
			else if(value == 0)
			begin
				value <= 9;
				value2 <= value2 - 1;
			end
			else
				value <= value - 1;
		end
		
	end
	
	
	Lab2 hex01(value, hexValue);
	Lab2 hex02(value2, hexValue2);
	
	
endmodule
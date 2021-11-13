module clockDivider(

input wire clkin, 
output reg clkout

);


always @(posedge clkin) 
begin
		clkout <= ~clkout;
	
end

	
endmodule
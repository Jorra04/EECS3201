`timescale 1 ns/10 ps

module lab3_testbench;

   integer i,j;
	wire [4:0] hex0bin,hex1bin;
	
	reg [3:0] num1,num2;
	reg s;
   wire [6:0] hex5,hex3,hex1,hex0;

   localparam period = 5;  
	
   lab3 UUT(.inputBus(num1),.inputBus2(num2),.outputBus(hex5),.outputBus2(hex3),.outputBus3(hex0),.outputBus4(hex1), .s(s));	
	hex2bin dex0decode(.in(hex0),.out(hex0bin));
	hex2bin dex1decode(.in(hex1),.out(hex1bin));
     
   initial begin
			//addition test
			$display("Addition Test Started");
			s = 1'b0;
			for (i=0; i<16; i=i+1) begin
				for (j=0; j<16; j=j+1) begin
					num1 = i;
					num2 = j;
					
					#period;
					
					//uncomment for printing of test cases
					//$display("num1=%b, num2=%b, expected=%b, got=%b", num1, num2, i+j, {hex1bin[3:0],hex0bin[3:0]});
					
					if(hex1bin == 5'b10000)
						$display("youre doing addition with positive numbers and you got a negative answer");
						
					if(i+j != {hex1bin[3:0],hex0bin[3:0]})
						$display("wrong result num1=%b, num2=%b, expected=%b, got=%b", num1, num2, i+j, {hex1bin[3:0],hex0bin[3:0]});
				end
			end
			$display("Addition Test Complete");
			
			//subtraction test 
			$display("Subtraction Test Started");
			s = 1'b1;
			for (i=0; i<16; i=i+1) begin
				for (j=0; j<16; j=j+1) begin
					num1 = i;
					num2 = j;
					
					#period;
					
					//uncomment for printing of test cases
					//$display("num1=%b, num2=%b, expected=%b, got=%b", num1, num2, (~(i-j))+1, {hex1bin[3:0],hex0bin[3:0]});
					
					if(i-j < 0 && ((~(i-j))+1 != {hex1bin[3:0],hex0bin[3:0]} || hex1bin != 5'b10000))
						$display("wrong result num1=%b, num2=%b, expected=%b, got=%b", num1, num2, (~(i-j))+1, {hex1bin[3:0],hex0bin[3:0]});
					
					if(i-j >= 0 && (i-j != {hex1bin[3:0],hex0bin[3:0]} || hex1bin == 5'b10000))
						$display("wrong result num1=%b, num2=%b, expected=%b, got=%b", num1, num2, (~(i-j))+1, {hex1bin[3:0],hex0bin[3:0]});
						
				end
			end
			$display("Subtraction Test Complete");
			
		end
		
endmodule

//decode module
module hex2bin(in,out);
	input [6:0] in;
	output reg [4:0] out;

		always @(*) begin 
		case(in) 
			7'b1111111	:	out <= 5'b00000;	//blank
			7'b1000000	:	out <= 5'b00000; //0
			7'b1111001	:	out <= 5'b00001; //1
			7'b0100100	:	out <= 5'b00010; //2 	
			7'b0110000	:	out <= 5'b00011; //3	
			7'b0011001	:	out <= 5'b00100; //4	
			7'b0010010	:	out <= 5'b00101; //5	
			7'b0000010	:	out <= 5'b00110; //6	
			7'b1111000	:	out <= 5'b00111; //7	
			7'b0000000	:	out <= 5'b01000; //8	
			7'b0010000	:	out <= 5'b01001; //9	
			7'b0001000	:	out <= 5'b01010; //A	
			7'b0000011	:	out <= 5'b01011; //B	
			7'b1000110	:	out <= 5'b01100; //C	
			7'b0100001	:	out <= 5'b01101; //D	
			7'b0000110	:	out <= 5'b01110; //E	
			7'b0001110	:	out <= 5'b01111; //F	
			7'b0111111 	: 	out <= 5'b10000; //-
		endcase
	end

endmodule 
module Lab3a(inputBus, inputBus2, outputBus, outputBus2, outputBus3, outputBus4, s);
	
	input[3:0] inputBus, inputBus2;
	input s;
	
	output[6:0] outputBus, outputBus2, outputBus3, outputBus4;
	
	Lab2a hex1(inputBus, outputBus);
	Lab2a hex2(inputBus2, outputBus2);
	
	wire[3:0] result;
	reg[3:0] temp, tempResult;
	wire carryOut;
	
	adder4a adder(0, inputBus, temp, result, carryOut);

	
	//Set outputBus4 to off
	assign outputBus4[0] = 1'b1;
	assign outputBus4[1] = ~carryOut || s;
	assign outputBus4[2] = ~carryOut || s;
	assign outputBus4[3] = 1'b1;
	assign outputBus4[4] = 1'b1;
	assign outputBus4[5] = 1'b1;
	assign outputBus4[6] = ~(~carryOut && s);

	
	//Handle twos complement conversion
	always @(*)
	begin
		if(s)	
			temp <= (~inputBus2) + 1;
		else
			temp <= inputBus2;
			
		if(((inputBus < inputBus2) && s))
			tempResult <= (~result) + 1;
		else
			tempResult <= result;
	end


	
	Lab2a hex3(tempResult, outputBus3);
	
	
endmodule


//Full adder from class slides
module fullAdder2(Cin, x, y, s, Cout);
	
	input Cin, x, y;
	output s, Cout;
	
	assign s = x ^ y ^ Cin;
	assign Cout = (x&y) | (x & Cin) | (y & Cin);

endmodule


module adder4a(carryIn, X, Y, S, carryOut);

	input carryIn;
	input[3:0] X,Y;
	output[3:0] S;
	output carryOut;
	wire[3:1] C;
	
	fullAdder2 stage0(carryIn, X[0], Y[0], S[0], C[1]);
	fullAdder2 stage1(C[1], X[1], Y[1], S[1], C[2]);
	fullAdder2 stage2(C[2], X[2], Y[2], S[2], C[3]);
	fullAdder2 stage3(C[3], X[3], Y[3], S[3], carryOut);
	
endmodule



module Lab2a(inputBus, outputBus);

	input [3:0] inputBus;
	output [6:0] outputBus;

	//outputBus[0] corresponds to LEDA
 	assign outputBus[0] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  | 
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])  | 
								 (inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])    | 
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0]);
	
	//outputBus[1] corresponds to LEDB
	assign outputBus[1] = (~inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & inputBus[2] & inputBus[1] & ~inputBus[0])  	 |
								 (inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]);     
								 
	
	//outputBus[2] corresponds to LEDC	
	assign outputBus[2] = (~inputBus[3] & ~inputBus[2] & inputBus[1] & ~inputBus[0])  |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & inputBus[2] & inputBus[1] & ~inputBus[0])    |
								 (inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]);     
	
	//outputBus[3] corresponds to LEDD
	assign outputBus[3] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  |
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])  |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & ~inputBus[2] & inputBus[1] & ~inputBus[0])   |
								 (inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]);     
							
	//outputBus[4] corresponds to LEDE						
	assign outputBus[4] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  |
								 (~inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0])  |
								 (~inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0]);
									
	//outputBus[5] corresponds to LEDF								
	assign outputBus[5] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  |
								 (~inputBus[3] & ~inputBus[2] & inputBus[1] & ~inputBus[0])  |
								 (~inputBus[3] & ~inputBus[2] & inputBus[1] & inputBus[0])   |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0])    |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & inputBus[0]);
							
								
	assign outputBus[6] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1]) |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]) |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0]);

endmodule
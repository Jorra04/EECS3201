module Lab2(inputBus, outputBus);

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
							
	//outputBus[6] corresponds to LEDG						
//	assign outputBus[6] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & ~inputBus[0]) |
//								 (~inputBus[3] & ~inputBus[2] & ~inputBus[1] & inputBus[0])  |
//								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0])    |
//								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0]);


// A = inputBus[3], B = inputBus[2], C = inputBus[1], D = inputBus[0]								
//								
//								Original form shown above, reduction steps are below...
//								
//								= (~A~B~C~D + ~A~B~CD + ~ABCD + AB~C~D)   
//								= (~A~B~C(~D + D) + ~ABCD + AB~C~D) Complement Law on D
//								= (~A~B~C(1) + ~ABCD + AB~C~D)
//								= (~A~B~C + ~ABCD + AB~C~D)
								
	assign outputBus[6] = (~inputBus[3] & ~inputBus[2] & ~inputBus[1]) |
								 (~inputBus[3] & inputBus[2] & inputBus[1] & inputBus[0]) |
								 (inputBus[3] & inputBus[2] & ~inputBus[1] & ~inputBus[0]);

endmodule
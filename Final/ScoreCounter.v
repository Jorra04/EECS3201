module ScoreCounter(clkin, reset, gameOver, hex01, hex02, hex03, hex04);
	input clkin, reset;
	wire clkout;
	input gameOver;
	reg[3:0] thousandsSecond, hundredsSecond, tensSecond, onesSecond;
	output[6:0] hex01, hex02, hex03, hex04;
	reg[31:0] counter;

	
	always @ (posedge clkin or negedge reset)
	begin

	
			if(~reset)
			begin
				thousandsSecond <= 4'b0000;
				hundredsSecond <= 4'b0000;
				tensSecond <= 4'b0000;
				onesSecond <= 4'b0000;
				counter <= 0;
			end
			else
			begin
	
				if(!gameOver)
					if(!((thousandsSecond == 9) && (hundredsSecond == 9) && (tensSecond == 9) && (onesSecond == 9) ))
				begin
					counter <= counter + 1;
			
					if(counter == 50000000)
					begin
						counter <= 0;
						if(hundredsSecond == 9 && tensSecond == 9 && onesSecond == 9)
						begin
							hundredsSecond <= 0;
							tensSecond <= 0;
							onesSecond <= 0;
							thousandsSecond <= thousandsSecond + 1;
						end
						else if(tensSecond == 9 && onesSecond == 9)
						begin
						
							hundredsSecond <= hundredsSecond + 1;
							tensSecond <= 0;
							onesSecond <= 0;
							
						end
						else if(onesSecond == 9)
						begin
							onesSecond <= 0;
							tensSecond <= tensSecond + 1;
						end
						else
							onesSecond <= onesSecond + 1;
					end
				end
				
			end
		end
	
	
	Lab2 displayHex01(onesSecond, hex01);
	Lab2 displayHex02(tensSecond, hex02);
	Lab2 displayHex03(hundredsSecond, hex03);
	Lab2 displayHex04(thousandsSecond, hex04);
	
	
endmodule
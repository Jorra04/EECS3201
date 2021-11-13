module EECS3201Final(clkin,rst,MISO,hsync,vsync,r,g,b,MOSI,spiclk,chipselect, hex01, hex02, hex03, hex04);
	//inputs
	input clkin; 	//50MHZ input clock
	input MISO;		//ADXL345 MISO
	input rst;		//the main rst (goes through the whole circuit)
	
	//outputs for VGA
	output reg hsync, vsync;
	output reg [3:0] r, g, b;
	
	//outputs for ADXL345
	output MOSI;			//ADXL345 MOSI
	output spiclk;			//ADXL345 SPIclk
	output chipselect;	//ADXL345 CS
	
	reg getData;			//pulse to the handler to issue read commands to the adxl345
	
	//find a better way
	wire [7:0] tempx, tempy;
	assign tempx = ~dataXout[7:0]+1'b1;
	assign tempy = ~dataYout[7:0]+1'b1;
	
	wire [7:0] temptargetx, temptargety;
	assign temptargetx = rng_out[7] ? targetx - 1'b1 : targetx + 1'b1;
	assign temptargety = rng_out[0] ? targety + 1'b1 : targety - 1'b1;
	
	//vga timing related registers 
	reg de;
	reg [9:0] x, y;
	
	//game logic registers
	//note player width and height is fixed 32by32
	reg [9:0] playerx, playery, targetx, targety; 
	reg [8:0] targetsize;
	wire [8:0] dataXout,dataYout;
	reg [5:0] counter;		

	//rng state reg
	reg rng_state;
	wire [7:0] rng_out;
	
	wire clk25M, clk1M;
	/*
	*PLL inclk = 50MHZ
	*PLL c0 = 25MHZ should be 25.2MHZ for proper 60Hz
	*PLL c1 = 1MHz
	*/
	pll	pll_inst (
		.areset ( areset_sig ),
		.inclk0 ( clkin ),
		.c0 ( clk25M ),
		.c1 ( clk1M ),
		.locked ( locked_sig )
	);
	
	output[6:0] hex01, hex02, hex03, hex04; 
	
	ScoreCounter score(clkin, rst, gameOver, hex01, hex02, hex03, hex04);

	//horizontal timings
	parameter HA_END = 639;
	parameter HS_STA = HA_END + 16;
	parameter HS_END = HS_STA + 96;
	parameter LINE = 799;
	
	//vertical timings
	parameter VA_END = 479;
	parameter VS_STA = VA_END + 10;
	parameter VS_END = VS_STA + 2;
	parameter SCREEN = 524;
	
	//writing sizes
	parameter BLOCK_SIZE = 16;
	parameter LETTER_SPACING = 70;
	
	parameter FIRST_BLOCK_INDENT_START = 84;
	parameter FIRST_BLOCK_INDENT_END = FIRST_BLOCK_INDENT_START + LETTER_SPACING; //In case we want to change the letter spacing
	
	parameter SECOND_BLOCK_INDENT_START = FIRST_BLOCK_INDENT_END + 70;
	parameter SECOND_BLOCK_INDENT_END = SECOND_BLOCK_INDENT_START + LETTER_SPACING;
	
	parameter THIRD_BLOCK_INDENT_START = SECOND_BLOCK_INDENT_END + 70;
	parameter THIRD_BLOCK_INDENT_END = THIRD_BLOCK_INDENT_START + LETTER_SPACING;
	
	parameter FOURTH_BLOCK_INDENT_START = THIRD_BLOCK_INDENT_END + 70;
	parameter FOURTH_BLOCK_INDENT_END = FOURTH_BLOCK_INDENT_START + LETTER_SPACING;
	
	parameter TOP_LETTERS_START = 45;
	parameter TOP_LETTERS_END = TOP_LETTERS_START + 75;

	parameter BOTTOM_LETTERS_START = 295;
	parameter BOTTOM_LETTERS_END = BOTTOM_LETTERS_START + 75;
	
	
	always @(*)begin
		hsync = ~(x >= HS_STA && x < HS_END);  
      vsync = ~(y >= VS_STA && y < VS_END);
		de = (x <= HA_END && y <= VA_END);	
	end
	
	reg gameOver;
	//note this is not the proper way to define should be changed
	//ADXL345 module
	ADXL345Handler accelerometer(clk1M,MISO,getData,rst,spiclk,chipselect,MOSI,dataXout,dataYout);
	//lfsr module 
	lfsr rng(clk25M, rst, rng_state, rng_out);
	
	always @(posedge clk25M or negedge rst) begin
		if(~rst)begin
			//rst the default values
			x <= 0;
			y <= 0;
			playerx <= 303;
			playery <= 223;
			getData <= 0;
			targetx <= 192;
			targety <= 112;
			targetsize <= 255;
			counter <= 0;
			rng_state <= 0;
			gameOver <= 1'b0;

			
		end else begin 
			
			if(de)begin	
				
				if(!gameOver) begin
					//Check if the player object is within the target object.	
					if(playerx < targetx || playery < targety || (playerx +32) > (targetx + targetsize) || (playery + 32) > (targety + targetsize)  )
					begin
						
						gameOver <= 1'b1;
						
					end
			
					//note non of the draw register should be updated during the de == 1 period 
					//or artifacts may appear
					else if(x >= playerx && x <= playerx+32 && y >= playery && y <= playery+32)begin
						//player is a pink color
						r <= 4'b1111;
						g <= 4'b1001;
						b <= 4'b1100;
					end else if(x >= targetx && x <= (targetx+targetsize) && y >= targety && y <= (targety+targetsize))begin
						//target color is blue
						r <= 4'b0010;
						g <= 4'b1000;
						b <= 4'b1111;
					end else begin
						//background is a orange color
						r <= 4'b1111;
						g <= 4'b1100;
						b <= 4'b1001;
					end
					
				end
				else
				begin
					//paint the game over screen
					if(0 <= y && y < 250)
					begin
						//Paint the top letters
						//Logic for creating the letter 'G'
						if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
						begin
							if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_START + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FIRST_BLOCK_INDENT_START <= x && x < FIRST_BLOCK_INDENT_START + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (TOP_LETTERS_END - BLOCK_SIZE < y && y < TOP_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FIRST_BLOCK_INDENT_END - BLOCK_SIZE <= x && x <= FIRST_BLOCK_INDENT_END) && (((TOP_LETTERS_START +TOP_LETTERS_END) /2) < y && y < TOP_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((((FIRST_BLOCK_INDENT_START + FIRST_BLOCK_INDENT_END) /2) <= x && x <= FIRST_BLOCK_INDENT_END) && (((TOP_LETTERS_START +TOP_LETTERS_END) /2) < y && y < ((TOP_LETTERS_START +TOP_LETTERS_END) /2) + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else
							begin
								r <= 4'b0000;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							
						end
						//Logic for creating the letter 'A'
						else if((SECOND_BLOCK_INDENT_START <= x && x <= SECOND_BLOCK_INDENT_END)&& (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
						begin
							if((SECOND_BLOCK_INDENT_START <= x && x <= SECOND_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_START + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_START + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((SECOND_BLOCK_INDENT_END - BLOCK_SIZE<= x && x < SECOND_BLOCK_INDENT_END + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_END) && (((TOP_LETTERS_START +TOP_LETTERS_END) /2) < y && y < ((TOP_LETTERS_START +TOP_LETTERS_END) /2) + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else 
							begin
								r <= 4'b0000;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for Creating letter 'M' will go here.
						else if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
						begin
							r <= 4'b1111;
							g <= 4'b0000;
							b <= 4'b0000;
						end
						//Logic for creating letter 'E'
						else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
						begin
							if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_START + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FOURTH_BLOCK_INDENT_START <= x && x < FOURTH_BLOCK_INDENT_START + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (TOP_LETTERS_END - BLOCK_SIZE < y && y < TOP_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FOURTH_BLOCK_INDENT_START <= x && x < FOURTH_BLOCK_INDENT_END) && (((TOP_LETTERS_START +TOP_LETTERS_END) /2) < y && y < ((TOP_LETTERS_START +TOP_LETTERS_END) /2) + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							
							else 
							begin
								r <= 4'b0000;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
	
						else 
						begin
							r <= 4'b0000;
							g <= 4'b0000;
							b <= 4'b0000;
						end
					end
					else
					//Bottom half letters
					begin
						//Logic for creating the 'O'
						if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
						begin
							if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_START + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FIRST_BLOCK_INDENT_START <= x && x < FIRST_BLOCK_INDENT_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FIRST_BLOCK_INDENT_END - BLOCK_SIZE<= x && x < FIRST_BLOCK_INDENT_END + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((FIRST_BLOCK_INDENT_START <= x && x < FIRST_BLOCK_INDENT_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else 
							begin
								r <= 4'b0000;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for creating the 'V'
						else if((SECOND_BLOCK_INDENT_START <= x && x <= SECOND_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
						begin
							if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((SECOND_BLOCK_INDENT_END - BLOCK_SIZE<= x && x < SECOND_BLOCK_INDENT_END + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else 
							begin
								r <= 4'b0000;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for creating the 'E'
						else if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
						begin
							if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_START + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((THIRD_BLOCK_INDENT_START <= x && x < THIRD_BLOCK_INDENT_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE < y && y < BOTTOM_LETTERS_END))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							else if((THIRD_BLOCK_INDENT_START <= x && x < THIRD_BLOCK_INDENT_END) && (((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) < y && y < ((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) + BLOCK_SIZE))
							begin
								r <= 4'b1111;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							
							else 
							begin
								r <= 4'b0000;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for creating the 'R' not done yet.
						else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END))
						begin
							r <= 4'b1111;
							g <= 4'b0000;
							b <= 4'b0000;
						end
						else
						begin
							r <= 4'b0000;
							g <= 4'b0000;
							b <= 4'b0000;
						end
						
					end
					
				end
				//if none of the above are true, paint it as black.
			end else begin		
				r <= 4'b0000;
				g <= 4'b0000;
				b <= 4'b0000;
	
		end
		
			
			
			
			//read data from the adxl345 and enable the rng
			if(y == 480 || y == 481)begin
				getData <= ~getData;
				if(counter == 0)
					rng_state <= ~rng_state;
			end
			
			//update playerx and playery
			if(y == 520)begin
				playerx <= dataXout[8] ? 303 + (tempx << 1) : 303 - (dataXout[7:0] << 1);
				playery <= dataYout[8] ? 223 - (tempy << 1) : 223 + (dataYout[7:0] << 1);
			end
			
			//screen timing logic
			if (x == LINE) begin  
				x <= 0;
				if(y == SCREEN) begin 
					y <= 0;
					if(counter == 60)begin
						counter <= 0;
						targetsize <= targetsize - 1'b1;
					end else begin
						counter <= counter + 1'b1;
						//this needs to be improved
						//x limiter
						if ((temptargetx < (640 - targetsize)) && (temptargetx > 0))  
							targetx <= temptargetx;
						
						//y limiter
						if ((temptargety < (480 - targetsize)) && (temptargety > 0))  
							targety <= temptargety;
						
					end
					
				end else 
					y <= y + 1'b1;
				
			end else 
				x <= x + 1;
				
		end
	end
	
endmodule
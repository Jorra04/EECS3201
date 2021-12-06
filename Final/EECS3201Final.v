module EECS3201Final(clkin,rst, pause ,MISO,hsync,vsync,r,g,b,MOSI,spiclk,chipselect, hex01, hex02, hex03, hex04);
	//inputs
	input clkin; 	//50MHZ input clock
	input MISO;		//ADXL345 MISO
	input rst;		//the main rst (goes through the whole circuit)
	input pause;
	
	//outputs for VGA
	output reg hsync, vsync;	//VGA sync's
	output reg [3:0] r, g, b;	//VGA RGB
	
	//outputs for ADXL345
	output MOSI;			//ADXL345 MOSI
	output spiclk;			//ADXL345 SPIclk
	output chipselect;	//ADXL345 CS
	reg getData;			//pulse to ADXL345Handler to issue read commands to the adxl345
	reg startGame;	 		//Reg to see when game should start.
	
	
	//outputs for score counter
	output[6:0] hex01, hex02, hex03, hex04;
	
	//find a better way
	wire [7:0] tempx, tempy;
	assign tempx = ~dataXout[7:0]+1'b1;
	assign tempy = ~dataYout[7:0]+1'b1;
	wire [7:0] temptargetx, temptargety, rng_target;
	assign temptargetx = rng_out[7] ? targetx - 1'b1 : targetx + 1'b1;
	assign temptargety = rng_out[0] ? targety + 1'b1 : targety - 1'b1;
	assign rng_target = playerx - targetx;
	
	//vga timing related registers 
	reg de;
	reg [9:0] x, y;
	
	//game logic registers
	//note player width and height is fixed 32by32
	reg [9:0] playerx, playery, targetx, targety; 
	reg [8:0] targetsize, rng_counter;
	wire [8:0] dataXout,dataYout;
	reg [5:0] counter;
	reg gameOver;

	reg[3:0] redTrue;
	reg alternateTitleColour;
	//rng state reg and output
	reg rng_state;
	wire [7:0] rng_out;
	
	/*
	*PLL inclk = 50MHZ
	*PLL c0 = 25MHZ should be 25.2MHZ for proper 60Hz
	*PLL c1 = 1MHz
	*/
	wire clk25M, clk1M;
	
	pll	pll_inst (
		.areset ( areset_sig ),
		.inclk0 ( clkin ),
		.c0 ( clk25M ),
		.c1 ( clk1M ),
		.locked ( locked_sig )
	);
	
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
	
	//generates hsync vysnc and de
	always @(*)begin
		hsync = ~(x >= HS_STA && x < HS_END);  
      vsync = ~(y >= VS_STA && y < VS_END);
		de = (x <= HA_END && y <= VA_END);	
	end
	
	//Update pausing
	always @(negedge pause or negedge rst)
	begin
		if(~rst)
			startGame <= 1'b0;
		else
			startGame <= 1'b1;
		
	end
	
	//note this is not the proper way to define modules should be changed
	//ADXL345 module
	ADXL345Handler accelerometer(clk1M,MISO,getData,rst,spiclk,chipselect,MOSI,dataXout,dataYout);
	//lfsr module 
	lfsr rng(clk25M, rst, rng_state, rng_out);
	//score module
	ScoreCounter score(clkin, rst, gameOver || !startGame, hex01, hex02, hex03, hex04);

	integer CLOUD_START_x = 35;
	integer CLOUD_END_x = 200;
	integer CLOUD_OFFSET_x = 10;
	integer CLOUD_OFFSET_y = 2;
	integer CLOUD_START_y = 115;
	integer CLOUD_END_y = 120;
	
	integer CLOUD2_START_x = 290;
	integer CLOUD2_END_x = 410;
	integer CLOUD2_START_y = 220;
	integer CLOUD2_END_y = 225;
	reg reverseMovement;
	
	integer cloudMovement;
	integer cloudMovement2;
	
	
	parameter START_SCREEN_LETTER_START = 220;
	parameter START_SCREEN_LETTER_END = 450;
	
	
	
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
			rng_counter <= 0;
			redTrue <= 4'b1111;
			alternateTitleColour <= 1'b0;			

		end else begin 
			//if x and y are within the draw area draw some pixels
			if(de)begin	
				if(!startGame) begin
				
					//Drawing the start screen
					integer i;
					integer CLOUD_OFFSET_y_count = 1;
					if((0 <= y && y < 350)) begin
						//Drawing cloud 1.
						if((115 <= y && y <= 120) && (35 +cloudMovement  <= x && x <= 200 +cloudMovement )) begin
							r <= 4'b1101;
							g <= 4'b1101;
							b <= 4'b1101;
						end else if((110 <= y && y <= 115) && (40+cloudMovement  <= x && x <= 195+cloudMovement  )) begin
							if( 50 +cloudMovement <= x ) begin
								r <= 4'b1101;
								g <= 4'b1101;
								b <= 4'b1101;
							end else begin
								r <= 4'b1111;
								g <= 4'b1111;
								b <= 4'b1111;
							end
							
						end else if((100 <= y && y <= 110) && (45 +cloudMovement  <= x && x <= 155 +cloudMovement  )) begin
							if((105 <= y && y <= 110) && (50 +cloudMovement  <= x && x <= 150 +cloudMovement  )) begin
								r <= 4'b1110;
								g <= 4'b1110;
								b <= 4'b1110;
							end else if((100 <= y && y <= 105) && (80 +cloudMovement  <= x && x <= 120 +cloudMovement  ) ) begin
								r <= 4'b1110;
								g <= 4'b1110;
								b <= 4'b1110;
							end else begin
								r <= 4'b1111;
								g <= 4'b1111;
								b <= 4'b1111;
							end
							
						end else if((95 <= y && y <= 100) && (55 +cloudMovement  <= x && x <= 65 +cloudMovement  )) begin
							r <= 4'b1111;
							g <= 4'b1111;
							b <= 4'b1111;
						end else if((80 <= y && y <= 100) && (75 +cloudMovement  <= x && x <= 125 +cloudMovement  )) begin
							if((85 <= y && y <= 100) && (80 +cloudMovement  <= x && x <= 115 +cloudMovement )) begin
								r <= 4'b1110;
								g <= 4'b1110;
								b <= 4'b1110;
							end else if((80 <= y && y <= 100) && (78 +cloudMovement  <= x && x <= 112 +cloudMovement  )) begin
								r <= 4'b1110;
								g <= 4'b1110;
								b <= 4'b1110;
							end else begin
								r <= 4'b1111;
								g <= 4'b1111;
								b <= 4'b1111;
							end
							
						end else if((70 <= y && y <= 80) && (85 +cloudMovement  <= x && x <= 115 +cloudMovement  )) begin
							if((75 <= y && y<= 80) && (96 +cloudMovement  <= x && x <= 104 +cloudMovement )) begin
								r <= 4'b1110;
								g <= 4'b1110;
								b <= 4'b1110;
							end else begin
								r <= 4'b1111;
								g <= 4'b1111;
								b <= 4'b1111;
							end
							
						end else if((60 <= y && y <= 70) && (90 +cloudMovement  <= x && x <= 110 +cloudMovement )) begin
							r <= 4'b1111;
							g <= 4'b1111;
							b <= 4'b1111;
						end else if((90 <= y && y <= 100) && (130 +cloudMovement  <= x && x <= 150 +cloudMovement  )) begin
							r <= 4'b1111;
							g <= 4'b1111;
							b <= 4'b1111;
						end else if((100 <= y && y <= 110) && (165 +cloudMovement  <= x && x <= 190 +cloudMovement  )) begin
							if((103 <= y && y <= 110) && (170 +cloudMovement  <= x && x <= 185 +cloudMovement  )) begin
								r <= 4'b1101;
								g <= 4'b1101;
								b <= 4'b1101;
							end else begin
								r <= 4'b1111;
								g <= 4'b1111;
								b <= 4'b1111;
							end
							
						//Second Cloud
							
						end else if((250 <= y && y <= 280) && (300 +cloudMovement2  <= x && x <=  400+cloudMovement2  )) begin
							if((260 <= y && y <= 280) && (300 +cloudMovement2  <= x && x <=  310+cloudMovement2  )) begin
							
								r <= 4'b1101;
								g <= 4'b1101;
								b <= 4'b1101;
							
							end else if((270 <= y && y <= 280) && (300 +cloudMovement2  <= x && x <=  400+cloudMovement2  )) begin
								r <= 4'b1101;
								g <= 4'b1101;
								b <= 4'b1101;
							end else if((250 <= y && y <= 260) && (330 +cloudMovement2  <= x && x <=  350+cloudMovement2  )) begin
								r <= 4'b1110;
								g <= 4'b1110;
								b <= 4'b1110;
							end else if((260 <= y && y <= 270) && (300 +cloudMovement2  <= x && x <=  400+cloudMovement2  )) begin
								r <= 4'b1110;
								g <= 4'b1110;
								b <= 4'b1110;
							end else begin
								r <= 4'b1111;
								g <= 4'b1111;
								b <= 4'b1111;
							end
							
						end else if((250 <= y && y <= 270) && (290 +cloudMovement2  <= x && x <=  300+cloudMovement2  )) begin
							r <= 4'b1101;
							g <= 4'b1101;
							b <= 4'b1101;
							
							
						end else if((240 <= y && y <= 250) && ((310 +cloudMovement2  <= x && x <=  360+cloudMovement2  ) || (370 +cloudMovement2  <= x && x <=  390+cloudMovement2) )) begin
							r <= 4'b1111;
							g <= 4'b1111;
							b <= 4'b1111;
						end else if((230 <= y && y <= 240) && (330 +cloudMovement2  <= x && x <=  350+cloudMovement2  )) begin 
							r <= 4'b1111;
							g <= 4'b1111;
							b <= 4'b1111;
						end else if ((260 <= y && y <= 280) && (400 +cloudMovement2  <= x && x <=  410+cloudMovement2  )) begin
							if ((260 <= y && y <= 270) && (400 +cloudMovement2  <= x && x <=  410+cloudMovement2  )) begin
								r <= 4'b1111;
								g <= 4'b1111;
								b <= 4'b1111;
							end else begin 
								r <= 4'b1101;
								g <= 4'b1101;
								b <= 4'b1101;
							end
						end else begin
							r <= 4'b1000;
							g <= 4'b1010;
							b <= 4'b1110;
						end
	
					//Drawing the letters of "Press key1 to begin".
						
					end else begin
						if((360 <= y && y <= 375) && (START_SCREEN_LETTER_START <= x && x <= START_SCREEN_LETTER_END)) begin
							//Drawing the P
							if((362 <= y && y <= 375) && (225 <= x && x <= 227)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((360 <= y && y <= 362) && (227 <= x && x <= 233)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((365 <= y && y <= 367) && (227 <= x && x <= 233)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((362 <= y && y <= 364) && (233 <= x && x <= 235)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								//End of P.
								//Start of r.
								
							end else if((362 <= y && y <= 375) && (239 <= x && x <= 241)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (239 <= x && x <= 246)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((366 <= y && y <= 368) && (244 <= x && x <= 246)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								//End of r.
								//Start of e.
								
							end else if((368 <= y && y <= 370) && (249 <= x && x <= 256)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((366 <= y && y <= 368) && ((249 <= x && x <= 251) || (254 <= x && x <= 256))) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (251 <= x && x <= 254)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (251 <= x && x <= 254)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((370 <= y && y <= 373) && (249 <= x && x <= 251)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (251 <= x && x <= 255)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
								//End of e.
								//start of s.
								
							end else if((364 <= y && y <= 366) && (261 <= x && x <= 269)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((367 <= y && y <= 369) && (259 <= x && x <= 261)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((369 <= y && y <= 371) && (261 <= x && x <= 267)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((371 <= y && y <= 373) && (267 <= x && x <= 269)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (259 <= x && x <= 267)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								//End of s.
								//Start of s
							end else if((364 <= y && y <= 366) && (273 <= x && x <= 281)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((367 <= y && y <= 369) && (271 <= x && x <= 273)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((369 <= y && y <= 371) && (273 <= x && x <= 279)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((371 <= y && y <= 373) && (279 <= x && x <= 281)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (271 <= x && x <= 279)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								//End of s.
								//Start of K.
							end else if((362 <= y && y <= 375) && (299 <= x && x <= 301)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((368 <= y && y <= 370) && (299 <= x && x <= 304)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((366 <= y && y <= 368) && (303 <= x && x <= 305)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((362 <= y && y <= 368) && (305 <= x && x <= 307)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((370 <= y && y <= 372) && (303 <= x && x <= 305)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((370 <= y && y <= 375) && (305 <= x && x <= 307)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								//End of K.
								//Start of e.
							end else if((368 <= y && y <= 370) && (310 <= x && x <= 317)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((366 <= y && y <= 368) && ((310 <= x && x <= 312) || (315 <= x && x <= 317))) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (312 <= x && x <= 315)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (312 <= x && x <= 315)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((370 <= y && y <= 373) && (310 <= x && x <= 312)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (312 <= x && x <= 316)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
								//End of e.
								//Start of y.
								
							end else if((363 <= y && y <= 367) && (320 <= x && x <= 322)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((367 <= y && y <= 369) && (321 <= x && x <= 329)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((363 <= y && y <= 371) && (327 <= x && x <= 329)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((371 <= y && y <= 373) && (326 <= x && x <= 328)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (321 <= x && x <= 325)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;

								//End of y.
								//Start of 1.
								
							end else if((373 <= y && y <= 375) && (332 <= x && x <= 340)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;

							end else if((362 <= y && y <= 375) && (335 <= x && x <= 337)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;

							end else if((364 <= y && y <= 366) && (333 <= x && x <= 337)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
								//End of 1.
								//Start of T.

							end else if((362 <= y && y <= 364) && (358 <= x && x <= 368)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;

							end else if((362 <= y && y <= 375) && (362 <= x && x <= 364)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;

								//End of T.
								//Start of o.
								
							end else if((364 <= y && y <= 366) && (372 <= x && x <= 378)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
							end else if((373 <= y && y <= 375) && (372 <= x && x <= 378)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;

							end else if((366 <= y && y <= 373) && (371 <= x && x <= 373)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;

							end else if((366 <= y && y <= 373) && (377 <= x && x <= 379)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
								//End of o.
								//Start of B.

							end else if((362 <= y && y <= 375) && (397 <= x && x <= 399)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((362 <= y && y <= 364) && (397 <= x && x <= 403)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (397 <= x && x <= 403)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((367 <= y && y <= 369) && (397 <= x && x <= 403)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (403 <= x && x <= 405)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((370 <= y && y <= 372) && (403 <= x && x <= 405)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							
								//End of B.
								//Start of e.
							
							end else if((368 <= y && y <= 370) && (408 <= x && x <= 415)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((366 <= y && y <= 368) && ((408 <= x && x <= 410) || (413 <= x && x <= 415))) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (410 <= x && x <= 413)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (410 <= x && x <= 413)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((370 <= y && y <= 373) && (408 <= x && x <= 410)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (410 <= x && x <= 414)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
								//End of e.
								//Start of g.
							
							end else if((363 <= y && y <= 365) && (418 <= x && x <= 426)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end 
							else if((365 <= y && y <= 367) && (417 <= x && x <= 419)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((368 <= y && y <= 369) && (418 <= x && x <= 426)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((363 <= y && y <= 371) && (424 <= x && x <= 426)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((371 <= y && y <= 373) && (423 <= x && x <= 425)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((373 <= y && y <= 375) && (418 <= x && x <= 422)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;	
							
							//End of g.
							//Start of i.
							end else if((364 <= y && y <= 366) && (429 <= x && x <= 431)) begin 
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;	
							
							end else if((368 <= y && y <= 375) && (429 <= x && x <= 431)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
							//End of i.
							//Start of n.
								
								
							end else if ((364 <= y && y <= 375) && (433 <= x && x <= 435)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
							end else if((364 <= y && y <= 366) && (433 <= x && x <= 439)) begin
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
							end else if((366  <= y && y <= 375) && (440 <= x && x <= 442)) begin	
								r <= alternateTitleColour ? 4'b1111 : 4'b0000;
								g <= alternateTitleColour ? 4'b1111 : 4'b0000;
								b <= alternateTitleColour ? 4'b1111 : 4'b0000;
								
							end else begin
								r <= 4'b0111;
								g <= 4'b1110;
								b <= 4'b0000;
							end
						
						//Drawing blades of grass
						end else if((450  <= y && y <= 452) && (440 <= x && x <= 450)) begin
								r <= 4'b1000;
								g <= 4'b1110;
								b <= 4'b1000;
						end else if((448  <= y && y <= 450) && (444 <= x && x <= 446)) begin
								r <= 4'b1000;
								g <= 4'b1110;
								b <= 4'b1000;
						end else begin
							r <= 4'b0111;
								g <= 4'b1110;
								b <= 4'b0000;
						end
					end
					//End of start screen drawing
				end else if(!gameOver) begin
					//Check if the player object is within the target object. ???????????????	 
					if((playerx < targetx) || (playery < targety) || (playerx + 32) > (targetx + targetsize) || (playery + 32) > (targety + targetsize))begin
						gameOver <= 1'b1;
					end
					//note non of the draw register should be updated during the de == 1 period 
					//or artifacts may appear
					else if(x >= playerx && x <= playerx+32 && y >= playery && y <= playery+32) begin
						//player is a pink color
						r <= 4'b1111;
						g <= 4'b1001;
						b <= 4'b1100;
					end else if(x >= targetx && x <= (targetx+targetsize) && y >= targety && y <= (targety+targetsize)) begin
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
					
				end else begin
					//paint the game over screen
					if(0 <= y && y < 250) begin
						//Paint the top letters
						//Logic for creating the letter 'G'
						if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
							if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_START + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FIRST_BLOCK_INDENT_START <= x && x < FIRST_BLOCK_INDENT_START + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (TOP_LETTERS_END - BLOCK_SIZE < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FIRST_BLOCK_INDENT_END - BLOCK_SIZE <= x && x <= FIRST_BLOCK_INDENT_END) && (((TOP_LETTERS_START +TOP_LETTERS_END) /2) < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((((FIRST_BLOCK_INDENT_START + FIRST_BLOCK_INDENT_END) /2) <= x && x <= FIRST_BLOCK_INDENT_END) && 
								(((TOP_LETTERS_START +TOP_LETTERS_END) /2) < y && y < ((TOP_LETTERS_START +TOP_LETTERS_END) /2) + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							
						end
						//Logic for creating the letter 'A'
						else if((SECOND_BLOCK_INDENT_START <= x && x <= SECOND_BLOCK_INDENT_END)&& (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
							if((SECOND_BLOCK_INDENT_START <= x && x <= SECOND_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_START + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_START + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((SECOND_BLOCK_INDENT_END - BLOCK_SIZE<= x && x < SECOND_BLOCK_INDENT_END + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_END) && 
								(((TOP_LETTERS_START +TOP_LETTERS_END) /2) < y && y < ((TOP_LETTERS_START +TOP_LETTERS_END) /2) + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for Creating letter 'M' will go here.
						else if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
							if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_START + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_START + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((THIRD_BLOCK_INDENT_END - BLOCK_SIZE <= x && x <= THIRD_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((((THIRD_BLOCK_INDENT_START + THIRD_BLOCK_INDENT_END) / 2) - (BLOCK_SIZE/2) <= x && x < ((THIRD_BLOCK_INDENT_START + THIRD_BLOCK_INDENT_END) / 2)  + (BLOCK_SIZE/2)) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for creating letter 'E'
						else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
							if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (TOP_LETTERS_START < y && y < TOP_LETTERS_START + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FOURTH_BLOCK_INDENT_START <= x && x < FOURTH_BLOCK_INDENT_START + BLOCK_SIZE) && (TOP_LETTERS_START < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (TOP_LETTERS_END - BLOCK_SIZE < y && y < TOP_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FOURTH_BLOCK_INDENT_START <= x && x < FOURTH_BLOCK_INDENT_END) && (((TOP_LETTERS_START +TOP_LETTERS_END) /2) - (BLOCK_SIZE/2) < y && 
								y < ((TOP_LETTERS_START +TOP_LETTERS_END) /2) + (BLOCK_SIZE /2 ))) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
	
						else begin
							r <= ~redTrue;
							g <= 4'b0000;
							b <= 4'b0000;
						end
					end else
					//Bottom half letters
					begin
						//Logic for creating the 'O'
						if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
							if((FIRST_BLOCK_INDENT_START <= x && x <= FIRST_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_START + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FIRST_BLOCK_INDENT_START <= x && x < FIRST_BLOCK_INDENT_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FIRST_BLOCK_INDENT_END - BLOCK_SIZE<= x && x < FIRST_BLOCK_INDENT_END + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FIRST_BLOCK_INDENT_START <= x && x < FIRST_BLOCK_INDENT_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for creating the 'V'
						else if((SECOND_BLOCK_INDENT_START <= x && x <= SECOND_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
							if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((SECOND_BLOCK_INDENT_END - BLOCK_SIZE<= x && x < SECOND_BLOCK_INDENT_END + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((SECOND_BLOCK_INDENT_START <= x && x < SECOND_BLOCK_INDENT_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for creating the 'E'
						else if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
							if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_START + BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((THIRD_BLOCK_INDENT_START <= x && x < THIRD_BLOCK_INDENT_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((THIRD_BLOCK_INDENT_START <= x && x <= THIRD_BLOCK_INDENT_END) && (BOTTOM_LETTERS_END - BLOCK_SIZE < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((THIRD_BLOCK_INDENT_START <= x && x < THIRD_BLOCK_INDENT_END) && (((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) - (BLOCK_SIZE / 2) < y && 
								y < ((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) + (BLOCK_SIZE / 2)))begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
						end
						//Logic for creating the 'R' not done yet.
						else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
							if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_START +BLOCK_SIZE)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_START + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < BOTTOM_LETTERS_END)) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FOURTH_BLOCK_INDENT_END - BLOCK_SIZE <= x && x <= FOURTH_BLOCK_INDENT_END + BLOCK_SIZE) && (BOTTOM_LETTERS_START < y && y < ((BOTTOM_LETTERS_START + BOTTOM_LETTERS_END) / 2))) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((FOURTH_BLOCK_INDENT_START <= x && x <= FOURTH_BLOCK_INDENT_END) && (((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) - (BLOCK_SIZE / 2) < y && 
								y < ((BOTTOM_LETTERS_START +BOTTOM_LETTERS_END) /2) + (BLOCK_SIZE / 2)))begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else if((((FOURTH_BLOCK_INDENT_START + FOURTH_BLOCK_INDENT_END) / 2) <= x && x <= (((FOURTH_BLOCK_INDENT_START + FOURTH_BLOCK_INDENT_END) / 2) + BLOCK_SIZE)) && (((BOTTOM_LETTERS_START + BOTTOM_LETTERS_END) / 2) <= y && y <= BOTTOM_LETTERS_END )) begin
								r <= redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end else begin
								r <= ~redTrue;
								g <= 4'b0000;
								b <= 4'b0000;
							end
							
						end else begin
							r <= ~redTrue;
							g <= 4'b0000;
							b <= 4'b0000;
						end
					end
				end
				//if !de then x and y are outside the draw area
				//set r g b to 4'b0000
			end else begin		
				r <= 4'b0000;
				g <= 4'b0000;
				b <= 4'b0000;
			end
		
			//clocks the rng playerx - targetx # of times
			if((rng_target > rng_counter) && counter != 60) begin 
				rng_state <= 1'b1;
				rng_counter <= rng_counter + 1;
			end else begin
				rng_state <= 1'b0;
				rng_counter <= 8'b11111111;
			end
		
			//read data from the adxl345
			if(y == 480 || y == 481)begin
				getData <= ~getData;
			end
			
			//update playerx and playery
			if(y == 520 && startGame)begin
				playerx <= dataXout[8] ? 303 + ((((tempx > 127) ? 127 : tempx) << 1) + (((tempx > 127) ? 127 : tempx) >> 2)) : 
					303 - ((((dataXout[7:0] > 127) ? 127 : dataXout[7:0]) << 1) + (((dataXout[7:0] > 127) ? 127 : dataXout[7:0]) >> 2));
					
				playery <= dataYout[8] ? 223 - (((tempy > 110) ? 110 : tempy) << 1) : 223 + (((dataYout[7:0] > 110) ? 110 : dataYout[7:0]) << 1);
			end
			
			//screen timing logic
			if (x == LINE) begin  
				x <= 0;
				if(y == SCREEN) begin 
					y <= 0;
					if(counter % 6 == 0)begin
						integer movement = 1;
						integer movement2 = 1;
						if(CLOUD_END_x + cloudMovement > 639 || CLOUD_START_x + cloudMovement < 1 )begin
							movement = movement * -1;
						end
						
						if(CLOUD2_END_x + cloudMovement2 > 639 || CLOUD2_START_x + cloudMovement2 < 1 )begin
							movement2 = movement2 * -1;
						end
						
						
						cloudMovement <= cloudMovement +  (1*movement);
						cloudMovement2 <= cloudMovement2 + (1*movement2);
					
						
					end if(counter == 60)begin
						counter <= 0;
						alternateTitleColour <= ~alternateTitleColour;
						redTrue <= ~redTrue;
						targetsize <= targetsize - (1'b1 && startGame);
						rng_counter <= 0;
					end else begin
						counter <= counter + 1'b1;
						//this needs to be improved
						//x limiter
						if (startGame && (temptargetx < (640 - targetsize)) && (temptargetx > 0))  
							targetx <= temptargetx;
						
						//y limiter
						if (startGame && (temptargety < (480 - targetsize)) && (temptargety > 0))  
							targety <= temptargety;
						
					end
				end else 
					y <= y + 1'b1;
				
			end else 
				x <= x + 1;
				
		end
	end
	
endmodule
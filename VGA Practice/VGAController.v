`timescale 1ns / 1ps

// image generator of a road and a sky 640x480 @ 60 fps

////////////////////////////////////////////////////////////////////////
module VGAController(
	input clk,           // 50 MHz
	output o_hsync,      // horizontal sync
	output o_vsync,	     // vertical sync
	output [3:0] o_red,
	output [3:0] o_blue,
	output [3:0] o_green  
);

	reg [9:0] counter_x = 0;  // horizontal counter
	reg [9:0] counter_y = 0;  // vertical counter
	reg [3:0] r_red = 0;
	reg [3:0] r_blue = 0;
	reg [3:0] r_green = 0;
	
	
	reg[14:0]a[19:0];

	always @(*)
	begin
		a[0] = 15'b111110000000000;
		a[1] = 15'b000010000000000;
		a[2] = 15'b000010000000000;
		a[3] = 15'b000011110000000;
		a[4] = 15'b000000010000000;
		a[5] = 15'b000000010000000;
		a[6] = 15'b000000010000000;
		a[7] = 15'b000000010000000;
		a[8] = 15'b000000010000000;
		a[9] = 15'b000000010000000;
		a[10] = 15'b000000010000000;
		a[11] = 15'b000000010000000;
		a[12] = 15'b000000010000000;
		a[13] = 15'b000000010000000;
		a[14] = 15'b000000011111000;
		a[15] = 15'b000000000001000;
		a[16] = 15'b000000000001000;
		a[17] = 15'b000000000001000;
		a[18] = 15'b000000000001000;
		a[19] = 15'b000000000001111;
		
	end
	
	
	
	reg reset = 0;  // for PLL
	
	wire clk25MHz;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// clk divider 50 MHz to 25 MHz
	clockDivider divider1(clk, clk25MHz); 
	// end clk divider 50 MHz to 25 MHz

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// counter and sync generation
	always @(posedge clk25MHz)  // horizontal counter
		begin 
			if (counter_x < 799)
				counter_x <= counter_x + 1;  // horizontal counter (including off-screen horizontal 160 pixels) total of 800 pixels 
			else
				counter_x <= 0;              
		end  // always 
	
	always @ (posedge clk25MHz)  // vertical counter
		begin 
			if (counter_x == 799)  // only counts up 1 count after horizontal finishes 800 counts
				begin
					if (counter_y < 525)  // vertical counter (including off-screen vertical 45 pixels) total of 525 pixels
						counter_y <= counter_y + 1;
					else
						counter_y <= 0;              
				end  // if (counter_x...
		end  // always
	// end counter and sync generation  

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// hsync and vsync output assignments
	assign o_hsync = (counter_x >= 0 && counter_x < 96) ? 1:0;  // hsync high for 96 counts                                                 
	assign o_vsync = (counter_y >= 0 && counter_y < 2) ? 1:0;   // vsync high for 2 counts
	// end hsync and vsync output assignments

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// pattern generate
		always @ (posedge clk)
		begin
		
		if(450 <= counter_x && counter_x <= 482)
		begin
			r_red <= 4'hF;    // white
			r_blue <= 4'h0;
			r_green <= 4'hF;
		end
		else
		begin
			r_red <= 4'hF;    // white
			r_blue <= 4'hF;
			r_green <= 4'hF;
		end
			
		end  // always
						
	// end pattern generate

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// color output assignments
	// only output the colors if the counters are within the adressable video time constraints
	assign o_red = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_red : 4'h0;
	assign o_blue = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_blue : 4'h0;
	assign o_green = (counter_x > 144 && counter_x <= 783 && counter_y > 35 && counter_y <= 514) ? r_green : 4'h0;
	// end color output assignments
	
endmodule  // VGA_image_gen
module ADXL345Handler(clk,MISO,getData,rst,spiclk,CS,MOSI,dataXout,dataYout);
	//inputs
	input clk, MISO, rst, getData;
	
	//outputs
	output spiclk;
	output MOSI;
	output reg CS;
	output reg [8:0] dataXout, dataYout;
	
	//internal registers
	reg [15:0] input_reg; 
	reg [10:0] timecounter;		//counter for polling interval and spi clocks
	reg spirst, adxl345setup;	//flags and resets

	//wires
	wire [31:0] output_reg; 	
	
	VeryBadSPI adxl345(spirst,clk,MISO,CS,input_reg,spiclk,MOSI,output_reg);
	
	always @(negedge clk or negedge rst or posedge getData) begin
		if (!rst) begin
			timecounter <= 0;
			adxl345setup <= 0;
			spirst <= 1;
			CS <= 1;
		end else if(getData) begin
			timecounter <= 0;
		end else begin
		
			if(adxl345setup == 0) begin
				timecounter <= timecounter + 1;
				
				if(timecounter == 1 || timecounter == 2) begin
					spirst <= ~spirst;	//pulse spirst
				end else if(timecounter == 10 && adxl345setup == 0) begin
					//initialize the adxl345
					input_reg <= 16'b0010110100001000; 		// <- sets the adxl345 to measure mode
					CS <= 0;
				end else if(timecounter == 44 && adxl345setup == 0) begin	
					//count some SPI clocks then set CS to 1
					CS <= 1;	
				end else if((timecounter == 1000 || timecounter == 1001) && adxl345setup == 0) begin	
					spirst <= ~spirst;	//pulse spirst
				end else if(timecounter == 1010 && adxl345setup == 0) begin
					//initialize the adxl345
					input_reg <= 16'b0011000100000000;		// <- configures the data format
					CS <= 0;
				end else if(timecounter == 1044 && adxl345setup == 0) begin	
					//count some SPI clocks then set CS to 1
					CS <= 1;
				end 
				
				if(timecounter == 2000)
					adxl345setup <= 1;
				
			end else if(adxl345setup == 1 && timecounter < 1000) begin 
				timecounter <= timecounter + 1;
				
				if(timecounter == 1 || timecounter == 2) begin
					spirst <= ~spirst;	//pulse spirst
				end else if(timecounter == 10) begin
					//4 byte read of reg 0x32 - 0x34 (datax0,datax1,datay0,datay1)
					input_reg <= 16'b1111001000000000;
					CS <= 0;
				end else if(timecounter == 92) begin
					dataXout <= {output_reg[17],output_reg[16],output_reg[31:25]};
					dataYout <= {output_reg[1],output_reg[0],output_reg[15:9]};
					CS <= 1;
				end
			
			end

		end
	end
	
	
endmodule
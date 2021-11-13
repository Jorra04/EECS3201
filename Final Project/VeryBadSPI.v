module VeryBadSPI(rst,clkin,MISO,CS,input_reg,clkout,MOSI,output_reg);
	//inputs
	input rst, clkin, MISO, CS;	//reset, clkin, MISO(Master In Slave Out), CS
	input [15:0] input_reg; 		//stores r/w, multi-r/w, 6bit address, 8bit data 
	
	//outputs
	output reg clkout;				//SPI CLOCK
	output reg MOSI;					//MOSI(Master Out Slave In)
	output reg [31:0] output_reg;	//stores 32bit input data (DATAX0,DATAX1,DATAY0,DATAY1)
	
	//hacks that should be removed 
	reg [15:0] MOSI_SHIFT;
	reg preMISO;
	
	always @(posedge clkin or negedge rst) begin 
		if(~rst) begin
			clkout <= 1;
		end else if(CS == 0 && clkout == 1) begin
			clkout <= 0;
		end else if(CS == 1 && clkout == 0) begin
			clkout <= 1;
		end else if(CS == 0) begin
			clkout <= ~clkout;
		end
		
	end
		
	//shifts data from input_reg to MOSI
	//this can be greatly improved 
	always @(negedge clkout or negedge rst) begin
		if(~rst) begin 
			MOSI_SHIFT <= 16'b1000000000000000;
		end else begin
			MOSI <= (input_reg & MOSI_SHIFT) ? 1'b1:1'b0;
			MOSI_SHIFT <= MOSI_SHIFT >> 1;
		end
	end

	
	//sample the data from MISO and place it into output_reg
	always @(posedge clkout) begin
			preMISO <= MISO;
			output_reg <= output_reg << 1;
			output_reg[0] <= preMISO;
	end
	
	
endmodule
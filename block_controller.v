`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background
   );
	wire block_fill;
	wire obs_fill;
	wire vobs_fill;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos, ypos_obs, xpos_obs, ypos_vobs, xpos_vobs;
	
	
	
	parameter RED   = 12'b1111_0000_0000;
	parameter PURPLE  = 12'b1111_0000_1111;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill) 
			rgb = RED;
		else if (obs_fill)
			rgb = PURPLE;
		else if (vobs_fill)
			rgb = PURPLE;
		else	
			rgb=background;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-30) && vCount<=(ypos+30) && hCount>=(xpos-30) && hCount<=(xpos+30);
	assign obs_fill=vCount>=(ypos_obs-10) && vCount<=(ypos_obs+10) && hCount>=(xpos_obs-40) && hCount<=(xpos_obs+40);
	assign vobs_fill=vCount>=(ypos_vobs-10) && vCount<=(ypos_vobs+10) && hCount>=(xpos_vobs-40) && hCount<=(xpos_vobs+40);
	
	always@(posedge clk, posedge rst) 
	begin
		if(rst)
		begin 
			//rough values for center of screen
			xpos<=450;
			ypos<=250;
		end
		else if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
			if(right) begin
				xpos<=xpos+2; //change the amount you increment to make the speed faster 
				if(xpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
					xpos<=150;
			end
			else if(left) begin
				xpos<=xpos-2;
				if(xpos==150)
					xpos<=800;
			end
			else if(up) begin
				ypos<=ypos-2;
				if(ypos==34)
					ypos<=514;
			end
			else if(down) begin
				ypos<=ypos+2;
				if(ypos==514)
					ypos<=34;
			end
		end
	end
	
	//the background color reflects the most recent button press
	always@(posedge clk, posedge rst) begin
		if(rst)
			background <= 12'b1111_1111_1111;
		else 
			if(right)
				background <= 12'b1111_1111_0000;
			else if(left)
				background <= 12'b0000_1111_1111;
			else if(down)
				background <= 12'b0000_1111_0000;
			else if(up)
				background <= 12'b0000_0000_1111;
	end
	// Obstacles
	
	always@(posedge clk, posedge rst) begin
		if(rst)
		begin 
			//rough values for center of screen
			xpos_obs<=450;
			ypos_obs<=250;
			xpos_vobs<=450;
			ypos_vobs<=250;
		end
		else
		begin
		ypos_obs<=ypos_obs+2;
		xpos_vobs<=xpos_vobs+2;
		if(ypos_obs==514)
			ypos_obs<=34;
		if(xpos_vobs==800)
			xpos_vobs<=150;
		end
		end
endmodule

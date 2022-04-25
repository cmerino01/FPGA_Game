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
	wire obs_fill; //street line
	wire vobs_fill; //street line
	wire streeta_fill; 
	wire streetb_fill;
	wire car1_fill;
	wire car2_fill;
	wire car3_fill;
	wire car4_fill;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos,xpos_streeta, ypos_streeta, xpos_streetb, ypos_streetb, ypos_obs, xpos_obs, ypos_vobs, xpos_vobs, xpos_car1, ypos_car1, xpos_car2, ypos_car2,xpos_car3, ypos_car3 , xpos_car4, ypos_car4;
	
	
	
	parameter RED   = 12'b1111_0000_0000;
	parameter PURPLE  = 12'b1111_0000_1111;
	parameter WHITE = 12'b1111_1111_1111;
	parameter BLUE = 12'b0000_1000_1010;
	parameter YELLOW = 12'b1111_1110_1000;
	parameter SILVER = 12'b1011_1011_1011;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	always@ (*) begin
    	if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (block_fill) 
			rgb = RED;
		else if (obs_fill)
			rgb = WHITE;
		else if (vobs_fill)
			rgb = WHITE;
		else if (streeta_fill)
			rgb = WHITE;
		else if (streetb_fill)
			rgb = WHITE;
        else if (car1_fill)
            rgb = PURPLE;
        else if (car2_fill)
            rgb = BLUE;
        else if (car3_fill)
            rgb = YELLOW;
        else if (car4_fill)
            rgb = SILVER;
		else	
			rgb=background;
	end
		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
	assign block_fill=vCount>=(ypos-30) && vCount<=(ypos+30) && hCount>=(xpos-30) && hCount<=(xpos+30);
	assign obs_fill=vCount>=(ypos_obs-10) && vCount<=(ypos_obs+10) && hCount>=(xpos_obs-40) && hCount<=(xpos_obs+40);
	assign vobs_fill=vCount>=(ypos_vobs-10) && vCount<=(ypos_vobs+10) && hCount>=(xpos_vobs-40) && hCount<=(xpos_vobs+40);
	assign streeta_fill=vCount>=(ypos_streeta-10) && vCount<=(ypos_streeta+10) && hCount>=(xpos_streeta-40) && hCount<=(xpos_streeta+40);
	assign streetb_fill=vCount>=(ypos_streetb-10) && vCount<=(ypos_streetb+10) && hCount>=(xpos_streetb-40) && hCount<=(xpos_streetb+40);
	assign car1_fill=vCount>=(ypos_car1-34) && vCount<=(ypos_car1+34) && hCount>=(xpos_car1-34) && hCount<=(xpos_car1+34);
	assign car2_fill=vCount>=(ypos_car2-34) && vCount<=(ypos_car2+34) && hCount>=(xpos_car2-34) && hCount<=(xpos_car2+34);
	assign car3_fill=vCount>=(ypos_car3-34) && vCount<=(ypos_car3+34) && hCount>=(xpos_car3-34) && hCount<=(xpos_car3+34);
	assign car4_fill=vCount>=(ypos_car4-34) && vCount<=(ypos_car4+34) && hCount>=(xpos_car4-34) && hCount<=(xpos_car4+34);
	
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
			background <= 12'b1000_1000_1000;
		/*else 
			if(right)
				background <= 12'b1111_1111_0000;
			else if(left)
				background <= 12'b0000_1111_1111;
			else if(down)
				background <= 12'b0000_1111_0000;
			else if(up)
				background <= 12'b0000_0000_1111;
				*/
	end
	// Obstacles
	
	always@(posedge clk, posedge rst) begin
		if(rst)
		begin 
			//rough values for center of screen
			xpos_obs<=450;
			ypos_obs<=180;
			xpos_vobs<=450;
			ypos_vobs<=380;
			xpos_streeta<=90;
			ypos_streeta<=180;
			xpos_streetb<=90;
			ypos_streetb<=380;
			xpos_car1<=450;
			ypos_car1<=130;
			xpos_car2<=450;
			ypos_car2<=450;
			xpos_car3<=450;
			ypos_car3<=320;
			xpos_car4<=600;
			ypos_car4<=250;
		end
		else
		begin
		xpos_obs<=xpos_obs+8;
		xpos_vobs<=xpos_vobs+8;
		xpos_streeta<=xpos_streeta+8;
		xpos_streetb<=xpos_streetb+8;
		xpos_car1<=xpos_car1+4;
		xpos_car2<=xpos_car2+8;
		xpos_car3<=xpos_car3+2;
		xpos_car4<=xpos_car4+6;
		if(xpos_obs==800)
			xpos_obs<=150;
		if(xpos_vobs==800)
			xpos_vobs<=150;
		if(xpos_streeta==800)
			xpos_streeta<=150;
		if(xpos_streetb==800)
			xpos_streetb<=150;
		if(xpos_car1==800)
		    xpos_car1<=150;
		if(xpos_car2==800)
		    xpos_car2<=150;
		if(xpos_car3==800)
		    xpos_car3<=150;
		if(xpos_car4==800)
		    xpos_car4<=150;
		end
		end
endmodule

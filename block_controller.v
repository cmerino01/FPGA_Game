`timescale 1ns / 1ps

module block_controller(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input rst,
	input up, input down, input left, input right,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [11:0] background,
	output reg [2:0] lives
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
	reg [9:0] xpos, ypos;
	reg [9:0] xpos_streeta, ypos_streeta;
	reg [9:0] xpos_streetb, ypos_streetb;
	reg [9:0] xpos_obs, ypos_obs;
	reg [9:0] xpos_vobs, ypos_vobs;
	reg [9:0] xpos_car1, ypos_car1;
	reg [9:0] xpos_car2, ypos_car2;
	reg [9:0] xpos_car3, ypos_car3;
	reg [9:0] xpos_car4, ypos_car4;

	//Flags for cars
	reg car1_hit;
	reg car2_hit;
	reg car3_hit;
	reg car4_hit;
	
	//Flag for gameover
	reg gameOver;
	
	parameter RED   = 12'b1111_0000_0000;
	parameter PURPLE  = 12'b1111_0000_1111;
	parameter WHITE = 12'b1111_1111_1111;
	parameter BLUE = 12'b0000_0000_1111;
	parameter YELLOW = 12'b1111_1110_1000;
	parameter GREEN = 12'b0000_1111_0000;
	
	/*when outputting the rgb value in an always block like this, make sure to include the if(~bright) statement, as this ensures the monitor 
	will output some data to every pixel and not just the images you are trying to display*/
	// Responsible for pixel colors
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
				rgb = GREEN;
		else	
			rgb=background;
	end
	
	//the +- dimensions for each block/obstacle, for collision detection and pixel coloring
	assign block_fill=vCount>=(ypos-30) && vCount<=(ypos+30) && hCount>=(xpos-30) && hCount<=(xpos+30);
	assign obs_fill=vCount>=(ypos_obs-10) && vCount<=(ypos_obs+10) && hCount>=(xpos_obs-40) && hCount<=(xpos_obs+40);
	assign vobs_fill=vCount>=(ypos_vobs-10) && vCount<=(ypos_vobs+10) && hCount>=(xpos_vobs-40) && hCount<=(xpos_vobs+40);
	assign streeta_fill=vCount>=(ypos_streeta-10) && vCount<=(ypos_streeta+10) && hCount>=(xpos_streeta-40) && hCount<=(xpos_streeta+40);
	assign streetb_fill=vCount>=(ypos_streetb-10) && vCount<=(ypos_streetb+10) && hCount>=(xpos_streetb-40) && hCount<=(xpos_streetb+40);
	assign car1_fill=vCount>=(ypos_car1-36) && vCount<=(ypos_car1+36) && hCount>=(xpos_car1-36) && hCount<=(xpos_car1+36);
	assign car2_fill=vCount>=(ypos_car2-36) && vCount<=(ypos_car2+36) && hCount>=(xpos_car2-36) && hCount<=(xpos_car2+36);
	assign car3_fill=vCount>=(ypos_car3-34) && vCount<=(ypos_car3+34) && hCount>=(xpos_car3-34) && hCount<=(xpos_car3+34);
	assign car4_fill=vCount>=(ypos_car4-34) && vCount<=(ypos_car4+34) && hCount>=(xpos_car4-34) && hCount<=(xpos_car4+34);
	
	always@(posedge clk, posedge rst)
	begin
	
		if(rst | car1_hit | car2_hit | car3_hit | car4_hit | gameOver)
		begin
		
			if(rst) begin
				background <= 12'b1000_1000_1000;
				lives <= 7;
				gameOver <= 0;
			end
			
			//rough values for center of screen
			xpos<=450;
			ypos<=250;
			
			//street 1 pos
			xpos_obs<=450;
			ypos_obs<=180;
			//street 2 pos
			xpos_vobs<=450;
			ypos_vobs<=380;
			//street 1
			xpos_streeta<=90;
			ypos_streeta<=180;
			//street 2
			xpos_streetb<=90;
			ypos_streetb<=380;
			//car 1
			xpos_car1<=450;
			ypos_car1<=130;
			car1_hit <= 1'b0;
			//car 2
			xpos_car2<=450;
			ypos_car2<=450;
			car2_hit <= 1'b0;
			//car 3
			xpos_car3<=450;
			ypos_car3<=320;
			car3_hit <= 1'b0;
			//car 4
			xpos_car4<=600;
			ypos_car4<=250;
			car4_hit <= 1'b0;
		end
		
		else begin
			if (!gameOver) begin
				//character
				if(right) begin
					xpos<=xpos+2;
					if(xpos==750)
						xpos<=750;
				end
				else if(left) begin
					xpos<=xpos-2;
					if(xpos==160)
						xpos<=160;
				end
				if(up) begin
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
			
			//cars 1-4
			if((car1_hit == 1'b0) && (car2_hit == 1'b0) && (car3_hit == 1'b0) && (car4_hit == 1'b0)) begin
				xpos_car1<=xpos_car1+4;
				xpos_car2<=xpos_car2+8;
				xpos_car3<=xpos_car3+2;
				xpos_car4<=xpos_car4+6;
				xpos_obs<=xpos_obs+8;
                xpos_vobs<=xpos_vobs+8;
                xpos_streeta<=xpos_streeta+8;
                xpos_streetb<=xpos_streetb+8;
				if(xpos_car1==800)
					xpos_car1<=150;
				if(xpos_car2==800)
					xpos_car2<=150;
				if(xpos_car3==800)
					xpos_car3<=150;
				if(xpos_car4==800)
					xpos_car4<=150;
				if(xpos_obs==800)
                    xpos_obs<=150;
                if(xpos_vobs==800)
                    xpos_vobs<=150;
                if(xpos_streeta==800)
                    xpos_streeta<=150;
                if(xpos_streetb==800)
                    xpos_streetb<=150;
			end
			
			if ( (xpos_car1==xpos) && (ypos==ypos_car1) ) begin
				lives <= lives-1;
				car1_hit <= 1'b1;
			end
			
			if ((xpos_car2==xpos) && (ypos==ypos_car2)) begin
				lives <= lives-1;
				car2_hit <= 1'b1;
			end
			
			if ((xpos_car3==xpos) && (ypos==ypos_car3)) begin
				lives <= lives-1;
				car3_hit <= 1'b1;
			end
			
			if ((xpos_car4==xpos) && (ypos==ypos_car4)) begin
				lives <= lives-1;
				car4_hit <= 1'b1;
			end
			
			//Game over
			if (lives == 0) begin
				gameOver <= 1;
			end
		end
	end
endmodule

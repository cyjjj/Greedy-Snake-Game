`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:11:22 01/08/2020 
// Design Name: 
// Module Name:    CreateRandPosition 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CreateRandPosition(clk,randx,randy
    );
		parameter LEFTLIMIT = 0;
		parameter RIGHTLIMIT = 640;
		parameter DOWNLIMIT = 0;
		parameter UPLIMIT = 480;//运动边界
		parameter A = 20;//长
		parameter B = 10;//宽
		input wire clk;
		output reg [9:0] randx;//生成的横坐标值，由于是矩形所以多了一位
		output reg [8:0] randy;//生成的纵坐标值
		reg [6:0] adx=15, ady = 15	;//从0到63
		
		always@(posedge clk)begin//根据clk时钟信号生成随机数
			adx <= adx + 3;
			ady <= ady + 1;
			
			if(adx>=63)begin
				adx <= 3;
				randx <= RIGHTLIMIT-A;//边界值
			end
			else if (adx<3)
				randx <= LEFTLIMIT+A;//边界值
			else
				randx <= (adx * 10);

			if(ady>47)begin
				ady <= 1;
				randy <= UPLIMIT-B;//边界值
			end
			else if (ady<1)
				randy <= DOWNLIMIT+B;//边界值
			else
				randy <= (ady * 10);
		end
		
endmodule

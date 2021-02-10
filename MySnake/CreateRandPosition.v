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
		parameter UPLIMIT = 480;//�˶��߽�
		parameter A = 20;//��
		parameter B = 10;//��
		input wire clk;
		output reg [9:0] randx;//���ɵĺ�����ֵ�������Ǿ������Զ���һλ
		output reg [8:0] randy;//���ɵ�������ֵ
		reg [6:0] adx=15, ady = 15	;//��0��63
		
		always@(posedge clk)begin//����clkʱ���ź����������
			adx <= adx + 3;
			ady <= ady + 1;
			
			if(adx>=63)begin
				adx <= 3;
				randx <= RIGHTLIMIT-A;//�߽�ֵ
			end
			else if (adx<3)
				randx <= LEFTLIMIT+A;//�߽�ֵ
			else
				randx <= (adx * 10);

			if(ady>47)begin
				ady <= 1;
				randy <= UPLIMIT-B;//�߽�ֵ
			end
			else if (ady<1)
				randy <= DOWNLIMIT+B;//�߽�ֵ
			else
				randy <= (ady * 10);
		end
		
endmodule

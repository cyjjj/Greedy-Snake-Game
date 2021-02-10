`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:34:40 01/08/2020 
// Design Name: 
// Module Name:    top 
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
module top(
input wire clk, 
input wire reset/*重置信号*/,
input wire clrn,
input wire [3:0]SW,
output [3:0] r,
output [3:0] g,
output [3:0] b,
output wire hs,
output wire vs,
output wire [3:0]AN,
output wire [7:0]SEGMENT,
output wire buzzer/*消磁干扰*/
    );
	reg [15:0] points = 16'b0;//分数
	 //移动过程状态
	reg HitBody=0;
	reg HitWall=0;
	reg BodyAdd=0;
	//四个状态
	reg [1:0] state = 2'b00;
	parameter RESET = 2'b00, MOVE = 2'b01, CHECK = 2'b10, FOOD = 2'b11;
	parameter LEFTLIMIT = 0, RIGHTLIMIT = 640, DOWNLIMIT = 0, UPLIMIT = 480;//边界参数
	parameter GOLEFT=2'b00, GORIGHT=2'b01, GOUP=2'b10, GODOWN=2'b11;
	reg [1:0] direction;//记录方向
	wire [31:0] clkdiv;
	//蛇
	reg [9:0] SnakeX [31:0];
	reg [8:0] SnakeY [31:0];
	parameter SNAKER = 10;//蛇半径
	//循环参数声明
	integer cnt;
	integer cnt0;
	reg [6:0] size;//蛇身长度
	//食物
	reg food;
	reg [9:0] foodX;
	reg [8:0] foodY;
	parameter FOODR = 10;//食物半径
	//随机位置
	wire [9:0] randx;
	wire [8:0] randy;
	/*VGA？...*/
	reg [11:0] d_in;//VGArgb输入 
	integer cnt1;
	//画面坐标
	wire [9:0] x;
	wire [8:0] y;
	//生成食物位置
	CreateRandPosition r1(.clk(clkdiv[1]),.randx(randx),.randy(randy));
	//clk
	clkdiv clk1(.clk(clk),.rst(1'b0),.clkdiv(clkdiv));
	//VGA接口...？
	vgac v1(.vga_clk(clkdiv[1]),.clrn(clrn),.d_in(d_in),.row_addr(y),.col_addr(x),.rdn(rdn),.r(r),.g(g),.b(b),.hs(hs),.vs(vs));
	//显示分数（用四位数码管了......）
	disp_num d1(.clk(clk),.HEXS(points),.LES(4'b0),.points(4'b0),.RST(1'b0),.AN(AN),.Segment(SEGMENT));
	
	//主程序：
	always@(posedge clkdiv[23])begin
		if(reset)//RESET重置
			state <= RESET;
		case(state)
		RESET:begin
			points <= 16'b0;//分数重置
			size <= 2;//初始二节身体
			SnakeX[0] <= 220;
			SnakeX[1] <= 210;
			SnakeY[0] <= 200;
			SnakeY[1] <= 200;
			for(cnt0=2;cnt0<31;cnt0=cnt0+1)begin
				SnakeX[cnt0] <= 0;
				SnakeY[cnt0] <= 0;
			end
			foodX <= 300;
			foodY <= 10;//初始食物位置
			if(SW[0]||SW[1]||SW[2]||SW[3])begin
				state <= MOVE;
			end
		end
		MOVE:begin
		/*控制蛇移动*/
		for(cnt=30; cnt>0; cnt=cnt-1)begin
				if(cnt<size)begin
					SnakeY[cnt] <= SnakeY[cnt-1];
					SnakeX[cnt] <= SnakeX[cnt-1];
				end
			end//蛇身移动，后面一节移到前面的位置
			if(SW[0]) begin
				direction <= GOLEFT;//左
				end
				else if(SW[1]) begin
				direction <= GORIGHT;//右
				end
				else if(SW[2]) begin
				direction <= GOUP;//上
				end
				else if(SW[3]) begin
				direction <= GODOWN;//下
				end
			case(direction)
				GOLEFT: SnakeX[0] <= SnakeX[0] - 10'd10;
				GORIGHT: SnakeX[0] <= SnakeX[0] + 10'd10;
				GODOWN: SnakeY[0] <= SnakeY[0] - 9'd10;
				GOUP: SnakeY[0] <= SnakeY[0] + 9'd10;
				default: ;
			endcase
	//根据方向移动蛇头
		state <= CHECK;
		end
		CHECK:begin
		/*检查状态，分为撞墙、撞身体以及吃到食物*/
			//撞墙：
			if(SnakeX[0]<LEFTLIMIT||SnakeX[0]>RIGHTLIMIT||SnakeY[0]<DOWNLIMIT||SnakeY[0]>UPLIMIT)
				state <= RESET;
			//吃到食物:
			else if(SnakeX[0]==foodX&&SnakeY[0]==foodY)begin
				size <= size + 1;//蛇身变长
				points <= points + 1;//加分
				state <= FOOD;//再生成新食物
			end
			//撞身体:
			else begin:loop
				for(cnt=30;cnt>0;cnt=cnt-1)begin
					if(cnt<size&&SnakeX[0]==SnakeX[cnt]&&SnakeY[0]==SnakeY[cnt])begin//检查头尾
						state <= RESET;//游戏结束重新开始
						disable loop;
					end
				end
				state <= MOVE;//无事件
			end
		end
		FOOD:begin
			foodX <= randx;
			foodY <= randy;
			state <= MOVE;
		end
		endcase
	end
	
	
	//VGA显示颜色等变化代码...?
	always@(*)begin
		if(!rdn)begin//rdn:read pixel RAM (active_low),这是为了保证目前是可读状态
			if(x>=0&&x<SNAKER&&y>=0&&y<SNAKER)begin//初始（0,0）用背景色遮盖
				d_in[3:0] <= 4'hf;
				d_in[7:4] <= 4'hf;
				d_in[11:8] <= 4'hf;
			end
			else if(x>=foodX&&x<foodX+FOODR&&y>=foodY&&y<foodY+FOODR)begin//食物红
				d_in[3:0] <= 4'b1111;
				d_in[7:4] <= 4'h0;
				d_in[11:8] <= 4'h0;
			end
			else if(x>=SnakeX[0]&&x<SnakeX[0]+SNAKER&&y>=SnakeY[0]&&y<SnakeY[0]+SNAKER)begin//头绿（大雾）
				d_in[3:0] <= 4'h0;
				d_in[7:4] <= 4'hf;
				d_in[11:8] <= 4'h0;
			end
			else begin:collapse
				for(cnt1=1;cnt1<31;cnt1=cnt1+1)begin
					if(cnt1<size&&x>=SnakeX[cnt1]&&x<SnakeX[cnt1]+SNAKER&&y>=SnakeY[cnt1]&&y<SnakeY[cnt1]+SNAKER)begin//身子蓝
						d_in[3:0] <= 4'h0;
						d_in[7:4] <= 4'h0;
						d_in[11:8] <= 4'hf;
						disable collapse;
					end
				end
				//白色背景
				d_in[3:0] <= 4'hf;
				d_in[7:4] <= 4'hf;
				d_in[11:8] <= 4'hf;
			end
		end
	end
		
	assign buzzer = 1'b1;//消磁干扰
	
endmodule

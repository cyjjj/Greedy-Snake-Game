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
input wire reset/*�����ź�*/,
input wire clrn,
input wire [3:0]SW,
output [3:0] r,
output [3:0] g,
output [3:0] b,
output wire hs,
output wire vs,
output wire [3:0]AN,
output wire [7:0]SEGMENT,
output wire buzzer/*���Ÿ���*/
    );
	reg [15:0] points = 16'b0;//����
	 //�ƶ�����״̬
	reg HitBody=0;
	reg HitWall=0;
	reg BodyAdd=0;
	//�ĸ�״̬
	reg [1:0] state = 2'b00;
	parameter RESET = 2'b00, MOVE = 2'b01, CHECK = 2'b10, FOOD = 2'b11;
	parameter LEFTLIMIT = 0, RIGHTLIMIT = 640, DOWNLIMIT = 0, UPLIMIT = 480;//�߽����
	parameter GOLEFT=2'b00, GORIGHT=2'b01, GOUP=2'b10, GODOWN=2'b11;
	reg [1:0] direction;//��¼����
	wire [31:0] clkdiv;
	//��
	reg [9:0] SnakeX [31:0];
	reg [8:0] SnakeY [31:0];
	parameter SNAKER = 10;//�߰뾶
	//ѭ����������
	integer cnt;
	integer cnt0;
	reg [6:0] size;//������
	//ʳ��
	reg food;
	reg [9:0] foodX;
	reg [8:0] foodY;
	parameter FOODR = 10;//ʳ��뾶
	//���λ��
	wire [9:0] randx;
	wire [8:0] randy;
	/*VGA��...*/
	reg [11:0] d_in;//VGArgb���� 
	integer cnt1;
	//��������
	wire [9:0] x;
	wire [8:0] y;
	//����ʳ��λ��
	CreateRandPosition r1(.clk(clkdiv[1]),.randx(randx),.randy(randy));
	//clk
	clkdiv clk1(.clk(clk),.rst(1'b0),.clkdiv(clkdiv));
	//VGA�ӿ�...��
	vgac v1(.vga_clk(clkdiv[1]),.clrn(clrn),.d_in(d_in),.row_addr(y),.col_addr(x),.rdn(rdn),.r(r),.g(g),.b(b),.hs(hs),.vs(vs));
	//��ʾ����������λ�������......��
	disp_num d1(.clk(clk),.HEXS(points),.LES(4'b0),.points(4'b0),.RST(1'b0),.AN(AN),.Segment(SEGMENT));
	
	//������
	always@(posedge clkdiv[23])begin
		if(reset)//RESET����
			state <= RESET;
		case(state)
		RESET:begin
			points <= 16'b0;//��������
			size <= 2;//��ʼ��������
			SnakeX[0] <= 220;
			SnakeX[1] <= 210;
			SnakeY[0] <= 200;
			SnakeY[1] <= 200;
			for(cnt0=2;cnt0<31;cnt0=cnt0+1)begin
				SnakeX[cnt0] <= 0;
				SnakeY[cnt0] <= 0;
			end
			foodX <= 300;
			foodY <= 10;//��ʼʳ��λ��
			if(SW[0]||SW[1]||SW[2]||SW[3])begin
				state <= MOVE;
			end
		end
		MOVE:begin
		/*�������ƶ�*/
		for(cnt=30; cnt>0; cnt=cnt-1)begin
				if(cnt<size)begin
					SnakeY[cnt] <= SnakeY[cnt-1];
					SnakeX[cnt] <= SnakeX[cnt-1];
				end
			end//�����ƶ�������һ���Ƶ�ǰ���λ��
			if(SW[0]) begin
				direction <= GOLEFT;//��
				end
				else if(SW[1]) begin
				direction <= GORIGHT;//��
				end
				else if(SW[2]) begin
				direction <= GOUP;//��
				end
				else if(SW[3]) begin
				direction <= GODOWN;//��
				end
			case(direction)
				GOLEFT: SnakeX[0] <= SnakeX[0] - 10'd10;
				GORIGHT: SnakeX[0] <= SnakeX[0] + 10'd10;
				GODOWN: SnakeY[0] <= SnakeY[0] - 9'd10;
				GOUP: SnakeY[0] <= SnakeY[0] + 9'd10;
				default: ;
			endcase
	//���ݷ����ƶ���ͷ
		state <= CHECK;
		end
		CHECK:begin
		/*���״̬����Ϊײǽ��ײ�����Լ��Ե�ʳ��*/
			//ײǽ��
			if(SnakeX[0]<LEFTLIMIT||SnakeX[0]>RIGHTLIMIT||SnakeY[0]<DOWNLIMIT||SnakeY[0]>UPLIMIT)
				state <= RESET;
			//�Ե�ʳ��:
			else if(SnakeX[0]==foodX&&SnakeY[0]==foodY)begin
				size <= size + 1;//����䳤
				points <= points + 1;//�ӷ�
				state <= FOOD;//��������ʳ��
			end
			//ײ����:
			else begin:loop
				for(cnt=30;cnt>0;cnt=cnt-1)begin
					if(cnt<size&&SnakeX[0]==SnakeX[cnt]&&SnakeY[0]==SnakeY[cnt])begin//���ͷβ
						state <= RESET;//��Ϸ�������¿�ʼ
						disable loop;
					end
				end
				state <= MOVE;//���¼�
			end
		end
		FOOD:begin
			foodX <= randx;
			foodY <= randy;
			state <= MOVE;
		end
		endcase
	end
	
	
	//VGA��ʾ��ɫ�ȱ仯����...?
	always@(*)begin
		if(!rdn)begin//rdn:read pixel RAM (active_low),����Ϊ�˱�֤Ŀǰ�ǿɶ�״̬
			if(x>=0&&x<SNAKER&&y>=0&&y<SNAKER)begin//��ʼ��0,0���ñ���ɫ�ڸ�
				d_in[3:0] <= 4'hf;
				d_in[7:4] <= 4'hf;
				d_in[11:8] <= 4'hf;
			end
			else if(x>=foodX&&x<foodX+FOODR&&y>=foodY&&y<foodY+FOODR)begin//ʳ���
				d_in[3:0] <= 4'b1111;
				d_in[7:4] <= 4'h0;
				d_in[11:8] <= 4'h0;
			end
			else if(x>=SnakeX[0]&&x<SnakeX[0]+SNAKER&&y>=SnakeY[0]&&y<SnakeY[0]+SNAKER)begin//ͷ�̣�����
				d_in[3:0] <= 4'h0;
				d_in[7:4] <= 4'hf;
				d_in[11:8] <= 4'h0;
			end
			else begin:collapse
				for(cnt1=1;cnt1<31;cnt1=cnt1+1)begin
					if(cnt1<size&&x>=SnakeX[cnt1]&&x<SnakeX[cnt1]+SNAKER&&y>=SnakeY[cnt1]&&y<SnakeY[cnt1]+SNAKER)begin//������
						d_in[3:0] <= 4'h0;
						d_in[7:4] <= 4'h0;
						d_in[11:8] <= 4'hf;
						disable collapse;
					end
				end
				//��ɫ����
				d_in[3:0] <= 4'hf;
				d_in[7:4] <= 4'hf;
				d_in[11:8] <= 4'hf;
			end
		end
	end
		
	assign buzzer = 1'b1;//���Ÿ���
	
endmodule

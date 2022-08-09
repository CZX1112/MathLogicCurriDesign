module Top(
    input rst,              //��Ϸ��λ��
    input clk,              //ϵͳʱ��
    output hsync,vsync,     //��ʱ�򡢳�ʱ��
    output [3:0] red,       //VGA��ɫ����
    output [3:0] blue,      //VGA��ɫ����
    output [3:0] green,     //VGA��ɫ����
    output [6:0] seg_led,   //�߶��������ʾ����
    output [7:0] AN,        //�߶������ѡ��
    input get,              //��������PMOD
    input up,               //�������������
    input down,             //�������������
    input left,             //�������������
    input right,            //�������������
    input start,            //��Ϸ��ʼ��ť
    input speed_up,         //���ٰ�ť
    input level2,           //��ͨģʽ
    input level3            //����ģʽ
);

wire [7:0] out;             //�������


//�����
reg [15:0] count_clk;
reg CLK_1000HZ=1'b0;
reg [3:0]data[0:7];
wire [6:0] Score;
wire [6:0] Time;
reg [6:0] Data;
reg [2:0] display_count;

wire live;

//����ģ��
bluetooth bluetooth(.clk(clk),.rst(rst),.get(get),.out(out));

//�߶��������ʾģ��
display7 Display(.clk(clk),.rst(rst),.Score(Score),.Time(Time),.seg_led(seg_led),.AN(AN));

//����ʱģ��
timecount Timecount(.clk(clk),.rst(rst),.start(start),.live(live),.Time(Time));

//vga��ʾģ��
vga_display vga_display(.rst(rst),.clk(clk),.hsync(hsync),.vsync(vsync),.red(red),.blue(blue),.green(green),.up(up),.down(down),.left(left),.right(right),.start(start),.speed_up(speed_up),.level2(level2),.level3(level3),.Score(Score),.out(out));

endmodule

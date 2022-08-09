module Top(
    input rst,              //游戏复位键
    input clk,              //系统时钟
    output hsync,vsync,     //行时序、场时序
    output [3:0] red,       //VGA红色分量
    output [3:0] blue,      //VGA蓝色分量
    output [3:0] green,     //VGA绿色分量
    output [6:0] seg_led,   //七段数码管显示数据
    output [7:0] AN,        //七段数码管选择
    input get,              //连接蓝牙PMOD
    input up,               //控制马里奥上移
    input down,             //控制马里奥下移
    input left,             //控制马里奥左移
    input right,            //控制马里奥右移
    input start,            //游戏开始按钮
    input speed_up,         //加速按钮
    input level2,           //普通模式
    input level3            //困难模式
);

wire [7:0] out;             //蓝牙输出


//数码管
reg [15:0] count_clk;
reg CLK_1000HZ=1'b0;
reg [3:0]data[0:7];
wire [6:0] Score;
wire [6:0] Time;
reg [6:0] Data;
reg [2:0] display_count;

wire live;

//蓝牙模块
bluetooth bluetooth(.clk(clk),.rst(rst),.get(get),.out(out));

//七段数码管显示模块
display7 Display(.clk(clk),.rst(rst),.Score(Score),.Time(Time),.seg_led(seg_led),.AN(AN));

//倒计时模块
timecount Timecount(.clk(clk),.rst(rst),.start(start),.live(live),.Time(Time));

//vga显示模块
vga_display vga_display(.rst(rst),.clk(clk),.hsync(hsync),.vsync(vsync),.red(red),.blue(blue),.green(green),.up(up),.down(down),.left(left),.right(right),.start(start),.speed_up(speed_up),.level2(level2),.level3(level3),.Score(Score),.out(out));

endmodule

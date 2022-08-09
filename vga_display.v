module vga_display(
    input rst,
    input clk,
    output reg hsync,vsync,
    output reg [3:0] red,
    output reg [3:0] blue,
    output reg [3:0] green,
    input up,
    input down,
    input left,
    input right,
    input start,
    input speed_up,
    input level2,
    input level3,
    output reg [6:0] Score,
    input [7:0] out
);

reg [3:0] red0;
reg [3:0] green0;
reg [3:0] blue0;
reg [3:0] red1;
reg [3:0] green1;
reg [3:0] blue1;
reg [3:0] red2;
reg [3:0] green2;
reg [3:0] blue2;
reg [1:0] flag;

parameter x_start=11'd144;
parameter y_start=11'd35;
parameter x_end=11'd640;
parameter y_end=11'd480;


reg [9:0] vga_x = 0; // 800 TS , x
reg [9:0] vga_y = 0; // 521 Ts , y
reg clk_25MHz = 0;
reg [1:0] count = 0;

reg [9:0] topline = 10;
reg [9:0] downline = 34;
reg [9:0] leftline = 10;
reg [9:0] rightline = 42;


//马里奥：坐标：上：170+mario_y-mario_y_sub 下：202+mario_y-mario_y_sub 左：558+mario_x-mario_x_sub 右：590+mario_x-mario_x_sub
reg [15:0] mario_x = 0;
reg [15:0] mario_y = 0;
reg [15:0] mario_x_sub = 0;
reg [15:0] mario_y_sub = 0;

reg [9:0] path_count=0;
reg [9:0] column_path=0;
reg [9:0] column_path1=0;
reg [9:0] column_path2=0;
reg [9:0] column_path3=0;

//数码管
reg [15:0] count_clk;
reg CLK_1000HZ=1'b0;
reg [3:0]data[0:7];
wire [6:0] Time;
reg [6:0] Data;
reg [2:0] display_count;

wire live;


//得分模块
always@(posedge vsync, negedge rst)
if(rst==1||flag==2'd0||flag==2'd2)
begin
    Score<=0;
    //Time<=0;
end
else
begin
    if(((574+mario_x-mario_x_sub-column_path-15)*(574+mario_x-mario_x_sub-column_path-15)<2)&&((170+mario_y-mario_y_sub>50)&&(202+mario_y-mario_y_sub<120)))
        begin
        Score<=Score+1;
        //Time<=Time+1;
        end
    else if(((574+mario_x-mario_x_sub-column_path-15)*(574+mario_x-mario_x_sub-column_path-15)<2)&&((170+mario_y-mario_y_sub>170)&&(202+mario_y-mario_y_sub<240)))
        begin
        Score<=Score+1;
        //Time<=Time+1;
        end
    else if(((574+mario_x-mario_x_sub-column_path1-15)*(574+mario_x-mario_x_sub-column_path1-15)<2)&&((170+mario_y-mario_y_sub>250)&&(202+mario_y-mario_y_sub<320)))
        begin
        Score<=Score+1;
        //Time<=Time+1;
        end
    else if(((574+mario_x-mario_x_sub-column_path2-15)*(574+mario_x-mario_x_sub-column_path2-15)<2)&&((170+mario_y-mario_y_sub>180)&&(202+mario_y-mario_y_sub<250)))
        begin
        Score<=Score+1;
        //Time<=Time+1;
        end
    else if(((574+mario_x-mario_x_sub-column_path2-15)*(574+mario_x-mario_x_sub-column_path2-15)<2)&&((170+mario_y-mario_y_sub>300)&&(202+mario_y-mario_y_sub<370)))
        begin
        Score<=Score+1;
        //Time<=Time+1;
        end
    else if(((574+mario_x-mario_x_sub-column_path3-15)*(574+mario_x-mario_x_sub-column_path3-15)<2)&&((170+mario_y-mario_y_sub>100)&&(202+mario_y-mario_y_sub<170)))
        begin
        Score<=Score+1;
        //Time<=Time+1;
        end
    else
        begin
        Score<=Score;
        //Time<=Time;
        end
end



//马里奥：坐标：上：170+mario_y-mario_y_sub 下：202+mario_y-mario_y_sub 左：558+mario_x-mario_x_sub 右：590+mario_x-mario_x_sub
always @(posedge vsync)
begin
    if(rst)
        flag<=2'd0;
    else if(start)
        flag<=2'd1;
    else if(((574+mario_x-mario_x_sub-column_path-15)*(574+mario_x-mario_x_sub-column_path-15)<36)&&((170+mario_y-mario_y_sub<50)||(202+mario_y-mario_y_sub>120&&202+mario_y-mario_y_sub<170)||(170+mario_y-mario_y_sub>120&&170+mario_y-mario_y_sub<170)||(202+mario_y-mario_y_sub>240)))
        flag<=2'd2;
    else if(((574+mario_x-mario_x_sub-column_path1-15)*(574+mario_x-mario_x_sub-column_path1-15)<36)&&((170+mario_y-mario_y_sub<250)||(170+mario_y-mario_y_sub>320)))
        flag<=2'd2;
    else if(((574+mario_x-mario_x_sub-column_path2-15)*(574+mario_x-mario_x_sub-column_path2-15)<36)&&((170+mario_y-mario_y_sub<180)||(202+mario_y-mario_y_sub>250&&202+mario_y-mario_y_sub<300)||(170+mario_y-mario_y_sub>250&&170+mario_y-mario_y_sub<300)||(202+mario_y-mario_y_sub>370)))
        flag<=2'd2;
    else if(((574+mario_x-mario_x_sub-column_path3-15)*(574+mario_x-mario_x_sub-column_path3-15)<36)&&((170+mario_y-mario_y_sub<100)||(170+mario_y-mario_y_sub>170)))
        flag<=2'd2;
    else
        flag<=flag;
end

//分频 25M Hz
always@(posedge clk)begin
        if(rst)begin
            count<=0;
        end
        else begin
            if(count < 1)begin
            count <= count + 1;
            end
        else
        begin
            clk_25MHz <=~clk_25MHz;
            count<= 0;
        end
    end
end

always @ (posedge clk_25MHz or posedge rst) begin
  if(rst) begin
    vga_x <= 0;
    vga_y <= 0;
  end
  else begin
  //根据basic VGA controller的电路图，在水平方向扫描一次后，使得垂直方向开始扫描
  // 因为水平方向是时钟计数的，垂直方向是根据水平方向的脉冲计数的
    if(vga_x >= 800) 
    begin
        vga_x <= 0;
        if(vga_y>=521)
            vga_y<=0;
        else
            vga_y<=vga_y+1'b1;
        vga_y <= (vga_y >= 521? 0 : vga_y + 1'b1);
    end
    else
        vga_x <= vga_x + 1'b1;
  end
end

//设置行选，列选信号有效。 由于有建立的Tpw时间，所以要把Tpw(脉冲宽度）时间段内的坐标视为无效
always @(posedge clk_25MHz or posedge rst) begin
if(rst)
begin
    hsync <= 0;
    vsync <= 0;
end
else
begin
    if(vga_x < 752 &&vga_x  >= 656)// 脉冲内为0 (800 - Tbp -Tpw) ~ (800 - Tbp)
        hsync <= 0;
    else
        hsync <= 1;

    if(vga_y < 492 && vga_y >= 490 )// 脉冲内为0 (521 - Tbp -Tpw) ~ (521 - Tbp)
        vsync <= 0;
    else 
        vsync <= 1;
end
end

//步数移动模块
always @(posedge vsync)
begin
    if(rst)
    begin
    mario_x<=0;
    mario_y<=0;
    mario_x_sub<=0;
    mario_y_sub<=0;
    end
    
    else if(flag==2'd1)
    begin
        if(up||out==49)
        begin
            mario_x<=mario_x;
            mario_y<=mario_y;
            mario_x_sub<=mario_x_sub;
            if(speed_up)
                mario_y_sub<=mario_y_sub+10'd5;
            else if(out==49)
                mario_y_sub<=mario_y_sub+10'd2;
            else
                mario_y_sub<=mario_y_sub+10'd3;
        end
        
        if(down||out==50)
        begin
            mario_x<=mario_x;
            if(speed_up)
                mario_y<=mario_y+10'd5;
            else if(out==50)
                mario_y<=mario_y+10'd1;
            else
                mario_y<=mario_y+10'd3;
            mario_x_sub<=mario_x_sub;
            mario_y_sub<=mario_y_sub;
        end
        
        if(left||out==51)
            begin
            mario_x<=mario_x;
            mario_y<=mario_y;
            if(speed_up)
                mario_x_sub<=mario_x_sub+10'd4;
            else if(out==51)
                mario_x_sub<=mario_x_sub+10'd1;
            else
                mario_x_sub<=mario_x_sub+10'd2;
            mario_y_sub<=mario_y_sub;
            end
        
        if(right||out==52)
            begin
            if(speed_up)
                mario_x<=mario_x+10'd4;
            else if(out==52)
                mario_x<=mario_x+10'd1;
            else
                mario_x<=mario_x+10'd2;
            mario_y<=mario_y;
            mario_x_sub<=mario_x_sub;
            mario_y_sub<=mario_y_sub;

        end
        mario_y<=mario_y+1;
        //马里奥：坐标：上：170+mario_y-mario_y_sub 下：202+mario_y-mario_y_sub 左：558+mario_x-mario_x_sub 右：590+mario_x-mario_x_sub
        if(170+mario_y-mario_y_sub<5)
            mario_y<=mario_y+10;
        else if(202+mario_y-mario_y_sub>460)
            mario_y_sub<=mario_y_sub+10;
        else if(558+mario_x-mario_x_sub<50)
            mario_x<=mario_x+10;
        else if(590+mario_x-mario_x_sub>700)
            mario_x_sub<=mario_x_sub+10;
    end
    else
    begin
    mario_x<=0;
    mario_y<=0;
    mario_x_sub<=0;
    mario_y_sub<=0;
    end

end

always @ (posedge vsync)
begin
if(rst)
    path_count<=0;
else if(flag==2'd0||flag==2'd2)
    path_count<=0;
else
begin
    if(path_count<700)
        begin
        if(level2)
            path_count<=path_count+2;
        else if(level3)
            path_count<=path_count+3;
        else
            path_count<=path_count+1;
        end
    else
        path_count<=path_count;
end
end

always @ (posedge vsync)
begin
if(rst)
    column_path<=0;
else if(flag==0||flag==2)
begin
    column_path<=0;
end
else
begin
    if(column_path>640)
        column_path<=0;
    else
        begin
        if(level2)
            column_path<=column_path+2;
        else if(level3)
            column_path<=column_path+3;
        else
            column_path<=column_path+1;
        end
end
end


always @ (posedge vsync)
begin
if(rst)
    column_path1<=0;
else if(flag==0||flag==2)
    column_path1<=0;
else
begin
if(path_count>160)
begin
    if(column_path1>640)
        column_path1<=0;
    else
        begin
        if(level2)
            column_path1<=column_path1+2;
        else if(level3)
            column_path1<=column_path1+3;
        else
            column_path1<=column_path1+1;
        end
end
end
end


always @ (posedge vsync)
begin
if(rst)
    column_path2<=0;
else if(flag==0||flag==2)
    column_path2<=0;
else
begin
if(path_count>320)
begin
    if(column_path2>640)
        column_path2<=0;
    else
        begin
        if(level2)
            column_path2<=column_path2+2;
        else if(level3)
            column_path2<=column_path2+3;
        else
            column_path2<=column_path2+1;
        end
end
end
end


always @ (posedge vsync)
begin
if(rst)
    column_path3<=0;
else if(flag==0||flag==2)
    column_path3<=0;
else
begin
if(path_count>480)
begin
    if(column_path3>640)
        column_path3<=0;
    else
        begin
        if(level2)
            column_path3<=column_path3+2;
        else if(level3)
            column_path3<=column_path3+3;
        else
            column_path3<=column_path3+1;
        end
end
end
end



//vga显示模块
always @ (posedge clk_25MHz)
begin
    if(rst==0&&flag==2'd1)
    begin
    if(vga_x >= 0  && vga_x <= 700  && vga_y >= 0 && vga_y <= 480)
    begin
        if((vga_x>=leftline&&vga_x<=rightline&&vga_y>=topline&&vga_y<=downline)||(vga_x>=column_path&&vga_x<=column_path+30)||(vga_x>=column_path1&&vga_x<=column_path1+30)||(vga_x>=column_path2&&vga_x<=column_path2+30)||(vga_x>=column_path3&&vga_x<=column_path3+30)||(vga_x>=558+mario_x-mario_x_sub&&vga_x<=580+mario_x-mario_x_sub&&vga_y>=170+mario_y-mario_y_sub&&vga_y<=202+mario_y-mario_y_sub))
        begin
        if(vga_x>=558+mario_x-mario_x_sub&&vga_x<=580+mario_x-mario_x_sub&&vga_y>=170+mario_y-mario_y_sub&&vga_y<=202+mario_y-mario_y_sub)
                    //mario
                    begin
                        //1
                        if(vga_x>=568+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=173+mario_y-mario_y_sub&&vga_y<=174+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //2
                        else if(vga_x>=564+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=174+mario_y-mario_y_sub&&vga_y<=175+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //3
                        else if(vga_x>=564+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=175+mario_y-mario_y_sub&&vga_y<=176+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //4
                        else if(vga_x>=567+mario_x-mario_x_sub&&vga_x<=568+mario_x-mario_x_sub&&vga_y>=176+mario_y-mario_y_sub&&vga_y<=177+mario_y-mario_y_sub)
                        begin red1<=4'h6;green1<=4'h8;blue1<=4'h8;end
                        else if(vga_x>=568+mario_x-mario_x_sub&&vga_x<=570+mario_x-mario_x_sub&&vga_y>=176+mario_y-mario_y_sub&&vga_y<=177+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=570+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=176+mario_y-mario_y_sub&&vga_y<=177+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        //5
                        else if(vga_x>=567+mario_x-mario_x_sub&&vga_x<=568+mario_x-mario_x_sub&&vga_y>=177+mario_y-mario_y_sub&&vga_y<=178+mario_y-mario_y_sub)
                        begin red1<=4'h6;green1<=4'h8;blue1<=4'hb;end
                        else if(vga_x>=564+mario_x-mario_x_sub&&vga_x<=567+mario_x-mario_x_sub&&vga_y>=177+mario_y-mario_y_sub&&vga_y<=178+mario_y-mario_y_sub)
                        begin red1<=4'h6;green1<=4'h8;blue1<=4'hb;end
                        else if(vga_x>=568+mario_x-mario_x_sub&&vga_x<=575+mario_x-mario_x_sub&&vga_y>=177+mario_y-mario_y_sub&&vga_y<=178+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        else if(vga_x>=575+mario_x-mario_x_sub&&vga_x<=577+mario_x-mario_x_sub&&vga_y>=177+mario_y-mario_y_sub&&vga_y<=178+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        //6
                        else if(vga_x>=562+mario_x-mario_x_sub&&vga_x<=575+mario_x-mario_x_sub&&vga_y>=178+mario_y-mario_y_sub&&vga_y<=179+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=575+mario_x-mario_x_sub&&vga_x<=577+mario_x-mario_x_sub&&vga_y>=178+mario_y-mario_y_sub&&vga_y<=179+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        //7
                        else if(vga_x>=562+mario_x-mario_x_sub&&vga_x<=566+mario_x-mario_x_sub&&vga_y>=179+mario_y-mario_y_sub&&vga_y<=180+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=566+mario_x-mario_x_sub&&vga_x<=567+mario_x-mario_x_sub&&vga_y>=179+mario_y-mario_y_sub&&vga_y<=180+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        else if(vga_x>=567+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=179+mario_y-mario_y_sub&&vga_y<=180+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=573+mario_x-mario_x_sub&&vga_x<=577+mario_x-mario_x_sub&&vga_y>=179+mario_y-mario_y_sub&&vga_y<=180+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        //8
                        else if(vga_x>=564+mario_x-mario_x_sub&&vga_x<=567+mario_x-mario_x_sub&&vga_y>=180+mario_y-mario_y_sub&&vga_y<=181+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        else if(vga_x>=567+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=180+mario_y-mario_y_sub&&vga_y<=181+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        //9
                        else if(vga_x>=565+mario_x-mario_x_sub&&vga_x<=574+mario_x-mario_x_sub&&vga_y>=181+mario_y-mario_y_sub&&vga_y<=182+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        //10
                        else if(vga_x>=567+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=182+mario_y-mario_y_sub&&vga_y<=183+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'hc;blue1<=4'hd;end
                        //11
                        else if(vga_x>=566+mario_x-mario_x_sub&&vga_x<=574+mario_x-mario_x_sub&&vga_y>=183+mario_y-mario_y_sub&&vga_y<=184+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //12
                        else if(vga_x>=564+mario_x-mario_x_sub&&vga_x<=576+mario_x-mario_x_sub&&vga_y>=184+mario_y-mario_y_sub&&vga_y<=185+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //13
                        else if(vga_x>=563+mario_x-mario_x_sub&&vga_x<=572+mario_x-mario_x_sub&&vga_y>=185+mario_y-mario_y_sub&&vga_y<=186+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=572+mario_x-mario_x_sub&&vga_x<=574+mario_x-mario_x_sub&&vga_y>=185+mario_y-mario_y_sub&&vga_y<=186+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=574+mario_x-mario_x_sub&&vga_x<=578+mario_x-mario_x_sub&&vga_y>=185+mario_y-mario_y_sub&&vga_y<=186+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //14
                        else if(vga_x>=561+mario_x-mario_x_sub&&vga_x<=566+mario_x-mario_x_sub&&vga_y>=186+mario_y-mario_y_sub&&vga_y<=187+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=566+mario_x-mario_x_sub&&vga_x<=568+mario_x-mario_x_sub&&vga_y>=186+mario_y-mario_y_sub&&vga_y<=187+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=568+mario_x-mario_x_sub&&vga_x<=572+mario_x-mario_x_sub&&vga_y>=186+mario_y-mario_y_sub&&vga_y<=187+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=572+mario_x-mario_x_sub&&vga_x<=574+mario_x-mario_x_sub&&vga_y>=186+mario_y-mario_y_sub&&vga_y<=187+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=574+mario_x-mario_x_sub&&vga_x<=581+mario_x-mario_x_sub&&vga_y>=186+mario_y-mario_y_sub&&vga_y<=187+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //15
                        else if(vga_x>=560+mario_x-mario_x_sub&&vga_x<=566+mario_x-mario_x_sub&&vga_y>=187+mario_y-mario_y_sub&&vga_y<=188+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=566+mario_x-mario_x_sub&&vga_x<=568+mario_x-mario_x_sub&&vga_y>=187+mario_y-mario_y_sub&&vga_y<=188+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=568+mario_x-mario_x_sub&&vga_x<=572+mario_x-mario_x_sub&&vga_y>=187+mario_y-mario_y_sub&&vga_y<=188+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=572+mario_x-mario_x_sub&&vga_x<=574+mario_x-mario_x_sub&&vga_y>=187+mario_y-mario_y_sub&&vga_y<=188+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=574+mario_x-mario_x_sub&&vga_x<=583+mario_x-mario_x_sub&&vga_y>=187+mario_y-mario_y_sub&&vga_y<=188+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        //16
                        else if(vga_x>=559+mario_x-mario_x_sub&&vga_x<=564+mario_x-mario_x_sub&&vga_y>=188+mario_y-mario_y_sub&&vga_y<=189+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=564+mario_x-mario_x_sub&&vga_x<=566+mario_x-mario_x_sub&&vga_y>=188+mario_y-mario_y_sub&&vga_y<=189+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=566+mario_x-mario_x_sub&&vga_x<=574+mario_x-mario_x_sub&&vga_y>=188+mario_y-mario_y_sub&&vga_y<=189+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=574+mario_x-mario_x_sub&&vga_x<=576+mario_x-mario_x_sub&&vga_y>=188+mario_y-mario_y_sub&&vga_y<=189+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=576+mario_x-mario_x_sub&&vga_x<=578+mario_x-mario_x_sub&&vga_y>=188+mario_y-mario_y_sub&&vga_y<=189+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=578+mario_x-mario_x_sub&&vga_x<=584+mario_x-mario_x_sub&&vga_y>=188+mario_y-mario_y_sub&&vga_y<=189+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        //17
                        else if(vga_x>=559+mario_x-mario_x_sub&&vga_x<=561+mario_x-mario_x_sub&&vga_y>=189+mario_y-mario_y_sub&&vga_y<=190+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=561+mario_x-mario_x_sub&&vga_x<=562+mario_x-mario_x_sub&&vga_y>=189+mario_y-mario_y_sub&&vga_y<=190+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'h0;blue1<=4'h0;end
                        else if(vga_x>=562+mario_x-mario_x_sub&&vga_x<=566+mario_x-mario_x_sub&&vga_y>=189+mario_y-mario_y_sub&&vga_y<=190+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=566+mario_x-mario_x_sub&&vga_x<=574+mario_x-mario_x_sub&&vga_y>=189+mario_y-mario_y_sub&&vga_y<=190+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=574+mario_x-mario_x_sub&&vga_x<=584+mario_x-mario_x_sub&&vga_y>=189+mario_y-mario_y_sub&&vga_y<=190+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        //18
                        else if(vga_x>=559+mario_x-mario_x_sub&&vga_x<=567+mario_x-mario_x_sub&&vga_y>=190+mario_y-mario_y_sub&&vga_y<=191+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=567+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=190+mario_y-mario_y_sub&&vga_y<=191+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=573+mario_x-mario_x_sub&&vga_x<=584+mario_x-mario_x_sub&&vga_y>=190+mario_y-mario_y_sub&&vga_y<=191+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        //19
                        else if(vga_x>=559+mario_x-mario_x_sub&&vga_x<=567+mario_x-mario_x_sub&&vga_y>=191+mario_y-mario_y_sub&&vga_y<=192+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        else if(vga_x>=567+mario_x-mario_x_sub&&vga_x<=573+mario_x-mario_x_sub&&vga_y>=191+mario_y-mario_y_sub&&vga_y<=192+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        else if(vga_x>=573+mario_x-mario_x_sub&&vga_x<=584+mario_x-mario_x_sub&&vga_y>=191+mario_y-mario_y_sub&&vga_y<=192+mario_y-mario_y_sub)
                        begin red1<=4'hf;green1<=4'hf;blue1<=4'hc;end
                        //20
                        else if(vga_x>=565+mario_x-mario_x_sub&&vga_x<=575+mario_x-mario_x_sub&&vga_y>=192+mario_y-mario_y_sub&&vga_y<=193+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        //21
                        else if(vga_x>=563+mario_x-mario_x_sub&&vga_x<=577+mario_x-mario_x_sub&&vga_y>=193+mario_y-mario_y_sub&&vga_y<=194+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        //22
                        else if(vga_x>=561+mario_x-mario_x_sub&&vga_x<=579+mario_x-mario_x_sub&&vga_y>=194+mario_y-mario_y_sub&&vga_y<=195+mario_y-mario_y_sub)
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'hf;end
                        //23
                        else if(vga_x>=562+mario_x-mario_x_sub&&vga_x<=565+mario_x-mario_x_sub&&vga_y>=195+mario_y-mario_y_sub&&vga_y<=196+mario_y-mario_y_sub)
                        begin red1<=4'hb;green1<=4'h2;blue1<=4'h2;end
                        else if(vga_x>=575+mario_x-mario_x_sub&&vga_x<=578+mario_x-mario_x_sub&&vga_y>=195+mario_y-mario_y_sub&&vga_y<=196+mario_y-mario_y_sub)
                        begin red1<=4'hb;green1<=4'h2;blue1<=4'h2;end
                        //24
                        else if(vga_x>=560+mario_x-mario_x_sub&&vga_x<=565+mario_x-mario_x_sub&&vga_y>=196+mario_y-mario_y_sub&&vga_y<=197+mario_y-mario_y_sub)
                        begin red1<=4'hb;green1<=4'h2;blue1<=4'h2;end
                        else if(vga_x>=575+mario_x-mario_x_sub&&vga_x<=581+mario_x-mario_x_sub&&vga_y>=196+mario_y-mario_y_sub&&vga_y<=197+mario_y-mario_y_sub)
                        begin red1<=4'hb;green1<=4'h2;blue1<=4'h2;end
                        //25
                        else if(vga_x>=560+mario_x-mario_x_sub&&vga_x<=565+mario_x-mario_x_sub&&vga_y>=197+mario_y-mario_y_sub&&vga_y<=198+mario_y-mario_y_sub)
                        begin red1<=4'hb;green1<=4'h2;blue1<=4'h2;end
                        else if(vga_x>=575+mario_x-mario_x_sub&&vga_x<=581+mario_x-mario_x_sub&&vga_y>=197+mario_y-mario_y_sub&&vga_y<=198+mario_y-mario_y_sub)
                        begin red1<=4'hb;green1<=4'h2;blue1<=4'h2;end
                        else 
                        begin red1<=4'h0;green1<=4'h0;blue1<=4'h0;end
                    end
            else if(vga_x>=leftline&&vga_x<=rightline&&vga_y>=topline&&vga_y<=downline)
            begin
            red1<=4'b1111;
            green1<=4'b1111;
            blue1<=4'b1111;
            end
            else if(vga_x>=column_path&&vga_x<=column_path+30)
            begin
            if((vga_y>=50&&vga_y<=120)||(vga_y>=170&&vga_y<=240))
            begin
            red1<=4'b0000;
            green1<=4'b0000;
            blue1<=4'b0000;
            end
            else
            begin
            red1<=4'b1111;
            green1<=4'b0000;
            blue1<=4'b1111;
            end
            end
            
            else if(vga_x>=column_path1&&vga_x<=column_path1+30)
            begin
            if(vga_y>=250&&vga_y<=320)
            begin
            red1<=4'b0000;
            green1<=4'b0000;
            blue1<=4'b0000;
            end
            else
            begin
            red1<=4'b0000;
            green1<=4'b1111;
            blue1<=4'b1111;
            end
            end
            
            else if(vga_x>=column_path2&&vga_x<=column_path2+30)
            begin
            if((vga_y>=180&&vga_y<=250)||(vga_y>=300&&vga_y<=370))
            begin
            red1<=4'b0000;
            green1<=4'b0000;
            blue1<=4'b0000;
            end
            else
            begin
            red1<=4'b1110;
            green1<=4'b0101;
            blue1<=4'b1111;
            end
            end
           
           
            else
            begin
            if(vga_y>=100&&vga_y<=170)
            begin
            red1<=4'b0000;
            green1<=4'b0000;
            blue1<=4'b0000;
            end
            
            else
            begin
            red1<=4'b0101;
            green1<=4'b1101;
            blue1<=4'b0000;
            end
            end
        end
        else
        begin
        red1<=4'b0000;
        green1<=4'b0000;
        blue1<=4'b0000;
        end
    end
    end
end


always @ (posedge clk_25MHz)
begin
    case(flag)
    2'd0:begin red=red0;green=green0;blue=blue0; end
    2'd1:begin red=red1;green=green1;blue=blue1; end
    2'd2:begin red=red2;green=green2;blue=blue2; end
    
    endcase
end


//绘制游戏开始界面GO
always @ (posedge clk_25MHz)
begin
    if(vga_x >= 0  && vga_x <= 700  && vga_y >= 0 && vga_y <= 480)
    begin
    
    if(vga_x >= 174  && vga_x <= 194  && vga_y >= 150 && vga_y <= 300)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 174  && vga_x <= 294  && vga_y >= 150 && vga_y <= 170)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 174  && vga_x <= 294  && vga_y >= 280 && vga_y <= 300)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 234  && vga_x <= 294  && vga_y >= 225 && vga_y <= 245)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 274  && vga_x <= 294  && vga_y >= 225 && vga_y <= 300)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 354  && vga_x <= 474  && vga_y >= 150 && vga_y <= 170)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 354  && vga_x <= 474  && vga_y >= 280 && vga_y <= 300)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 354  && vga_x <= 374  && vga_y >= 150 && vga_y <= 300)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 454  && vga_x <= 474  && vga_y >= 150 && vga_y <= 300)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 534  && vga_x <= 554  && vga_y >= 150 && vga_y <= 260)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else if(vga_x >= 534  && vga_x <= 554  && vga_y >= 280 && vga_y <= 300)
    begin
        red0<=4'b1111;
        green0<=4'b1111;
        blue0<=4'b1111;
    end
    else
    begin
        red0<=4'b0000;
        green0<=4'b0000;
        blue0<=4'b0000;
    end
    
    end
end


//绘制游戏结束界面GG
always @ (posedge clk_25MHz)
begin
    if(vga_x >= 0  && vga_x <= 700  && vga_y >= 0 && vga_y <= 480)
    begin
    
    if(vga_x >= 174  && vga_x <= 194  && vga_y >= 150 && vga_y <= 300)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 174  && vga_x <= 294  && vga_y >= 150 && vga_y <= 170)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 174  && vga_x <= 294  && vga_y >= 280 && vga_y <= 300)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 234  && vga_x <= 294  && vga_y >= 225 && vga_y <= 245)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 274  && vga_x <= 294  && vga_y >= 225 && vga_y <= 300)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 354  && vga_x <= 374  && vga_y >= 150 && vga_y <= 300)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 354  && vga_x <= 474  && vga_y >= 150 && vga_y <= 170)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 354  && vga_x <= 474  && vga_y >= 280 && vga_y <= 300)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 414  && vga_x <= 474  && vga_y >= 225 && vga_y <= 245)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 454  && vga_x <= 474  && vga_y >= 225 && vga_y <= 300)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 534  && vga_x <= 554  && vga_y >= 150 && vga_y <= 260)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else if(vga_x >= 534  && vga_x <= 554  && vga_y >= 280 && vga_y <=300)
    begin
        red2<=4'b1111;
        green2<=4'b1111;
        blue2<=4'b1111;
    end
    else
    begin
        red2<=4'b0000;
        green2<=4'b0000;
        blue2<=4'b0000;
    end
    
    end
end

endmodule
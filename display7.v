module display7(
    input clk,
    input rst,
    input [6:0] Score,
    input [6:0] Time,
    output reg [6:0] seg_led,
    output reg [7:0] AN
);

reg [3:0] data[0:7];
reg [6:0] Data;

reg CLK_1000HZ=1'b0;
reg [15:0] count_clk;

reg [2:0] display_count;

//1000HZ¡¤???
always@(posedge clk)
    begin
        if(count_clk==16'd49999)
        begin
        count_clk<=16'd0;
        CLK_1000HZ<=~CLK_1000HZ;
        end
        
        else
        count_clk<=count_clk+1;
    end


always@(*) 
begin
Data = Score;
data[0] = Data % 10;
Data = Data / 10;
data[1] = Data % 10;
Data = Data / 10;
data[2] = Data % 10;
Data = Data / 10;
data[3] = Data % 10;

Data = Time;
data[4] = Data % 10;
Data = Data / 10;
data[5] = Data % 10;
Data = Data / 10;
data[6] = Data % 10;
Data = Data / 10;
data[7] = Data % 10;
Data = Data / 10;
end

//Î»¿Ø
always@ (posedge CLK_1000HZ)
begin
if(display_count == 3'd7)
display_count = 0;
else
display_count = display_count + 1;
case(display_count)
3'd0: AN = 8'b11111110;
3'd1: AN = 8'b11111101;
3'd2: AN = 8'b11111011;
3'd3: AN = 8'b11110111;
3'd4: AN = 8'b11101111;
3'd5: AN = 8'b11011111;
3'd6: AN = 8'b10111111;
3'd7: AN = 8'b01111111;
default: AN = 8'b11111111;
endcase
end

//ÒëÂë
always@(*) begin
case(data[display_count])
0: seg_led = 7'b1000000;
1: seg_led = 7'b1111001;
2: seg_led = 7'b0100100;
3: seg_led = 7'b0110000;
4: seg_led = 7'b0011001;
5: seg_led = 7'b0010010;
6: seg_led = 7'b0000010;
7: seg_led = 7'b1111000;
8: seg_led = 7'b0000000;
9: seg_led = 7'b0010000;
default seg_led=7'b0;
endcase
end



endmodule
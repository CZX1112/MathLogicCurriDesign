module timecount(
    input clk,
    input rst,
    input start,
    output reg live,
    output reg [6:0] Time
);

integer counter = 0;
reg out = 0;
always@(posedge clk) 
begin
    if (rst == 1'b1||start) 
    begin
        counter = 0;
        out <= 0;
    end
    else 
    begin
        if (counter >= 50000000) 
        begin
            counter = 0;
            out <= ~out;
        end
        else 
        begin
            counter = counter + 1;
            out <= out;
        end
    end
end

always@(posedge out or negedge rst) 

begin
    if (rst == 1'b1||start) 
    begin
        Time <= 100;
        live <= 1;
    end
    else
        begin
        if (Time > 0) 
        begin
            Time <= Time - 1;
            live <= 1;
        end
        
        else 
        begin
            Time <= 0;
            live <= 0;
        end
    end

end
endmodule
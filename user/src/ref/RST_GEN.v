/*
 * @Author: shawag 727627411@qq.com
 * @Date: 2024-03-12 22:16:33
 * @LastEditors: shawag 727627411@qq.com
 * @LastEditTime: 2024-03-17 17:30:23
 * @FilePath: \uart\user\src\RST_GEN.v
 * @Description: RDC问题，系统复位处于快时钟域下，uart复位在慢时钟域
 */
 `timescale 1ns/1ps
 module RST_GEN #(
     parameter    RST_CYCLE  = 1
 ) (
     input            i_clk               ,
     output           o_rst
 );

localparam CNT_BIT = $clog2(RST_CYCLE);

reg [CNT_BIT-1:0]     r_cnt='d0;
reg                   ro_rst = 1;

assign o_rst = ro_rst;
always@(posedge i_clk) begin
    if(r_cnt == RST_CYCLE-1 || RST_CYCLE == 0) begin
        r_cnt <= r_cnt;
    end
    else begin
        r_cnt <= r_cnt + 1'b1;
    end
end

always@(posedge i_clk) begin
    if(r_cnt == RST_CYCLE-1 || RST_CYCLE == 0) begin
        ro_rst <= 1'b0;
    end
    else begin
        ro_rst <= 1'b1;
    end
end     
 endmodule  //name
 

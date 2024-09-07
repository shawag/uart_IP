/*
 * @Author: shawag 727627411@qq.com
 * @Date: 2024-03-12 20:14:21
 * @LastEditors: shawag 727627411@qq.com
 * @LastEditTime: 2024-03-19 21:06:50
 * @FilePath: \uart\src\BAUD_CAL.v
 * @Description: 通过波特率计算uart时钟 
*/
`timescale 1ns / 1ps
module BUAD_CAL #(
    parameter    SYSTEM_CLK  = 50000000,
    parameter    UART_BUAD_RATE = 9600
) (
    input                  i_sys_clk,
    input                  i_rst,
    output                 o_u_clk
);

localparam DIVIDER_FACTOR = (SYSTEM_CLK/UART_BUAD_RATE);
localparam HALF_DIVIDER_FACTOR = (DIVIDER_FACTOR/2);
localparam CNT_BIT = $clog2(DIVIDER_FACTOR);
reg                 ro_u_clk;
reg   [CNT_BIT-1:0] div_cnt;


assign o_u_clk = ro_u_clk;

always@(posedge i_sys_clk or posedge i_rst) begin
    if(i_rst) begin
        div_cnt <= 'd0;
    end
    else if(div_cnt == DIVIDER_FACTOR-1) begin
        div_cnt <= 'd0;
    end
    else begin
        div_cnt <= div_cnt + 1'b1;
    end
end

always@(posedge i_sys_clk or posedge i_rst) begin
    if(i_rst) begin
        ro_u_clk <= 1'b0;
    end
    else if(div_cnt <= HALF_DIVIDER_FACTOR) begin
        ro_u_clk <= 1'b1;
    end
    else begin
        ro_u_clk <= 1'b0;
    end
end

    
endmodule  //BAUD_CAL


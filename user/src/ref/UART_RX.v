/*
 * @Author: shawag 727627411@qq.com
 * @Date: 2024-03-13 21:18:10
 * @LastEditors: shawag 727627411@qq.com
 * @LastEditTime: 2024-03-19 20:18:45
 * @FilePath: \uart\user\src\UART_RX.v
 * @Description: uart接收模块
 */
 `timescale 1ns/1ps
module UART_RX #(
    parameter       UART_DATA_WIDTH    = 8                    ,
    parameter       UART_STOP_WIDTH    = 1                    ,
    parameter       UART_CHECK         = 0        //0 for none, 1 for odd, 2 for even
) (
    input                                           i_clk           ,
    input                                           i_rst           ,

    input                                           i_uart_rx       ,
    output              [UART_DATA_WIDTH-1:0]       o_user_rx_data  ,
    output                                          o_user_rx_valid
);

reg     [UART_DATA_WIDTH-1:0]       ro_user_rx_data;
reg                                 ro_user_rx_valid;

//reg     [1:0]                       r_uart_rx;
reg     [3:0]                       r_cnt;
reg                                 r_rx_check;

assign o_user_rx_data = ro_user_rx_data;
assign o_user_rx_valid = ro_user_rx_valid;
//过采样生成时钟，则不考虑CDC
//CDC
/* 
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_uart_rx <= 2'b11;  //协议默认电平为高
    end
    else begin
        r_uart_rx <= {r_uart_rx[0],i_uart_rx};
    end
end
*/
//state cnt
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_cnt <= 4'd0;
    end
    else if(r_cnt == UART_DATA_WIDTH + UART_STOP_WIDTH && UART_CHECK==0) begin
        r_cnt <= 4'd0;
    end
    else if(r_cnt == UART_DATA_WIDTH + 1 + UART_STOP_WIDTH && UART_CHECK >0) begin
        r_cnt <= 4'd0;
    end
    else if(i_uart_rx == 0 || r_cnt>0) begin
        r_cnt <= r_cnt +1'b1;
    end
    else begin
        r_cnt <= r_cnt;
    end
end
//data recieve
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        ro_user_rx_data <= 'd0;
    end
    else if(r_cnt >= 1 && r_cnt <= UART_DATA_WIDTH) begin
        ro_user_rx_data <= {i_uart_rx,ro_user_rx_data[UART_DATA_WIDTH-1:1]};
    end
    else begin
        ro_user_rx_data <= ro_user_rx_data;
    end
end
    
//valid
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        ro_user_rx_valid <= 1'b0;
    end
    else if(r_cnt ==UART_DATA_WIDTH && UART_CHECK == 0) begin
        ro_user_rx_valid <= 1'b1;
    end
    else if(r_cnt == UART_DATA_WIDTH+1 && UART_CHECK == 1 && i_uart_rx == ~r_rx_check)begin
        ro_user_rx_valid <= 1'b1;
    end
    else if(r_cnt == UART_DATA_WIDTH+1 && UART_CHECK == 2 && i_uart_rx == r_rx_check) begin
        ro_user_rx_valid <= 1'b1;
    end
    else begin
        ro_user_rx_valid <= 1'b0;
    end
end
//odd/even check
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_rx_check <= 1'b0;
    end
    else if(r_cnt >= 1 && r_cnt <= UART_DATA_WIDTH)begin
        r_rx_check <= r_rx_check ^ i_uart_rx;
    end
    else begin
        r_rx_check <= 1'b0;
    end
end


    
endmodule  //UART_RX


/*
 * @Author: shawag 727627411@qq.com
 * @Date: 2024-03-16 15:33:45
 * @LastEditors: shawag 727627411@qq.com
 * @LastEditTime: 2024-03-24 23:06:34
 * @FilePath: \uart\user\src\UART_TX.v
 * @Description: uart发送模块
 */
 `timescale 1ns/1ps
module UART_TX #(
    parameter       UART_DATA_WIDTH    = 8                    ,
    parameter       UART_STOP_WIDTH    = 1                    ,
    parameter       UART_CHECK         = 0        //0 for none, 1 for odd, 2 for even
) (
    input                                     i_clk           ,
    input                                     i_rst           ,

    output                                    o_uart_tx,

    input         [UART_DATA_WIDTH-1:0]       i_user_tx_data  ,
    input                                     i_user_tx_valid ,
    output                                    o_user_tx_ready 
);

reg                             ro_uart_tx;
reg                             ro_user_tx_ready;
reg   [3:0]                     r_cnt;
reg   [UART_DATA_WIDTH-1:0]     r_uart_tx_data;
reg                             r_tx_check;

assign  o_uart_tx = ro_uart_tx;
assign  o_user_tx_ready = ro_user_tx_ready;

assign w_tx_active = i_user_tx_valid & o_user_tx_ready;
//ready
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        ro_user_tx_ready <= 1'b1;
    end
    else if(w_tx_active) begin
        ro_user_tx_ready <= 1'b0;
    end
    else if(r_cnt==UART_DATA_WIDTH + UART_STOP_WIDTH - 1&& UART_CHECK ==0) begin
        ro_user_tx_ready <= 1'b1;
    end
    else if(r_cnt==UART_DATA_WIDTH + UART_STOP_WIDTH && UART_CHECK > 0) begin
        ro_user_tx_ready <= 1'b1;
    end
    else begin
        ro_user_tx_ready <= ro_user_tx_ready;
    end
end

//r_cnt
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_cnt <= 4'd0;
    end
    else if(r_cnt == UART_DATA_WIDTH + UART_STOP_WIDTH && UART_CHECK == 0) begin
        r_cnt <= 4'd0;
    end
    else if(r_cnt == UART_DATA_WIDTH + UART_STOP_WIDTH + 1 && UART_CHECK > 0) begin
        r_cnt <= 4'd0;
    end
    else if(!ro_user_tx_ready) begin
        r_cnt <= r_cnt +1'b1;
    end
    else begin
        r_cnt <= r_cnt;
    end
end

//tx_data
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_uart_tx_data <= 'd0;
    end
    else if(w_tx_active) begin
        r_uart_tx_data <= i_user_tx_data;
    end
    else if(!ro_user_tx_ready) begin
        r_uart_tx_data <= r_uart_tx_data >> 1;
    end
    else begin
        r_uart_tx_data <= r_uart_tx_data;
    end

end
//uart_tx'
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        ro_uart_tx <= 1'b1;
    end
    else if(w_tx_active) begin
        ro_uart_tx <= 1'b0;
    end
    else if(r_cnt == UART_DATA_WIDTH && UART_CHECK > 0) begin
        ro_uart_tx <= UART_CHECK == 1? ~r_tx_check : r_tx_check;
    end
    else if(r_cnt >= UART_DATA_WIDTH && UART_CHECK == 0) begin
        ro_uart_tx <= 1'b1;
    end
    else if(r_cnt >= UART_DATA_WIDTH +1 && UART_CHECK >0) begin
        ro_uart_tx <= 1'b1;
    end
    else if(!ro_user_tx_ready) begin
        ro_uart_tx <= r_uart_tx_data[0];
    end
    else begin
        ro_uart_tx <= 1'b1;
    end
end

//check
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_tx_check <= 1'b0;
    end
    else if(r_cnt == UART_DATA_WIDTH) begin
        r_tx_check <= 1'b0;
    end
    else begin
        r_tx_check <= r_tx_check ^ r_uart_tx_data[0];
    end
end
endmodule
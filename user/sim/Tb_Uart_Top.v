/*
 * @Author: shawag 727627411@qq.com
 * @Date: 2024-03-17 20:52:17
 * @LastEditors: shawag 727627411@qq.com
 * @LastEditTime: 2024-03-17 21:02:31
 * @FilePath: \uart\user\sim\TB_UART_DRIVE.v
 * @Description: 
 */
module Tb_Uart_Top();

/****仿真语法、产生时钟与复位****/

localparam CLK_PERIOD = 20 ;

reg clk,rst;

initial begin   //过程语句，只在仿真里可以使用，不可综合
    rst = 1;    //上电开始复位
    #100;       //延时100ns
    @(posedge clk) rst = 0;    //上电复位释放
end

always begin//过程语句，只在仿真里可以使用，不可综合
    clk = 0;
    #(CLK_PERIOD/2);
    clk = 1;
    #(CLK_PERIOD/2);
end

localparam P_USER_DATA_WIDTH = 8;

reg  [P_USER_DATA_WIDTH - 1 : 0]    r_user_tx_data  ;
reg                                 r_user_tx_valid ;
wire                                w_user_tx_ready ;     
wire [P_USER_DATA_WIDTH - 1 : 0]    w_user_rx_data  ;
wire                                w_user_rx_valid ;
wire                                w_user_active   ;
wire                                w_user_clk      ;
wire                                w_user_rst      ;
wire                                o_uart_tx        ;

assign w_user_active = r_user_tx_valid & w_user_tx_ready;


Uart_Driver #(
	.P_SYSTEM_CLK      	( 100000000         ),
	.P_UART_BUADRATE   	( 1152000  ),
	.P_UART_DATA_WIDTH 	( 8 ),
	.P_UART_STOP_WIDTH 	( 1 ),
	.P_UART_CHECK      	( 0      ),
	.P_RST_CYCLE       	( 10  )
)
u_UART_DRIVE
(                  
    .clock              (clk),
    .reset              (rst),  

    .i_uart_rx          (o_uart_tx              ),
    .o_uart_tx          (o_uart_tx              ),

    .i_user_tx_data     (r_user_tx_data         ),
    .i_user_tx_valid    (r_user_tx_valid        ),
    .o_user_tx_ready    (w_user_tx_ready        ),

    .o_user_rx_data     (w_user_rx_data         ),
    .o_user_rx_valid    (w_user_rx_valid        ),
    .o_user_clk         (w_user_clk             ) ,
    .o_user_rst         (w_user_rst             )  
);
/****激励信号****/
always@(posedge w_user_clk,posedge w_user_rst)
begin
    if(w_user_rst)
        r_user_tx_data <= 'd0;
    else if(w_user_active)
        r_user_tx_data <= r_user_tx_data + 1;
    else 
        r_user_tx_data <= r_user_tx_data;
end

always@(posedge w_user_clk,posedge w_user_rst)
begin
    if(w_user_rst)
        r_user_tx_valid <= 'd0;
    else if(w_user_active)
        r_user_tx_valid <= 'd0;
    else if(w_user_tx_ready)
        r_user_tx_valid <= 'd1;
    else 
        r_user_tx_valid <= r_user_tx_valid;
end

endmodule

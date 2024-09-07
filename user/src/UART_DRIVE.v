/*
 * 
 *    ┏┓　　　┏┓
 *  ┏┛┻━━━┛┻┓
 *  ┃　　　　　　　┃
 *  ┃　　　━　　　┃
 *  ┃　＞　　　＜　┃
 *  ┃　　　　　　　┃
 *  ┃...　⌒　...　┃
 *  ┃　　　　　　　┃
 *  ┗━┓　　　┏━┛
 *      ┃　　　┃　
 *      ┃　　　┃
 *      ┃　　　┃
 *      ┃　　　┃  神兽保佑
 *      ┃　　　┃  代码无bug　　
 *      ┃　　　┃
 *      ┃　　　┗━━━┓
 *      ┃　　　　　　　┣┓
 *      ┃　　　　　　　┏┛
 *      ┗┓┓┏━┳┓┏┛
 *        ┃┫┫　┃┫┫
 *        ┗┻┛　┗┻┛
 */
/*
 * @Author: shawag 727627411@qq.com
 * @Date: 2024-03-12 22:00:09
 * @LastEditors: shawag 727627411@qq.com
 * @LastEditTime: 2024-03-12 22:15:24
 * @FilePath: \uart\user\src\UART_DRIVE.v
 * @Description: uart驱动部分总体连接
 */
`timescale 1ns/1ps
module UART_DRIVE #(
    parameter       P_SYSTEM_CLK         = 50000000       ,
    parameter       P_UART_BUADRATE      = 115200             ,
    parameter       P_UART_DATA_WIDTH    = 8                ,
    parameter       P_UART_STOP_WIDTH    = 1                ,
    parameter       P_UART_CHECK         = 0                ,//0 for none, 1 for odd, 2 for even
    parameter       P_RST_CYCLE          = 10 
) (
    input                                  i_sys_clk           ,
    input                                  i_sys_rst           ,
        
    input                                  i_uart_rx           ,
    output                                 o_uart_tx           ,

    input      [P_UART_DATA_WIDTH-1:0]     i_user_tx_data      ,
    input                                  i_user_tx_valid     ,
    input                                  o_user_tx_ready     ,

    output     [P_UART_DATA_WIDTH-1:0]     o_user_rx_data      ,
    output                                 o_user_rx_valid     ,

    output                                 o_user_clk          ,
    output                                 o_user_rst
);

wire                            w_uart_baudclk       ; 
wire                            w_uart_baudclk_rst   ;
wire							w_uart_rx_clk		 ;
reg								r_uart_rx_clk_rst	 ;							
wire [P_UART_DATA_WIDTH-1:0]    w_user_rx_data;
wire                            w_user_rx_valid;      

reg								r_rx_overlock;
reg  [2:0]                      r_rx_overvaule;
reg  [2:0]                      r_rx_overvaule_1;

reg	[P_UART_DATA_WIDTH-1:0]		r_user_rx_data_1;
reg	[P_UART_DATA_WIDTH-1:0]		r_user_rx_data_2;
reg								r_user_rx_valid ;
reg								r_user_rx_valid_1;
reg								r_user_rx_valid_2;


assign		o_user_clk = w_uart_baudclk		;
assign		o_user_rst = w_uart_baudclk_rst	;
assign		o_user_rx_data = r_user_rx_data_2;
assign		o_user_rx_valid = r_user_rx_valid_2;


localparam                              P_CLK_DIV_NUMBER = P_SYSTEM_CLK / P_UART_BUADRATE;

BUAD_CAL #(
	.SYSTEM_CLK     	( P_SYSTEM_CLK  ),
	.UART_BUAD_RATE 	( P_UART_BUADRATE )
)
u_BUAD_CAL_u0
(
	.i_sys_clk 	( i_sys_clk          ),
	.i_rst     	( i_sys_rst          ),
	.o_u_clk   	( w_uart_baudclk     )
);

BUAD_CAL #(
	.SYSTEM_CLK     	( P_SYSTEM_CLK  ),
	.UART_BUAD_RATE 	( P_UART_BUADRATE )
)
u_BUAD_CAL_u1
(
	.i_sys_clk 	( i_sys_clk          ),
	.i_rst     	( r_uart_rx_clk_rst  ),
	.o_u_clk   	( w_uart_rx_clk      )
);

/*
CLK_DIV_module#(
    .P_CLK_DIV_CNT                      (P_CLK_DIV_NUMBER   )//最大为65535
)               
CLK_DIV_module_u0               
(               
    .i_clk                              (i_sys_clk              ),//输入时钟
    .i_rst                              (i_sys_rst              ),//high value
    .o_clk_div                          (w_uart_baudclk     ) //分频后的时钟
);



CLK_DIV_module#(
    .P_CLK_DIV_CNT                      (P_CLK_DIV_NUMBER   )//最大为65535
)               
CLK_DIV_module_u1               
(               
    .i_clk                              (i_sys_clk              ),//输入时钟
    .i_rst                              (r_uart_rx_clk_rst  ),//high value
    .o_clk_div                          (w_uart_rx_clk      ) //分频后的时钟
);
*/
RST_GEN #(
	.RST_CYCLE 	( P_RST_CYCLE  )
)
u_RST_GEN
(
	.i_clk 	( w_uart_baudclk      ),
	.o_rst 	( w_uart_baudclk_rst  )
);


UART_RX #(
	.UART_DATA_WIDTH 	( P_UART_DATA_WIDTH  ),
	.UART_STOP_WIDTH 	( P_UART_STOP_WIDTH  ),
	.UART_CHECK      	( P_UART_CHECK       )
)
u_UART_RX
(
	.i_clk           	( w_uart_rx_clk      ),
	.i_rst           	( w_uart_baudclk_rst  ),
	.i_uart_rx       	( i_uart_rx        ),
	.o_user_rx_data  	( w_user_rx_data   ),
	.o_user_rx_valid 	( w_user_rx_valid  )
);


UART_TX #(
	.UART_DATA_WIDTH 	( P_UART_DATA_WIDTH  ),
	.UART_STOP_WIDTH 	( P_UART_STOP_WIDTH  ),
	.UART_CHECK      	( P_UART_CHECK       )
)
u_UART_TX
(
	.i_clk           	( w_uart_baudclk            ),
	.i_rst           	( w_uart_baudclk_rst            ),
	.o_uart_tx       	( o_uart_tx        ),
	.i_user_tx_data  	( i_user_tx_data   ),
	.i_user_tx_valid 	( i_user_tx_valid  ),
	.o_user_tx_ready 	( o_user_tx_ready  )
);

always @(posedge i_sys_clk or posedge i_sys_rst) begin
    if(i_sys_rst) begin
        r_rx_overvaule <= 3'd0;
    end
    else if (!r_rx_overlock) begin
		r_rx_overvaule <= {r_rx_overvaule[1:0], i_uart_rx};
	end
	else begin
		r_rx_overvaule <= 3'b111;
	end
end

always @(posedge i_sys_clk or posedge i_sys_rst) begin
	if(i_sys_rst) begin
		r_rx_overvaule_1 <= 3'd0;
	end
	else begin
		r_rx_overvaule_1 <= r_rx_overvaule;
	end
end


always @(posedge i_sys_clk or posedge i_sys_rst) begin
	if(i_sys_rst) begin
		r_rx_overlock <= 1'b0;
	end
	else if(!w_user_rx_valid && r_user_rx_valid) begin
		r_rx_overlock <= 1'b0;
	end
	else if(r_rx_overvaule == 3'b000 && r_rx_overvaule_1 != 3'b000) begin
		r_rx_overlock <= 1'b1;
	end
	else begin
		r_rx_overlock <= r_rx_overlock;
	end
end

always @(posedge i_sys_clk or posedge i_sys_rst) begin
	if(i_sys_rst) begin
		r_user_rx_valid <= 1'b0;
	end
	else begin
		r_user_rx_valid <= w_user_rx_valid;
	end
end

always @(posedge i_sys_clk or posedge i_sys_rst) begin
	if(i_sys_rst) begin
		r_uart_rx_clk_rst <= 1'b1;
	end
	else if(!w_user_rx_valid && r_user_rx_valid) begin
		r_uart_rx_clk_rst <= 1'b1;
	end
	else if(r_rx_overvaule == 3'b000 && r_rx_overvaule_1 != 3'b000) begin
		r_uart_rx_clk_rst <= 1'b0;
	end
	else begin
		r_uart_rx_clk_rst <= r_uart_rx_clk_rst;
	end
end



always @(posedge w_uart_baudclk or posedge w_uart_baudclk_rst) begin
	if(w_uart_baudclk_rst) begin
		r_user_rx_data_1 <= 'd0;
		r_user_rx_data_2 <= 'd0;
		r_user_rx_valid_1 <= 1'b0;
		r_user_rx_valid_2 <= 1'b0;
	end
	else begin
		r_user_rx_data_1 <= w_user_rx_data;
		r_user_rx_data_2 <= r_user_rx_data_1;
		r_user_rx_valid_1 <= w_user_rx_valid;
		r_user_rx_valid_2 <= r_user_rx_valid_1;
	end
end

endmodule  //UART_DRIVE

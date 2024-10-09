	//Date :2024-09-13 
	//Author : shawag
	//Module Name: [Uart_Driver.v] - [Uart_Driver]
	//Target Device: [Target FPGA or ASIC Device]
	//Tool versions: [EDA Tool Version]
	//Revision Historyc :
	//Revision :
	//    Revision 0.01 - File Created
	//Description :A brief description of what the module does. Describe its
	//             functionality, inputs, outputs, and any important behavior.
	//
	//Dependencies:
	//         List any modules or files this module depends on, or any
	//            specific conditions required for this module to function 
	//             correctly.
	//	
	//Company : ncai Technology .Inc
	//Copyright(c) 1999, ncai Technology Inc, All right reserved
	//
	//wavedom
	`timescale 1ns / 1ps

	module Uart_Driver 
	(
	    input                                  clock           ,
	    input                                  reset           ,
	
	    input                                  i_uart_rx           ,
	    output                                 o_uart_tx           ,

		input                                  i_uart_cts      			,
		output                                 o_uart_rts			,
	

	    input      [7:0]     i_user_tx_data      ,
	    input                                  i_user_tx_valid     ,
	    output                                 o_user_tx_ready     ,

	    output     [7:0]     o_user_rx_data      ,
	    output                                 o_user_rx_valid     ,

		input		[23:0]						i_div_num,
		input		[3:0]						i_data_bit,
		input 		[1:0]						i_stop_bit,
		input	 	[1:0]						i_check_bit

	   // output                                 o_user_clk          ,
	 //   output                                 o_user_rst
	);

	wire                            w_uart_baudclk       ; 
	wire                            w_uart_baudclk_rst   ;
	wire							w_uart_rx_clk		 ;
	reg								r_uart_rx_clk_rst	 ;							
	wire [7:0]    w_user_rx_data;
	wire                            w_user_rx_valid;      

	reg								r_rx_overlock;
	reg  [2:0]                      r_rx_overvaule;
	reg  [2:0]                      r_rx_overvaule_1;

	reg	[7:0]		r_user_rx_data_1;
	reg	[7:0]		r_user_rx_data_2;
	reg								r_user_rx_valid ;
	reg								r_user_rx_valid_1;
	reg								r_user_rx_valid_2;


	//assign		o_user_clk = w_uart_baudclk		;
	//assign		o_user_rst = w_uart_baudclk_rst	;
	assign		o_user_rx_data = r_user_rx_data_2;
	assign		o_user_rx_valid = r_user_rx_valid_2;



	Baud_Generator  u0_Baud_Generator
	(
		.clock 	    ( clock          ),
		.reset     	( reset          ),
		.i_div_num  ( i_div_num       ),
		.o_u_clk   	( w_uart_baudclk     )
	);

	Baud_Generator u1_Baud_Generator
	(
		.clock   	( clock          ) ,
		.reset     	( r_uart_rx_clk_rst  ),
		.i_div_num  ( i_div_num       ),
		.o_u_clk   	( w_uart_rx_clk      )
	);

/*
	Rst_Gen #(
		.P_RST_CYCLE 	( P_RST_CYCLE  )
	)
	u0_Rst_Gen
	(
		.i_clk 	( w_uart_baudclk      ),
		.o_rst 	( w_uart_baudclk_rst  )
	);
*/

	Uart_Receiver u0_Uart_Receiver
	(
		.i_u_clk           	( w_uart_rx_clk      ),
		.i_u_rst           	( reset  ),
		.i_uart_rx       	( i_uart_rx        ),
		.o_uart_rx_data  	( w_user_rx_data   ),
		.o_uart_rx_valid 	( w_user_rx_valid  ),
		.i_data_bit			( i_data_bit ),
		.i_stop_bit			( i_stop_bit ),
		.i_check_bit		( i_check_bit )
	);


	Uart_Transmitter u0_Uart_Transmitter
	(
		.i_u_clk           	( w_uart_baudclk            ),
		.i_u_rst           	( reset            ),
		.o_uart_tx       	( o_uart_tx        ),
		.i_uart_tx_data  	( i_user_tx_data   ),
		.i_uart_tx_valid 	( i_user_tx_valid  ),
		.o_uart_tx_ready 	( o_user_tx_ready  ),
		.i_data_bit			( i_data_bit ),
		.i_stop_bit			( i_stop_bit ),
		.i_check_bit		( i_check_bit )
	);


	//oversample reg to sample the negedge occur when recieve start bit
	always @(posedge clock or posedge reset) begin
	    if(reset) begin
	        r_rx_overvaule <= 3'd0;
	    end
	    else if (!r_rx_overlock) begin
			r_rx_overvaule <= {r_rx_overvaule[1:0], i_uart_rx};
		end
		else begin
			r_rx_overvaule <= 3'b111;
		end
	end
	//synchronize FF1 of overvalue
	always @(posedge clock or posedge reset) begin
		if(reset) begin
			r_rx_overvaule_1 <= 3'd0;
		end
		else begin
			r_rx_overvaule_1 <= r_rx_overvaule;
		end
	end


	always @(posedge clock or posedge reset) begin
		if(reset) begin
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

	always @(posedge clock or posedge reset) begin
		if(reset) begin
			r_user_rx_valid <= 1'b0;
		end
		else begin
			r_user_rx_valid <= w_user_rx_valid;
		end
	end

	always @(posedge clock or posedge reset) begin
		if(reset) begin
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



	always @(posedge w_uart_baudclk or posedge reset) begin
		if(reset) begin
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

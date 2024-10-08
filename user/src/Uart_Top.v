	//Date :2024-09-10 
	//Author : shawag
	//Module Name: [Uart_Receiver.v] - [Uart_Receiver]
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
	module Uart_Top
	#(
	    parameter       P_SYSTEM_CLK         = 100_000_000          ,
	    parameter       P_UART_BUADRATE      = 1152000   ,
	    parameter       P_UART_DATA_WIDTH    = 8  ,
	    parameter       P_UART_STOP_WIDTH    = 1  ,
	    //0 for none, 1 for odd, 2 for even
	    parameter       P_UART_CHECK         = 0       ,
	    parameter       P_RST_CYCLE          = 10
	)
	(
	    input 								   clock,
	    input 								   reset,
	    input 								   i_uart_rx,
		output 								   o_uart_tx,
		input      [P_UART_DATA_WIDTH-1:0]     i_user_tx_data      ,
	    input                                  i_user_tx_valid     ,
	  	output                                 o_user_tx_ready     ,
	
	    output     [P_UART_DATA_WIDTH-1:0]     o_user_rx_data      ,
	    output                                 o_user_rx_valid     
	);    
	
	
	
	Uart_Driver #(
		.P_SYSTEM_CLK      	( P_SYSTEM_CLK          ),
		.P_UART_BUADRATE   	( P_UART_BUADRATE   ),
		.P_UART_DATA_WIDTH 	( P_UART_DATA_WIDTH  ),
		.P_UART_STOP_WIDTH 	( P_UART_STOP_WIDTH  ),
		.P_UART_CHECK      	( P_UART_CHECK       ),
		.P_RST_CYCLE       	( P_RST_CYCLE   ))
	u0_Uart_Driver(
		.clock           	( clock            ),
		.reset           	( reset            ),
		.i_uart_rx       	( i_uart_rx        ),
		.o_uart_tx       	( o_uart_tx        ),
		.i_user_tx_data  	( i_user_tx_data   ),
		.i_user_tx_valid 	( i_user_tx_valid  ),
		.o_user_tx_ready 	( o_user_tx_ready  ),
		.o_user_rx_data  	( o_user_rx_data   ),
		.o_user_rx_valid 	( o_user_rx_valid  )
	);
	endmodule
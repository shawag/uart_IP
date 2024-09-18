//Date : 2024-09-10
//Author : shawag
//Module Name:Uart_Defines.v 
//Target Device: [Target FPGA or ASIC Device]
//Tool versions: [EDA Tool Version]
//Revision Historyc :
//Revision :
//    Revision 0.01 - File Created
//Description : This file is used to define uart related parameters
//Dependencies:
//        
//	
//Company : ncai Technology .Inc
//Copyright(c) 1999, ncai Technology Inc, All right reserved
//
//wavedom
//system parameter
`define SYS_CLK 100000000
`define UART_RST_CYCLE 10
//uart parameter
`define UART_BAUD_RATE 115200
`define UART_DATA_WIDTH 8
`define UART_STOP_WIDTH 1
//0 for none, 1 for odd, 2 for even
`define UART_CHECK 0

//Date : 2024-09-09
//Author :shawag
//Module Name: [Baud_Generator.v] - [Baud_Generator]
//Target Device: [Target FPGA or ASIC Device]
//Tool versions: [EDA Tool Version]
//Revision Historyc :
//Revision :
//    Revision 0.01 - File Created
//Description :This module is used to generate clock for uart from system clock
//
//Dependencies:
//        
//Company : ncai Technology .Inc
//Copyright(c) 1999, ncai Technology Inc, All right reserved
//
//wavedom
`include "Timescale.v"
`include "Uart_Defines.v"
module Baud_Generator #( 
    //system clock frequency (unit:MHz)
    parameter P_SYS_CLK = `SYS_CLK ,
    //uart baud rate (unit:bps)
    parameter P_UART_BAUD_RATE = `UART_BAUD_RATE
    
)(
    //system clock
    input  clock,
    //system reset, active high
    input  reset,
    //uart clock output
    output o_u_clk
);
//localparam calculate
localparam DIVIDER_FACTOR = ((P_SYS_CLK)/P_UART_BAUD_RATE);
localparam HALF_DIVIDER_FACTOR = $floor((DIVIDER_FACTOR-1)/2)+1;
localparam CNT_BIT = $clog2(DIVIDER_FACTOR);
//reg define
//reg output
reg               ro_u_clk;
//divider cnt
reg [CNT_BIT-1:0] div_cnt;
//connect output to reg
assign o_u_clk = ro_u_clk;
//logic of cnt divider
always@(posedge clock or posedge reset) begin
    if(reset) begin
        div_cnt <= {CNT_BIT{1'b0}};
    end
    else if(div_cnt == DIVIDER_FACTOR-1) begin
        div_cnt <= {CNT_BIT{1'b0}}; 
    end
    else begin
        div_cnt <= div_cnt + 1'b1;
    end
end
//logic of uart clock
always@(posedge clock or posedge reset) begin
    if(reset) begin
        ro_u_clk <= 1'b0;
    end
    else if(div_cnt <= HALF_DIVIDER_FACTOR) begin
        ro_u_clk <= 1'b1;
    end
    else begin
        ro_u_clk <= 1'b0;
    end
end

endmodule
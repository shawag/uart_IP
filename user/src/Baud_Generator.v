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
    `timescale 1ns / 1ps

    module Baud_Generator 
    (
        //system clock
        input  clock,
        //system reset, active high
        input  reset,

        input [23:0] i_div_num ,
        //uart clock output
        output o_u_clk
    );
    //localparam calculate
    /*
    localparam DIVIDER_FACTOR = ((P_SYS_CLK)/P_UART_BAUD_RATE);
    localparam HALF_DIVIDER_FACTOR = $floor((DIVIDER_FACTOR-1)/2)+1;
    localparam CNT_BIT = $clog2(DIVIDER_FACTOR);
    */
    wire [23:0] div_num_half = i_div_num <<< 1;
    //reg define
    //reg output
    reg               ro_u_clk;
    //divider cnt
    reg [23:0] div_cnt;
    //connect output to reg
    assign o_u_clk = ro_u_clk;
    //logic of cnt divider
    always@(posedge clock or posedge reset) begin
        if(reset) begin
            div_cnt <= {24{1'b0}};
        end
        else if(div_cnt == i_div_num - 1'b1) begin
            div_cnt <= {24{1'b0}}; 
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
        else if(div_cnt <= div_num_half) begin
            ro_u_clk <= 1'b1;
        end
        else begin
            ro_u_clk <= 1'b0;
        end
    end

    endmodule
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

    module Uart_Receiver 
    (
        input i_u_clk,
        input i_u_rst,

        input i_uart_rx,
        input [3:0] i_data_bit, 
		input [1:0] i_stop_bit ,
		input [1:0] i_check_bit,
        //uart recieve data out
        output [7:0] o_uart_rx_data,
        //rx valid signal,generate a high pulse when data recieve down
        output o_uart_rx_valid
    );
    //reg output define and assign
    reg [7:0] ro_uart_rx_data;
    reg                         ro_uart_rx_valid;

    assign o_uart_rx_data = ro_uart_rx_data; 
    assign o_uart_rx_valid = ro_uart_rx_valid;
    //reg define
    reg     [3:0]                       r_cnt;
    reg                                 r_rx_check;

    //counter controller to comntrol data recieve process
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            r_cnt <= 4'd0;
        end
        else if(r_cnt == i_data_bit + i_stop_bit && i_check_bit==0) begin
            r_cnt <= 4'd0;
        end
        else if(r_cnt == i_data_bit + 1 + i_stop_bit && i_check_bit >0) begin
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
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            ro_uart_rx_data <= 'd0;
        end
        else if(r_cnt >= 1 && r_cnt <= i_data_bit) begin
            ro_uart_rx_data <= {i_uart_rx,ro_uart_rx_data[7:1]};
        end
        else begin
            ro_uart_rx_data <= ro_uart_rx_data;
        end
    end

    //loigic for rx valid signal
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            ro_uart_rx_valid <= 1'b0;
        end
        else if(r_cnt ==i_data_bit && i_check_bit == 0) begin
            ro_uart_rx_valid <= 1'b1;
        end
        else if(r_cnt == i_data_bit+1 && i_check_bit == 1 && i_uart_rx == ~r_rx_check)begin
            ro_uart_rx_valid <= 1'b1;
        end
        else if(r_cnt == i_data_bit+1 && i_check_bit == 2 && i_uart_rx == r_rx_check) begin
            ro_uart_rx_valid <= 1'b1;
        end
        else begin
            ro_uart_rx_valid <= 1'b0;
        end
    end

    //parity bit calculation
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            r_rx_check <= 1'b0;
        end
        else if(r_cnt >= 1 && r_cnt <= i_data_bit)begin
            r_rx_check <= r_rx_check ^ i_uart_rx;
        end
        else begin
            r_rx_check <= 1'b0;
        end
    end

    endmodule
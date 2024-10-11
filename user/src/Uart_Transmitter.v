    //Date :2024-09-13 
    //Author : shawag
    //Module Name: [Uart_Transmitter.v] - [Uart_Transmitter.v]
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

    module Uart_Transmitter
    (
        input                                     i_u_clk           ,
        input                                     i_u_rst           ,
        input [3:0]                               i_data_bit, 
        input [1:0]                               i_stop_bit ,
        input [1:0]                               i_check_bit,
        input                                     i_uart_cts,

        output                                    o_uart_tx,

        input         [7:0]                       i_uart_tx_data  ,
        //tx valid signal, 
        input                                     i_uart_tx_valid ,
        //tx ready signal
        output                                    o_uart_tx_ready 
    );
    //reg output define and assign
    reg                             ro_uart_tx;
    reg                             ro_uart_tx_ready;
    assign  o_uart_tx = ro_uart_tx;
    assign  o_uart_tx_ready = ro_uart_tx_ready;
    //reg define
    reg   [3:0]                       r_cnt;
    reg   [7:0]                       r_uart_tx_data;
    reg                               r_tx_check;

    reg                               r_uart_cts;
    //indicate transmit process
    assign cts_valid = !r_uart_cts & (!i_uart_cts);
    assign w_tx_active = i_uart_tx_valid & o_uart_tx_ready & cts_valid;

    //reg used to capture cts
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            r_uart_cts <= 1'b1;
        end
        else begin
            r_uart_cts <= i_uart_cts;
        end
    end
    //logic for tx ready, active low during tranmission
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            ro_uart_tx_ready <= 1'b1;
        end
        else if(w_tx_active) begin
            ro_uart_tx_ready <= 1'b0;
        end
        else if(r_cnt==i_data_bit + i_stop_bit - 1&& i_check_bit ==0) begin
            ro_uart_tx_ready <= 1'b1;
        end
        else if(r_cnt==i_data_bit + i_stop_bit && i_check_bit > 0) begin
            ro_uart_tx_ready <= 1'b1;
        end
        else begin
            ro_uart_tx_ready <= ro_uart_tx_ready;
        end
    end

    //counter for trnsmition process
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            r_cnt <= 4'd0;
        end
        else if(r_cnt == i_data_bit + i_stop_bit && i_check_bit == 0) begin
            r_cnt <= 4'd0;
        end
        else if(r_cnt == i_data_bit + i_stop_bit + 1 && i_check_bit > 0) begin
            r_cnt <= 4'd0;
        end
        else if(!ro_uart_tx_ready) begin
            r_cnt <= r_cnt +1'b1;
        end
        else begin
            r_cnt <= r_cnt;
        end
    end

    //tranmit data during tranmission
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            r_uart_tx_data <= 'd0;
        end
        else if(w_tx_active) begin
            r_uart_tx_data <= i_uart_tx_data;
        end
        else if(!ro_uart_tx_ready) begin
            r_uart_tx_data <= r_uart_tx_data >> 1;
        end
        else begin
            r_uart_tx_data <= r_uart_tx_data;
        end

    end
    //pairty bit and stop bit transmition
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            ro_uart_tx <= 1'b1;
        end
        else if(w_tx_active) begin
            ro_uart_tx <= 1'b0;
        end
        else if(r_cnt == i_data_bit && i_check_bit > 0) begin
            ro_uart_tx <= i_check_bit == 1? ~r_tx_check : r_tx_check;
        end
        else if(r_cnt >= i_data_bit && i_check_bit == 0) begin
            ro_uart_tx <= 1'b1;
        end
        else if(r_cnt >= i_data_bit +1 && i_check_bit >0) begin
            ro_uart_tx <= 1'b1;
        end
        else if(!ro_uart_tx_ready) begin
            ro_uart_tx <= r_uart_tx_data[0];
        end
        else begin
            ro_uart_tx <= 1'b1;
        end
    end

    //parity bit calculation
    always @(posedge i_u_clk or posedge i_u_rst) begin
        if(i_u_rst) begin
            r_tx_check <= 1'b0;
        end
        else if(r_cnt == i_data_bit) begin
            r_tx_check <= 1'b0;
        end
        else begin
            r_tx_check <= r_tx_check ^ r_uart_tx_data[0];
        end
    end
    endmodule
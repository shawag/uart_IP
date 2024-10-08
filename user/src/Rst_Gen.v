    //Date :2024-09-13 
    //Author : shawag
    //Module Name: [Rst_Gen.v] - [Rst_Gen]
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
    module Rst_Gen #(
        parameter    P_RST_CYCLE  = 10
    ) 
    (
        input            i_clk               ,
        output           o_rst
    );

    localparam CNT_BIT = $clog2(P_RST_CYCLE);

    reg [CNT_BIT-1:0]     r_cnt='d0;
    reg                   ro_rst = 1;

    assign o_rst = ro_rst;
    //cycle counter
    always@(posedge i_clk) begin
        if(r_cnt == P_RST_CYCLE -1 || P_RST_CYCLE == 0) begin
            r_cnt <= r_cnt;
        end
        else begin
            r_cnt <= r_cnt + 1'b1;
        end
    end
    //output rst signal
    always@(posedge i_clk) begin
        if(r_cnt == P_RST_CYCLE -1 || P_RST_CYCLE == 0) begin
            ro_rst <= 1'b0;
        end
        else begin
            ro_rst <= 1'b1;
        end
    end     
     endmodule
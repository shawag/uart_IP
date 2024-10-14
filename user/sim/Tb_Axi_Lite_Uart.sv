`timescale 1ns / 1ps
module Tb_AxizLite_Uart();
    reg             clock           ;
    reg             reset    ;
    reg     [15:0]  s_axi_awaddr    ;
    reg             s_axi_awvalid   ;
    wire            s_axi_awready   ;
    reg     [31:0]  s_axi_wdata     ;
    reg             s_axi_wvalid    ;
    wire            s_axi_wready    ;
    wire    [1:0]   s_axi_bresp     ;
    wire            s_axi_bvalid    ;
    reg             s_axi_bready    ;
    reg     [15:0]  s_axi_araddr    ;
    reg             s_axi_arvalid   ;
    wire            s_axi_arready   ;
    wire    [31:0]  s_axi_rdata     ;
    wire    [1:0]   s_axi_rresp     ;
    wire            s_axi_rvalid    ;
    reg             s_axi_rready    ;
    //    wire            interrupt       ;
    wire            RTS;
    reg             CTS;

     // inner logic
     
    logic           start_write;
    logic           start_read;
    logic   [31:0]  rd_data;
    wire            TxD_RxD;

    parameter CLOCK_PERIOD = 10;
    parameter P_FIFO_DEPTH = 8;
    parameter P_S_AXI_DATA_WIDTH = 32;
    parameter P_S_AXI_ADDR_WIDTH = 16;


    task clock_gen;
    begin
        clock = 1;
        $display("%t:clock is activated, period is %d ns", $time,CLOCK_PERIOD);
        forever # (CLOCK_PERIOD/2)
            clock = ~clock;
    end
    endtask

    task rst_gen;
    input integer reset_time;
    begin
        reset = 1'b0;
        $display("%t:reset low is activated", $time);
        #(reset_time)
        reset = 1'b1;
        $display("%t:reset low is end, take %d ns to finish", $time, reset_time);
    end
    endtask

    task sys_value_init;
    begin
        s_axi_awaddr    =   16'h0   ;
        s_axi_awvalid   =   1'b0    ;
        s_axi_wdata     =   32'h0   ;
        s_axi_wvalid    =   1'b0    ;
        s_axi_bready    =   1'b0    ;
        s_axi_araddr    =   16'h0   ;
        s_axi_arvalid   =   1'b0    ;
        s_axi_rready    =   1'b0    ;
        CTS             =   1'b0;
    end
    endtask
   
    task axi_lite_write_process;
    input [P_S_AXI_ADDR_WIDTH-1:0] axi_write_addr;
    input [P_S_AXI_DATA_WIDTH-1:0] axi_write_data;
    begin
        @(posedge clock)
        s_axi_awvalid = 1'b1;
        s_axi_awaddr = axi_write_addr;
        s_axi_wdata = axi_write_data;
        wait(s_axi_awready==1'b1);
        @(posedge clock)
        s_axi_awvalid = 1'b0;
        @(posedge clock)
        s_axi_wvalid = 1'b1;
        s_axi_bready = 1'b1;
        wait(s_axi_wready==1'b1);
        @(posedge clock)
        s_axi_wvalid = 1'b0;
        wait(s_axi_bvalid==1'b1);
        if(s_axi_bresp == 2'b00)
            $display("%t:write data %h to address %h, write success", $time, axi_write_data, axi_write_addr);
        else
            $display("%t:write data %h to address %h, write failed", $time, axi_write_data, axi_write_addr);
        @(posedge clock)
        s_axi_bready = 1'b0; 
    end
    endtask

    task axi_lite_read_process;
    input [P_S_AXI_ADDR_WIDTH-1:0] axi_read_addr;
    begin
        @(posedge clock)
        s_axi_arvalid = 1'b1;
        s_axi_araddr = axi_read_addr;
        wait(s_axi_arready==1'b1);
        @(posedge clock)
        s_axi_arvalid = 1'b0;
        s_axi_rready = 1'b1;
        wait(s_axi_rvalid==1'b1);
        @(posedge clock)
        rd_data = s_axi_rdata;
        @(posedge clock)
        $display("%t:read data %h from address %h", $time, rd_data, axi_read_addr);
    end
    endtask

    initial begin
        clock_gen;
    end

    initial begin

        #(5*CLOCK_PERIOD)
        sys_value_init;
        rst_gen(10*CLOCK_PERIOD);
        #(5*CLOCK_PERIOD)
        axi_lite_write_process(16'h0004, 32'h00000001);
        axi_lite_write_process(16'h0004, 32'h00000002);
        axi_lite_write_process(16'h0004, 32'h00000003);
        axi_lite_write_process(16'h0004, 32'h00000004);
        axi_lite_write_process(16'h0004, 32'h00000005);
        axi_lite_write_process(16'h0004, 32'h00000006);
        axi_lite_write_process(16'h0004, 32'h00000007);
        axi_lite_write_process(16'h0004, 32'h00000008);
        #(10000*CLOCK_PERIOD)
        axi_lite_read_process(16'h0000);
    end
    


    //  ============================= Control =============================
    //  100MHz Clock
    /*
    initial                 clock = 1'b0       ;
    always #(Clockperiod/2) clock = ~clock;
    */
    /*
    initial begin
        async_resetn    =   1'b0    ;
        /*      
        s_axi_awaddr    =   16'h0   ;
        s_axi_awvalid   =   1'b0    ;
        s_axi_wdata     =   32'h0   ;
        s_axi_wvalid    =   1'b0    ;
        s_axi_bready    =   1'b0    ;

        s_axi_araddr    =   16'h0   ;
        s_axi_arvalid   =   1'b0    ;
        s_axi_rready    =   1'b0    ;
        
        #1500
        async_resetn    =   1'b1    ;
        //s_axi_bready    =   1'b1    ;

        #1500                       
        start_write=0;
        #50
        start_write=1;
        #10
        start_write=0;
    end
    */

    //  发起写请求
    //  写地址通道
    //  s_axi_awvalid
    /*
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_awvalid <= 0;
        end else if(start_write) begin
            s_axi_awvalid <= 1;
        end else if(s_axi_awvalid && s_axi_awready) begin
            //写地址通道完成
            s_axi_awvalid <= 0;
        end
    end
    //  s_axi_awaddr
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_awaddr <= 16'd0;
        end else if(start_write) begin
            s_axi_awaddr <= 16'd4;
        end
    end
    //  写数据通道
    //  s_axi_wdata
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_wdata <= 0;
        end else if(s_axi_awvalid && s_axi_awready) begin 
            // 写地址通道完成
            s_axi_wdata <= 16'd12;
        end
    end
    //  s_axi_wvalid
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_wvalid <= 0;
        end else if(s_axi_awvalid && s_axi_awready) begin 
            // 写地址结束，开始写数据，写数据写地址可同时进行
            s_axi_wvalid <= 1;
        end else if(s_axi_wvalid && s_axi_wready) begin
            // 写数据完毕
            s_axi_wvalid <= 0;
        end
    end
    //  写响应通道
    //  s_axi_bready
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_bready <= 0;
        end else if(s_axi_awvalid && s_axi_awready) begin // 写地址通道结束后可提前拉高
            s_axi_bready <= 1;
        end else if(s_axi_bready && s_axi_bvalid && s_axi_bresp == 2'b00) begin      
            s_axi_bready <= 0;
        end
    end

    //  发起读请求
    //  start_read
    // always_ff @(posedge clock, negedge async_resetn)
    // if(!async_resetn)
    //     start_read <= 0;
    // else if(s_axi_bresp == 2'b00 && s_axi_bvalid && s_axi_bready)
    //     start_read <= 1;
    // else
    //     start_read <= 0;
    initial begin
        #120000
        start_read=0;
        #50
        start_read=1;
        #10
        start_read=0;
    end

    //  读地址通道
    //  s_axi_arvalid
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_arvalid <= 0;
        end else if(start_read) begin
            s_axi_arvalid <= 1;
        end else if(s_axi_arvalid && s_axi_arready) begin   
            //读地址通道结束
            s_axi_arvalid <= 0;
        end
    end
    //  s_axi_araddr
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_araddr <= 0;
        end else if(start_read) begin
            s_axi_araddr <= 16'd0;
        end
    end
    //  读数据通道
    //  s_axi_rready
    always_ff @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            s_axi_rready <= 0;
        end else if(s_axi_arvalid && s_axi_arready) begin    
            //读地址通道结束后，拉高RREADY以准备接收数据
            s_axi_rready <= 1;
        end else if(s_axi_rready && s_axi_rvalid) begin                   //读数据完成
            s_axi_rready <= 0;
        end
    end
    //  rd_data
    always @(posedge clock, negedge async_resetn) begin
        if(!async_resetn) begin
            rd_data <= 0;
        end else if(s_axi_rvalid && s_axi_rready) begin  //同时为高，可读取数据
            rd_data <= s_axi_rdata;
            $strobe("%d",rd_data);
        end
    end
    /*
    initial begin
        $dumpfile("./sim/axilite_uart_tb.vcd");
        $dumpvars(0, axilite_uart_tb);
        #10000000
        $finish;
    end
    */
    Axi_Lite_Uart  #(
        .P_S_AXI_DATA_WIDTH 	( P_S_AXI_DATA_WIDTH        )  ,
	    .P_S_AXI_ADDR_WIDTH 	( P_S_AXI_ADDR_WIDTH        )  ,
        .P_FIFO_DEPTH           ( P_FIFO_DEPTH )
    )
    Axi_Lite_Uart_u0
    (
        .clock          (clock)         , 
        .reset          (reset)  ,

        .s_axi_awaddr   (s_axi_awaddr)  ,
        .s_axi_awvalid  (s_axi_awvalid) ,
        .s_axi_awready  (s_axi_awready) ,

        .s_axi_wdata    (s_axi_wdata)   ,
        .s_axi_wvalid   (s_axi_wvalid)  ,
        .s_axi_wready   (s_axi_wready)  ,

        .s_axi_bresp    (s_axi_bresp)   ,
        .s_axi_bvalid   (s_axi_bvalid)  ,
        .s_axi_bready   (s_axi_bready)  ,

        .s_axi_araddr   (s_axi_araddr)  ,
        .s_axi_arvalid  (s_axi_arvalid) ,
        .s_axi_arready  (s_axi_arready) ,

        .s_axi_rdata    (s_axi_rdata)   ,
        .s_axi_rresp    (s_axi_rresp)   ,
        .s_axi_rvalid   (s_axi_rvalid)  ,
        .s_axi_rready   (s_axi_rready)  , 

       // .interrupt      (interrupt)     ,
        .RxD            (TxD_RxD)           ,
        .TxD            (TxD_RxD)           ,
        .RTS           (RTS)              ,
        .CTS           (CTS)             
    );

endmodule
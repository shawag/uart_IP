    `timescale 1ns / 1ps
    //
    // Company: 
    // Engineer: 
    // 
    // Create Date: 2021/03/09 09:08:00
    // Design Name: 
    // Module Name: axi_lite_master_test
    // Project Name: 
    // Target Devices: 
    // Tool Versions: 
    // Description: 
    // 
    // Dependencies: 
    // 
    // Revision:
    // Revision 0.01 - File Created
    // Additional Comments:
    // 
    //
    
    
    module Tb_Axi_Lite_Uart;
    //global signals
    logic ACLK;
    logic ARESETn;
    //AW channel
    logic AWVALID;
    logic [31:0]AWADDR; 
    logic [2:0]AWPROT; 
    logic AWREADY;
    //W channel
    logic WVALID;
    logic [31:0] WDATA; 
    logic [3:0] WSTRB;
    logic WREADY;
    //WB channel
    logic BREADY;
    logic BVALID;
    logic [1:0] BRESP;
    //AR channel
    logic ARVALID;
    logic [31:0] ARADDR; 
    logic [2:0] ARPROT; 
    logic ARREADY;
    //R channel
    logic RREADY;
    logic RVALID;
    logic [31:0] RDATA; 
    logic [1:0] RRESP;
    //inner logic
    logic start_write;
    logic start_read;
    logic [31:0] rd_data;
    
    logic TX_RX;
    
    //ACLK AND ARESETn
    initial begin
        ACLK=0;
        forever begin
            #5 ACLK=~ACLK;
        end
    end
    
    initial begin
        ARESETn=0;
        #10
        ARESETn=1;
    end
    //start_write
    initial begin
        start_write=0;
        #50
        start_write=1;                    //拉高一个周期以开始写数据操作
        #10
        start_write=0;
    end
    //发起写请求
    //写地址通道
    //AWVALID
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        AWVALID<=0;
    else if(start_write)
        AWVALID<=1;
    else if(AWVALID&&AWREADY)           //写地址通道传输完毕
        AWVALID<=0;
    //AWADDR
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        AWADDR<=32'd0;
    else if(start_write)
        AWADDR<=32'd4;
    //AWPROT
    always_comb 
    begin
        AWPROT=3'b000;    
    end    
    //写数据通道
    //WDATA
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
       WDATA<=0;
    else if(AWVALID&&AWREADY)                   //写地址通道完成
       WDATA<=32'd6;
    //WVALID
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
       WVALID<=0;
    else if(AWVALID&&AWREADY)                   //写地址通道结束，开始写数据，事实上，写数据和写地址通道可以同时进行
       WVALID<=1;
    else if(WVALID&&WREADY)                     //写数据完毕
       WVALID<=0;
    //WSTRB
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        WSTRB<=4'b0000;
    else if(AWVALID&&AWREADY)
        WSTRB<=4'b1111;
    //写响应通道
    //BREADY
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        BREADY<=0;
    else if(AWVALID&&AWREADY)                      //写地址通道结束后就可以提前拉高
        BREADY<=1;
    else if(BREADY&&BVALID&&BRESP==2'b00)           //
        BREADY<=0;
    //发起读请求
    //start_read
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        start_read<=0;
    else if(BRESP==2'b00&&BVALID&&BREADY)
        start_read<=1;
    else
        start_read<=0;
    //读地址通道
    //ARVALID
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        ARVALID<=0;
    else if(start_read)
        ARVALID<=1;
    else if(ARVALID&&ARREADY)   //读地址通道结束
        ARVALID<=0;
    //ARADDR
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        ARADDR<=0;
    else if(start_read)
        ARADDR<=32'd0;
    //ARPROT
    always_comb 
    begin
        ARPROT=3'b000;    
    end
    //读数据通道
    //RREADY
    always_ff @(posedge ACLK,negedge ARESETn) 
    if(!ARESETn)
        RREADY<=0;
    else if(ARVALID&&ARREADY)                  //读地址通道结束后，拉高RREADY以准备接收数据
        RREADY<=1;
    else if(RREADY&&RVALID)                    //读数据完成
        RREADY<=0;
    //rd_data
    always_ff@(posedge ACLK,negedge ARESETn)
    if(!ARESETn)
        rd_data<=0;
    else if(RVALID&&RREADY)                    //同时为高，可读取数据
    begin
        rd_data<=RDATA;
        $display("%d",rd_data);
    end
    
    Axi_Lite_Uart #(
    	.P_S_AXI_DATA_WIDTH 	( 32        )  ,
    	.P_S_AXI_ADDR_WIDTH 	( 32        )  ,
        .P_SYSTEM_CLK           (100_000_000)  ,
        .P_UART_BUADRATE        (1152000    )  ,
        .P_UART_DATA_WIDTH      (8          )  ,
        .P_UART_STOP_WIDTH      (1          )  ,
        .P_UART_CHECK           (0          )  ,
        .P_RST_CYCLE            (10         )
        
        
        )
    u_Axi_Lite_Uart(
    	.s_axi_aclk    	( ACLK     ),
    	.s_axi_aresetn 	( ARESETn  ),
    	.s_axi_awaddr  	( AWADDR   ),
    	.s_axi_awprot  	( AWPROT   ),
    	.s_axi_awvalid 	( AWVALID  ),
    	.s_axi_awready 	( AWREADY  ),
    	.s_axi_wdata   	( WDATA    ),
    	.s_axi_wstrb   	( WSTRB    ),
    	.s_axi_wvalid  	( WVALID   ),
    	.s_axi_wready  	( WREADY   ),
    	.s_axi_bresp   	( BRESP    ),
    	.s_axi_bvalid  	( BVALID   ),
    	.s_axi_bready  	( BREADY   ),
    	.s_axi_araddr  	( ARADDR   ),
    	.s_axi_arprot  	( ARPROT   ),
    	.s_axi_arvalid 	( ARVALID  ),
    	.s_axi_arready 	( ARREADY  ),
    	.s_axi_rdata   	( RDATA    ),
    	.s_axi_rresp   	( RRESP    ),
    	.s_axi_rvalid  	( RVALID   ),
    	.s_axi_rready  	( RREADY   ),
        .rx             (TX_RX),
        .tx             (TX_RX)
    );
    
    
    endmodule
    
    
    `timescale 1ns / 1ps
    module Axi_Lite_Uart #(
        parameter integer P_S_AXI_DATA_WIDTH	= 32,
        parameter integer P_S_AXI_ADDR_WIDTH	= 16,
    
        parameter       P_SYSTEM_CLK         = 100_000_000,
        parameter       P_UART_BUADRATE      = 1152000   ,
        parameter       P_UART_DATA_WIDTH    = 8  ,
        parameter       P_UART_STOP_WIDTH    = 1  ,
        //0 for none, 1 for odd, 2 for even
        parameter       P_UART_CHECK         = 0       ,
        parameter       P_RST_CYCLE          = 10
    )
    (
        input   s_axi_aclk,
    	// Global Reset Signal. This Signal is Active LOW
    	input   s_axi_aresetn,
    	// Write address 
    	input  [P_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    	// Write channel Protection type. 
    	input  [2:0] s_axi_awprot,
    	// Write address valid.
    	input   s_axi_awvalid,
    	// Write address ready. 
    	output   s_axi_awready,
    	// Write data.
    	input  [P_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
    	// Write strobes. This signal indicates which byte lanes hold
    	input  [(P_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,
    	// Write valid. This signal indicates that valid write
    	input   s_axi_wvalid,
    	// Write ready. This signal indicates that the slave
    	output   s_axi_wready,
    	// Write response. This signal indicates the status
    	output  [1:0] s_axi_bresp,
    	// Write response valid. 
    	output   s_axi_bvalid,
    	// Response ready. This signal indicates that the master
    	input   s_axi_bready,
    	// Read address
    	input  [P_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    	// Protection type.
    	input  [2:0] s_axi_arprot,
    	// Read address valid.
    	input   s_axi_arvalid,
    	// Read address ready.
    	output   s_axi_arready,
    	// Read data
    	output  [P_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
    	// Read response. 
    	output  [1:0] s_axi_rresp,
    	// Read valid. 
    	output   s_axi_rvalid,
    	// Read ready.
    	input   s_axi_rready,
    
        input   rx,
        output  tx
    );
    
    wire  w_user_rx_valid;
    wire  [P_UART_DATA_WIDTH-1:0] w_user_rx_data;
    wire  w_user_tx_ready;
    wire  w_user_tx_valid;
    wire  [P_UART_DATA_WIDTH-1:0] w_user_tx_data;
    
    
    S_Axi_Lite #(
    	.P_S_AXI_DATA_WIDTH 	( P_S_AXI_DATA_WIDTH  ),
    	.P_S_AXI_ADDR_WIDTH 	( P_S_AXI_ADDR_WIDTH   ),
        .P_UART_DATA_WIDTH      (P_UART_DATA_WIDTH)
    )      
    u_S_Axi_Lite(
    	.s_axi_aclk      	( s_axi_aclk       ),
    	.s_axi_aresetn   	( s_axi_aresetn    ),
    	.s_axi_awaddr    	( s_axi_awaddr     ),
    	.s_axi_awprot    	( s_axi_awprot     ),
    	.s_axi_awvalid   	( s_axi_awvalid    ),
    	.s_axi_awready   	( s_axi_awready    ),
    	.s_axi_wdata     	( s_axi_wdata      ),
    	.s_axi_wstrb     	( s_axi_wstrb      ),
    	.s_axi_wvalid    	( s_axi_wvalid     ),
    	.s_axi_wready    	( s_axi_wready     ),
    	.s_axi_bresp     	( s_axi_bresp      ),
    	.s_axi_bvalid    	( s_axi_bvalid     ),
    	.s_axi_bready    	( s_axi_bready     ),
    	.s_axi_araddr    	( s_axi_araddr     ),
    	.s_axi_arprot    	( s_axi_arprot     ),
    	.s_axi_arvalid   	( s_axi_arvalid    ),
    	.s_axi_arready   	( s_axi_arready    ),
    	.s_axi_rdata     	( s_axi_rdata      ),
    	.s_axi_rresp     	( s_axi_rresp      ),
    	.s_axi_rvalid    	( s_axi_rvalid     ),
    	.s_axi_rready    	( s_axi_rready     ),
    	.i_user_rx_valid 	( w_user_rx_valid  ),
    	.i_user_rx_data  	( w_user_rx_data   ),
    	.i_user_tx_ready 	( w_user_tx_ready  ),
    	.o_user_tx_valid 	( w_user_tx_valid  ),
    	.o_user_tx_data  	( w_user_tx_data   )
    );
    
    Uart_Top #(
    	.P_SYSTEM_CLK      	( P_SYSTEM_CLK      ),
    	.P_UART_BUADRATE   	( P_UART_BUADRATE   ),
    	.P_UART_DATA_WIDTH 	( P_UART_DATA_WIDTH  ),
    	.P_UART_STOP_WIDTH 	( P_UART_STOP_WIDTH  ),
    	.P_UART_CHECK      	( P_UART_CHECK       ),
    	.P_RST_CYCLE       	( P_RST_CYCLE   ))
    u_Uart_Top(
    	.clock           	( s_axi_aclk       ),
    	.reset           	( ~s_axi_aresetn   ),
    	.i_uart_rx       	( rx        ),
    	.o_uart_tx       	( tx        ),
    	.i_user_tx_data  	( w_user_tx_data   ),
    	.i_user_tx_valid 	( w_user_tx_valid  ),
    	.o_user_tx_ready 	( w_user_tx_ready  ),
    	.o_user_rx_data  	( w_user_rx_data   ),
    	.o_user_rx_valid 	( w_user_rx_valid  )
    );
    
    
    
    endmodule
`include "Timescale.v"
`include "Uart_Defines.v"
module Axi_Lite_Uart #(
    parameter integer P_S_AXI_DATA_WIDTH	= 32,
    parameter integer P_S_AXI_ADDR_WIDTH	= 4
)
(
    input wire  S_AXI_ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input wire  S_AXI_ARESETN,
    // Write address 
    input wire [P_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    // Write channel Protection type. 
    input wire [2 : 0] S_AXI_AWPROT,
    // Write address valid.
    input wire  S_AXI_AWVALID,
    // Write address ready. 
    output wire  S_AXI_AWREADY,
    // Write data.
    input wire [P_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    // Write strobes. This signal indicates which byte lanes hold
    input wire [(P_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    // Write valid. This signal indicates that valid write
    input wire  S_AXI_WVALID,
    // Write ready. This signal indicates that the slave
    output wire  S_AXI_WREADY,
    // Write response. This signal indicates the status
    output wire [1 : 0] S_AXI_BRESP,
    // Write response valid. 
    output wire  S_AXI_BVALID,
    // Response ready. This signal indicates that the master
    input wire  S_AXI_BREADY,
    // Read address
    input wire [P_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    // Protection type.
    input wire [2 : 0] S_AXI_ARPROT,
    // Read address valid.
    input wire  S_AXI_ARVALID,
    // Read address ready.
    output wire  S_AXI_ARREADY,
    // Read data
    output wire [P_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    // Read response. 
    output wire [1 : 0] S_AXI_RRESP,
    // Read valid. 
    output wire  S_AXI_RVALID,
    // Read ready.
    input wire  S_AXI_RREADY,

    input wire  RXD,
    output wire  TXD
);

wire  w_user_rx_valid;
wire  [`UART_DATA_WIDTH-1:0] w_user_rx_data;
wire  w_user_tx_ready;
wire  w_user_tx_valid;
wire  [`UART_DATA_WIDTH-1:0] w_user_tx_data;


S_Axi_Lite #(
	.P_S_AXI_DATA_WIDTH 	( P_S_AXI_DATA_WIDTH  ),
	.P_S_AXI_ADDR_WIDTH 	( P_S_AXI_ADDR_WIDTH   ))
u_S_Axi_Lite(
	.S_AXI_ACLK      	( S_AXI_ACLK       ),
	.S_AXI_ARESETN   	( S_AXI_ARESETN    ),
	.S_AXI_AWADDR    	( S_AXI_AWADDR     ),
	.S_AXI_AWPROT    	( S_AXI_AWPROT     ),
	.S_AXI_AWVALID   	( S_AXI_AWVALID    ),
	.S_AXI_AWREADY   	( S_AXI_AWREADY    ),
	.S_AXI_WDATA     	( S_AXI_WDATA      ),
	.S_AXI_WSTRB     	( S_AXI_WSTRB      ),
	.S_AXI_WVALID    	( S_AXI_WVALID     ),
	.S_AXI_WREADY    	( S_AXI_WREADY     ),
	.S_AXI_BRESP     	( S_AXI_BRESP      ),
	.S_AXI_BVALID    	( S_AXI_BVALID     ),
	.S_AXI_BREADY    	( S_AXI_BREADY     ),
	.S_AXI_ARADDR    	( S_AXI_ARADDR     ),
	.S_AXI_ARPROT    	( S_AXI_ARPROT     ),
	.S_AXI_ARVALID   	( S_AXI_ARVALID    ),
	.S_AXI_ARREADY   	( S_AXI_ARREADY    ),
	.S_AXI_RDATA     	( S_AXI_RDATA      ),
	.S_AXI_RRESP     	( S_AXI_RRESP      ),
	.S_AXI_RVALID    	( S_AXI_RVALID     ),
	.S_AXI_RREADY    	( S_AXI_RREADY     ),
	.i_user_rx_valid 	( w_user_rx_valid  ),
	.i_user_rx_data  	( w_user_rx_data   ),
	.i_user_tx_ready 	( w_user_tx_ready  ),
	.o_user_tx_valid 	( w_user_tx_valid  ),
	.o_user_tx_data  	( w_user_tx_data   )
);

Uart_Top #(
	.P_SYSTEM_CLK      	( `SYS_CLK          ),
	.P_UART_BUADRATE   	( `UART_BAUD_RATE   ),
	.P_UART_DATA_WIDTH 	( `UART_DATA_WIDTH  ),
	.P_UART_STOP_WIDTH 	( `UART_STOP_WIDTH  ),
	.P_UART_CHECK      	( `UART_CHECK       ),
	.P_RST_CYCLE       	( `UART_RST_CYCLE   ))
u_Uart_Top(
	.clock           	( S_AXI_ACLK       ),
	.reset           	( ~S_AXI_ARESETN   ),
	.i_uart_rx       	( RXD        ),
	.o_uart_tx       	( TXD        ),
	.i_user_tx_data  	( w_user_tx_data   ),
	.i_user_tx_valid 	( w_user_tx_valid  ),
	.o_user_tx_ready 	( w_user_tx_ready  ),
	.o_user_rx_data  	( w_user_rx_data   ),
	.o_user_rx_valid 	( w_user_rx_valid  ),
	.o_user_clk      	(        ),
	.o_user_rst      	(        )
);



endmodule
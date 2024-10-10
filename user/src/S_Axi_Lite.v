	//Date : 2024-09-24
	//Author : shawag
	//Module Name: [File Name] - [Module Name]
	//Target Device: [Target FPGA or ASIC Device]
	//Tool versions: [EDA Tool Version]
	//Revision Historyc :
	//Revision :
	//    Revision 0.01 - File Created
	//Description :This module describes axi lite protocol for slave
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

	module S_Axi_Lite #(
	    parameter integer P_S_AXI_DATA_WIDTH	= 32,
	    parameter integer P_S_AXI_ADDR_WIDTH	= 16
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

	    input   i_user_rx_valid,
	    input   [7:0] i_user_rx_data,

	    input   i_user_tx_ready,
	    output  o_user_tx_valid,
	    output  [7:0] o_user_tx_data,

		input		RxD,
		output  	TxD,

		input		CTS,
		output  	RTS
	);
	//output reg define
	//AW channel
	reg [P_S_AXI_DATA_WIDTH-1:0] r_axi_awaddr;
	//reg                          r_axi_awvalid;
	//W channel
	reg                          r_axi_wready;
	//WR channel
	reg [1:0]                    r_axi_bresp;
	reg                          r_axi_bvalid;
	//AR channel
	reg [P_S_AXI_ADDR_WIDTH-1:0] r_axi_araddr;
	reg                          r_axi_arready;
	reg [P_S_AXI_DATA_WIDTH-1:0] r_axi_rdata;
	reg [1:0]                    r_axi_rresp;
	//R channel
	reg                          r_axi_rvalid;
	reg                          r_axi_awready;
	
	


	//output connection
	//assign s_axi_awaddr = r_axi_awaddr;
	//assign s_axi_awvalid = r_axi_awvalid;
	assign s_axi_wready = r_axi_wready;
	assign s_axi_bresp = r_axi_bresp;
	assign s_axi_bvalid = r_axi_bvalid;
	//assign s_axi_araddr = r_axi_araddr;
	assign s_axi_arready = r_axi_arready;
	assign s_axi_rdata = r_axi_rdata;
	assign s_axi_rresp = r_axi_rresp;
	assign s_axi_rvalid = r_axi_rvalid;
	assign s_axi_awready = r_axi_awready;
	//wire define
	wire                        user_rx_valid_posedge;
	wire                        user_tx_ready_posedge;

	wire [23:0]					w_div_num;
	wire [3:0]					w_data_bit;
	wire [1:0]					w_stop_bit;
	wire [1:0]					w_check_bit;
	//reg define
	//indicate this is valid to write the write address
	//reg							 r_aw_valid;
	reg                         r_user_rx_valid;
	reg                         r_user_tx_ready;
	reg                         ro_user_tx_valid;

	//slave reg define
	reg [P_S_AXI_DATA_WIDTH-1:0] r_axi_reg0;
	reg [P_S_AXI_DATA_WIDTH-1:0] r_axi_reg1;
	reg [P_S_AXI_DATA_WIDTH-1:0] r_axi_reg2;
	reg [P_S_AXI_DATA_WIDTH-1:0] r_axi_reg3;

	//logic define
	//splite setting reg(reg2), use different part to realize the setting of uart
	assign w_div_num = r_axi_reg2[23:0];
	assign w_data_bit = r_axi_reg3[31:28];
	assign w_stop_bit = r_axi_reg3[27:26];
	assign w_check_bit = r_axi_reg3[25:24];

	wire axi_reg_wren = r_axi_wready && s_axi_wvalid ;
	wire axi_reg_rden = r_axi_rvalid && s_axi_rready;
	assign user_rx_valid_posedge = i_user_rx_valid && (~r_user_rx_valid);
	assign o_user_tx_data = r_axi_reg1[7:0];
	assign user_tx_ready_posedge = i_user_tx_ready && (~r_user_tx_ready);
	assign o_user_tx_valid = ro_user_tx_valid;


	//logic
	


	//awready signal generator 
	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        r_axi_awready <= 1'b0;   
	    else begin
	        if(~r_axi_awready && s_axi_awvalid )
	            r_axi_awready <= 1'b1;
	        else if(s_axi_bready && r_axi_bvalid) 
	            r_axi_awready <= 1'b0;
	        else
	            r_axi_awready <= 1'b0; 
	    end
	end
	//logic for awaddr
	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        r_axi_awaddr <= {P_S_AXI_ADDR_WIDTH{1'b0}};
	    else begin
	        if(r_axi_awready && s_axi_awvalid )
	            r_axi_awaddr <= s_axi_awaddr;
	        else
	            r_axi_awaddr <= r_axi_awaddr;
	    end
	end
	/*
	//aw_valid signal generator
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn)
			r_aw_valid <= 1'b1;
		else begin
			if(~r_axi_awready && s_axi_awvalid  && r_aw_valid)
				r_aw_valid <= 1'b0;
			else if(r_axi_bvalid && s_axi_bready)
				r_aw_valid <= 1'b1;
			else
				r_aw_valid <= r_aw_valid;
		end

	end
	*/
	//wready signal generator
	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        r_axi_wready <= 1'b0;
	    else begin
	       if(~r_axi_wready  && s_axi_wvalid )
	            r_axi_wready <= 1'b1;
	        else
	            r_axi_wready <= 1'b0;
	    end
	end
	//bvalid signal generator
	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        r_axi_bvalid <= 1'b0;
	    else begin
	        if( ~r_axi_bvalid && r_axi_wready && s_axi_wvalid)
	            r_axi_bvalid <= 1'b1;
	        else if (r_axi_bvalid && s_axi_bready)
	            r_axi_bvalid <= 1'b0;
	        else
	            r_axi_bvalid <= r_axi_bvalid;
	    end
	end
	//bresp signal generator
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn)
			r_axi_bresp <= 2'b00;
		else begin
			//this bresp indicates the transmission error is error when tx is transmitting data
			if(~r_axi_bvalid && r_axi_wready && s_axi_wvalid && ~i_user_tx_ready)
				r_axi_bresp <= 2'b10;
			else if(r_axi_awready && ~r_axi_bvalid && r_axi_wready && s_axi_wvalid)
				r_axi_bresp <= 2'b00;
			else if(i_user_tx_ready)
				r_axi_bresp <= 2'b00;
			else
				r_axi_bresp <= r_axi_bresp;
		end
	end
	//arready signal generator
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn)
		 	r_axi_arready <= 1'b0;
		else begin
			if(~r_axi_arready && s_axi_arvalid)
				r_axi_arready <= 1'b1;
			else
				r_axi_arready <= 1'b0;
		end
	end
	//logic for araddr
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn)
			r_axi_araddr <= {P_S_AXI_ADDR_WIDTH{1'b0}};
		else begin
			if(~r_axi_arready && s_axi_arvalid)
				r_axi_araddr <= s_axi_araddr;
			else
				r_axi_araddr <= r_axi_araddr;
		end
	end
	//rvalid signal generator
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn)
			r_axi_rvalid <= 1'b0;
		else begin
			if(~r_axi_rvalid &&  s_axi_arvalid)
				r_axi_rvalid <= 1'b1;
			else if(r_axi_rvalid && s_axi_rready)
				r_axi_rvalid <= 1'b0;
			else
				r_axi_rvalid <= r_axi_rvalid;
		end
	end
	//rresp signal generator
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn)
			r_axi_rresp <= 2'b00;
		else begin
			if(~r_axi_rvalid && r_axi_arready )
				r_axi_rresp <= 2'b00;
			else
				r_axi_rresp <= 2'b00;
		end
	end
	//write reg process
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn) begin
			r_axi_reg1 <= {P_S_AXI_DATA_WIDTH{1'b0}};
			r_axi_reg2 <= {P_S_AXI_DATA_WIDTH{1'b0}};
			r_axi_reg3 <= {P_S_AXI_DATA_WIDTH{1'b0}};
		end
		else begin
			if(axi_reg_wren && r_axi_awaddr[P_S_AXI_ADDR_WIDTH-1:4]==0) begin
				case(r_axi_awaddr[3:0]) 
					4'h04: r_axi_reg1 <= s_axi_wdata;
					4'h08: r_axi_reg2 <= s_axi_wdata;
					4'h0c: r_axi_reg3 <= s_axi_wdata;
					//2'b11: r_axi_reg3 <= s_axi_wdata;
					default: begin
						r_axi_reg1 <= r_axi_reg1;
						r_axi_reg2 <= r_axi_reg2;
						r_axi_reg3 <= r_axi_reg3;
						//r_axi_reg3 <= r_axi_reg3;
					end
				endcase
			end
			else begin
				r_axi_reg1 <= r_axi_reg1;
				r_axi_reg2 <= r_axi_reg2;
				r_axi_reg3 <= r_axi_reg3;
				//r_axi_reg3 <= r_axi_reg3;
			end
		end
	end
	//reg0 is a data recieve reg,is a read only reg
	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        r_axi_reg0 <= {P_S_AXI_DATA_WIDTH{1'b0}}; 
	    else if(user_rx_valid_posedge)
	        r_axi_reg0 <= {{24{1'b0}},i_user_rx_data};
	    else
	        r_axi_reg0 <= r_axi_reg0;
	end


	//read reg process
	always @(posedge s_axi_aclk) begin
		if(~s_axi_aresetn)
			r_axi_rdata <= {P_S_AXI_DATA_WIDTH{1'b0}};
		else begin
			if(axi_reg_rden && r_axi_awaddr[P_S_AXI_ADDR_WIDTH-1:4]==0)
				case(r_axi_araddr[3:0])
				4'h00: r_axi_rdata = r_axi_reg0;
				4'h04: r_axi_rdata = r_axi_reg1;
				4'h08: r_axi_rdata = r_axi_reg2;
				4'h0c: r_axi_rdata = r_axi_reg3;
				default: r_axi_rdata = {P_S_AXI_DATA_WIDTH{1'b0}};
				endcase
			else
				r_axi_rdata <= r_axi_rdata;
		end
	end


	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        r_user_rx_valid <= 1'b0;
	    else
	        r_user_rx_valid <= i_user_rx_valid;
	end

	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        r_user_tx_ready <= 1'b0;
	    else
	        r_user_tx_ready <= i_user_tx_ready;
	end

	always @(posedge s_axi_aclk) begin
	    if(~s_axi_aresetn)
	        ro_user_tx_valid <= 1'b0;
	    else begin
	        if(r_axi_awaddr[3:0]==4'h04 && r_axi_rvalid && s_axi_rready)
	            ro_user_tx_valid <= 1'b1;
	        else if(user_tx_ready_posedge)
	            ro_user_tx_valid <= 1'b0;
	        else
	            ro_user_tx_valid <= ro_user_tx_valid;
	    end
	end

Uart_Driver u_Uart_Driver(
	.clock           	( s_axi_aclk       ),
	.reset           	( ~s_axi_aresetn   ),         
	.i_uart_rx       	( RX        ),
	.o_uart_tx       	( TX        ),
	.i_uart_cts      	( CTS       ),
	.o_uart_rts      	( RTS       ),
	.i_user_tx_data  	( i_user_tx_data   ),
	.i_user_tx_valid 	( i_user_tx_valid  ),
	.o_user_tx_ready 	( o_user_tx_ready  ),
	.o_user_rx_data  	( o_user_rx_data   ),
	.o_user_rx_valid 	( o_user_rx_valid  ),
	.i_div_num       	( w_div_num        ),
	.i_data_bit      	( w_data_bit       ),
	.i_stop_bit      	( w_stop_bit       ),
	.i_check_bit     	( w_check_bit      )
);


	endmodule

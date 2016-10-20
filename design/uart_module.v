// ---------------------------------------------------------------------------
//
// Description:
//  <Description text here, indented multiple lines allowed>
//
// File:        $Source: /var/cvsmucontrol/users/tgu/Tools/merlin2/DigitalFlow/Templates/verilog.v.tpl,v $
// Created:     Fri Jul 01 15:31:35 EEST 2016
//      by:     opo
// Updated:     $Date: 2011/08/09 12:38:38 $
//              $Author: tgu $
// Revision:    $Revision: 1.1 $
//
// Copyright (c) Melexis Digital Competence Center
//
// ---------------------------------------------------------------------------
module uart_module(  
              i_clk,
              i_rst_n,

              i_we,
              i_udr_select,
              i_ubrrh_ucsrc_select,
              i_ucsra_select,
              i_ucsrb_select,
              i_ubrrl_select,

              i_ddr_xck,

              i_udr,

              i_rx,
              i_xcki,


              i_ubrrh_ucsrc,
              i_ubrrl,
              i_ucsra,
              i_ucsrb,

              o_ubrrh_ucsrc,
              o_ubrrl,
              o_ucsra,
              o_ucsrb,

              o_udr,
              o_tx,
              o_xcko
            );
            
/*--------------------------Parameter--------------------------*/

parameter WIDTH = 8;

/*--------------------------Input ports------------------------*/

input                 i_clk;    // clock input
input                 i_rst_n;  // reset input, active low

input   [WIDTH-1:0]   i_udr;    // udr(transmit) input 
input   			  i_rx;     // receive input port 
input 				  i_we;		// write enable

input                 i_xcki;   // input for external clock, used in synchronous slave mode
input 				  i_ddr_xck; // clock direction register in sync mode

// adress bus select
input 					i_udr_select; 
input 	              	i_ubrrh_ucsrc_select; 
input 	              	i_ucsra_select;
input 	              	i_ucsrb_select;
input 	              	i_ubrrl_select;

/*--------------------------Inout ports------------------------*/

input   [WIDTH-1:0]   i_ubrrh_ucsrc;  // high byte of baud rate and control and status register C
input   [WIDTH-1:0]   i_ubrrl;        // low byte of baud rate

input   [WIDTH-1:0]   i_ucsra;        // control and status register A interface
input   [WIDTH-1:0]   i_ucsrb;        // control and status register B interface

output   [WIDTH-1:0]   o_ubrrh_ucsrc;  // high byte of baud rate and control and status register C
output   [WIDTH-1:0]   o_ubrrl;        // low byte of baud rate

output   [WIDTH-1:0]   o_ucsra;        // control and status register A interface
output   [WIDTH-1:0]   o_ucsrb;        // control and status register B interface


/*--------------------------Output ports------------------------*/

output  [WIDTH-1:0]   o_udr;    // udr(receive) output
output  			  o_tx;     // transmit output port

output  reg           o_xcko;    // clock output, used in synchronous master mode
  
/*--------------------------Variables--------------------------*/

reg     [WIDTH-1:0]   ubrrh;    // high baud rate register
reg     [WIDTH-1:0]   ubrrl;    // low baud rate register

reg     [WIDTH-1:0]   ucsra;    // control and status register A
reg     [WIDTH-1:0]   ucsrb;    // control and status register B
reg     [WIDTH-1:0]   ucsrc;    // consrol and status register C

reg     [WIDTH-1:0]   udr_tx;             // udr tramsmit register
reg 				  udr_tx_data_en; 	  // data enable in tx

reg                   ubrrh_ucsrc_read_access;  // ff for read access to ubrrb or ucsrc

wire 				  txclk, rxclk; // tx and rx clock signal
wire 				  transmit_complete ; // tx complete signal
wire 				  xclko; // output clock used in sync mode
wire [8:0]				shift_reg;
reg [8:0]				shift_reg_re_order;
wire 					shift_reg_valid;
wire 					frame_err;
wire 					data_overrun_err;
wire 					parity_err;
wire 					receive_buffer_valid;
wire 					udr_valid;
wire [7:0]				udr_receiver1;
wire 					tx;
wire 					parity_error_flag;
wire 					data_overrun_flag;
wire 					frame_error_flag;
wire 					ucsrb_1;
wire 					udr_empty;
wire 					fifo_read;

integer 				i; 	// iterator for shift register reorder

/*--------------------------Module instances-------------------*/

clock_generator clock_generator1_inst1(  
              							.i_clk					(i_clk),
              							.i_rst_n				(i_rst_n),
              							.i_ubrrl_new			(i_ubrrl_select),
              							.i_ubrr 				({ubrrh[3:0], ubrrl}),
              							.i_xcki					(i_xcki),
              							.i_ddr_xck				(i_ddr_xck),
              							.i_ucpol				(ucsrc[0]),				
              							.i_umsel				(ucsrc[6]),
              							.i_u2x					(ucsra[1]),
              							.i_txen					(ucsrb[3]),
              							.i_rxen					(ucsrb[4]),
              							.i_transmit_complete	(transmit_complete),
              							.o_txclk				(txclk),
              							.o_rxclk				(rxclk),
              							.o_xcko					(xclko)
            						);

transmitter	transmitter1_inst1		(
										.i_txclk				(txclk),
										.i_rst_n				(i_rst_n),	
										.i_tx_data 				(udr_tx),
										.i_tx_data_9bit 		(ucsrb[0]),
										.i_tx_data_en 			(udr_tx_data_en),
										.i_ucz					({ucsrb[2],ucsrc[2:1]}),
										.i_upm 					(ucsrc[5:4]),
										.i_usbs 				(ucsrc[3]),
										.o_tx 					(tx),
										.o_transmit_complete	(transmit_complete),
										.o_data_read_from_udr 	(udr_empty)
									);  

receiver receiver1_inst1 			(
										.i_rxclk				(rxclk),
										.i_rst_n				(i_rst_n),
										.i_rx 					(i_rx),
										.i_upm 					(ucsrc[5:4]),
										.i_ucsz					({ucsrb[2],ucsrc[2:1]}),
										.i_udr_valid 			(udr_valid),
										.i_receive_buffer_valid	(receive_buffer_valid),
										.i_mpcm					(ucsra[0]),
										.i_u2x					(ucsra[1]),
										.i_umsel				(ucsrc[6]),
										.o_shift_register 		(shift_reg),
										.o_frame_error 			(frame_err),
										.o_data_overrun			(data_overrun_err),
										.o_parity_error			(parity_err),
										.o_shift_register_valid	(shift_reg_valid)
									);  

fifo fifo1_inst1 					(  
										.i_clk 					(i_clk),
										.i_rst_n 				(i_rst_n),
							            .i_shift_register 		(shift_reg_re_order),
							            .i_shift_register_valid (shift_reg_valid),
							            .i_frame_error 			(frame_err),
							            .i_data_overrun			(data_overrun_err),
							            .i_parity_error 		(parity_err),
							            .i_mcu_read 			(fifo_read),
							            .o_udr 					(udr_receiver1),
							            .o_rxb8 				(ucsrb_1),
							            .o_udr_valid 			(udr_valid),
							            .o_receive_buffer_valid	(receive_buffer_valid),
							            .o_parity_error_flag	(parity_error_flag),
							            .o_frame_error_flag		(frame_error_flag),
							            .o_data_overrun_flag	(data_overrun_flag)
							        );      

/*--------------------------Combinational logic----------------*/

assign 	  o_tx = tx;
assign 	  fifo_read = i_udr_select& !i_we;
assign    o_ucsra =  ucsra;
assign    o_ucsrb =  {ucsrb[7:2], ucsrb_1, ucsrb[0]};
assign    o_ubrrh_ucsrc =  ubrrh_ucsrc_read_access ? ucsrc : ubrrh; // read access to ubrrb or ucsrc
assign    o_ubrrl =  ubrrl; 
assign    o_udr    =  udr_receiver1;

/*--------------------------Sequential logic-------------------*/

always @(posedge i_clk or negedge i_rst_n) begin 
	if(~i_rst_n) begin
		udr_tx <= 0;
		udr_tx_data_en <= 0;
	end else begin
		case (1'b1)
			i_we & i_udr_select: begin
				udr_tx <= i_udr;
				udr_tx_data_en <= 1;
			end
			udr_empty: 
				udr_tx_data_en <= 0;
		endcase 
	end
end

always @(posedge i_clk or negedge i_rst_n) begin : ucsra_block
	if(~i_rst_n) begin
		ucsra <= 0;
		ucsra[5] <= 1;
	end else begin
		if (i_ucsra_select & i_we) begin : mcu_write_to_ucsra
			ucsra[1:0]	<= 	i_ucsra[1:0];
		end	else begin : usart_write_to_ucsra
			ucsra[7]	<=	udr_valid;
			ucsra[6]	<=	transmit_complete;
			ucsra[5]	<=  !udr_tx_data_en & !udr_empty;
			ucsra[4]	<=	frame_error_flag;
			ucsra[3]	<=	data_overrun_flag;
			ucsra[2]	<=	parity_error_flag;
		end
	end
end

always @(posedge i_clk or negedge i_rst_n) begin : ucsrb_block
	if(~i_rst_n) begin
		ucsrb <= 0;
	end else begin
		if(i_ucsrb_select & i_we) begin
			ucsrb[7:2] 	<= i_ucsrb[7:2];
			ucsrb[0]	<= i_ucsrb[0];
		end
	end
end

always @(posedge i_clk or negedge i_rst_n) begin : ucsrc_ubrrh_block
	if(~i_rst_n) begin
		ucsrc <= 8'b10000110;
		ubrrh <= 0;
	end else begin
		if (i_ubrrh_ucsrc[7] & i_we & i_ubrrh_ucsrc_select) begin
			ucsrc <= i_ubrrh_ucsrc;
		end else begin
			if (!i_ubrrh_ucsrc[7] & i_we & i_ubrrh_ucsrc_select) begin
				ubrrh[7] <= i_ubrrh_ucsrc[7];
				ubrrh[3:0] <= i_ubrrh_ucsrc[3:0];
			end
		end
	end
end

always @(posedge i_clk or negedge i_rst_n) begin : ucsrc_ubrrh_access_block
	if(~i_rst_n) begin
		ubrrh_ucsrc_read_access <= 0;
	end else begin
		if (i_ubrrh_ucsrc_select & !i_we) begin
			ubrrh_ucsrc_read_access <= ~ubrrh_ucsrc_read_access;
		end
	end
end

always @(posedge i_clk or negedge i_rst_n) begin : ubrrl_block
	if(~i_rst_n) begin
		ubrrl <= 0;
	end else begin
		if (i_we & i_ubrrl_select)
			ubrrl <= i_ubrrl;
	end
end

always @(*) begin : xclko_block
	o_xcko = xclko;
end

always @(*) begin : shift_reg_data_reorder_block
	case({ucsrb[2],ucsrc[2:1]}) // full_case
		3'b000: // 5 - bit
			begin
				for (i = 0; i < 5; i = i + 1) begin
					shift_reg_re_order[i] = shift_reg[4-i];
				end
			end
		3'b001:	// 6 - bit
			begin
				for (i = 0; i < 6; i = i + 1) begin
					shift_reg_re_order[i] = shift_reg[5-i];
				end
			end	
		3'b010:	// 7 - bit
			begin
				for (i = 0; i < 7; i = i + 1) begin
					shift_reg_re_order[i] = shift_reg[6-i];
				end
			end	
		3'b011:	// 8 - bit
			begin
				for (i = 0; i < 8; i = i + 1) begin
					shift_reg_re_order[i] = shift_reg[7-i];
				end
			end	
		3'b111:	// 9 - bit
			begin
				for (i = 0; i < 9; i = i + 1) begin
					shift_reg_re_order[i] = shift_reg[8-i];
				end
			end		
	endcase
end

/*--------------------------Finite state machine---------------*/

endmodule

// ---------------------------------------------------------------------------
//
// Description:
//  <Description text here, indented multiple lines allowed>
//
// File:        $Source: /var/cvsmucontrol/users/tgu/Tools/merlin2/DigitalFlow/Templates/verilog.v.tpl,v $
// Created:     Mon Jul 18 10:59:33 EEST 2016
//      by:     opo
// Updated:     $Date: 2011/08/09 12:38:38 $
//              $Author: tgu $
// Revision:    $Revision: 1.1 $
//
// Copyright (c) Melexis Digital Competence Center
//
// ---------------------------------------------------------------------------
module fifo(  
			  i_clk,
			  i_rst_n,
              i_shift_register,
              i_shift_register_valid,
              i_frame_error,
              i_data_overrun,
              i_parity_error,
              i_mcu_read,
              o_udr,
              o_rxb8,
              o_udr_valid,
              o_receive_buffer_valid,
              o_parity_error_flag,
              o_frame_error_flag,
              o_data_overrun_flag
            );
            
/*--------------------------Parameter--------------------------*/

/*--------------------------Input ports------------------------*/

input 				i_clk; 		// system clock
input 				i_rst_n;	// system reset, active low

input 	[8:0]		i_shift_register;	//	receive shift register
input 				i_shift_register_valid; // valid data in shift register
input 				i_data_overrun;	// data overrun error
input 				i_parity_error; // parity error
input 				i_frame_error;	// frame error 
input 				i_mcu_read;		// device select on address bus

/*--------------------------Ouput ports------------------------*/

output reg 	[7:0]	o_udr; 		
output reg 			o_rxb8;		
output reg 			o_udr_valid;
output reg 			o_receive_buffer_valid;
output reg 			o_parity_error_flag;
output reg 			o_frame_error_flag;
output reg 			o_data_overrun_flag;


/*--------------------------Inout ports------------------------*/

/*--------------------------Variables--------------------------*/

reg 	[8:0]		receive_buffer;
reg 				frame_error_0;
reg 				parity_error_0;

reg 				udr_valid;
reg 				receive_buffer_valid;
reg 				shift_reg_read;

wire 				shift_reg_valid;


/*--------------------------Sequential logic-------------------*/

assign 	shift_reg_valid = i_shift_register_valid & !shift_reg_read;

/*--------------------------Combinational logic----------------*/

always @(posedge i_clk or negedge i_rst_n) begin : receive_buffer_block
	if(~i_rst_n) begin : receive_buffer_reset
		receive_buffer 		 <= 0;
		frame_error_0		 <= 0;
		parity_error_0 		 <= 0;
		shift_reg_read 		 <= 0;
	end else begin : receive_buffer_operation
		if (!receive_buffer_valid & i_shift_register_valid | i_mcu_read) begin
			receive_buffer 	<=	i_shift_register;
			shift_reg_read  <=	1;
			frame_error_0 	<= 	i_frame_error;
			parity_error_0	<= 	i_parity_error;
		end
		if (!i_shift_register_valid)
			shift_reg_read 	<=  0;
	end
end

always @(posedge i_clk or negedge i_rst_n) begin : receive_buffer_valid_bit_block
	if(~i_rst_n) begin : receive_buffer_valid_bit_reset
		receive_buffer_valid <= 0; 
	end else begin : receive_buffer_valid_bit_operation
		if(i_mcu_read | !receive_buffer_valid | !udr_valid) begin
			receive_buffer_valid <= i_shift_register_valid;
		end
		if(i_shift_register_valid & shift_reg_read) 
			receive_buffer_valid <= 0;
	end
end

always @(*) begin : o_receive_buffer_valid_block
	o_receive_buffer_valid = receive_buffer_valid;
end

always @(posedge i_clk or negedge i_rst_n) begin : udr_block
	if(~i_rst_n) begin : udr_reset
		o_udr 	<=	0;
		o_rxb8	<=	0;
		o_parity_error_flag	<=	0;
		o_frame_error_flag	<=	0;
		o_data_overrun_flag	<=	0;
	end else begin : udr_operation
		if (i_mcu_read | !udr_valid) begin
			o_udr 	<=	receive_buffer[7:0];
			o_rxb8 	<=	receive_buffer[8];
			o_parity_error_flag	<=	parity_error_0;
			o_frame_error_flag 	<= 	frame_error_0;
			o_data_overrun_flag <= 	i_data_overrun;
		end
	end
end

always @(posedge i_clk or negedge i_rst_n) begin : udr_valid_block
	if(~i_rst_n) begin : udr_valid_reset
		udr_valid <= 0;
	end else begin : udr_valid_operation
		if (i_mcu_read | !udr_valid) 
			udr_valid 	<= 	receive_buffer_valid;
	end
end

always @(*) begin : o_udr_valid_block
	o_udr_valid = udr_valid;
end

/*--------------------------Finite state machine---------------*/

endmodule
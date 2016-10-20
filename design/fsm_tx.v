// ---------------------------------------------------------------------------
//
// Description:
//  <Description text here, indented multiple lines allowed>
//
// File:        $Source: /var/cvsmucontrol/users/tgu/Tools/merlin2/DigitalFlow/Templates/verilog.v.tpl,v $
// Created:     Tue Jul 12 11:44:24 EEST 2016
//      by:     opo
// Updated:     $Date: 2011/08/09 12:38:38 $
//              $Author: tgu $
// Revision:    $Revision: 1.1 $
//
// Copyright (c) Melexis Digital Competence Center
//
// ---------------------------------------------------------------------------
module fsm_tx ( 
				i_txclk, 
				i_rst_n,
				i_data_in_udr,
				i_last_bit_sent,
				i_upm1,
				i_usbs,
				o_start_bit_insert,
				o_parity_generate,
    			o_reg_wr_or_shift,
    			o_rewr_or_count,
    			o_data_transmit,
    			o_parity_insert,
    			o_stop_bit,
    			o_transmit_complete,
              );
            
/*--------------------------Parameter--------------------------*/

parameter 					IDLE 				= 0, 
							START_TRANSMISSION	= 1,
							SEND_DATA			= 2,
							PARITY_INSERT		= 3,
							STOP_BIT			= 4;

/*--------------------------Input ports------------------------*/

input 					i_txclk;		// tx clock signal
input 					i_rst_n;		// system reset
input 					i_data_in_udr;	// new data in udr signal
input 					i_last_bit_sent;	  // last bit was sent, counter = 0

input 					i_upm1;			//	1 - parity enable, 0 - parity disable

input 					i_usbs; 		// stop bit select, 0 - 1-bit, 1 - 2-bit

/*--------------------------Ouput ports------------------------*/

output  reg 			o_start_bit_insert; // start bit signal insert

output  reg 			o_data_transmit; 	// signals that show that fsm in data transmit state

output  reg 			o_parity_generate; // signal for parity bit generation

output	reg				o_reg_wr_or_shift; // transmit shift register rewrite or shift en
										   // 1 - rewrite, 0 - send
output  reg 			o_rewr_or_count;   // bit couter rewrite of counter en
										   // 1 - rewrite, 0 - send
output  reg 			o_parity_insert;   // insert parity signal

output 	reg 			o_stop_bit;		   // enable signal for stop bit send

output 	reg 			o_transmit_complete; // transmition complete signal

/*--------------------------Inout ports------------------------*/

/*--------------------------Variables--------------------------*/

reg		[2:0]			state, next_state; 	// part of fsm state change logic 

/*--------------------------Sequential logic-------------------*/

always @(posedge i_txclk or negedge i_rst_n) begin : fsm_state_change_block
	if(~i_rst_n) begin : fsm_state_change_reset
		state <= IDLE;
	end else begin : fsm_state_change_operation
		state <= next_state;
	end
end

/*--------------------------Combinational logic----------------*/

always @(posedge i_txclk or negedge i_rst_n) begin : fsm_output_logic_block
	if(~i_rst_n) begin : fsm_output_logic_reset
		o_start_bit_insert  <= 0;
		o_parity_generate 	<= 0;
		o_reg_wr_or_shift 	<= 0;
		o_rewr_or_count	  	<= 0;
		o_parity_insert   	<= 0;
		o_stop_bit		  	<= 0;
		o_transmit_complete	<= 1;
		o_data_transmit		<= 0;
	end else begin : fsm_output_logic_operation
		o_start_bit_insert  <= 0;
		o_parity_generate 	<= 0;
		o_reg_wr_or_shift 	<= 0;
		o_rewr_or_count	  	<= 0;
		o_parity_insert   	<= 0;
		o_stop_bit		  	<= 0;
		o_transmit_complete	<= 0;
		o_data_transmit 	<= 0;
		case(next_state)
			IDLE: 	begin : idle_state_operation
						o_stop_bit 			<= 1;
						o_transmit_complete	<= 1;
					end
			START_TRANSMISSION:
					begin : start_transmissiom_operation
						o_reg_wr_or_shift 		<= 1;
						o_rewr_or_count	  		<= 1;
						o_parity_generate 		<= 1;
						o_start_bit_insert 		<= 1;
					end
			SEND_DATA:
					begin : send_data_operation
						o_data_transmit <= 1;
						if (i_last_bit_sent) o_parity_insert <= 1;
					end
			PARITY_INSERT:
					begin : parity_insert
						o_parity_insert <= 1;
					end
			STOP_BIT:
					begin : STOP_BIT_operation
						o_stop_bit		<= 1;
					end
		endcase
	end
end

/*--------------------------Finite state machine---------------*/

always @(*) begin : fsm_state_change_logic_block
	case (state)
		IDLE: 	if(i_data_in_udr) begin
					next_state = START_TRANSMISSION;
				end else begin
					next_state = IDLE;
				end
		START_TRANSMISSION:
					next_state = SEND_DATA;
		SEND_DATA:
				if (i_last_bit_sent) begin
					if (i_upm1) next_state = PARITY_INSERT;
					else begin
						if(i_usbs) 	next_state = STOP_BIT;
						else next_state = IDLE;
					end
				end else begin
					next_state = SEND_DATA;
				end
		PARITY_INSERT:
				if(i_usbs) next_state = STOP_BIT;
				else next_state = IDLE;
		STOP_BIT:
				next_state = IDLE;
		default: next_state = IDLE;
	endcase // state
end // fsm_state_change_logic_block

endmodule
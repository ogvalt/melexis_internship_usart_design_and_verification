module fsm_rx1 (
				i_rxclk,
				i_rst_n,
				i_edge_detect,
				i_start_bit,
				i_data_recovery,
				i_end_frame,
				i_upm1,
				o_start_bit_wait,
				o_data_bit_wait,
				o_sampling_en,
				o_bit_counter_load_en,
				o_parity_check,
				o_stop_bit_wait,
				o_receive_complete
				);

/*--------------------------Parameter--------------------------*/

parameter 					IDLE_RESET 		= 5,
							IDLE 			= 0,
							START_BIT		= 1,
							DATA_RECEIVE	= 2,
							PARITY_CHECK 	= 3,
							STOP_BIT 		= 4;

/*--------------------------Input ports------------------------*/

input 						i_rxclk;	//	receiver1 clock signal
input 						i_rst_n;	// 	system reset
input 						i_edge_detect;	//	falling edge flag
input 						i_start_bit;	// start bit detect
input 						i_data_recovery; // signal that points that data was recovered
input 						i_end_frame;	//	last bit receiving
input 						i_upm1;	//	//	1 - parity enable, 0 - parity disable

/*--------------------------Ouput ports------------------------*/

output reg					o_sampling_en;	// enable signal for sample counter operation
output reg 					o_bit_counter_load_en; // bit counter write enable
output reg					o_stop_bit_wait;	// fsm waits for stop bits
output reg 					o_parity_check; // signal for parity check
output reg 					o_receive_complete; // receive complete flag
output reg 					o_start_bit_wait; // fsm wait for start bit
output reg 					o_data_bit_wait;	// fsm wait for data bits

/*--------------------------Inout ports------------------------*/

/*--------------------------Variables--------------------------*/

reg 	[2:0]				state, next_state; // part of fsm state change logic

/*--------------------------Sequential logic-------------------*/

always @(posedge i_rxclk or negedge i_rst_n) begin : fsm_state_change_block
	if(~i_rst_n) begin : fsm_state_change_reset
		state <= IDLE_RESET;
	end else begin : fsm_state_change_operation
		state <= next_state;
	end
end

/*--------------------------Combinational logic----------------*/

always @(posedge i_rxclk or negedge i_rst_n) begin : fsm_output_logic_block
	if(~i_rst_n) begin : fsm_output_logic_reset
		o_sampling_en 		  <= 0;
		o_bit_counter_load_en <= 0;
		o_stop_bit_wait 	  <= 0;
		o_parity_check		  <= 0;
		o_receive_complete	  <= 0;
		o_start_bit_wait	  <= 0;
		o_data_bit_wait 	  <= 0;
	end else begin : fsm_output_logic_operation
		o_sampling_en 		  <= 1;
		o_bit_counter_load_en <= 0;
		o_stop_bit_wait		  <= 0;
		o_parity_check		  <= 0;
		o_receive_complete 	  <= 0;
		o_start_bit_wait	  <= 0;
		o_data_bit_wait 	  <= 0;
		 case(next_state)
		 	IDLE_RESET:
					begin : idle_reset_operation
						o_sampling_en 		<= 0;
					end
		 	IDLE:	begin : idle_state_operation
		 				o_sampling_en		<= 0;
		 				o_receive_complete	<= 1;
		 			end
		 	START_BIT:
		 			begin : start_bit_operation
		 				o_bit_counter_load_en <= 1;
		 				o_start_bit_wait	  <= 1;
		 				if(o_stop_bit_wait) o_receive_complete 	<=	1;
		 			end
		 	DATA_RECEIVE:
		 			begin : data_receive_operation
		 				o_data_bit_wait <= 1;
		 			end
		 	PARITY_CHECK:
		 			begin : parity_check_operation
		 				if (i_data_recovery)
		 					o_parity_check <= 1;
		 			end
		 	STOP_BIT:
		 			begin : stop_bit_1_operation
		 				o_stop_bit_wait  	  <= 1;
		 				if (i_data_recovery)
		 					o_receive_complete 	<=	1;	 					
		 			end
		 endcase // next_state
	end
end

/*--------------------------Finite state machine---------------*/

always @(*) begin : fsm_state_chage_logic_block
	case(state)
		IDLE_RESET: 
				if (i_edge_detect) 	
					next_state = START_BIT;
				else 	
					next_state = IDLE_RESET;
		IDLE: 	if (i_edge_detect) 	
					next_state = START_BIT;
				else 	
					next_state = IDLE;
		START_BIT:
				if (i_start_bit)
					next_state = DATA_RECEIVE;
				else 
					if(i_data_recovery) 
						next_state = IDLE;
					else 
						next_state = START_BIT;	
		DATA_RECEIVE:
				case(1'b1)
					i_upm1 & i_end_frame: next_state = PARITY_CHECK;
					i_end_frame	:		  next_state = STOP_BIT;
					default: 			  next_state = DATA_RECEIVE;
				endcase
		PARITY_CHECK:
				if(o_parity_check) 	
						next_state = STOP_BIT;
				else 	next_state = PARITY_CHECK;
		STOP_BIT:
				case (1'b1)
					i_edge_detect & i_data_recovery:
								 				next_state = START_BIT;
					i_data_recovery: 			next_state = IDLE;
					default: 					next_state = STOP_BIT;
				endcase
		default: next_state = IDLE;
	endcase
end

endmodule
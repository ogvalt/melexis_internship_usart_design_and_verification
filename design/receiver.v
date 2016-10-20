// ---------------------------------------------------------------------------
//
// Description:
//  <Description text here, indented multiple lines allowed>
//
// File:        $Source: /var/cvsmucontrol/users/tgu/Tools/merlin2/DigitalFlow/Templates/verilog.v.tpl,v $
// Created:     Wed Jul 13 09:58:45 EEST 2016
//      by:     opo
// Updated:     $Date: 2011/08/09 12:38:38 $
//              $Author: tgu $
// Revision:    $Revision: 1.1 $
//
// Copyright (c) Melexis Digital Competence Center
//
// ---------------------------------------------------------------------------
module receiver (
					i_rxclk,
					i_rst_n,
					i_rx,
					i_upm,
					i_ucsz,
					i_udr_valid,
					i_receive_buffer_valid,
					i_mpcm,
					i_u2x,
					i_umsel,
					o_shift_register,
					o_frame_error,
					o_data_overrun,
					o_parity_error,
					o_shift_register_valid
				);

/*--------------------------Parameter--------------------------*/

/*--------------------------Input ports------------------------*/

input 				i_rxclk; // input clock from Clock Gen
input 				i_rst_n; // system reset, active low
input 				i_rx;	 // rx line
input 	[1:0]		i_upm;	 //	parity mode
	/*
		|UPM1	|UPM0	|Parity mode 	|
		|	0	|	0	|Disable		|
		|	0	|	1	|Reserved		|
		|	1	|	0	|Enable, Even	|
		|	1	|	1	|Enable, Odd	|
	*/
input 	[2:0]		i_ucsz;	// character size 
	/*	
		|UCZ2	|UCZ1	|UCZ0	|Character size		|
	 	|	0	|	0	|	0	|	5-bit			|
	 	|	0	|	0	|	1	|	6-bit			|
	 	|	0	|	1	|	0	|	7-bit			|
	 	|	0	|	1	|	1	|	8-bit			|
	 	|	1	|	0	|	0	|	Reserved		|
	 	|	1	|	0	|	1	|	Reserved		|
	 	|	1	|	1	|	0	|	Reserved		|
	 	|	1	|	1	|	1	|	9-bit			|
	*/
input 				i_mpcm; // multi-processor communication mode
input 				i_u2x;	// double speed mode
input 				i_umsel; // Async/sync mode. 0-async, 1 -sync
input 				i_receive_buffer_valid; // valid bit from reseive buffer
input 				i_udr_valid;

/*--------------------------Ouput ports------------------------*/

output  reg	[8:0]	o_shift_register;	// shift register
output  reg			o_frame_error;		// frame error flag
output 	reg 		o_data_overrun;		// data overrun flag
output  reg 		o_parity_error;		// parity error flag
output 	reg 		o_shift_register_valid;	// valid data in receive buffer flag

/*--------------------------Inout ports------------------------*/

/*--------------------------Variables--------------------------*/

reg			[8:0]	shift_register;		// transmitter1 shift register
reg 				input_ff;	// save sample from rx line and helps to 
								// detect edge 
reg 		[3:0]	sample_counter;		// sample counter 
reg 		[2:0] 	vote_sample; // vote sample decide what logic bit is receiving now
reg 		[3:0]	bit_counter; // count number of bits
reg 				mpcm_address_receive_bit; // address receive in multiprocessor communication

wire 				high_to_low_transition; // high to low transition flag
wire 				recovery_bit; // bit recovery from the rx line
wire 				start_bit; // start bit detected flag
wire 				recovery_ready; // depend of speed mode sample than 
									   // point when valid data enables
wire                fsm_sample_count_en; // sample counter count enable
wire 				shift_register_we; // write enable for shift register
wire 				fsm_bit_couter_load_en; 	// write enable for bit coutnter 
wire 				fsm_stop_bit_wait;	// ready for stop bit detect
wire 				parity_bit;			// frame parity
wire 				fsm_receive_complete;	// receive complete signal from fsm
wire 				fsm_wait_start_bit;	// readty to start bit detect
wire 				stop_bit;			// stop bit signal
wire 				fsm_data_bit_wait;	// ready to receive data bits
wire 				data_overrun_error;	// data overrun error flag
wire 				sync_recovery; // frame bit recovery, use in sync mode
wire 				frame_end_sync;
wire 				fsm_frame_end;

/*--------------------------Modules Instances-------------------*/

parity_checker  parity_check2 (
				              	.i_clk 				(i_rxclk),
				              	.i_rst_n			(i_rst_n),  
				              	.i_parity_mode_0	(i_upm[0]),
				              	.i_parity_en		(1'b1),
				              	.i_frame_size		(i_ucsz),
				              	.i_frame 			(shift_register),
				              	.o_parity_check		(parity_bit)
				              );

fsm_rx receiver1_fsm1	(
							.i_rxclk					(i_rxclk),
							.i_rst_n					(i_rst_n),
							.i_edge_detect				(high_to_low_transition),
							.i_start_bit				(start_bit),
							.i_data_recovery			(recovery_ready),
							.i_end_frame				(fsm_frame_end),
							.i_upm1						(i_upm[1]),
							.o_sampling_en				(fsm_sample_count_en),
							.o_start_bit_wait			(fsm_wait_start_bit),
							.o_data_bit_wait			(fsm_data_bit_wait),
							.o_bit_counter_load_en		(fsm_bit_couter_load_en),
							.o_parity_check				(fsm_parity_check),
							.o_stop_bit_wait			(fsm_stop_bit_wait),
							.o_receive_complete			(fsm_receive_complete)
						);

/*--------------------------Sequential logic-------------------*/

assign	high_to_low_transition = input_ff & ! i_rx;
// counting start from zero, in documents start from 1
assign  sync_recovery = (sample_counter == 0);
assign  smp_4 = (sample_counter == 3); 
assign  smp_5 = (sample_counter == 4);
assign  smp_6 = (sample_counter == 5);
assign  smp_7 = (sample_counter == 6);
assign  smp_8 = (sample_counter == 7);
assign  smp_9 = (sample_counter == 8);
assign  smp_10 = (sample_counter == 9);
assign	smp_11 = (sample_counter == 10);
assign  recovery_bit = (i_umsel) ? (input_ff):
						(vote_sample[0] & vote_sample[1]) | 
							(vote_sample[0] & vote_sample[2]) | 
								(vote_sample[1] & vote_sample[2]); 
assign	recovery_ready = (i_umsel)?	(sync_recovery)	: ((i_u2x) ? (smp_7) : (smp_11));
assign	start_bit = recovery_ready & !recovery_bit & fsm_wait_start_bit;
assign 	frame_end = (bit_counter == 0);
assign  shift_register_we = recovery_ready & fsm_data_bit_wait & !frame_end;	
assign  frame_end_sync = (bit_counter == 1);
assign  fsm_frame_end = (i_umsel) ? (frame_end | frame_end_sync) : (frame_end);
assign 	stop_bit = fsm_stop_bit_wait & recovery_ready;
assign 	data_overrun_error = i_receive_buffer_valid & i_udr_valid;


/*--------------------------Combinational logic----------------*/

always @(posedge i_rxclk or negedge i_rst_n) begin : edge_detector_block
	if(~i_rst_n) begin
		input_ff <= 1;
	end else begin
		input_ff <= i_rx;
	end
end

always @(posedge i_rxclk or negedge i_rst_n) begin : sample_counter_block
	if(~i_rst_n) begin : sample_counter_reset
		sample_counter <= 0;
	end else begin : sample_counter_operation
		if (fsm_sample_count_en) begin
			if (stop_bit) begin
				sample_counter <= 0;
			end
			else begin
				if (i_u2x & smp_8 | i_umsel)
					sample_counter <= 0;
				else 
					sample_counter <= sample_counter + 1;
			end
		end	
	end
end

always @(posedge i_rxclk or negedge i_rst_n) begin : vote_samples_block
	if(~i_rst_n) begin
		vote_sample <= 0;
	end else begin
		if (!i_u2x) begin
			if(smp_8) 	vote_sample[0] <= input_ff;
			if(smp_9) 	vote_sample[1] <= input_ff;
			if(smp_10)	vote_sample[2] <= input_ff;
		end else begin 
			if(smp_4) 	vote_sample[0] <= input_ff;
			if(smp_5) 	vote_sample[1] <= input_ff;
			if(smp_6) 	vote_sample[2] <= input_ff;
		end
		
	end
end

always @(posedge i_rxclk or negedge i_rst_n) begin : shift_register_block
	if(~i_rst_n) begin : shift_register_reset
		shift_register <= 0;
	end else begin : shift_register_operation
		// if (shift_register_we & !data_overrun_error) begin 
		if (shift_register_we) begin 	
			shift_register 		<= shift_register << 1;
			shift_register[0] 	<= recovery_bit;
		end
	end
end

always @(posedge i_rxclk or negedge i_rst_n) begin : bit_counter_block
	if(~i_rst_n) begin : bit_counter_reset
		bit_counter <= 0;
	end else begin : bit_counter_operation
		if (fsm_bit_couter_load_en) begin
			case(i_ucsz)
				3'b000:		bit_counter <= 5; // 5-bit  
				3'b001:		bit_counter <= 6; // 6-bit
				3'b010:		bit_counter <= 7; // 7-bit
				3'b011:		bit_counter <= 8; // 8-bit
				3'b111:		bit_counter <= 9; // 9-bit
				default:	bit_counter <= 0; // Reserved
			endcase // i_ucsz
		end else begin
			if (shift_register_we)
				bit_counter <= bit_counter - 1;
		end
	end
end

always @(posedge i_rxclk or negedge i_rst_n) begin : parity_error_block
	if(~i_rst_n) begin : parity_error_reset
		o_parity_error <= 0;
	end else begin : parity_error_operation
		if (fsm_parity_check)
			o_parity_error <= !(parity_bit == recovery_bit);
	end
end

always @(posedge i_rxclk or negedge i_rst_n) begin : frame_error_block
	if(~i_rst_n) begin : frame_error_reset
		o_frame_error <= 0;
	end else begin : frame_error_operation
		if (stop_bit)
			o_frame_error <= !recovery_bit;
	end
end

always @(posedge i_rxclk or negedge i_rst_n) begin : data_overrun_error_block
	if(~i_rst_n) begin : data_overrun_error_reset
		o_data_overrun <= 0;
	end else begin : data_overrun_error_operation
		if (start_bit)
			o_data_overrun <= data_overrun_error;
		else begin
			if(!i_receive_buffer_valid)
				o_data_overrun <= 0;
		end
	end
end

always @(*) begin : valid_bit_block
	if (i_mpcm)
		o_shift_register_valid = fsm_receive_complete & shift_register[0]; 
	else 
		o_shift_register_valid = fsm_receive_complete;
end

always @(*) begin  
	o_shift_register   = shift_register;
end

/*--------------------------Finite state machine---------------*/

endmodule
// ---------------------------------------------------------------------------
//
// Description:
//  <Description text here, indented multiple lines allowed>
//
// File:        $Source: /var/cvsmucontrol/users/tgu/Tools/merlin2/DigitalFlow/Templates/verilog.v.tpl,v $
// Created:     Fri Jul 08 16:27:13 EEST 2016
//      by:     opo
// Updated:     $Date: 2011/08/09 12:38:38 $
//              $Author: tgu $
// Revision:    $Revision: 1.1 $
//
// Copyright (c) Melexis Digital Competence Center
//
// ---------------------------------------------------------------------------
module clock_generator1 (  
              i_clk,
              i_rst_n,
              i_ubrrl_new,
              i_ubrr,
              i_xcki,
              i_ddr_xck,
              i_ucpol,
              i_umsel,
              i_u2x,
              i_txen,
              i_rxen,
              i_transmit_complete,
              o_txclk,
              o_rxclk,
              o_xcko
            );
            
/*--------------------------Parameter--------------------------*/

/*--------------------------Input ports------------------------*/

input                     	i_clk;      // system clock input
input                     	i_rst_n;    // system reset with active low 
input                     	i_xcki;     // external clock input in slave sync mode
input                     	i_ddr_xck;  // data direction for synchronous mode

/* To prevent down-counter rewriting when UBRRL register value is change we need 
to compare new value of UBRRL with old one. */
 
input   [11:0]		i_ubrr; 	// baud rate value
input   					i_ubrrl_new;// new data in ubrrl

input 						i_ucpol;	// clock polarity
input 						i_umsel; 	// USART mode select 0 - Async, 1 - Sync
input 						i_u2x;		// double speed mode
input 						i_rxen;		// enable transmitter1
input 						i_txen;		// enable receiver1
input             i_transmit_complete; // transmit complete flag

/*--------------------------Ouput ports------------------------*/

output  	            	o_txclk;    // transmiter clock
output                  o_rxclk;    // receiver1 clock
output                  o_xcko;     // internal clock output in master sync mode

/*--------------------------Inout ports------------------------*/

/*--------------------------Variables--------------------------*/

wire                      	baud_rate_clock_en; // down_counter = 0, enable signal for clock gating 
												// and counter reset to baud rate value
wire                      	baud_rate_clock;	// clock formed after down_counter

wire 						edge_detect;		// edge detector output
wire 						rising_edge;		// low to high transition
wire 						falling_edge;		// high to low transition

wire 						sync_mode_clock; 	// clock used in synchronours mode
wire 						ux_u2x_clock;		// normal or 2x mode clock 

wire 						txclk;				// txclk
wire 						rxclk;				// rxclk

reg     [11:0]			  	down_counter;

reg                       	gated_clock_latch_br;  // gated clock latch baud rate output
reg                       	gated_clock_latch_tx;  // gated clock latch baud rate output
reg                       	gated_clock_latch_rx;  // gated clock latch baud rate output

reg 						divide_by_2;		// baud rate clock after divide by 2 block(frq/2) 
reg 	[1:0]				divide_by_8;		// baud rate clock after divide by 4 block(frq/8)
reg 						divide_by_16;		// baud rate clock after divide by 2 block(frq/16)

reg 	[1:0]				sync_register;		// user for synchronizing external clock in current clock domain
reg 						edge_detection_ff;	// ff user for edge detection aim

/*--------------------------Sequential logic-------------------*/

assign baud_rate_clock_en   =  (down_counter == 0);

assign baud_rate_clock      =  i_clk & gated_clock_latch_br;

assign o_rxclk				=  rxclk & gated_clock_latch_rx;

assign o_txclk				=  txclk & gated_clock_latch_tx;

assign rising_edge			=  sync_register[1] & ~edge_detection_ff;

assign falling_edge			= ~sync_register[1] & edge_detection_ff;

assign edge_detect 			= (i_ucpol) ? (rising_edge) : (falling_edge);

assign o_xcko				= divide_by_2;

assign sync_mode_clock 		= (i_ddr_xck) ? (divide_by_2) : (edge_detect); 

assign ux_u2x_clock			= (i_u2x)	? (divide_by_8[1]) : (divide_by_16);

assign txclk				= (i_umsel) ? (sync_mode_clock) : (ux_u2x_clock);

assign rxclk				= (i_umsel) ? (sync_mode_clock) : (baud_rate_clock);


/*--------------------------Combinational logic----------------*/

always @(posedge i_clk, negedge i_rst_n) begin: down_counter_block
    if(!i_rst_n)  begin: down_counter_reset
      down_counter <= 0;
    end // down-counter reset
    else begin: down_counter_operation
      // down-counter rewrite when ubrr changed or count to zero
      if (i_ubrrl_new || baud_rate_clock_en) begin: down_counter_new_ubrr
        down_counter <= i_ubrr;
      end // down_couter_new_ubrr
      else begin: down_counter_counting
        down_counter <= down_counter - 1;
      end // down_couter_when_zero
    end // down_couter_operation
end // down_couter_block 

always @(*) begin: gated_clock_latch_br_block
    if(!i_clk) begin: transparent_state
        gated_clock_latch_br = baud_rate_clock_en;
    end // transparent_state
end // gated_clock_latch_block

always @(posedge baud_rate_clock or negedge i_rst_n) begin : divide_by_2_block
	if(~i_rst_n) begin: divide_by_2_reset 
		divide_by_2 <= 0;
	end else begin: divide_by_2_operation
		divide_by_2 <= ~divide_by_2;
	end
end // divide_by_2_block

always @(posedge divide_by_2 or negedge i_rst_n) begin : divide_by_4_block
	if(~i_rst_n) begin: divide_by_4_reset
		divide_by_8[0] <= 0;
	end else begin: divide_by_4_operation
		divide_by_8[0] <= ~divide_by_8[0];
	end
end // divide_by_4_block

always @(posedge divide_by_8[0] or negedge i_rst_n) begin : divide_by_8_block
	if(~i_rst_n) begin: divide_by_8_reset
		divide_by_8[1] <= 0;
	end else begin: divide_by_8_operation
		divide_by_8[1] <= ~divide_by_8[1];
	end
end // divide_by_8_block

always @(posedge divide_by_8[1] or negedge i_rst_n) begin : divide_by_16_block
	if(~i_rst_n) begin: divide_by_16_reset 
		divide_by_16 <= 0;
	end else begin: divide_by_16_operation
		divide_by_16 <= ~divide_by_16;
	end
end // divide_by_16_block

// Used for external clock synchronization in sync slave mode
always @(posedge i_clk or negedge i_rst_n) begin : sync_register_block
	if(~i_rst_n) begin: sync_register_reset
		sync_register <= 0;
	end else begin
		sync_register[0] <= i_xcki;
		sync_register[1] <= sync_register[0];
	end
end //sync_register_block

always @(posedge i_clk or negedge i_rst_n) begin : edge_detection_block
	if(~i_rst_n) begin
		edge_detection_ff <= 0;
	end else begin
		edge_detection_ff <= sync_register[1];
	end
end // edge_detection_block

// Output gated clock for tx and rx
always @(*) begin: gated_clock_latch_tx_block
    if(!txclk) begin: transparent_state
        gated_clock_latch_tx = i_txen | !i_transmit_complete;
    end // transparent_state
end // gated_clock_latch_block

always @(*) begin: gated_clock_latch_rx_block
    if(!rxclk) begin: transparent_state
        gated_clock_latch_rx = i_rxen;
    end // transparent_state
end // gated_clock_latch_block

/*--------------------------Finite state machine---------------*/

endmodule
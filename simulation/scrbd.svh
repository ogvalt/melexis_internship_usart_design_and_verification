
`ifndef __SCOREBOARD_SVH__
`define __SCOREBOARD_SVH__

`include "./simulation/if.svh"
`include "./simulation/uart_uvc.svh"
// `include "chcker.svh"

class scoreboard;

	virtual uart_interface 	uart_if;
	virtual bus_interface  	bus_if;
	virtual dut_interface 	dut_if;

	uart_monitor 	uart_mon; // UART Tx monitor
	mailbox #(base_uart_transaction) uart_mb;

	base_uart_transaction 	trn;

	uart_mon_frame 			uart_frm;

	function new	(
						virtual uart_interface 	uart_if,
						virtual bus_interface 	bus_if,
						virtual dut_interface 	dut_if
					);
		this.uart_if 	= 	uart_if;
		this.bus_if 	= 	bus_if;
		this.dut_if 	= 	dut_if;

		uart_mb 	 	= 	new();

		uart_mon 		= 	new( uart_if.monport, but_if.monport, dut_if, uart_mb);

		fork
			this.transaction_filter();
		join_none

	endfunction : new

	task transaction_filter ();
		forever begin
			#1;
		end
	endtask : transaction_filter

endclass : scoreboard

`endif // __SCOREBOARD_SVH__

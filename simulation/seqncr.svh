
`ifndef __SEQUENCER_SVH__
`define __SEQUENCER_SVH__

`include "./simulation/if.svh"
`include "./simulation/uart_uvc.svh"

class sequencer;

	virtual bus_interface bus_if;
	virtual uart_interface uart_if;
	virtual dut_interface dut_if;


	uart_frame_items 	uart_frm_itm;
	uart_transactor 	uart_xtr;

	function new(	virtual bus_interface bus_if,
					virtual uart_interface uart_if,
					virtual dut_interface dut_if
				);
		$display("[%t][INFO] Sequencer constructor start",$time());
		this.bus_if 	= bus_if;
		this.uart_if 	= uart_if;
		this.dut_if 	= dut_if;

		uart_xtr = new(bus_if, uart_if, dut_if);
		uart_frm_itm = new();

		$display("[%t][INFO] Sequencer constructor finish",$time());

	endfunction : new

	task generate_stimulus(int unsigned count = 1);

		repeat(count) begin
			assert(uart_frm_itm.randomize() with {});
			uart_xtr.uart_operation(uart_frm_itm);
		end

	endtask : generate_stimulus

endclass : sequencer

`endif // __SEQUENCER_SVH__

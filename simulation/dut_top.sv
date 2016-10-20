
`ifndef __DUT_TOP__
`define __DUT_TOP__

`include "./simulation/if.svh"
`include "./design/uart.v"

module dut_top (
					dut_interface 		dut_if,
					bus_interface		bus_if,
					uart_interface 		uart_if  
				);
	
	uart 	dut (
					.i_clk 			(dut_if.clk),
					.i_rst_n 		(dut_if.rst_n),
					.i_we 			(bus_if.write_enable),
					.i_address 		(bus_if.address),
					.i_data 		(bus_if.data_in),
					.i_rx 			(uart_if.rx),
					.i_xcki 		(uart_if.xcki),
					.i_ddr_xck 		(uart_if.ddr_xck),
					.o_xcko 		(uart_if.xcko),
					.o_tx 			(uart_if.tx),
					.o_data 		(bus_if.data_out)
				);

endmodule


`endif // __DUT_TOP__
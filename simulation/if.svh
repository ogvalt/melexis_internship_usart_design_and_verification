
`ifndef __DUT_IF__
`define __DUT_IF__

interface dut_interface(
						input clk, 
						input rst_n
						);
endinterface: dut_interface

`endif //__DUT_IF__

`ifndef __BUS_IF__
`define __BUS_IF__

interface bus_interface ();
	logic 	write_enable;
	logic 	[7:0] address;
	logic 	[7:0] data_in;
	logic	[7:0] data_out;

	modport  drvport (
						output write_enable,
						output address,
						output data_in
					 );
	modport  monport (
						input write_enable,
						input data_in,
						input data_out,
						input address
					 );

endinterface: bus_interface

`endif //__BUS_IF__

`ifndef __UART_IF__
`define __UART_IF__

interface uart_interface(
							input xcki
						);
	logic 	rx;
	logic 	tx;
	logic 	xcko;
	logic 	ddr_xck;

	modport drvport (
						output rx,
						output ddr_xck
					);
	modport monport (
						input rx,
						input tx,
						input xcko,
						input ddr_xck
					);

endinterface: uart_interface

`endif //__UART_IF__

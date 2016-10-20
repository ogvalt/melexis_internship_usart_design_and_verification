// ---------------------------------------------------------------------------
//
// Description:
//  <Description text here, indented multiple lines allowed>
//
// File:        $Source: /var/cvsmucontrol/users/tgu/Tools/merlin2/DigitalFlow/Templates/Verilog.v.tpl,v $
// Created:     Wed Jul 20 12:46:14 EEST 2016
//      by:     opo
// Updated:     $Date: 2011/08/09 12:38:38 $
//              $Author: tgu $
// Revision:    $Revision: 1.3 $
//
// Copyright (c) Melexis Digital Competence Center
//
// ---------------------------------------------------------------------------

`include "if.svh"
`include "dut_top.sv"
`include "environment.sv"

module verification();

	parameter 	CLOCK_PERIOD  	= 	2;
	parameter 	RESET_DELAY 	=   10;

	parameter 	EXTERNAL_CLOCK 	= 	60;

	logic 		clk, rst_n, xcki;

	dut_interface dut_if(clk, rst_n); 	//	DUT interface
	bus_interface bus_if();		// 	interface between uart and bus
	uart_interface uart_if(xcki);	// 	uart external interface

	environment env(dut_if, bus_if, uart_if);	// 	Simulation environment
	dut_top	dut_top	(
						.dut_if(dut_if),
						.bus_if(bus_if),
						.uart_if(uart_if)
					);

	initial begin
		$display("=============================================");
		$display("[%t][INFO] Clock generation start, reset is active", $time());
		clk = 0;
		forever #(CLOCK_PERIOD/2) clk = ~clk;
	end
	initial begin
		xcki = 0;
		forever #(EXTERNAL_CLOCK/2) xcki = ~xcki;
	end
	initial begin 
		rst_n = 0;
		repeat(RESET_DELAY) @(negedge clk);
		rst_n = 1;
		$display("[%t][INFO] Reset inactive", $time());
		$display("=============================================");
	end

endmodule // verificaiton
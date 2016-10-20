
`include "if.svh"
// `include "scrbd.svh"
`include "seqncr.svh"

program environment(dut_interface dut_if, bus_interface bus_if, uart_interface uart_if);

	// scoreboard 	sb; // Score Board (Cheker)
	sequencer 	sq; // Sequencer (Stimulus)

	initial begin: start

		sq = new(bus_if, uart_if, dut_if);
		// sb = new(uart_if, bus_if, dut_if);

		$display("[%t][INFO] Sequencer instance create",$time());
		
		$display("[%t][INFO] Simulation Environment Initialised",$time());
		repeat(100) @(negedge dut_if.clk);

		sq.generate_stimulus(10);
		
	end : start// simulation_start

	final begin: finish
    	// End of simulation
    	$display("\n=============================================");
    	$display("[%t][INFO] Simulation Environment Finished",$time());
    	//sb.report_final_status();
    end : finish // simulation_finish
	
endprogram : environment

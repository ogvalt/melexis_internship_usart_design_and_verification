module uart1 	(
					i_clk,
					i_rst_n,
					i_we,
					i_address,
					i_data,
					i_rx,
					i_xcki,
					i_ddr_xck,
					o_xcko,
					o_tx,
					o_data
				);

	input 				i_clk;
	input 				i_rst_n;
	input 				i_we;

	input 	[7:0] 		i_address;
	input 	[7:0] 		i_data;

	input      			i_rx;
	input 				i_xcki;
	input 				i_ddr_xck;

	output  reg [7:0]	o_data;
	output 				o_tx;
	output 				o_xcko;

	reg 				ubrrh_ucsrc_select,
						ucsra_select,
						ucsrb_select,
						ubrrl_select,
						udr_select;

	wire 	[7:0]		ubrrh_ucsrc,
						ucsra,
						ucsrb,
						ubrrl,
						udr;

	uart_module1 uart_module1_inst1 	(  
						              .i_clk					(i_clk),
						              .i_rst_n					(i_rst_n),
						              .i_we						(i_we),
						              .i_udr_select				(udr_select),
						              .i_ubrrh_ucsrc_select		(ubrrh_ucsrc_select),
						              .i_ucsra_select			(ucsra_select),
						              .i_ucsrb_select			(ucsrb_select),
						              .i_ubrrl_select			(ubrrl_select),
						              .i_ddr_xck				(i_ddr_xck),
						              .i_udr 					(i_data),
						              .i_rx 					(i_rx),
						              .i_xcki					(i_xcki),
						              .i_ubrrh_ucsrc 			(i_data),
						              .i_ubrrl 					(i_data),
						              .i_ucsra 					(i_data),
						              .i_ucsrb 					(i_data),
						              .o_ubrrh_ucsrc 			(ubrrh_ucsrc),
						              .o_ubrrl 					(ubrrl),
						              .o_ucsra 					(ucsra),
						              .o_ucsrb 					(ucsrb),
						              .o_udr 					(udr),
						              .o_tx 					(o_tx),
						              .o_xcko 					(o_xcko)
            						);

	always @(*) begin : address_block
		ucsra_select 		= 0;
		ucsrb_select 		= 0;
		ubrrh_ucsrc_select  = 0;
		ubrrl_select 		= 0;
		udr_select 			= 0;
		case(i_address)
			8'h00: 
					begin
						ucsra_select = 1;
					end
			8'h01:
					begin
						ucsrb_select = 1;
					end
			8'h02:
					begin
						ubrrh_ucsrc_select = 1;
					end
			8'h03:
					begin
						ubrrl_select = 1;
					end
			8'h04:
					begin
						udr_select = 1;
					end
		endcase // i_address
	end

	always @(*) begin  
		case(1'b1)
			ucsra_select:			o_data = ucsra;
			ucsrb_select:			o_data = ucsrb;
			ubrrh_ucsrc_select:		o_data = ubrrh_ucsrc;
			ubrrl_select:			o_data = ubrrl;
			udr_select:				o_data = udr;
		endcase // 1'b1
	end

endmodule // uart
/*
  Module description
*/

module parity_checker1(
              i_clk,
              i_rst_n,  
              i_parity_mode_0,
              i_parity_en,
              i_frame_size,
              i_frame,
              o_parity_check
            );
            
/*--------------------------Parameter--------------------------*/

/*--------------------------Input ports------------------------*/

input                 i_clk;
input                 i_rst_n;

input                 i_parity_mode_0; // UPM0 bit, if 0 - even parity, 1 - odd parity
input                 i_parity_en;// enable to write into output flip-flop the result
                                       // of parity check
input   [2:0]         i_frame_size;    // frame size accoding to Control Bit configuration
input   [8:0]         i_frame;         // data frame

/*--------------------------Ouput ports------------------------*/

output  reg           o_parity_check;  // result of parity check

/*--------------------------Inout ports------------------------*/


/*--------------------------Variables--------------------------*/

/*--------------------------Sequential logic-------------------*/

always @(*) begin: parity_check_block
    case (i_frame_size)  // full_case
          // 5-bit frame
          3'b000: o_parity_check = (^i_frame[4:0])^i_parity_mode_0;
          // 6-bit frame
          3'b001: o_parity_check = (^i_frame[5:0])^i_parity_mode_0;
          // 7-bit frame
          3'b010: o_parity_check = (^i_frame[6:0])^i_parity_mode_0;
          // 8-bit frame
          3'b011: o_parity_check = (^i_frame[7:0])^i_parity_mode_0;
          // 9-bit frame
          3'b111: o_parity_check = (^i_frame[8:0])^i_parity_mode_0;
        endcase     
end
/*--------------------------Combinational logic----------------*/


/*--------------------------Finite state machine---------------*/

endmodule       
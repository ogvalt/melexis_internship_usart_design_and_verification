
`include "if.svh"

`ifndef __UART_UVC_DEFINES__
`define __UART_UVC_DEFINES__

`define UCSRA_ADDR      8'h00;
`define UCSRB_ADDR      8'h01;
`define UBRRH_UCSRC_ADDR  8'h02;
`define UBRRL_ADDR      8'h03;
`define UDR_ADDR      8'h04;

typedef enum bit[2:0] {
  DATA_5BIT,
  DATA_6BIT,
  DATA_7BIT,
  DATA_8BIT,
  DATA_9BIT

} uart_data_length_type_t;

typedef enum bit[1:0]  {
  PARITY_DISABLE_0,
  PARITY_DISABLE_1,
  PARITY_ENABLE_EVEN,
  PARITY_ENABLE_ODD
} uart_parity_mode_type_t;

typedef enum bit   {
  STOP_BIT_1,
  STOP_BIT_2
} uart_stop_bit_length_type_t;

typedef enum bit  {
  MPCM_DISABLE,
  MPCM_ENABLE
} uart_mpcm_mode_type_t;

typedef enum bit    {
  SINGLE_SPEED,
  DOUBLE_SPEED
} uart_speed_mode_type_t;

typedef enum bit    {
  ASYNC_OPERATION,
  SYNC_OPERATION
} uart_async_sync_mode_type_t;

typedef enum bit  {
  RISING_FALLING,
  FALLING_RISING
} uart_clock_pol_type_t;

class base_uart_transaction;
  string name;

  function new();
    name = "base_uart_transaction";
  endfunction : new
endclass : base_uart_transaction

`endif // __UART_UVC_DEFINES__

`ifndef __UART_TRANSACTION__
`define __UART_TRANSACTION__

class uart_frame_tx extends base_uart_transaction;

  rand uart_data_length_type_t    data_len_type;
  rand uart_parity_mode_type_t    parity_mode_type;
  rand uart_stop_bit_length_type_t  stop_bit_len_type;
  rand uart_mpcm_mode_type_t      mpcm_mode_type;
  rand uart_speed_mode_type_t     speed_mode_type;
  rand uart_async_sync_mode_type_t  async_sync_type;
  rand uart_clock_pol_type_t      clock_polatiry_type;

  rand logic  [8:0] data;
  rand logic  [11:0]  baud_rate;
  logic         speed_mode;
  logic         sync_async;
  logic     [2:0] char_size;
  logic     [1:0] parity_mode;
  logic         stop_bit_mode;
  logic         mpcm_mode;
  logic         clock_pol;

  constraint c_baud_rate{
    if(async_sync_type == SYNC_OPERATION) baud_rate == 0;
  }

  function new();
    case (data_len_type)
      DATA_5BIT:  char_size = 3'b000;
      DATA_6BIT:  char_size = 3'b001;
      DATA_7BIT:  char_size = 3'b010;
      DATA_8BIT:  char_size = 3'b011;
      DATA_9BIT:  char_size = 3'b111;
    endcase // data_len_type
    case (parity_mode_type)
      PARITY_DISABLE_0:   parity_mode = 2'b00;
      PARITY_DISABLE_1:   parity_mode = 2'b01;
      PARITY_ENABLE_EVEN: parity_mode = 2'b10;
      PARITY_ENABLE_ODD:  parity_mode = 2'b11;
    endcase
    case(stop_bit_len_type)
      STOP_BIT_1:   stop_bit_mode = 0;
      STOP_BIT_2:   stop_bit_mode = 1;
    endcase // stop_bit_len_type
    case(mpcm_mode_type)
      MPCM_DISABLE: mpcm_mode = 0;
      MPCM_ENABLE:  mpcm_mode = 1;
    endcase // mpcm_mode_type
    case(speed_mode_type)
      SINGLE_SPEED:   speed_mode = 0;
      DOUBLE_SPEED:   speed_mode = 1;
    endcase // speed_mode_type
    case(async_sync_type)
      ASYNC_OPERATION: sync_async = 0;
      SYNC_OPERATION:  sync_async = 1;  
    endcase // async_sync_type
    case(clock_polatiry_type)
      RISING_FALLING:  clock_pol = 0;
      FALLING_RISING:  clock_pol = 1;
    endcase // clock_polatiry_type
  endfunction : new
endclass : uart_frame_tx

class uart_frame_rx extends  base_uart_transaction;

  rand uart_data_length_type_t    data_len_type;
  rand uart_parity_mode_type_t    parity_mode_type;
  rand uart_stop_bit_length_type_t  stop_bit_len_type;
  rand uart_mpcm_mode_type_t      mpcm_mode_type;
  rand uart_speed_mode_type_t     speed_mode_type;
  rand uart_async_sync_mode_type_t  async_sync_type;
  rand uart_clock_pol_type_t      clock_polatiry_type;


  rand logic [8:0]  data; 
  rand logic [2:0]    char_size;
  rand logic [11:0]   baud_rate;
  rand logic      speed_mode;
  rand logic      sync_async;
  rand logic [3:0]  rx_bits_num; // Amount of bits to be received by receiver
  rand logic      mpcm_bit;
  rand logic      parity_bit;  // parity bit
  rand logic [1:0]  parity_mode; // parity mode 
  rand logic      stop_bit;  // stop bit
  rand logic      stop_bit_mode; 
  rand logic      clock_pol;

  constraint c_tx_bits_num {
    if(mpcm_mode_type == MPCM_ENABLE)
      rx_bits_num inside {[4:8]};
    else 
      rx_bits_num inside {[5:9]};
  }
  constraint c_baud_rate {
    if (async_sync_type == SYNC_OPERATION)
      baud_rate == 0;
  }
  constraint c_char_size {
    if (data_len_type == DATA_5BIT) char_size == 3'b000;
    if (data_len_type == DATA_6BIT) char_size == 3'b001;
    if (data_len_type == DATA_7BIT) char_size == 3'b010;
    if (data_len_type == DATA_8BIT) char_size == 3'b011;
    if (data_len_type == DATA_9BIT) char_size == 3'b111;
    }

  function new();
  
  endfunction : new


  function void post_randomize(logic mpcm_mode = 0, logic mpcm_frame_type = 0);
  /*  
    post_randomize() - function that will 
    generate only correct frames with no error
  */
    // set number of receive data bits accoding to expected one
    case (data_len_type) 
      DATA_5BIT:  rx_bits_num = 5;
      DATA_6BIT:  rx_bits_num = 6;
      DATA_7BIT:  rx_bits_num = 7;
      DATA_8BIT:  rx_bits_num = 8;
      DATA_9BIT:  rx_bits_num = 9;
    endcase // data_len_type
    // decrease number of data bit if mpcm enable 
    // for inserting mpcm frame type bit
    if (mpcm_mode_type == MPCM_ENABLE) begin
      rx_bits_num--; 
    end
    // generate correct parity bit accourding to settings 
    case (parity_mode_type)
      PARITY_DISABLE_0:   
          begin
            parity_bit  = 0;
            parity_mode = 2'b00;
          end
      PARITY_DISABLE_1:   
          begin
            parity_bit = 0;
            parity_mode = 2'b01;
          end
      PARITY_ENABLE_EVEN: 
          begin
            parity_bit = (^data)^1'b0; //(^data[(rx_bits_num-1):0])^1'b0;
            parity_mode = 2'b10;
          end
      PARITY_ENABLE_ODD:  
          begin
            parity_bit = (^data)^1'b1; // (^data[(rx_bits_num-1):0])^1'b1;
            parity_mode = 2'b11;
          end
    endcase

    case (speed_mode_type)
      SINGLE_SPEED:   speed_mode = 0;
      DOUBLE_SPEED:   speed_mode = 1;
    endcase

    case(async_sync_type)
      ASYNC_OPERATION: sync_async = 0;
      SYNC_OPERATION:  sync_async = 1;  
    endcase // async_sync_type

    case(clock_polatiry_type)
      RISING_FALLING:  clock_pol = 0;
      FALLING_RISING:  clock_pol = 1;
    endcase // clock_polatiry_type
    case(mpcm_mode)
      0: mpcm_mode_type = MPCM_DISABLE;
      1: mpcm_mode_type = MPCM_ENABLE;
    endcase // mpcm_mode
    // correct stop bit
    case(stop_bit_len_type)
      STOP_BIT_1:   stop_bit_mode = 0;
      STOP_BIT_2:   stop_bit_mode = 1;
    endcase

    stop_bit  =   1;
    // user defined mpcm frame type: address or data
    mpcm_bit = mpcm_frame_type;

  endfunction : post_randomize
endclass : uart_frame_rx  

`endif // __UART_TRANSACTION__

`ifndef __UART_DRIVER__
`define __UART_DRIVER__

class uart_driver;

  virtual bus_interface.drvport   bus_drv_port;
  virtual uart_interface.drvport  uart_drv_port;
  virtual dut_interface       dut_port;

  // create mailbox and semaphore 
  // for interprocess communication
  mailbox #(base_uart_transaction)  trn_mb;
  semaphore trn_done;

  base_uart_transaction trn; 

  uart_frame_rx   frm_rx;
  uart_frame_tx   frm_tx;

  function new (  mailbox #(base_uart_transaction) trn_mb,
          semaphore trn_done,
          virtual bus_interface.drvport   bus_drv_port,
          virtual uart_interface.drvport  uart_drv_port,
          virtual dut_interface       dut_port
        );
    $display("[%t][INFO] Driver constructor start",$time());
    this.bus_drv_port   = bus_drv_port;
    this.uart_drv_port  = uart_drv_port;
    this.trn_mb     = trn_mb;
    this.trn_done     = trn_done;
    this.dut_port     = dut_port;

    // Init UART and BUS interface
    bus_drv_port.write_enable   = 0;
    bus_drv_port.address    = 0;
    bus_drv_port.data_in    = 0;

    uart_drv_port.rx      = 1;
    uart_drv_port.xcki      = 0;
    uart_drv_port.ddr_xck   = 0;
    $display("[%t][INFO] Try to run Driver",$time());
    fork
      this.run_driver();
    join_none
    $display("[%t][INFO] Driver constructor finish",$time());
  endfunction : new 
  // Driver main task
  task run_driver();
    forever begin
      // Get transaction from mailbox
      // or wait for any transaction
      trn_mb.get(trn);

      if ($cast(frm_rx, trn)) begin
        drive_rx_frame(frm_rx);
      end 
      else begin
        if ($cast(frm_tx, trn)) begin
          drive_tx_frame(frm_tx);
        end
        else begin
          $display("[%t][SPI_DRV][SIM_ERR] Unknown Transaction in Driver. TypeName: %s",
            $time(),$typename(trn));
        end
      end
      trn_done.put();
    end
  endtask : run_driver

  task wait_task(uart_frame_rx frm);
    int multiplier = (frm.sync_async) ? ( 1  ) : ((frm.speed_mode) ? 8 : 16);
    int baud       = (frm.baud_rate + 1) * multiplier;
    $display("[%t][INFO] Baud_rate: [%d]  Multiplier: [%d] Baud: [%d]",$time(),
                        frm.baud_rate,multiplier,baud);

    repeat (baud) begin 
      @(negedge dut_port.clk); 
    end
    $display("[%t][INFO] End time",$time);
  endtask : wait_task
  // Drive UART frame for receive
  task drive_rx_frame(uart_frame_rx frm);

    while (!dut_port.rst_n) #1;
    @(negedge dut_port.clk);
    bus_drv_port.write_enable = 1;

    bus_drv_port.address = `UBRRH_UCSRC_ADDR;
    bus_drv_port.data_in = {1'b0, 3'b0, frm.baud_rate[11:8]};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UBRRL_ADDR;
    bus_drv_port.data_in = frm.baud_rate[7:0];
    @(negedge dut_port.clk);
    bus_drv_port.address = `UCSRA_ADDR;
    bus_drv_port.data_in = {6'b0, frm.speed_mode, frm.mpcm_bit};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UBRRH_UCSRC_ADDR;
    bus_drv_port.data_in = {1'b1, frm.sync_async, frm.parity_mode,
                  frm.stop_bit_mode, frm.char_size[1:0],
                  frm.clock_pol};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UCSRB_ADDR;
    bus_drv_port.data_in = {3'b0, 2'b10, // tx_en 
                  frm.char_size[2], 1'b0, 1'b0};

    @(negedge dut_port.clk);
    bus_drv_port.write_enable = 0;
    wait_task(frm);
    uart_drv_port.rx      = 0;
    for (int i = 0; i < frm.rx_bits_num; i++) begin
      wait_task(frm);
      uart_drv_port.rx  = frm.data[i];
    end
    if (frm.mpcm_mode_type == MPCM_ENABLE) begin
      wait_task(frm);
      uart_drv_port.rx  = frm.mpcm_bit;
      wait_task(frm);
      uart_drv_port.rx  = frm.parity_bit;
    end else begin
      wait_task(frm);
      uart_drv_port.rx  = frm.parity_bit;
    end
    wait_task(frm);
    uart_drv_port.rx  = frm.stop_bit;
    wait_task(frm);
  endtask : drive_rx_frame
  // Drive UART frame for transmit
  task drive_tx_frame(uart_frame_tx frm);
    while (!dut_port.rst_n) #1;
    @(negedge dut_port.clk);
    bus_drv_port.write_enable = 1;

    bus_drv_port.address = `UBRRH_UCSRC_ADDR;
    bus_drv_port.data_in = {1'b0, 3'b0, frm.baud_rate[11:8]};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UBRRL_ADDR;
    bus_drv_port.data_in = frm.baud_rate[7:0];
    @(negedge dut_port.clk);
    bus_drv_port.address = `UCSRA_ADDR;
    bus_drv_port.data_in = {6'b0, frm.speed_mode, frm.mpcm_mode};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UBRRH_UCSRC_ADDR;
    bus_drv_port.data_in = {1'b1, frm.sync_async, frm.parity_mode,
                  frm.stop_bit_mode, frm.char_size[1:0],
                  frm.clock_pol};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UCSRB_ADDR;
    bus_drv_port.data_in = {4'b0, 1'b1, // tx_en 
                  frm.char_size[2],frm.data[8], 1'b0};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UDR_ADDR;
    bus_drv_port.data_in = frm.data[7:0];

    @(negedge dut_port.clk);
    bus_drv_port.write_enable = 0;
  endtask : drive_tx_frame

endclass : uart_driver

`endif // __UART_DRIVER__

`ifndef __UART_TRANSACTOR__
`define __UART_TRANSACTOR__

class uart_transactor;
  virtual bus_interface     bus_if;
  virtual uart_interface      uart_if;
  virtual dut_interface       dut_if;

  mailbox #(base_uart_transaction) trn_mb;
  semaphore trn_done;

  uart_driver uart_drv;

  uart_frame_rx   frm_rx;
  uart_frame_tx   frm_tx;

  function new( virtual bus_interface bus_if,
          virtual uart_interface uart_if,
          virtual dut_interface dut_if
        );
    $display("[%t][INFO] Transactor constructor start",$time());
    this.bus_if = bus_if;
    this.uart_if = uart_if;
    this.dut_if = dut_if;

    trn_mb = new();
    trn_done = new();
    uart_drv = new  ( trn_mb,
              trn_done,
              bus_if.drvport ,
              uart_if.drvport,
              dut_if
            );
    $display("[%t][INFO] Transactor constructor finish",$time());
  endfunction : new

  task uart_tx_data();
    $display("[%t][UART_TRN] UART Tx Frame",$time());
    frm_tx = new();
    
    assert(frm_tx.randomize() with {});

    trn_mb.put(frm_tx);
    trn_done.get();

    $write("[%t][UART_TRN] UART Frame Tx have been sent, Data[%2d]\n",$time(),frm_tx.data);
  endtask : uart_tx_data

  task uart_rx_data();
    $display("[%t][UART_TRN] UART Rx Frame",$time());
    frm_rx = new();
    
    assert(frm_rx.randomize() with {});
    frm_rx.post_randomize();

    trn_mb.put(frm_rx);
    trn_done.get();
    $write("[%t][UART_TRN] UART Frame Rx have been sent, Data[%2d]\n",$time(),frm_rx.data);
  endtask : uart_rx_data


endclass : uart_transactor


`endif // __UART_TRANSACTOR__

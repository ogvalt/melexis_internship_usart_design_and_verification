
`include "if.svh"

`ifndef __UART_UVC_DEFINES__
`define __UART_UVC_DEFINES__

`define UCSRA_ADDR        8'h00;
`define UCSRB_ADDR        8'h01;
`define UBRRH_UCSRC_ADDR  8'h02;
`define UBRRL_ADDR        8'h03;
`define UDR_ADDR          8'h04;

typedef enum bit[2:0] {
  DATA_5BIT,
  DATA_6BIT,
  DATA_7BIT,
  DATA_8BIT,
  DATA_RESERVED_0,
  DATA_RESERVED_1,
  DATA_RESERVED_2,
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

typedef enum bit {
  SLAVE_MODE,
  MASTER_MODE
} uart_sync_mode_type_t;

typedef enum bit[1:0] {
  INIT,
  TRANSMIT,
  RECEIVE,
  DUPLEX
} uart_operation_mode_type_t;

class base_uart_transaction;
  string name;

  function new();
    name = "base_uart_transaction";
  endfunction : new
endclass : base_uart_transaction

class uart_frame_items;

  rand uart_data_length_type_t      data_len_type;
  rand uart_parity_mode_type_t      parity_mode_type;
  rand uart_stop_bit_length_type_t  stop_bit_mode_type;
  rand uart_mpcm_mode_type_t        mpcm_mode_type;
  rand uart_speed_mode_type_t       speed_mode_type;
  rand uart_async_sync_mode_type_t  async_sync_type;
  rand uart_clock_pol_type_t        clock_polatiry_type;
  rand uart_sync_mode_type_t        sync_mode_type;
  rand uart_operation_mode_type_t   uart_op_mode_type;

  function new();
  
  endfunction : new

endclass : uart_frame_items

`endif // __UART_UVC_DEFINES__

`ifndef __UART_TRANSACTION__
`define __UART_TRANSACTION__

class uart_frame extends base_uart_transaction;

  rand uart_data_length_type_t      data_len_type;
  rand uart_parity_mode_type_t      parity_mode_type;
  rand uart_stop_bit_length_type_t  stop_bit_mode_type;
  rand uart_mpcm_mode_type_t        mpcm_mode_type;
  rand uart_speed_mode_type_t       speed_mode_type;
  rand uart_async_sync_mode_type_t  async_sync_type;
  rand uart_clock_pol_type_t        clock_polatiry_type;
  rand uart_sync_mode_type_t        sync_mode_type;
  rand uart_operation_mode_type_t   uart_op_mode_type;

  rand logic    [8:0]       tx_data;
  rand logic    [8:0]       rx_data;
  rand logic    [11:0]      baud_rate;
  rand logic    [3:0]       rx_bits_num; // number of transmitted bits to the receiver
  rand logic                speed_mode;
  rand logic                async_sync_mode;
  rand logic    [1:0]       parity_mode;
  rand logic    [2:0]       char_size;
  rand logic                stop_bit_mode;
  rand bit                  mpcm_bit;
  rand logic                mpcm_frame_type;
  rand logic                clock_polatiry_mode;
  rand logic                sync_mode;
  rand logic                parity_bit;

  int                       frame_size;

  constraint c_rx_bits_num {
    if(mpcm_mode_type == MPCM_ENABLE)
      rx_bits_num inside {[4:8]};
    else 
      rx_bits_num inside {[5:9]};
  }
  constraint c_baud_rate {
    if (async_sync_type == SYNC_OPERATION)
      baud_rate == 0;
  }
  constraint c_speed_mode {
    if(speed_mode_type == SINGLE_SPEED) speed_mode == 0;
    if(speed_mode_type == DOUBLE_SPEED) speed_mode == 1;
  }
  constraint c_async_sync {
    if(async_sync_type == ASYNC_OPERATION) async_sync_mode == 0;
    if(async_sync_type == SYNC_OPERATION) async_sync_mode == 1;
  }
  constraint c_parity_mode {
    if(parity_mode_type == PARITY_DISABLE_0) parity_mode == 2'b00;
    if(parity_mode_type == PARITY_DISABLE_1) parity_mode == 2'b01;
    if(parity_mode_type == PARITY_ENABLE_ODD) parity_mode == 2'b11;
    if(parity_mode_type == PARITY_ENABLE_EVEN) parity_mode == 2'b10;
  }
  constraint c_char_size {
    if(data_len_type == DATA_5BIT) char_size == 3'b000;
    if(data_len_type == DATA_6BIT) char_size == 3'b001;
    if(data_len_type == DATA_7BIT) char_size == 3'b010;
    if(data_len_type == DATA_8BIT) char_size == 3'b011;
    if(data_len_type == DATA_RESERVED_0) char_size == 3'b100;
    if(data_len_type == DATA_RESERVED_1) char_size == 3'b101;
    if(data_len_type == DATA_RESERVED_2) char_size == 3'b110;
    if(data_len_type == DATA_9BIT) char_size == 3'b111;
  }
  constraint c_stop_bit {
    if(stop_bit_mode_type == STOP_BIT_1) stop_bit_mode == 0;
    if(stop_bit_mode_type == STOP_BIT_2) stop_bit_mode == 1;
  }
  constraint c_mpcm_mode {
    if(mpcm_mode_type == MPCM_DISABLE) mpcm_bit == 0;
    if(mpcm_mode_type == MPCM_ENABLE) mpcm_bit == 1;
  }
  constraint c_clock_polarity{
    if(clock_polatiry_type == RISING_FALLING) clock_polatiry_mode == 0;
    if(clock_polatiry_type == FALLING_RISING) clock_polatiry_mode == 1;
  }
  constraint c_sync_mode {
    if(sync_mode == SLAVE_MODE) sync_mode == 0;
    if(sync_mode == MASTER_MODE) sync_mode == 1;
  }
  // CONSTRUCTOR HERE!!!!!!!!
  function new();
    // calc_tx_frame_size;
    // show_frame;
    // $display("[%t][INSTN] CREATE FRAME INSTANCE",$time);
  endfunction : new
  
  function post_randomize(logic mpcm_frame_type);

    case (data_len_type) 
          DATA_5BIT:      rx_bits_num = 5;
          DATA_6BIT:      rx_bits_num = 6;
          DATA_7BIT:      rx_bits_num = 7;
          DATA_8BIT:      rx_bits_num = 8;
          DATA_RESERVED_0:rx_bits_num = 0;
          DATA_RESERVED_1:rx_bits_num = 0;
          DATA_RESERVED_2:rx_bits_num = 0;
          DATA_9BIT:      rx_bits_num = 9;
    endcase // data_len_type
    if (mpcm_mode_type == MPCM_ENABLE) begin
      rx_bits_num--; 
    end
    mpcm_bit = mpcm_frame_type;

  endfunction : post_randomize

  task calc_tx_frame_size();
      begin
        case (data_len_type) 
          DATA_5BIT:        frame_size = 5;
          DATA_6BIT:        frame_size = 6;
          DATA_7BIT:        frame_size = 7;
          DATA_8BIT:        frame_size = 8;
          DATA_RESERVED_0:  frame_size = 0;
          DATA_RESERVED_1:  frame_size = 0;
          DATA_RESERVED_2:  frame_size = 0;
          DATA_9BIT:        frame_size = 9;
        endcase // data_len_type
        // $display("[%t][INFO] USART FRAME SIZE [%d]\n",$time, frame_size);
        case(parity_mode_type)
          PARITY_ENABLE_EVEN: frame_size = frame_size + 1;
          PARITY_ENABLE_ODD:  frame_size = frame_size + 1;
        endcase // parity_mode_type
        // $display("[%t][INFO] USART FRAME SIZE [%d]\n",$time, frame_size);
        case(stop_bit_mode_type)
          STOP_BIT_1: frame_size = frame_size + 1;
          STOP_BIT_2: frame_size = frame_size + 2;
        endcase // stop_bit_mode_type
        // $display("[%t][INFO] USART FRAME SIZE [%d]\n",$time, frame_size);
        frame_size++;
        // $display("[%t][INFO] USART FRAME SIZE [%d]\n",$time, frame_size);
      end
  endtask: calc_tx_frame_size

  function show_frame();
    $display("[%t][UART_FRAME_BODY]",$time);  
    case(data_len_type)
      DATA_5BIT:        $display("[\t\t\t]DATA_5BIT");
      DATA_6BIT:        $display("[\t\t\t]DATA_6BIT");
      DATA_7BIT:        $display("[\t\t\t]DATA_7BIT");
      DATA_8BIT:        $display("[\t\t\t]DATA_8BIT");
      DATA_RESERVED_0:  $display("[\t\t\t]DATA_RESERVED_0");
      DATA_RESERVED_1:  $display("[\t\t\t]DATA_RESERVED_1");
      DATA_RESERVED_2:  $display("[\t\t\t]DATA_RESERVED_2");
      DATA_9BIT:        $display("[\t\t\t]DATA_9BIT");
    endcase // data_len_type

    case(parity_mode_type)
      PARITY_DISABLE_0:     $display("[\t\t\t]PARITY_DISABLE_0");
      PARITY_DISABLE_1:     $display("[\t\t\t]PARITY_DISABLE_1");
      PARITY_ENABLE_EVEN:   $display("[\t\t\t]PARITY_ENABLE_EVEN");  
      PARITY_ENABLE_ODD:    $display("[\t\t\t]PARITY_ENABLE_ODD");  
    endcase // parity_mode_type

    case(stop_bit_mode_type)
      STOP_BIT_1:   $display("[\t\t\t]STOP_BIT_1");   
      STOP_BIT_2:   $display("[\t\t\t]STOP_BIT_2");
    endcase // stop_bit_mode_type

    case(mpcm_mode_type)
      MPCM_DISABLE: $display("[\t\t\t]MPCM_DISABLE");
      MPCM_ENABLE:  $display("[\t\t\t]MPCM_ENABLE");
    endcase // mpcm_mode_type

    case(speed_mode_type)
      SINGLE_SPEED: $display("[\t\t\t]SINGLE_SPEED");
      DOUBLE_SPEED: $display("[\t\t\t]DOUBLE_SPEED");
    endcase // speed_mode_type

    case(async_sync_type)
      ASYNC_OPERATION: $display("[\t\t\t]ASYNC_OPERATION");
      SYNC_OPERATION:  $display("[\t\t\t]SYNC_OPERATION");
    endcase // async_sync_type

    case(clock_polatiry_type)
      RISING_FALLING:  $display("[\t\t\t]RISING_FALLING EDGE");
      FALLING_RISING:  $display("[\t\t\t]FALLING_RISING EDGE");
    endcase // clock_polatiry_type

    case(sync_mode_type)
      SLAVE_MODE:    $display("[\t\t\t]SLAVE_MODE");
      MASTER_MODE:   $display("[\t\t\t]MASTER_MODE");    
    endcase // sync_mode_type
    case(uart_op_mode_type)
      INIT:     $display("[\t\t\t]INIT");  
      TRANSMIT: $display("[\t\t\t]TRANSMIT");
      RECEIVE:  $display("[\t\t\t]RECEIVE");
      DUPLEX:   $display("[\t\t\t]DUPLEX");
    endcase // uart_op_mode_type
  endfunction : show_frame
endclass : uart_frame

`endif // __UART_TRANSACTION__

`ifndef __UART_DRIVER__
`define __UART_DRIVER__

class uart_driver;

  virtual bus_interface.drvport   bus_drv_port;
  virtual uart_interface.drvport  uart_drv_port;
  virtual dut_interface           dut_port;

  // create mailbox and semaphore 
  // for interprocess communication
  mailbox #(base_uart_transaction)  trn_mb;
  semaphore trn_done;

  base_uart_transaction trn; 

  uart_frame   frm;

  function new (  mailbox #(base_uart_transaction) trn_mb,
                  semaphore trn_done,
                  virtual bus_interface.drvport   bus_drv_port,
                  virtual uart_interface.drvport  uart_drv_port,
                  virtual dut_interface           dut_port
                );
    $display("[%t][INFO] Driver constructor start",$time());
    this.bus_drv_port   = bus_drv_port;
    this.uart_drv_port  = uart_drv_port;
    this.trn_mb     = trn_mb;
    this.trn_done     = trn_done;
    this.dut_port     = dut_port;

    // Init UART and BUS interface
    bus_drv_port.write_enable   = 0;
    bus_drv_port.address        = 0;
    bus_drv_port.data_in        = 0;

    uart_drv_port.rx        = 1;
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

      if ($cast(frm, trn)) begin
        case(frm.uart_op_mode_type)
          INIT:
            begin
              frm.show_frame;
              $display("[%t][INFO] UART INIT TASK",$time());
              uart_init(frm);
            end
          TRANSMIT:
            begin
              frm.show_frame;
              $display("[%t][INFO] UART TX FRAME TASK",$time());
              uart_tx_frame(frm);
            end
          RECEIVE:
            begin
              frm.show_frame;
              $display("[%t][INFO] UART RX FRAME TASK",$time());
              uart_rx_frame(frm);
            end
          DUPLEX:
            begin
              frm.show_frame;
              $display("[%t][INFO] UART FULL DUPLEX TASK",$time());
              uart_duplex_operation(frm);
            end
        endcase // uart_op_mode_type
        $display("[%t][INFO] UART TASK END",$time);
        $display("=============================================");
      end 
      else begin
          $display("[%t][SPI_DRV][SIM_ERR] Unknown Transaction in Driver. TypeName: %s",
            $time(),$typename(trn));
        end
      trn_done.put();
    end
  endtask : run_driver

  task wait_task(uart_frame frm);
    int multiplier = (frm.async_sync_mode) ? ( 1  ) : ((frm.speed_mode) ? 8 : 16);
    int baud       = (frm.baud_rate + 1) * multiplier;
    // $display("[%t][INFO] Baud_rate: [%d]  Multiplier: [%d] Baud: [%d]",$time(),
                        // frm.baud_rate,multiplier,baud);

    repeat (baud) begin 
      @(negedge dut_port.clk); 
    end
    // $display("[%t][INFO] End time",$time);
  endtask : wait_task
  // Drive UART frame for receive
  task uart_init(uart_frame frm);
    
    while (!dut_port.rst_n) #1;
    uart_drv_port.ddr_xck = frm.sync_mode;
    @(negedge dut_port.clk);
    bus_drv_port.write_enable = 1;

    bus_drv_port.address = `UBRRH_UCSRC_ADDR;
    bus_drv_port.data_in = {1'b0, 3'b0, frm.baud_rate[11:8]};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UBRRL_ADDR;
    bus_drv_port.data_in = frm.baud_rate[7:0];
    @(negedge dut_port.clk);
    bus_drv_port.address = `UCSRA_ADDR;
    bus_drv_port.data_in = {6'b000000, frm.speed_mode, frm.mpcm_bit};
    @(negedge dut_port.clk);
    bus_drv_port.address = `UBRRH_UCSRC_ADDR;
    bus_drv_port.data_in = {1'b1, frm.async_sync_mode , frm.parity_mode,
                  frm.stop_bit_mode, frm.char_size[1:0],
                  frm.clock_polatiry_mode};
  endtask : uart_init

  task uart_tx_frame(uart_frame frm);

    uart_init(frm);
    bus_drv_port.write_enable = 1;
    @(negedge dut_port.clk);
    bus_drv_port.address = `UCSRB_ADDR;
    bus_drv_port.data_in = {3'b0, 2'b01, frm.char_size[2], 1'b0, frm.tx_data[8]};
    @(negedge dut_port.clk);

    bus_drv_port.address = `UDR_ADDR;
    bus_drv_port.data_in = frm.tx_data[7:0];
    @(negedge dut_port.clk);
    bus_drv_port.address = 0;
    bus_drv_port.write_enable = 0;
    // $display("[%t][INFO] Number of repeats: [%d]",$time, frm.frame_size);
    // frm.show_frame;
    repeat(frm.frame_size) begin
      wait_task(frm);
      // $display("[%t]WOW",$time);
    end

  endtask : uart_tx_frame

  task uart_rx_frame(uart_frame frm);
    
    uart_init(frm);
    bus_drv_port.write_enable = 1;
    @(negedge dut_port.clk);

    bus_drv_port.address = `UCSRB_ADDR;
    bus_drv_port.data_in = {3'b0, 2'b10, frm.char_size[2], 1'b0, 1'b0};  
    @(negedge dut_port.clk);
    bus_drv_port.address = 0;
    bus_drv_port.write_enable = 0;

    wait_task(frm);
    uart_drv_port.rx      = 0;
    for (int i = 0; i < frm.rx_bits_num; i++) begin
      wait_task(frm);
      uart_drv_port.rx  = frm.rx_data[i];
    end
    if (frm.mpcm_mode_type == MPCM_ENABLE) begin
      wait_task(frm);
      uart_drv_port.rx  = frm.mpcm_bit;
      if(frm.parity_mode_type == PARITY_ENABLE_EVEN | frm.parity_mode_type == PARITY_ENABLE_ODD) begin
        wait_task(frm);
        uart_drv_port.rx  = frm.parity_bit;
      end
    end else begin
      if(frm.parity_mode_type == PARITY_ENABLE_EVEN | frm.parity_mode_type == PARITY_ENABLE_ODD) begin
        wait_task(frm);
        uart_drv_port.rx  = frm.parity_bit;
      end
    end
    wait_task(frm);
    uart_drv_port.rx  = 1'b1;   // stop bit
    wait_task(frm);

  endtask : uart_rx_frame

  task uart_duplex_operation(uart_frame frm);
    // there is a bug here, only receive will work 
    uart_init(frm);
    bus_drv_port.write_enable = 1;
    @(negedge dut_port.clk);

    bus_drv_port.address = `UCSRB_ADDR;
    bus_drv_port.data_in = {3'b0, 2'b11, frm.char_size[2], 1'b0, 1'b0};  
    @(negedge dut_port.clk);

    bus_drv_port.address = `UDR_ADDR;
    bus_drv_port.data_in = frm.tx_data[7:0];
    @(negedge dut_port.clk);
    bus_drv_port.write_enable = 0;

    wait_task(frm);
    uart_drv_port.rx      = 0;
    for (int i = 0; i < frm.rx_bits_num; i++) begin
      wait_task(frm);
      uart_drv_port.rx  = frm.rx_data[i];
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
    uart_drv_port.rx  = 1'b1;   // stop bit
    wait_task(frm);

  endtask : uart_duplex_operation

endclass : uart_driver

`endif // __UART_DRIVER__

`ifndef __UART_TRANSACTOR__
`define __UART_TRANSACTOR__

class uart_transactor;
  virtual bus_interface       bus_if;
  virtual uart_interface      uart_if;
  virtual dut_interface       dut_if;

  mailbox #(base_uart_transaction) trn_mb;
  semaphore trn_done;

  uart_driver uart_drv;

  uart_frame   frm;

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

  task uart_operation(uart_frame_items items);
    $display("[%t][UART] UART RUN",$time());
    frm = new();
    assert(frm.randomize() with {
      this.data_len_type        == items.data_len_type;
      this.parity_mode_type     == items.parity_mode_type;
      this.stop_bit_mode_type   == items.stop_bit_mode_type;
      this.mpcm_mode_type       == items.mpcm_mode_type;
      this.speed_mode_type      == items.speed_mode_type;
      this.async_sync_type      == items.async_sync_type;
      this.clock_polatiry_type  == items.clock_polatiry_type;
      this.sync_mode_type       == items.sync_mode_type;
      this.uart_op_mode_type    == items.uart_op_mode_type;
      });
    frm.calc_tx_frame_size;
    $display("[%t][INFO] SEND FRAME TO DRIVER",$time());
    $write("[%t][UART] UART Operation mode: [%d]\n",$time(),frm.uart_op_mode_type);
    trn_mb.put(frm);
    trn_done.get();
  endtask : uart_operation

endclass : uart_transactor


`endif // __UART_TRANSACTOR__

// `ifndef __UART_MONITOR__
// `define __UART_MONITOR__

// class  uart_mon_frame extends base_uart_transaction;
//   logic   [7:0]   uscra;
//   logic   [7:0]   uscrb;
//   logic   [7:0]   uscrc;
//   logic   [11:0]  ubrr;
//   logic   [7:0]   tx_udr;
//   logic   [10:0]  tx_data;
//   logic   [7:0]   rx_udr;
//   logic   [10:0]  rx_data;  

//   function new();
  
//   endfunction : new
  
// class uart_monitor;

//   virtual uart_interface.monport uart_mon_port;
//   virtual bus_interface.monport  bus_mon_port;
//   virtual dut_interface          dut_port;

//   mailbox   #(base_uart_transaction) trn_mb;

//   uart_mon_frame  frm;

//   function new( virtual uart_interface.monport uart_mon_port,
//                 virtual bus_interface.monport  bus_mon_port,
//                 virtual dut_interface          dut_port,
//                 mailbox #(base_uart_transaction) trn_mb
//                 );
//     this.uart_mon_port  = uart_mon_port;
//     this.bus_mon_port   = bus_mon_port;
//     this.dut_port       = dub_port;
//     this.trn_mb         = trn_mb;
//     // run monitor
//     fork
//       this.run_monitor();
//     join_none
//   endfunction : new

//   task run_monitor();
//     // fork 
//       frame_processing();
//     // join_none
//   endtask : run_monitor

//   task frame_processing();
//     frm = new();
//     forever begin
//       @(posedge bus_mon_port.write_enable);
//       while (bus_mon_port.write_enable===1'b1) 
//         begin
//           case(bus_mon_port.address)
//             UCSRA_ADDR:
//                       begin
//                         frm.uscra = bus_mon_port.data_in; 
//                       end      
//             UCSRB_ADDR:
//                       begin
//                         frm.uscrb = bus_mon_port.data_in;
//                       end      
//             UBRRH_UCSRC_ADDR:
//                       begin
//                         if(bus_mon_port.data_in[7]===1'b1)
//                           frm.uscrc = bus_mon_port.data_in;
//                         if(bus_drv_port.data_in[7]===1'b0) 
//                           frm.ubrr[11:8] = bus_mon_port.data_in[3:0];
//                       end
//             UBRRL_ADDR:
//                       begin
//                         frm.ubrr[7:0] = bus_mon_port.data_in;
//                       end      
//             UDR_ADDR:
//                       begin
//                         frm.tx_udr = bus_mon_port.data_in;
//                       end   
//           endcase // bus_drv_port.address   
//           @(posedge dut_port.clk);
//         end  
//       tx_processing(frm);
//       $write("[%t][MON] UART Frame received, Data[%2d]: ",$time(),frm.tx_data);
//       trn_mb.put(frm);
//     end  
//   endtask : frame_processing

//   task tx_processing(uart_mon_frame frm);
    
//     int multiplier  = (frm.uscrc[6]) ? ( 1  ) : ((frm.uscra) ? 8 : 16);
//     int baud        = (frm.ubrr + 1) * multiplier;
//     int num_of_bits = 0;

//       case({uscrb[2], uscrc[2:1]})
//         3'b000: num_of_bits = 5;
//         3'b001: num_of_bits = 6;
//         3'b010: num_of_bits = 7;
//         3'b011: num_of_bits = 8;
//         3'b111: num_of_bits = 9;
//       endcase // {uscrb[2], uscrc[2:1]}

//       case (uscrc[5:4])
//         2'b10:  num_of_bits++;
//         2'b11:  num_of_bits++;
//       endcase // uscrc[5:4]
//       num_of_bits++; // add stop bit

//       @(negedge uart_mon_port.tx);

//       repeat(baud/2) @(negedge dut_port.clk);

//       if (uart_mon_port.tx === 0) begin
//           for (int i = 0; i<num_of_bits; i++) begin 
//             repeat(baud) @(negedge dut_port.clk);

//             frm.tx_data = frm.tx_data << 1;
//             frm.tx_data[0] = uart_mon_port.tx;
//           end
//       end

//   endtask : tx_processing
  
// endclass : uart_monitor

// `endif // __UART_MONITOR__

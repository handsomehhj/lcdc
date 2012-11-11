// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : uart_top.v
// Author   : Handsome Huang
// Abstract : UART function implementation
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/08    Handsome     New creation
//
// =========================================================================
module uart_top (
  clk,
  rst_x,

  empty, 
  
  rdreq, rdack,
  raddr, 
  rdata,

  sout
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         empty;           // High  FIFO empty flag
  
  output        rdreq;           // High  FIFO read request
  input         rdack;           // High  FIFO read acknowledge
  output [10:0] raddr;           //       FIFO read address
  input  [17:0] rdata;           //       FIFO read data

  output        sout;            //       Serial output
//==========================================================================
//     Wires & Regs
//==========================================================================
  wire        uart_req;
  wire        uart_ack;
  wire [17:0] uart_dat;

  wire        uart_tm_en;
  wire        uart_tm_ov;

//==========================================================================
//      Logic description
//==========================================================================
  uart_if A_UART_IF (
    .clk          ( clk            ),
    .rst_x        ( rst_x          ),

    .empty        ( empty          ), 
  
    .rdreq        ( rdreq          ), 
    .rdack        ( rdack          ),
    .raddr        ( raddr[10:0]    ), 
    .rdata        ( rdata[17:0]    ),

    .uart_req     ( uart_req       ), 
    .uart_ack     ( uart_ack       ),
    .uart_dat     ( uart_dat[17:0] )
  );

  uart_timer A_UART_TIMER (
    .clk          ( clk            ),
    .rst_x        ( rst_x          ),

    .uart_tm_en   ( uart_tm_en     ),
    .uart_tm_ov   ( uart_tm_ov     )
  );

  uart_transfer A_UART_TRANSFER (
    .clk          ( clk            ),
    .rst_x        ( rst_x          ),

    .uart_tm_ov   ( uart_tm_ov     ),
    .uart_tm_en   ( uart_tm_en     ),

    .uart_req     ( uart_req       ), 
    .uart_ack     ( uart_ack       ),
    .uart_dat     ( uart_dat[17:0] ),

    .uart_sout    ( sout           ) 
  );




endmodule

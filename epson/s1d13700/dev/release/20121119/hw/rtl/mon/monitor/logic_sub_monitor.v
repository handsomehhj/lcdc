// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : logic_sub_monitor.v
// Author   : Handsome Huang
// Abstract : Host monitor logic sub module
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/06    Handsome     New creation
//
// =========================================================================
//   logic_sub_monitor
//       |
//       +-- host_if
//       +-- fifo
//       +-- uart_top
//
// ==========================================================================
module logic_sub_monitor (
  clk,
  rst_x,

  ce_x,
  a0,
  wr_x, rd_x,
  dat,

  ram_ce,
  ram_we,
  ram_addr,
  ram_wdata, ram_rdata,
  
  sout
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         clk;             //       System clock
  input         rst_x;           // Low   Reset, active low

  input         ce_x;            // Low   Chip select
  input         a0;              //       A0 address
  input         wr_x;            // Low   Write strobe
  input         rd_x;            // Low   Read strobe
  input  [7:0]  dat;             //       Data bus

  output        ram_ce;          // Low   RAM chip select
  output        ram_we;          // Low   RAM write enable
  output [10:0] ram_addr;        //       RAM address
  output [17:0] ram_wdata;       //       RAM write data
  input  [17:0] ram_rdata;       //       RAM read data

  output        sout;            //       Serial output
//====================================================================
//      Wires
//====================================================================
  wire        wrreq, wrack;
  wire [10:0] waddr;
  wire [17:0] wdata;

  wire        rdreq, rdack;
  wire [10:0] raddr;
  wire [17:0] rdata;

  wire        empty;
  wire        almost_empty;

//=============================================================================
//      Sub-module Connection
//=============================================================================
  host_if A_HOST_IF (
    .clk         ( clk              ),
    .rst_x       ( rst_x            ),

    .ce_x        ( ce_x             ),
    .a0          ( a0               ),
    .wr_x        ( wr_x             ),
    .rd_x        ( rd_x             ),
    .dat         ( dat[7:0]         ),

    .wrreq       ( wrreq            ), 
    .wrack       ( wrack            ),
    .waddr       ( waddr[10:0]      ),
    .wdata       ( wdata[17:0]      )
  );
  
  fifo A_FIFO (
    .clk          ( clk              ),
    .rst_x        ( rst_x            ),

    .rdreq        ( rdreq            ),
    .rdack        ( rdack            ),
    .raddr        ( raddr[10:0]      ),
    .rdata        ( rdata[17:0]      ),

    .wrreq        ( wrreq            ),
    .wrack        ( wrack            ),
    .waddr        ( waddr[10:0]      ),
    .wdata        ( wdata[17:0]      ),

    .ram_ce       ( ram_ce           ),
    .ram_we       ( ram_we           ),
    .ram_addr     ( ram_addr[10:0]   ),
    .ram_wdata    ( ram_wdata[17:0]  ),
    .ram_rdata    ( ram_rdata[17:0]  ),

    .empty        ( empty            ), 
    .full         (                  )
  );

  uart_top A_UART_TOP (
    .clk          ( clk              ),
    .rst_x        ( rst_x            ),

    .empty        ( empty            ), 
  
    .rdreq        ( rdreq            ), 
    .rdack        ( rdack            ),
    .raddr        ( raddr[10:0]      ), 
    .rdata        ( rdata[17:0]      ),
    
    .sout         ( sout             )
  );
  

endmodule // logic_sub_monitor


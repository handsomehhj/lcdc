// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
//
// File     : logic_top_monitor.v
// Author   : Handsome Huang
// Abstract : Host monitor logic top module
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/05    Handsome     New creation
//
// =========================================================================
//   logic_top_monitor 
//       |
//       +-- logic_sub_monitor
//       +-- ram_6kbx8
// ==========================================================================
module logic_top_monitor (
  rst_x,
  clk,

  ce_x,
  a0,
  wr_x, rd_x,
  dat,

  sout
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset
  input         clk;             //       Clock

  input         ce_x;            // Low   Chip select
  input         a0;              //       A0 address
  input         wr_x;            // Low   Write strobe
  input         rd_x;            // Low   Read strobe
  input  [7:0]  dat;             //       Data bus

  output        sout;            //       Serial data output
//=========================================================================
//      Wires
//=========================================================================
  wire         ram_ce;
  wire         ram_we;
  wire [10:0]  ram_addr;
  wire [17:0]  ram_wdata;
  wire [17:0]  ram_rdata;

//=========================================================================
//      Logic Sub
//=========================================================================
  logic_sub_monitor A_LOGIC_SUB_MONITOR (
    .clk         ( clk             ),
    .rst_x       ( rst_x           ),

    .ce_x        ( ce_x            ),
    .a0          ( a0              ),
    .wr_x        ( wr_x            ),
    .rd_x        ( rd_x            ),
    .dat         ( dat[7:0]        ),

    .ram_ce      ( ram_ce          ),
    .ram_we      ( ram_we          ),
    .ram_addr    ( ram_addr[10:0]  ),
    .ram_wdata   ( ram_wdata[17:0] ), 
    .ram_rdata   ( ram_rdata[17:0] ),

    .sout        ( sout            )
  );

//================================================================
//     RAM
//================================================================
  ram_2kbx18 A_RAM_2KBX18 (
    .clk         ( clk             ),
    .rst_x       ( rst_x           ),

    .ce          ( ram_ce          ), 
    .we          ( ram_we          ), 
    .addr        ( ram_addr[10:0]  ),

    .di          ( ram_wdata[17:0] ), 
    .do          ( ram_rdata[17:0] )
  );

endmodule // logic_top_monitor



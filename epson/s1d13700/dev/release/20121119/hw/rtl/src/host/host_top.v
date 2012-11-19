// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : host_top.v
// Author   : Handsome Huang
// Abstract : Host function implementation
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/10/21    Handsome     New creation
//
// =========================================================================
module host_top (
  clk,
  rst_x,

  ce_x,
  a0,
  wr_x,
  dat,
  
  reg_tcr,
  tst
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         ce_x;            // Low   Chip select
  input         a0;              //       A0 address
  input         wr_x;            //       Write strobe
  input  [7:0]  dat;             //       Data bus

  output [7:0]  reg_tcr;         //       Total Character Bytes per Row
  output [3:0]  tst;

//==========================================================================
//     Wires & Regs
//==========================================================================
  wire        reg_0x00_ce;
  wire        reg_0x01_ce;
  wire        reg_0x02_ce;
  wire        reg_0x03_ce;
  wire        reg_0x04_ce;
  wire        reg_0x05_ce;
  wire        reg_0x06_ce;
  wire        reg_0x07_ce;

  wire        reg_wrreq;
  wire [7:0]  reg_wdata;

//==========================================================================
//      Logic description
//==========================================================================

  host_if A_HOST_IF (
    .clk         ( clk            ),
    .rst_x       ( rst_x          ),

    .ce_x        ( ce_x           ),
    .a0          ( a0             ),
    .wr_x        ( wr_x           ),
    .dat         ( dat[7:0]       ),

    .reg_0x00_ce ( reg_0x00_ce    ), 
    .reg_0x01_ce ( reg_0x01_ce    ), 
    .reg_0x02_ce ( reg_0x02_ce    ), 
    .reg_0x03_ce ( reg_0x03_ce    ),
    .reg_0x04_ce ( reg_0x04_ce    ), 
    .reg_0x05_ce ( reg_0x05_ce    ), 
    .reg_0x06_ce ( reg_0x06_ce    ), 
    .reg_0x07_ce ( reg_0x07_ce    ),

    .reg_wrreq   ( reg_wrreq      ),
    .reg_wdata   ( reg_wdata[7:0] ),
    .tst         (                )
  );


  host_reg A_HOST_REG (
    .clk         ( clk            ),
    .rst_x       ( rst_x          ),

    .reg_0x00_ce (), 
    .reg_0x01_ce (), 
    .reg_0x02_ce (), 
    .reg_0x03_ce (),
    .reg_0x04_ce ( reg_0x04_ce    ),
    .reg_0x05_ce (), 
    .reg_0x06_ce (), 
    .reg_0x07_ce (),

    .reg_wrreq   ( reg_wrreq      ),
    .reg_wdata   ( reg_wdata[7:0] ),

    .reg_tcr     ( reg_tcr[7:0]   ),
    .tst         ( tst[3:0]       )

  );


  


endmodule

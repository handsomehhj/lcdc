// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
//
// File     : monitor_top.v
// Author   : Handsome Huang
// Abstract : Host monitor top module
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/05    Handsome     New creation
//
// =========================================================================
module monitor_top (
  P_RST_X, 
  P_MCLKI,

  P_CE_X, P_A0,
  P_WR_X, P_RD_X,
  P_D7, P_D6, P_D5, P_D4,
  P_D3, P_D2, P_D1, P_D0,

  P_FPSHIFT, P_FPLINE, P_FPFRAME,  
  P_SOUT,

  P_TST0, P_TST1, P_TST2
);

//==========================================================================
//      Signals
//==========================================================================
// dir    signal name                   act   description
//------  ---------------------------   ----  ----------------------------
  input   P_RST_X;                    // LOW   Reset, active low   
  input   P_MCLKI;                    //       OSC3 clock input

  input   P_CE_X;                     // LOW   Chip select
  input   P_A0;                       //       Address bus
  input   P_WR_X;                     // LOW   Write strobe
  input   P_RD_X;                     // LOW   Read strobe
  input   P_D7;                       //       D7
  input   P_D6;                       //       D6
  input   P_D5;                       //       D5
  input   P_D4;                       //       D4
  input   P_D3;                       //       D3
  input   P_D2;                       //       D2
  input   P_D1;                       //       D1
  input   P_D0;                       //       D0

  input   P_FPSHIFT;                  //       STN panel shift clock
  input   P_FPLINE;                   // HIGH  STN panel line sync
  input   P_FPFRAME;                  // HIGH  STN panel frame sync

  output  P_SOUT;                     //       Serial output

  output  P_TST0;
  output  P_TST1;
  output  P_TST2;

//====================================================================
//      Regs & Wires
//====================================================================
  wire        rst_x;
  wire        clk;

  wire        ce_x;
  wire        a0;
  wire        wr_x;
  wire        rd_x;
  wire [7:0]  dat;

  wire        stn_fpframe, stn_fpline, stn_fpshift;
  wire        sout;
  
//==========================================================================
//      Logic description
//==========================================================================
  assign rst_x  = P_RST_X;
  assign clk    = P_MCLKI;

// Write bus signal
  assign ce_x     = P_CE_X;
  assign a0       = P_A0;
  assign wr_x     = P_WR_X;
  assign rd_x     = P_RD_X;
 
  assign dat[7:0] = {P_D7, P_D6, P_D5, P_D4, P_D3, P_D2, P_D1, P_D0};

// Input STN panel signal   
  assign stn_fpframe = P_FPFRAME;
  assign stn_fpline  = P_FPLINE;
  assign stn_fpshift = P_FPSHIFT;

// Output serial signal 
  assign P_SOUT  = sout;

  logic_top_monitor A_LOGIC_TOP_MONITOR (
    .rst_x       ( rst_x          ),
    .clk         ( clk            ),

    .ce_x        ( ce_x           ),
    .a0          ( a0             ),
    .wr_x        ( wr_x           ),
    .rd_x        ( rd_x           ),
    .dat         ( dat[7:0]       ),
 
    .sout        ( sout           )
);

  assign P_TST0 = stn_fpframe;
  assign P_TST1 = stn_fpline;  
  assign P_TST2 = stn_fpshift;


endmodule


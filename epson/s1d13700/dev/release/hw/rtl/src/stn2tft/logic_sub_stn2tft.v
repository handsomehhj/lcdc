// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : logic_sub_stn2tft.v
// Author   : Handsome Huang
// Abstract : STN2TFT logic sub module
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/12    Handsome     New creation
//
// =========================================================================
//   logic_sub_stn2tft
//       |
//       +-- cpu_top
//       +-- logic_peri_dps
//
// ==========================================================================
module logic_sub_stn2tft (
  clk,
  rst_x,

  ce_x,
  a0,
  wr_x,
  dat,

  stn_fpframe, stn_fpline, stn_fpshift,
  stn_fpdat,

  tft_vsync, tft_hsync, tft_dotclk, 
  tft_enable,
  tft_r, tft_g, tft_b,

  ram_ce, ram_we,
  ram_addr,
  ram_wdata, ram_rdata,

  tst
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
  input         wr_x;            //       Write strobe
  input  [7:0]  dat;             //       Data bus

  input         stn_fpframe;     // High  STN panel frame
  input         stn_fpline;      // High  STN panel line
  input         stn_fpshift;     //       STN panel shift clock
  input  [3:0]  stn_fpdat;       //       STN panel data
  
  output        tft_vsync;       // Low   TFT panel VSYNC
  output        tft_hsync;       // Low   TFT panel HSYNC
  output        tft_dotclk;      //       TFT panel dot clock 
  output        tft_enable;      // High  TFT panel enable
  output [5:0]  tft_r;           //       TFT panel R data
  output [5:0]  tft_g;           //       TFT panel G data
  output [5:0]  tft_b;           //       TFT panel B data

  output        ram_ce;          // High  RAM chip select
  output        ram_we;          // High  RAM write enable
  output [12:0] ram_addr;        //       RAM address
  output [7:0]  ram_wdata;       //       RAM write data
  input  [7:0]  ram_rdata;       //       RAM read data

  output [3:0]  tst;

//====================================================================
//      Wires
//====================================================================
  wire        fifo_rdreq, fifo_rdack;
  wire        fifo_wrreq, fifo_wrack;
  wire [12:0] fifo_raddr;
  wire [12:0] fifo_waddr;
  wire [7:0]  fifo_rdata;
  wire [7:0]  fifo_wdata;

  wire        stn_tst;
  wire [1:0]  fifo_tst;
  wire [3:0]  host_tst;

  wire [7:0]  reg_tcr;

//=============================================================================
//      Sub-module Connection
//=============================================================================

  host_top A_HOST (
    .clk         ( clk              ),
    .rst_x       ( rst_x            ),

    .ce_x        ( ce_x             ),
    .a0          ( a0               ),
    .wr_x        ( wr_x             ),
    .dat         ( dat[7:0]         ),

    .reg_tcr     ( reg_tcr[7:0]     ),
    .tst         ( host_tst[3:0]    )

  );

  
  stn_td A_STN_TD (
    .clk         ( clk              ),
    .rst_x       ( rst_x            ),

    .stn_fpframe ( stn_fpframe      ),
    .stn_fpline  ( stn_fpline       ), 
    .stn_fpshift ( stn_fpshift      ),
    .stn_fpdat   ( stn_fpdat[3:0]   ),

    .fifo_wrreq  ( fifo_wrreq       ), 
    .fifo_wrack  ( fifo_wrack       ),
    .fifo_waddr  ( fifo_waddr[12:0] ),
    .fifo_wdata  ( fifo_wdata[7:0]  ),

    .stn_tst     ( stn_tst          )    
    
  );

  tft_tg A_TFT_TG (
    .clk         ( clk              ),
    .rst_x       ( rst_x            ),

    .reg_tcr     ( reg_tcr[7:0]     ),    

    .stn_fpframe ( stn_fpframe      ),

    .fifo_rdreq  ( fifo_rdreq       ),  
    .fifo_rdack  ( fifo_rdack       ),
    .fifo_raddr  ( fifo_raddr[12:0] ),
    .fifo_rdata  ( fifo_rdata[7:0]  ),

    .tft_vsync   ( tft_vsync        ), 
    .tft_hsync   ( tft_hsync        ),
    .tft_dotclk  ( tft_dotclk       ), 
    .tft_enable  ( tft_enable       ),

    .tft_r       ( tft_r[5:0]       ),
    .tft_g       ( tft_g[5:0]       ),
    .tft_b       ( tft_b[5:0]       )
  );

  fifo A_FIFO (
    .clk         ( clk              ),
    .rst_x       ( rst_x            ),

    .fifo_rdreq  ( fifo_rdreq       ),  
    .fifo_rdack  ( fifo_rdack       ),
    .fifo_raddr  ( fifo_raddr[12:0] ),
    .fifo_rdata  ( fifo_rdata[7:0]  ),

    .fifo_wrreq  ( fifo_wrreq       ),
    .fifo_wrack  ( fifo_wrack       ),
    .fifo_waddr  ( fifo_waddr[12:0] ),
    .fifo_wdata  ( fifo_wdata[7:0]  ),

    .ram_ce      ( ram_ce           ),
    .ram_we      ( ram_we           ),
    .ram_addr    ( ram_addr[12:0]   ),
    .ram_wdata   ( ram_wdata[7:0]   ),
    .ram_rdata   ( ram_rdata[7:0]   ),

    .tst         ( fifo_tst[1:0]    )
  );


  assign tst[0] = host_tst[0];
  assign tst[1] = host_tst[1];
  assign tst[2] = host_tst[2];
  assign tst[3] = host_tst[3];

endmodule // logic_sub_stn2tft


// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
//
// File     : logic_top_stn2tft.v
// Author   : Handsome Huang
// Abstract : STN2TFT logic top module
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/12    Handsome     New creation
//
// =========================================================================
//   logic_top_stn2tft 
//       |
//       +-- logic_sub_stn2tft
//       +-- rom_2kbx32
// ==========================================================================
module logic_top_stn2tft (
  rst_x,
  clk,

  ce_x,
  a0,
  wr_x,
  dat,

  stn_fpframe, stn_fpline, stn_fpshift,
  stn_fpdat,

  tft_vsync, tft_hsync, tft_dotclk, 
  tft_enable,
  tft_r, tft_g, tft_b,

  color_sel,

  tst

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
  input         wr_x;            //       Write strobe
  input  [7:0]  dat;             //       Data bus

  input         stn_fpframe;     // High  STN panel frame
  input         stn_fpline;      // High  STN panel line
  input         stn_fpshift;     //       STN panel shift clock
  input  [3:0]  stn_fpdat;       //       STN panel data

  output        tft_vsync;       // Low   TFT panel vsync
  output        tft_hsync;       // Low   TFT panel hsync
  output        tft_dotclk;      //       TFT panel dot clock
  output        tft_enable;      // High  TFT panel data enable
  output [5:0]  tft_r;           //       TFT panel R data
  output [5:0]  tft_g;           //       TFT panel G data
  output [5:0]  tft_b;           //       TFT panel B data

  input  [2:0]  color_sel;       //       TFT color select

  output [3:0]  tst;

//=========================================================================
//      Wires
//=========================================================================
  wire         ram_ce;
  wire         ram_we;
  wire [12:0]  ram_addr;
  wire [7:0]   ram_wdata;
  wire [7:0]   ram_rdata;

//=========================================================================
//      Logic Sub
//=========================================================================
  logic_sub_stn2tft A_LOGIC_SUB_STN2TFT (
    .clk         ( clk            ),
    .rst_x       ( rst_x          ),

    .ce_x        ( ce_x           ),
    .a0          ( a0             ),
    .wr_x        ( wr_x           ),
    .dat         ( dat[7:0]       ),
    
    .stn_fpframe ( stn_fpframe    ), 
    .stn_fpline  ( stn_fpline     ), 
    .stn_fpshift ( stn_fpshift    ),
    .stn_fpdat   ( stn_fpdat[3:0] ),

    .tft_vsync   ( tft_vsync      ), 
    .tft_hsync   ( tft_hsync      ), 
    .tft_dotclk  ( tft_dotclk     ), 
    .tft_enable  ( tft_enable     ),
    .tft_r       ( tft_r[5:0]     ), 
    .tft_g       ( tft_g[5:0]     ), 
    .tft_b       ( tft_b[5:0]     ),

    .color_sel   ( color_sel[2:0] ),

    .ram_ce      ( ram_ce         ),
    .ram_we      ( ram_we         ),
    .ram_addr    ( ram_addr[12:0] ),
    .ram_wdata   ( ram_wdata[7:0] ), 
    .ram_rdata   ( ram_rdata[7:0] ),

    .tst         ( tst[3:0]       )
  );


  ram_6kbx8 A_RAM_6KBX8 (
    .clk         ( clk            ),
    .rst_x       ( rst_x          ),

    .ce          ( ram_ce         ), 
    .we          ( ram_we         ), 
    .addr        ( ram_addr[12:0] ),

    .di          ( ram_wdata[7:0] ), 
    .do          ( ram_rdata[7:0] )
  );




//================================================================
//     ROM & RAM
//================================================================
/*
  rom_1kbx32 B_ROM (
    .clk  ( clk             ),

    .xcs  ( rom_xcs         ),
    .a    ( rom_addr[9:0]   ),
    .xwe  ( 1'b1            ),
    .xbwe ( 4'b1111         ),

    .d    ( 32'h0000_0000   ),
    .y    ( rom_rdata[31:0] )
  );

 lb_14kbx18 B_LB (
    .clk_a  ( vi_clk               ),
    .xcs_a  ( video_lb_xcs         ),
    .addr_a ( video_lb_addr[13:0]  ),
    .xwe_a  ( video_lb_xwe         ),
    .xbwe_a ( video_lb_xbwe[1:0]   ),
    .di_a   ( video_lb_wdata[19:0] ),
    .do_a   (                      ),

    .clk_b  ( vi_clk               ),
    .xcs_b  ( lcdc_lb_xcs          ),
    .addr_b ( lcdc_lb_addr[13:0]   ),
    .xwe_b  ( lcdc_lb_xwe          ),
    .xbwe_b ( lcdc_lb_xbwe[1:0]    ),
    .di_b   ( 20'h0_0000           ),
    .do_b   ( lcdc_lb_rdata[19:0]  )
  );

*/

endmodule // logic_top_stn2tft


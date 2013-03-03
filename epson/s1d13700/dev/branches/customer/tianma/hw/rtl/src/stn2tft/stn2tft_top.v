// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
//
// File     : stn2tft_top.v
// Author   : Handsome Huang
// Abstract : STN2TFT top module
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/01    Handsome     New creation
//
// =========================================================================
module stn2tft_top (
  P_RST_X, 
  P_MCLKI,

  P_CE_X, P_A0,
  P_WR_X,
  P_D7, P_D6, P_D5, P_D4,
  P_D3, P_D2, P_D1, P_D0,

  P_FPSHIFT, P_FPLINE, P_FPFRAME,
  P_FPDAT3, P_FPDAT2, P_FPDAT1, P_FPDAT0,

  P_DCLK,  
  P_HSYNC, P_VSYNC,
  P_DEN,
  P_R5, P_R4, P_R3, P_R2, P_R1, P_R0,
  P_G5, P_G4, P_G3, P_G2, P_G1, P_G0,
  P_B5, P_B4, P_B3, P_B2, P_B1, P_B0,

  P_RL, P_UD,
  P_COLOR_S0, P_COLOR_S1, P_COLOR_S2,

  P_TST0, P_TST1, P_TST2,

  P_STANDBY
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
  input   P_FPDAT3;                   //       STN panel data bit3
  input   P_FPDAT2;                   //       STN panel data bit2
  input   P_FPDAT1;                   //       STN panel data bit1
  input   P_FPDAT0;                   //       STN panel data bit0

  output  P_DCLK;                     //       TFT panel data clock
  output  P_HSYNC;                    // LOW   TFT panel horizontal sync
  output  P_VSYNC;                    // LOW   TFT panel vertical sync
  output  P_DEN;                      // HIGH  TFT panel data enable

  output  P_R5;                       //       TFT panel R5
  output  P_R4;                       //       TFT panel R4
  output  P_R3;                       //       TFT panel R3
  output  P_R2;                       //       TFT panel R2
  output  P_R1;                       //       TFT panel R1
  output  P_R0;                       //       TFT panel R0

  output  P_G5;                       //       TFT panel G5
  output  P_G4;                       //       TFT panel G4
  output  P_G3;                       //       TFT panel G3
  output  P_G2;                       //       TFT panel G2
  output  P_G1;                       //       TFT panel G1
  output  P_G0;                       //       TFT panel G0
  
  output  P_B5;                       //       TFT panel B5
  output  P_B4;                       //       TFT panel B4
  output  P_B3;                       //       TFT panel B3
  output  P_B2;                       //       TFT panel B2
  output  P_B1;                       //       TFT panel B1
  output  P_B0;                       //       TFT panel B0

  output  P_RL;                       //       RL setting
  output  P_UD;                       //       UD setting

  input   P_COLOR_S0;                 //       Color selecting bit 0
  input   P_COLOR_S1;                 //       Color selecting bit 1
  input   P_COLOR_S2;                 //       Color selecting bit 2

  output  P_TST0;
  output  P_TST1; 
  output  P_TST2;

  output  P_STANDBY;

//====================================================================
//      Regs & Wires
//====================================================================
  wire        rst_x;
  wire        clki;
  wire        clk;

  wire        ce_x;
  wire        a0;
  wire        wr_x;
  wire [7:0]  dat;

  wire        stn_fpframe, stn_fpline, stn_fpshift;
  wire [3:0]  stn_fpdat;

  wire        tft_vsync;
  wire        tft_hsync;
  wire        tft_enable;
  wire        tft_dotclk;
  wire [5:0]  tft_r;
  wire [5:0]  tft_g;
  wire [5:0]  tft_b;

  wire [2:0]  color_sel;
  wire [3:0]  tst;

//==========================================================================
//      Logic description
//==========================================================================
  assign rst_x  = P_RST_X;
  assign clki   = P_MCLKI;

// Write bus signal
  assign ce_x     = P_CE_X;
  assign a0       = P_A0;
  assign wr_x     = P_WR_X;
 
  assign dat[7:0] = {P_D7, P_D6, P_D5, P_D4, P_D3, P_D2, P_D1, P_D0};

// Input STN panel signal   
  assign stn_fpframe = P_FPFRAME;
  assign stn_fpline  = P_FPLINE;
  assign stn_fpshift = P_FPSHIFT;
  assign stn_fpdat[3:0] = {P_FPDAT3, P_FPDAT2, P_FPDAT1, P_FPDAT0};

// Output TFT panel signal 
  assign P_DCLK  = tft_dotclk;
  assign P_HSYNC = tft_hsync;
  assign P_VSYNC = tft_vsync;
  assign P_DEN   = tft_enable;

  assign P_R5 = tft_r[5];
  assign P_R4 = tft_r[4];
  assign P_R3 = tft_r[3];
  assign P_R2 = tft_r[2];
  assign P_R1 = tft_r[1];
  assign P_R0 = tft_r[0];

  assign P_G5 = tft_g[5];
  assign P_G4 = tft_g[4];
  assign P_G3 = tft_g[3];
  assign P_G2 = tft_g[2];
  assign P_G1 = tft_g[1];
  assign P_G0 = tft_g[0];
  
  assign P_B5 = tft_b[5];
  assign P_B4 = tft_b[4];
  assign P_B3 = tft_b[3];
  assign P_B2 = tft_b[2];
  assign P_B1 = tft_b[1];
  assign P_B0 = tft_b[0];

// Color select
  assign color_sel[2:0] = {P_COLOR_S2, P_COLOR_S1, P_COLOR_S0};

  DCM_SP #(.CLKFX_DIVIDE   ( 5      ), 
           .CLKFX_MULTIPLY ( 5      ), 
           .CLK_FEEDBACK   ( "NONE" )) 
  A_DCM_SP (
    .RST      ( ~rst_x ),  
    .CLKIN    ( clki   ),

    .PSEN     ( 1'b0   ), 
    .PSINCDEC ( 1'b0   ),
    .PSCLK    ( 1'b0   ),
    .DSSEN    ( 1'b0   ),

    .CLKFB    (        ),
	.CLK0     (        ),  
    .CLK180   (        ), 
    .CLK270   (        ), 
    .CLK2X    (        ), 
    .CLK2X180 (        ), 
    .CLK90    (        ),
    .CLKDV    (        ), 
    .CLKFX    ( clk    ), 
    .CLKFX180 (        ), 
    
    .LOCKED   (        ), 
    .PSDONE   (        ), 
    .STATUS   (        )
  );


  logic_top_stn2tft A_LOGIC_TOP_STN2TFT (
    .rst_x       ( rst_x          ),
    .clk         ( clk            ),

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
    .tft_enable  ( tft_enable     ),
    .tft_dotclk  ( tft_dotclk     ), 
    .tft_r       ( tft_r[5:0]     ), 
    .tft_g       ( tft_g[5:0]     ), 
    .tft_b       ( tft_b[5:0]     ),

    .color_sel   ( color_sel[2:0] ),

    .tst         ( tst[3:0]       )
);


  assign P_STANDBY = 1'b1;

  assign P_TST0 = tft_vsync; 
  assign P_TST1 = tft_hsync;
  assign P_TST2 = tft_enable;


  assign P_RL = 1'b0;
  assign P_UD = 1'b1;


endmodule

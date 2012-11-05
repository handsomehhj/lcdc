// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : tb_stn2tft_top.v
// Author   : Handsome Huang
// Abstract : STN2TFT test bench (Top level)
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/08    Handsome     New creation
// =========================================================================
`timescale 1ps/1ps

module top;

// =====================================================================
//      Regs
// =====================================================================
  reg         p_mst_sda_r;
  reg         p_mst_scl_r;

  reg         p_slv_sda_r;
  reg         p_slv_scl_r;


// =====================================================================
//      Wires
// =====================================================================
  wire        clk;
  wire        rst_x;

  wire        cs_x;
  wire        a0;
  wire        rd_x, wr_x;
  wire [7:0]  dat;

  wire [7:0]  reg_tcr;


  wire        stn_fpframe;
  wire        stn_fpline;
  wire        stn_fpshift;
  wire [3:0]  stn_fpdat;


  tri         P_MST_SDA;
  tri         P_MST_SCL;

  tri         P_SLV_SDA;
  tri         P_SLV_SCL;
 

//  defparam `FLASH.flash_file = "flash_code.cod";
  
//  assign C17_DOUT[23:0] = `C17.da_out[23:0];

//=====================================================================
//     Logic Description
//=====================================================================
integer cyc_num;  

initial begin
    for (cyc_num = 0; cyc_num < `CYCNUM; cyc_num = cyc_num + 1) #(`CYCLE);
    $display ("" ) ;
    $display ("<<<<<<<<<<<<<<  Time OVER  >>>>>>>>>>>>>");
    $display ("              cycle = %0d", cyc_num);
    $display ("<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>") ;
    $display ("" );
    $finish;
end // initial begin

initial begin
    p_mst_sda_r = 1'b1;
    p_mst_scl_r = 1'b1;

    p_slv_sda_r = 1'b1;
    p_slv_scl_r = 1'b1;
end   

assign (pull0, pull1) P_MST_SDA = p_mst_sda_r;
assign (pull0, pull1) P_MST_SCL = p_mst_scl_r;

assign (pull0, pull1) P_SLV_SDA = p_slv_sda_r;
assign (pull0, pull1) P_SLV_SCL = p_slv_scl_r;


//=====================================================================
//     Sub Module
//=====================================================================     
  clk #(`CYCLE) A_CLK (
    .P_MCLK    ( clk          ), 
    .P_RST_X   ( rst_x        )
  );


  host A_HOST (
    .clk       ( clk          ),

    .cs_x      ( cs_x         ),
    .a0        ( a0           ),
    .rd_x      ( rd_x         ), 
    .wr_x      ( wr_x         ),

    .dat       ( dat[7:0]     )
  );

  host_top A_HOST_TOP (
    .clk         ( clk              ),
    .rst_x       ( rst_x            ),

    .ce_x        ( cs_x             ),
    .a0          ( a0               ),
    .wr_x        ( wr_x             ),
    .dat         ( dat[7:0]         ),

    .reg_tcr     ( reg_tcr[7:0]     )
  );

  stn A_STN (
    .P_CLK     ( clk          ),
    .P_RST_X   ( rst_x        ),

    .P_FPFRAME ( stn_fpframe  ),
    .P_FPLINE  ( stn_fpline   ),
    .P_FPSHIFT ( stn_fpshift  ),

    .P_FPDAT3  ( stn_fpdat[3] ),
    .P_FPDAT2  ( stn_fpdat[2] ),
    .P_FPDAT1  ( stn_fpdat[1] ),
    .P_FPDAT0  ( stn_fpdat[0] ),

    .P_CNF1    ( 1'b0         ),
    .P_CNF0    ( 1'b1         ),

    .reg_tcr   ( reg_tcr[7:0] )
  );

  stn2tft_top A_STN2TFT_TOP (
    .P_MCLKI   ( clk          ),
    .P_RST_X   ( rst_x        ), 

    .P_CE_X    ( cs_x         ), 
    .P_A0      ( a0           ),
    .P_WR_X    ( wr_x         ),

    .P_D7      ( dat[7]       ), 
    .P_D6      ( dat[6]       ), 
    .P_D5      ( dat[5]       ), 
    .P_D4      ( dat[4]       ),
    .P_D3      ( dat[3]       ),
    .P_D2      ( dat[2]       ), 
    .P_D1      ( dat[1]       ), 
    .P_D0      ( dat[0]       ),

    .P_FPSHIFT ( stn_fpshift  ), 
    .P_FPLINE  ( stn_fpline   ), 
    .P_FPFRAME ( stn_fpframe  ),
    .P_FPDAT3  ( stn_fpdat[3] ), 
    .P_FPDAT2  ( stn_fpdat[2] ), 
    .P_FPDAT1  ( stn_fpdat[1] ), 
    .P_FPDAT0  ( stn_fpdat[0] ),

    .P_DCLK    (),
    .P_DEN     (),
    .P_HSYNC   (), 
    .P_VSYNC   (),
    .P_R5      (), 
    .P_R4      (), 
    .P_R3      (), 
    .P_R2      (), 
    .P_R1      (), 
    .P_R0      (),
  





    .P_STANDBY ()
);











glbl glbl();

//=====================================================================
//     Test Pattern
//=====================================================================     

initial begin    
    #(`CYCLE * 100);
    @(posedge clk);
    A_HOST.CMD_WR(8'h40);
    A_HOST.DAT_WR(8'h55);
    A_HOST.DAT_WR(8'h55);
    A_HOST.DAT_WR(8'h55);
    A_HOST.DAT_WR(8'h55);
    A_HOST.DAT_WR(8'h34);
    A_HOST.DAT_WR(8'h55);
    A_HOST.DAT_WR(8'h55);




end




   

//  always @(posedge P_OSC3) begin
//    if (C17_DOUT[23:0] == 24'hc17803) begin
//      $display ("" ) ;
//      $display (" <<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>");
//      $display (" <<<<<<<<<<<<  Finish simulation  >>>>>>>>>>>");
//      $display (" <<<<<<<<<<<<   Detect key-word   >>>>>>>>>>>");
//      $display ("    DOUT = %h",C17_DOUT,  "  cycle = %0d", cyc_num);
//      $display (" %%r0=%h",R0," %%r1=%h",R1," %%r2=%h",R2," %%r3=%h",R3);
//      $display (" %%r4=%h",R4," %%r5=%h",R5," %%r6=%h",R6," %%r7=%h",R7);
//      $display ();      
//      $display (" %%pc=%h",PC," %%sp=%h",SP," CVZN=%b",PSRL," IE=%b",PSRH[4]," IL=%h",PSRH[7:5] );
//      $display (" <<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>" ) ;
//      $display ("" );
//      $finish;
//    end // if (C17_DOUT[23:0] == 24'hc17803)
//  end // always @ (posedge P_OSC3)
   
//`ifdef SVISION
//  initial begin
//    $shm_open("wave");
//    $shm_probe(top, "AC");
//  end
//`endif

`ifdef SSCAN
initial begin
    $recordsetup("design=top","compress");
    $recordvars;
end
`endif

//`ifdef VERDI
//  initial begin
//    $fsdbDumpfile("wave.fsdb");
//    $fsdbDumpvars(0, top);
//  end
//`endif


endmodule

// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : tb_mon_top.v
// Author   : Handsome Huang
// Abstract : Monitor test bench (Top level)
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/07    Handsome     New creation
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

  monitor_top A_MONITOR_TOP (
    .P_MCLKI   ( clk          ),
    .P_RST_X   ( rst_x        ), 

    .P_CE_X    ( cs_x         ), 
    .P_A0      ( a0           ),
    .P_WR_X    ( wr_x         ),
    .P_RD_X    ( 1'b1         ),

    .P_D7      ( dat[7]       ), 
    .P_D6      ( dat[6]       ), 
    .P_D5      ( dat[5]       ), 
    .P_D4      ( dat[4]       ),
    .P_D3      ( dat[3]       ),
    .P_D2      ( dat[2]       ), 
    .P_D1      ( dat[1]       ), 
    .P_D0      ( dat[0]       ),

    .P_SOUT    (              )
);











glbl glbl();

//=====================================================================
//     Test Pattern
//=====================================================================     

initial begin    
    #(`CYCLE * 100);
    @(posedge clk);
    A_HOST.CMD_WR(8'h40);
    A_HOST.DAT_WR(8'h01);
    A_HOST.DAT_WR(8'h02);
    A_HOST.DAT_WR(8'h03);
    A_HOST.DAT_WR(8'h04);
    A_HOST.DAT_WR(8'h48);
    A_HOST.DAT_WR(8'h05);
    A_HOST.DAT_WR(8'h06);

    A_HOST.CMD_WR(8'h42);
    A_HOST.DAT_WR(8'h22);
    A_HOST.DAT_WR(8'h33);
    A_HOST.DAT_WR(8'h44);

    A_HOST.CMD_WR(8'h40);


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

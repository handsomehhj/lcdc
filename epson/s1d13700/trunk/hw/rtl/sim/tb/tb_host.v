// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
//
// File    : tb_host.v
// Author  : Handsome Huang
// Abstract: Host I/F test bench
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/10/07    Handsome     New creation
// =========================================================================

// A.C spec
`define tDh    5000     // Data hold time

module host (
  clk,

  cs_x,
  a0,
  rd_x, wr_x,

  dat
);

//======================================================================
//      Signals
//======================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ------------------------------
  input         clk;             //       Input clock

  output        cs_x;            // Low   Chip select
  output        a0;              //       Address bus
  output        rd_x;            // Low   Read strobe
  output        wr_x;            // Low   Write strobe

  inout  [7:0]  dat;             //       Data bus

//===================================================================
//     Wires and Regs
//===================================================================
  reg         a0_r;
  reg         cs_x_r;
  reg         rd_x_r;
  reg         wr_x_r;
  reg         oe_x_r;

  reg  [7:0]  wdata_r;
//==========================================================
//      Logic description
//==========================================================
  assign a0   = a0_r;
  assign cs_x = cs_x_r;
  assign rd_x = rd_x_r;
  assign wr_x = wr_x_r;

  assign dat[7:0] = oe_x_r ? 8'bz : wdata_r[7:0];
  
//----------------------------------------------------------
//----- Task Start -----------------------------------------
//----------------------------------------------------------
  initial begin
    a0_r         = 1'b0;
    cs_x_r       = 1'b1;
    rd_x_r       = 1'b1;
    wr_x_r       = 1'b1;
    oe_x_r       = 1'b1;
    wdata_r[7:0] = 8'h00;
  end

  task CMD_WR;
    input [7:0] dat;
    begin
      @(posedge clk);
      a0_r         = 1'b1;
      cs_x_r       = 1'b0;
      wr_x_r       = 1'b1;
      wdata_r[7:0] = 8'h00;
      @(posedge clk);
      cs_x_r       = 1'b0;
      wr_x_r       = 1'b0;
      #(`tDh) oe_x_r = 1'b0;
      wdata_r[7:0] = dat[7:0];
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      wr_x_r       = 1'b1;
      #(`tDh) oe_x_r = 1'b1;
      wdata_r[7:0] = 8'h00;
      @(posedge clk);
      cs_x_r       = 1'b1;
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);      
    end
  endtask // CMD_WR

  task DAT_WR;
    input [7:0] dat;
    begin
      @(posedge clk);
      a0_r         = 1'b0;
      cs_x_r       = 1'b0;
      wr_x_r       = 1'b1;
      wdata_r[7:0] = 8'h00;
      @(posedge clk);
      cs_x_r       = 1'b0;
      wr_x_r       = 1'b0;
      #(`tDh) oe_x_r = 1'b0;
      wdata_r[7:0] = dat[7:0];
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      wr_x_r       = 1'b1;
      #(`tDh) oe_x_r = 1'b1;
      wdata_r[7:0] = 8'h00;
      @(posedge clk);
      cs_x_r       = 1'b1;
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
    end
  endtask // CMD_WR

















  
endmodule // i2cm

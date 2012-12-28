// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : host_reg.v
// Author   : Handsome Huang
// Abstract : Host I/F register implementation
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/10/21    Handsome     New creation
//
// =========================================================================
module host_reg (
  clk,
  rst_x,

  reg_0x00_ce, reg_0x01_ce, reg_0x02_ce, reg_0x03_ce,
  reg_0x04_ce, reg_0x05_ce, reg_0x06_ce, reg_0x07_ce,

  reg_wrreq,
  reg_wdata,

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

  input         reg_0x00_ce;     // High  Reg 0x00 chip enable
  input         reg_0x01_ce;     // High  Reg 0x01 chip enable
  input         reg_0x02_ce;     // High  Reg 0x02 chip enable
  input         reg_0x03_ce;     // High  Reg 0x03 chip enable
  
  input         reg_0x04_ce;     // High  Reg 0x04 chip enable
  input         reg_0x05_ce;     // High  Reg 0x05 chip enable
  input         reg_0x06_ce;     // High  Reg 0x06 chip enable
  input         reg_0x07_ce;     // High  Reg 0x07 chip enable
  
  input         reg_wrreq;       // High  Reg write request
  input  [7:0]  reg_wdata;       //       Reg write data

  output [7:0]  reg_tcr;         //       Total Character Bytes per Row
  output [3:0]  tst;

//==========================================================================
//     Wires & Regs
//==========================================================================
  reg  [7:0]  reg_tcr_r;

//==========================================================================
//      Logic description
//==========================================================================
  assign reg_tcr[7:0] = reg_tcr_r[7:0];

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      reg_tcr_r[7:0] <= 8'h00;
    else begin
      if (reg_0x04_ce & reg_wrreq) reg_tcr_r[7:0] <= reg_wdata[7:0];
    end
  end

  assign tst[0] = reg_tcr_r[3];
  assign tst[1] = reg_tcr_r[6];
  assign tst[2] = reg_tcr_r[7];
  assign tst[3] = 1'b0;
  


endmodule

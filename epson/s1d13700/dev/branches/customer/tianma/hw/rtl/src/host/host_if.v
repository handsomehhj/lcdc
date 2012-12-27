// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : host_if.v
// Author   : Handsome Huang
// Abstract : Host I/F
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/10/20    Handsome     New creation
//
// =========================================================================
module host_if (
  clk,
  rst_x,

  ce_x,
  a0,
  wr_x,
  dat,

  reg_0x00_ce, reg_0x01_ce, reg_0x02_ce, reg_0x03_ce,
  reg_0x04_ce, reg_0x05_ce, reg_0x06_ce, reg_0x07_ce,

  reg_wrreq,
  reg_wdata,

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

  output        reg_0x00_ce;     // High  Reg 0x00 chip enable
  output        reg_0x01_ce;     // High  Reg 0x01 chip enable
  output        reg_0x02_ce;     // High  Reg 0x02 chip enable
  output        reg_0x03_ce;     // High  Reg 0x03 chip enable
  
  output        reg_0x04_ce;     // High  Reg 0x04 chip enable
  output        reg_0x05_ce;     // High  Reg 0x05 chip enable
  output        reg_0x06_ce;     // High  Reg 0x06 chip enable
  output        reg_0x07_ce;     // High  Reg 0x07 chip enable
  
  output        reg_wrreq;       // High  Reg write request
  output [7:0]  reg_wdata;       //       Reg write data

  output [3:0]  tst;
  
// =====================================================================
//      Parameters
// =====================================================================
  parameter IDLE   = 2'b00;
  parameter SETUP  = 2'b01;
  parameter HOLD   = 2'b10;

//==========================================================================
//     Wires & Regs
//==========================================================================
  wire [1:0]  bus_sta_i;
  wire        wr_cmd, wr_dat;
  wire        reg_0x00_ce;
  wire        reg_0x01_ce;


  reg  [1:0]  bus_sta_r;
  reg  [7:0]  reg_cmd_r;
  reg  [3:0]  reg_addr_r;

//==========================================================================
//      Logic description
//==========================================================================

  assign tst[0] = wr_cmd;
  assign tst[1] = wr_dat;

  assign tst[2] = reg_0x04_ce;
  assign tst[3] = 1'b0;

// ----- Write State Machine ----------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      bus_sta_r[1:0] <= IDLE;
    else begin
      bus_sta_r[1:0] <= bus_sta_i[1:0];
    end
  end

  // Call function
  assign bus_sta_i[1:0] = fc_bus_sta_i(bus_sta_r[1:0], ce_x, wr_x, 1'b1);

  // Function body
  function[1:0] fc_bus_sta_i;
    input [1:0] fc_bus_sta_r;
    input       fc_ce_x;
    input       fc_wr_x;
    input       fc_rd_x;
    begin
      case (fc_bus_sta_r[1:0]) // synopsys parallel_case
      // ------------------------------------------------------------
        IDLE:   if (~fc_ce_x & ~(fc_wr_x & fc_rd_x))
                  fc_bus_sta_i[1:0] = SETUP;
                else
                  fc_bus_sta_i[1:0] = IDLE;
      // ------------------------------------------------------------
        SETUP:  fc_bus_sta_i[1:0] = HOLD;
      // ------------------------------------------------------------
        HOLD:   if (fc_ce_x | (fc_wr_x & fc_rd_x))
                  fc_bus_sta_i[1:0] = IDLE;
                else
                  fc_bus_sta_i[1:0] = HOLD;
      // ------------------------------------------------------------
        default: fc_bus_sta_i = IDLE;
      endcase
    end
  endfunction
  

// ----- Internal Address Generator ---------------------------------
  assign wr_cmd = (bus_sta_r[1:0] == SETUP) & ~ce_x & ~wr_x & a0;
  assign wr_dat = (bus_sta_r[1:0] == SETUP) & ~ce_x & ~wr_x & ~a0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      reg_cmd_r[7:0] <= 8'h00;
    else begin
      if (wr_cmd) reg_cmd_r[7:0] <= dat[7:0];
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      reg_addr_r[3:0] <= 4'b0000;
    else begin 
      if (wr_cmd)
        reg_addr_r[3:0] <= 4'b0000;
      else if (wr_dat) begin
        reg_addr_r[3:0] <= reg_addr_r[3:0] + 4'b0001;
      end  
    end
  end

// ----- Reg Access Signal Generator --------------------------------
  assign reg_0x00_ce = (reg_cmd_r[7:0] == 8'h40) & (reg_addr_r[3:0] == 4'h0);
  assign reg_0x01_ce = (reg_cmd_r[7:0] == 8'h40) & (reg_addr_r[3:0] == 4'h1);
  

  assign reg_0x04_ce = (reg_cmd_r[7:0] == 8'h40) & (reg_addr_r[3:0] == 4'h4);

  
  assign reg_wrreq = wr_dat;
  assign reg_wdata[7:0] = wr_dat? dat[7:0] : 8'h00; 


endmodule

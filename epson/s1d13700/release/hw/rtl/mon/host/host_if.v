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
// 2012/11/07    Handsome     New creation
//
// =========================================================================
module host_if (
  clk,
  rst_x,

  ce_x,
  a0,
  wr_x, rd_x,
  dat,

  wrreq, wrack,
  waddr,
  wdata
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
  input         wr_x;            // Low   Write strobe
  input         rd_x;            // Low   Read strobe
  input  [7:0]  dat;             //       Data bus

  output        wrreq;           // High  Write request
  input         wrack;           // High  Write acknowledge
  output [10:0] waddr;           //       Write address
  output [17:0] wdata;           //       Write data
    
// =====================================================================
//      Parameters
// =====================================================================
  parameter IDLE  = 2'b00;
  parameter SETUP = 2'b01;
  parameter HOLD  = 2'b10;

  parameter NORW  = 4'b0000; 
  parameter WCMD  = 4'b0001;
  parameter WDAT  = 4'b0010;
  parameter RDAT  = 4'b0011;
  parameter WMEM  = 4'b0100;
  parameter RMEM  = 4'b0101;
  parameter OTHE  = 4'b1111;

//==========================================================================
//     Wires & Regs
//==========================================================================
  wire [1:0]  bus_sta_i;
  wire        wr_cmd, wr_dat, rd_dat;
  wire        wr_mem, rd_mem;
  wire [3:0]  bus_cmd_i;
  wire [10:0] waddr_i;
  wire [13:0] wdata_i;

  reg  [1:0]  bus_sta_r;
  reg  [7:0]  reg_cmd_r;
  reg  [3:0]  bus_cmd_r;

  reg         wrreq_r;
  reg  [10:0] waddr_r;
  reg  [7:0]  wdata_r;
  reg         rwmem_r;
  reg  [13:0] rwmem_cnt_r;

//==========================================================================
//      Logic description
//==========================================================================

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
  

// ----- Internal chip select Generator -----------------------------
  assign wr_cmd = (bus_sta_r[1:0] == SETUP) & ~ce_x & ~wr_x & a0;
  assign wr_dat = (bus_sta_r[1:0] == SETUP) & ~ce_x & ~wr_x & ~a0;
  assign rd_dat = (bus_sta_r[1:0] == SETUP) & ~ce_x & ~rd_x & a0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      reg_cmd_r[7:0] <= 8'h00;
    else begin
      if (wr_cmd) reg_cmd_r[7:0] <= dat[7:0];
    end
  end

  assign wr_mem = (wr_dat & (reg_cmd_r[7:0] == 8'h42))? 1'b1 : 1'b0;
  assign rd_mem = (rd_dat & (reg_cmd_r[7:0] == 8'h43))? 1'b1 : 1'b0;

  function[3:0] fc_bus_cmd;
    input        fc_wr_cmd;
    input        fc_wr_dat;
    input        fc_rd_dat;
    input        fc_wr_mem;
    input        fc_rd_mem;
    begin
      casex ({fc_wr_cmd, fc_wr_dat, fc_rd_dat, fc_wr_mem, fc_rd_mem})
        5'b000_00: fc_bus_cmd[3:0] = NORW;
        5'b000_01: fc_bus_cmd[3:0] = OTHE;
        5'b000_10: fc_bus_cmd[3:0] = OTHE;
        5'b000_11: fc_bus_cmd[3:0] = OTHE;
        5'b001_00: fc_bus_cmd[3:0] = RDAT;
        5'b001_01: fc_bus_cmd[3:0] = RMEM;
        5'b001_10: fc_bus_cmd[3:0] = OTHE;
        5'b001_11: fc_bus_cmd[3:0] = OTHE;
        5'b010_00: fc_bus_cmd[3:0] = WDAT;
        5'b010_01: fc_bus_cmd[3:0] = OTHE;
        5'b010_10: fc_bus_cmd[3:0] = WMEM;        
        5'b010_11: fc_bus_cmd[3:0] = WMEM;
        5'b011_00: fc_bus_cmd[3:0] = WDAT;
        5'b011_01: fc_bus_cmd[3:0] = OTHE;
        5'b011_10: fc_bus_cmd[3:0] = WMEM;
        5'b011_11: fc_bus_cmd[3:0] = WMEM;
        5'b1xx_xx: fc_bus_cmd[3:0] = WCMD;
        default:   fc_bus_cmd[3:0] = NORW;
     endcase
   end
  endfunction

  assign bus_cmd_i[3:0] = fc_bus_cmd(wr_cmd, wr_dat, rd_dat, wr_mem, rd_mem);

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      bus_cmd_r[3:0] <= NORW;
    else begin
      if (wr_cmd | wr_dat | rd_dat) bus_cmd_r[3:0] <= bus_cmd_i[3:0];
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      wdata_r[7:0] <= 8'h00;
    else begin
      if (wr_cmd | wr_dat) 
        wdata_r[7:0] <= dat[7:0];
      else begin
        if (rd_dat) wdata_r[7:0] <= 8'h00;
      end
    end
  end

// ----- Write Request & Address Generator --------------------------
  assign wrreq = wrreq_r;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      wrreq_r <= 1'b0;
    else begin
      if (wrreq_r & wrack) 
        wrreq_r <= 1'b0;
      else begin 
        if (wr_cmd | wr_dat | rd_dat) wrreq_r <= 1'b1;
      end  
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      rwmem_r <= 1'b0;
    else begin
      if (wrreq_r & wrack) begin
        if (bus_cmd_r[3:0] == WCMD) 
          rwmem_r <= 1'b0;
        else if ((bus_cmd_r[3:0] == WMEM) | (bus_cmd_r[3:0] == RMEM))
          rwmem_r <= 1'b1;
      end
    end
  end


  function[10:0] fc_next_addr;
    input [3:0]  fc_bus_cmd;
    input        fc_rwmem_r;
    input [10:0] fc_cur_addr;
    begin
      casex ({fc_bus_cmd[3:0], fc_rwmem_r})
        5'b0000_x: fc_next_addr = fc_cur_addr[10:0];             // NORW
        5'b0001_0: fc_next_addr = fc_cur_addr[10:0] + 11'h001;   // WCMD
        5'b0001_1: fc_next_addr = fc_cur_addr[10:0] + 11'h002;   // WCMD
        5'b0010_x: fc_next_addr = fc_cur_addr[10:0] + 11'h001;   // WDAT
        5'b0011_x: fc_next_addr = fc_cur_addr[10:0] + 11'h001;   // RDAT
        5'b0100_x: fc_next_addr = fc_cur_addr[10:0];             // WMEM
        5'b0101_x: fc_next_addr = fc_cur_addr[10:0];             // RMEM
        default:   fc_next_addr = fc_cur_addr[10:0];             // OTHE
      endcase
    end
  endfunction

  assign waddr_i[10:0] = fc_next_addr(bus_cmd_r[3:0], rwmem_r, waddr_r[10:0]);
  
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      waddr_r[10:0] <= 11'h000;
    else begin
      if (wrreq_r & wrack) waddr_r[10:0] <= waddr_i[10:0];
    end
  end
  
  assign waddr[10:0] = (bus_cmd_r[3:0] == WCMD)
                         ? (waddr_r[10:0] + {10'h000, rwmem_r})
                         : waddr_r[10:0];

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      rwmem_cnt_r[13:0] <= 14'h0000;
    else begin
      if (wrreq_r & wrack) begin
        if ((bus_cmd_r[3:0] == WMEM) | (bus_cmd_r[3:0] == RMEM))
          rwmem_cnt_r[13:0] <= rwmem_cnt_r[13:0] + 14'h0001;
        else
          rwmem_cnt_r[13:0] <= 14'h0000;
      end  
    end
  end
                              
  assign wdata[17:0] = ((bus_cmd_r[3:0] == WMEM) | (bus_cmd_r[3:0] == RMEM))
                         ? {bus_cmd_r[3:0], rwmem_cnt_r[13:0]}
                         : {bus_cmd_r[3:0], 6'h00, wdata_r[7:0]};                         


endmodule


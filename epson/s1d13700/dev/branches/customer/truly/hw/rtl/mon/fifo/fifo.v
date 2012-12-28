// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : fifo.v
// Author   : Handsome Huang
// Abstract : Data FIFO of monitor
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/07    Handsome     New creation
//
// =========================================================================
module fifo (
  clk,
  rst_x,

  rdreq,
  rdack,
  raddr,
  rdata,

  wrreq,
  wrack,
  waddr,
  wdata,

  ram_ce,
  ram_we,
  ram_addr,
  ram_wdata,
  ram_rdata,

  empty, full
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         rdreq;           // High  FIFO read request
  output        rdack;           // High  FIFO read ack
  input  [10:0] raddr;           //       FIFO read address
  output [17:0] rdata;           //       FIFO read data

  input         wrreq;           // High  FIFO write request
  output        wrack;           // High  FIFO write ack
  input  [10:0] waddr;           //       FIFO write address
  input  [17:0] wdata;           //       FIFO write data

  output        ram_ce;          // High  RAM chip select
  output        ram_we;          // High  RAM write enable
  output [10:0] ram_addr;        //       RAM address
  output [17:0] ram_wdata;       //       RAM write data
  input  [17:0] ram_rdata;       //       RAM read data

  output        empty;           // High  FIFO empty flag
  output        full;            // High  FIFO full flag 

//==========================================================================
//      Logic description
//==========================================================================
  assign wrack = wrreq;
  assign rdack = ~wrreq & rdreq;

  assign ram_ce = rdreq | wrreq;
  assign ram_we = wrreq;
  assign ram_addr[10:0] = wrreq ? waddr[10:0] : raddr[10:0];

  assign rdata[17:0]     = ram_rdata[17:0];
  assign ram_wdata[17:0] = wdata[17:0];

  
  assign empty = (raddr[10:0] == waddr[10:0])? 1'b1 : 1'b0;
  assign full  = (raddr[10:0] == (waddr[10:0] + 11'h001))? 1'b1 : 1'b0;   


endmodule


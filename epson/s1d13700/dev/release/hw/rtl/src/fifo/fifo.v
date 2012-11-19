// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : fifo.v
// Author   : Handsome Huang
// Abstract : Data FIFO of stn2tft
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/15    Handsome     New creation
//
// =========================================================================
module fifo (
  clk,
  rst_x,

  fifo_rdreq,
  fifo_rdack,
  fifo_raddr,
  fifo_rdata,

  fifo_wrreq,
  fifo_wrack,
  fifo_waddr,
  fifo_wdata,

  ram_ce,
  ram_we,
  ram_addr,
  ram_wdata,
  ram_rdata,

  tst
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         fifo_rdreq;      // High  FIFO read request
  output        fifo_rdack;      // High  FIFO read ack
  input  [12:0] fifo_raddr;      //       FIFO read address
  output [7:0]  fifo_rdata;      //       FIFO read data

  input         fifo_wrreq;      // High  FIFO write request
  output        fifo_wrack;      // High  FIFO write ack
  input  [12:0] fifo_waddr;      //       FIFO write address
  input  [7:0]  fifo_wdata;      //       FIFO write data

  output        ram_ce;          // High  RAM chip select
  output        ram_we;          // High  RAM write enable
  output [12:0] ram_addr;        //       RAM address
  output [7:0]  ram_wdata;       //       RAM write data
  input  [7:0]  ram_rdata;       //       RAM read data

  output [1:0]  tst;
//==========================================================================
//     Wires & Regs
//==========================================================================
  reg  [7:0]  rdata_r;
  reg         latch_en;

//==========================================================================
//      Logic description
//==========================================================================
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      latch_en <= 1'b0;
    end
    else begin
      latch_en <= fifo_rdreq & fifo_rdack;
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      rdata_r[7:0] <= 8'h0000;
    end
    else begin
      if (latch_en) rdata_r[7:0] <= ram_rdata[7:0];
    end
  end


  assign fifo_rdack = fifo_rdreq;
  assign fifo_wrack = ~fifo_rdreq & fifo_wrreq;

  assign fifo_rdata[7:0] = ram_rdata[7:0];
  assign ram_wdata[7:0] = fifo_wdata[7:0];

  assign ram_ce = fifo_rdreq | fifo_wrreq;
  assign ram_we = ~fifo_rdreq;
  assign ram_addr[12:0] = fifo_rdreq ? fifo_raddr[12:0] : fifo_waddr[12:0];


  assign tst[0] = fifo_rdreq & (fifo_raddr[12:0] == 13'h1270);
  assign tst[1] = fifo_wrreq & fifo_wrack & (fifo_waddr[12:0] == 13'h1270);


endmodule

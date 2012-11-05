// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : tft_td.v
// Author   : Handsome Huang
// Abstract : STN panel timing dector
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/15    Handsome     New creation
//
// =========================================================================
module stn_td (
  clk,
  rst_x,

  stn_fpframe, stn_fpline, 
  stn_fpshift,
  stn_fpdat,

  fifo_wrreq, fifo_wrack,
  fifo_waddr,
  fifo_wdata,

  stn_tst
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         stn_fpframe;     // High  STN panel frame
  input         stn_fpline;      // High  STN panel line 
  input         stn_fpshift;     //       STN panel shift clock
  input  [3:0]  stn_fpdat;       //       STN panel data

  output        fifo_wrreq;      // High  FIFO write request
  input         fifo_wrack;      // High  FIFO write ack
  output [12:0] fifo_waddr;      //       FIFO write address
  output [7:0]  fifo_wdata;      //       FIFO write data

  output        stn_tst;

//==========================================================================
//     Wires & Regs
//==========================================================================
  wire        fpdat_latch_en;
  
  reg  [1:0]  stn_fpshift_r;
  reg         stn_fpline_r;
  reg         latch_cnt_r;

  reg         wrreq_r;
  reg  [12:0] waddr_r; 
  reg  [7:0]  wdata_r;

  reg         stn_tst_r;

//==========================================================================
//      Logic description
//==========================================================================

// ----- Sync STN panel signals -----------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_fpline_r       <= 1'b0;
      stn_fpshift_r[1:0] <= 2'b00;
    end
    else begin
      stn_fpline_r       <= stn_fpline;    
      stn_fpshift_r[1:0] <= {stn_fpshift_r[0], stn_fpshift};
    end
  end

  assign fpdat_latch_en = stn_fpshift_r[1] & (~stn_fpshift_r[0]);

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      latch_cnt_r <= 1'b0;
    end
    else begin
      if (stn_fpframe & stn_fpline_r & fpdat_latch_en) 
        latch_cnt_r <= 1'b0;
      else begin
        if (fpdat_latch_en) latch_cnt_r <= ~latch_cnt_r;
      end
    end
  end  

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      wdata_r[7:0] <= 8'h00;
    end
    else begin
      if (fpdat_latch_en) begin
        if (~latch_cnt_r) wdata_r[7:4] <= stn_fpdat[3:0];
        if (latch_cnt_r)  wdata_r[3:0] <= stn_fpdat[3:0];
      end
    end
  end  

// ----- FIFO write signals ---------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      wrreq_r <= 1'b0;
    end
    else begin
      if (fifo_wrack) 
        wrreq_r <= 1'b0;
      else if (fpdat_latch_en & latch_cnt_r)
        wrreq_r <= 1'b1;
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      waddr_r[12:0] <= 13'h0000;
      stn_tst_r <= 1'b0;
    end
    else begin
      if (wrreq_r & fifo_wrack) begin
        if (stn_fpframe & stn_fpline_r)
            waddr_r[12:0] <= 13'h0028;
        else begin
          if (waddr_r[12:0] == 13'h12bf) waddr_r[12:0] <= 13'h0000;
          else waddr_r[12:0] <= waddr_r[12:0] + 13'h0001;   
        end
      end
    end
  end


  assign fifo_wrreq = wrreq_r;
  assign fifo_waddr[12:0] = waddr_r[12:0];  
  assign fifo_wdata[7:0]  = wdata_r[7:0];
//  assign fifo_wdata[7:0]  = (waddr_r[12:0] == 13'h0000)? 8'h88 : 8'h00;

  assign stn_tst = (waddr_r[12:0] == 13'h1298) ? 1'b1 : 1'b0;

endmodule


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
  wire        fpframe_rst_en;
  wire        fpline_rst_en;
  wire        fpdat_latch_en;
  wire        stn_hcnt_en;

  wire        stn_fifo_en;


  wire        stn_hcnt_start;
  wire        stn_hcnt_end;
  wire        stn_hdp;
 
  wire [6:0]  stn_hcnt_i;
  wire        stn_disable_i;


  reg  [6:0]  stn_hcnt_r;
  reg  [7:0]  stn_hext_r;
  reg  [7:0]  stn_vcnt_r;


  reg  [1:0]  stn_fpshift_r;
  reg  [1:0]  stn_fpline_r;
  reg  [1:0]  stn_fpframe_r;
  reg         latch_cnt_r;

  reg         wrreq_r;
  reg  [7:0]  wdata_r;
  reg  [12:0] waddr_fifo_r;
  reg  [12:0] waddr_ram_r;

  reg         stn_disable_r;


//==========================================================================
//      Logic description
//==========================================================================

// ----- Sync STN panel signals -----------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_fpframe_r[1:0] <= 2'b00;
      stn_fpline_r[1:0]  <= 2'b00;
      stn_fpshift_r[1:0] <= 2'b00;
    end
    else begin
      stn_fpframe_r[1:0] <= {stn_fpframe_r[0], stn_fpframe};
      stn_fpline_r[1:0]  <= {stn_fpline_r[0], stn_fpline};    
      stn_fpshift_r[1:0] <= {stn_fpshift_r[0], stn_fpshift};
    end
  end

  assign fpframe_rst_en = stn_fpframe_r[0]  & (~stn_fpframe_r[1]);
  assign fpline_rst_en  = stn_fpline_r[1]  & (~stn_fpline_r[0]);
  assign fpdat_latch_en = stn_fpshift_r[1] & (~stn_fpshift_r[0]);
  assign stn_hcnt_en    = stn_fpshift_r[0] & (~stn_fpshift_r[1]);

// Pixel counter
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_hcnt_r[6:0] <= 7'h00;
    end
    else begin
      if (fpframe_rst_en | fpline_rst_en) begin     
        stn_hcnt_r[6:0] <= 7'h00;
      end  
      else begin
        if (stn_hcnt_en) stn_hcnt_r[6:0] <= stn_hcnt_r[6:0] + 7'h01;
      end
    end
  end  


  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_hext_r[7:0] <= 8'hbf;
    end
    else begin
      if (fpframe_rst_en) begin     
        stn_hext_r[7:0] <= 8'hbf;
      end  
      else begin
        if ((stn_hext_r[7:0] != 8'hbf) | fpline_rst_en) 
          stn_hext_r[7:0] <= stn_hext_r[7:0] + 8'h01;
      end
    end
  end

  assign stn_hdp = ((stn_hext_r[7:0] == 8'hbf) &
                    (stn_hcnt_r[6:0] <= 7'h50)) ? 1'b1 : 1'b0; 

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_vcnt_r[7:0] <= 8'h00;
    end
    else begin
      if (fpframe_rst_en) begin
        stn_vcnt_r[7:0] <= 8'h00;
      end  
      else begin
        if (fpline_rst_en & (stn_hext_r[7:0] == 8'hbf))
          stn_vcnt_r[7:0] <= stn_vcnt_r[7:0] + 8'h01;
      end
    end
  end

// ----- STN data latch -------------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      latch_cnt_r <= 1'b0;
    end
    else begin
      if (fpline_rst_en) 
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
  assign stn_fifo_en = (stn_vcnt_r[7:0] < 8'h78)? 1'b1 : 1'b0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      wrreq_r <= 1'b0;
    end
    else begin
      if (fifo_wrack) 
        wrreq_r <= 1'b0;
      else if (fpdat_latch_en & latch_cnt_r & stn_hdp)
        wrreq_r <= 1'b1;
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      waddr_fifo_r[12:0] <= 13'h0000;
    end
    else begin
      if (~stn_fifo_en) 
        waddr_fifo_r[12:0] <= 13'h0000;
      else begin 
        if (wrreq_r & fifo_wrack) begin
          if (waddr_fifo_r[12:0] >= 13'h04ff) waddr_fifo_r[12:0] <= 13'h0000;
          else waddr_fifo_r[12:0] <= waddr_fifo_r[12:0] + 13'h0001;
        end
      end
    end
  end
  
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      waddr_ram_r[12:0] <= 13'h0500;
    end
    else begin
      if (stn_fifo_en) 
        waddr_ram_r[12:0] <= 13'h0500;
      else begin 
        if (wrreq_r & fifo_wrack) begin
          if (waddr_ram_r[12:0] >= 13'h17bf) waddr_ram_r[12:0] <= 13'h0500;
          else waddr_ram_r[12:0] <= waddr_ram_r[12:0] + 13'h0001;
        end
      end
    end
  end

//  assign fifo_wrreq = wrreq_r & (~(stn_disable_r | stn_disable_i));
  assign fifo_wrreq = wrreq_r;
  assign fifo_waddr[12:0] = stn_fifo_en ? waddr_fifo_r[12:0] 
                                        : waddr_ram_r[12:0];

  assign fifo_wdata[7:0]  = wdata_r[7:0];
  assign stn_disable_i = (((fifo_waddr[12:0] == 13'h156b) | (fifo_waddr[12:0] == 13'h1593)) &&
                          (fifo_wdata[7]    == 1'b1)     && 
                          (wrreq_r          == 1'b1))? 1'b1 : 1'b0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_disable_r <= 1'b0;
    end
    else begin
      if (fpframe_rst_en) 
        stn_disable_r <= 1'b0;
      else begin
        if (stn_disable_i) stn_disable_r <= 1'b1;
      end  
    end
  end



endmodule


// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : tft_tg.v
// Author   : Handsome Huang
// Abstract : TFT panel timing generator
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/01    Handsome     New creation
//
// =========================================================================
module tft_tg (
  clk,
  rst_x,

  reg_tcr,

  
  stn_fpframe,

  fifo_rdreq, fifo_rdack,
  fifo_raddr,
  fifo_rdata,

  tft_vsync, tft_hsync, tft_dotclk, 
  tft_enable,
  tft_r, tft_g, tft_b
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input  [7:0]  reg_tcr;         //       Total Character Bytes Per Row



  input         stn_fpframe;     // High  STN panel frame

  output        fifo_rdreq;     // High   FIFO read request
  input         fifo_rdack;     // High   FIFO read ack
  output [12:0] fifo_raddr;
  input  [7:0]  fifo_rdata;

  output        tft_vsync;       // Low   TFT panel VSYNC
  output        tft_hsync;       // Low   TFT panel HSYNC
  output        tft_dotclk;      //       TFT panel dot clock
  output        tft_enable;      // High  TFT panel data enable

  output [5:0]  tft_r;
  output [5:0]  tft_g;
  output [5:0]  tft_b;

//==========================================================================
//     Wires & Regs
//==========================================================================
  wire        tg_rst;
  
  wire        vcnt_en, vcnt_ov;
  wire        hcnt_en, hcnt_ov;
  wire        pcnt_en, pcnt_ov;
 
  wire [8:0]  reg_vsync;
  wire [9:0]  reg_hsync;


  wire [8:0]  vcnt_vdp;
  wire [8:0]  vcnt_vndp1;
  wire [8:0]  vcnt_vndp2;
  
  wire [9:0]  hcnt_hdp;
  wire [9:0]  hcnt_hndp1;  
  wire [9:0]  hcnt_hndp2;

  wire        vdp;
  wire        hdp;

  wire        fifo_ren;

  reg  [2:0]  stn_fpframe_r;
  reg  [8:0]  vcnt_r;            // VSYNC counter 
  reg  [9:0]  hcnt_r;            // HSYNC counter
  reg         pcnt_r;            // PIXEL counter
  reg  [2:0]  scnt_r;            // Shifter counter

  reg         vsync_r;
  reg  [1:0]  hsync_r;
  reg         de_r;
  reg  [1:0]  dclk_r;
  reg  [7:0]  data_r;
  reg  [7:0]  fifo_data_r;
  reg  [12:0] raddr_r;

  reg         rdreq_r;
  reg         latch_en_r;

  wire [7:0] fifo_rdata_i;

//==========================================================================
//      Logic description
//==========================================================================
  assign reg_vsync[8:0] = (reg_tcr[7:0] == 8'h34)? 9'h129 : 
                          (reg_tcr[7:0] == 8'h48)? 9'h148 : 9'h13a;

  assign reg_hsync[9:0] = (reg_tcr[7:0] == 8'h34)? 10'h198 :
                          (reg_tcr[7:0] == 8'h48)? 10'h1ff : 10'h20f;



// ----- Sync STN frame -------------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_fpframe_r[2:0] <= 3'b000;
    end
    else begin
      stn_fpframe_r[2:0] <= {stn_fpframe_r[1:0], stn_fpframe};
    end
  end

  assign tg_rst = stn_fpframe_r[0] & (~stn_fpframe_r[1]);

// ----- VSYNC counter --------------------------------------------------
  assign vcnt_vndp2[8:0] = reg_vsync[8:0] - 9'h0fc;
  assign vcnt_vndp1[8:0] = reg_vsync[8:0] - 9'h0ec;
  assign vcnt_vdp[8:0]   = reg_vsync[8:0];
  
  assign vcnt_en = hcnt_en & hcnt_ov;
  assign vcnt_ov = (vcnt_r[8:0] == reg_vsync[8:0])? 1'b1 : 1'b0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      vcnt_r[8:0] <= 9'h000;
    end
    else begin
      if (tg_rst) vcnt_r[8:0] <= 9'h000;
      else begin 
        if (vcnt_en) begin
          if (~vcnt_ov) vcnt_r[8:0] <= vcnt_r[8:0] + 9'h001;
        end  
      end
    end  
  end

// Generate VSYNC and VDP signal
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      vsync_r <= 1'b1;
    end
    else begin
      if (vcnt_en) begin
        if (vcnt_r[8:0] == vcnt_vndp2[8:0]) vsync_r <= 1'b0;
        else                                vsync_r <= 1'b1;
      end
    end
  end

  assign vdp = ((vcnt_r[8:2] == 7'h00) | (vcnt_r[8:0] == 9'h004) |
                ((vcnt_r[8:0] > vcnt_vndp1[8:0]) & 
                 (vcnt_r[8:0] <= vcnt_vdp[8:0]))) ? 1'b1 : 1'b0;

// ----- HSYNC counter --------------------------------------------------
  assign hcnt_hndp1[9:0] = 10'h044;
  assign hcnt_hdp[9:0]   = 10'h184;

  assign hcnt_en  = pcnt_en & pcnt_ov & 
                    (~(vcnt_ov & (hcnt_r[9:0] > hcnt_hdp[9:0])));
  assign hcnt_ov  = (hcnt_r[9:0] == reg_hsync[9:0])? 1'b1 : 1'b0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      hcnt_r[9:0] <= 10'h000;
    end
    else begin
      if (tg_rst) hcnt_r[9:0] <= reg_hsync[9:0];
      else if (hcnt_en) begin
        if (hcnt_ov) hcnt_r[9:0] <= 10'h000;
        else         hcnt_r[9:0] <= hcnt_r[9:0] + 10'h001;
      end
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      hsync_r[1:0] <= 2'b11;
    end
    else begin
      hsync_r[0] <= ~hcnt_ov;  
      hsync_r[1] <= hsync_r[0];
    end
  end


  assign hdp = ((hcnt_r[9:0] > hcnt_hndp1[9:0]) &
                (hcnt_r[9:0] <= hcnt_hdp[9:0])) ? 1'b1 : 1'b0;
 
// ----- PIXEL counter --------------------------------------------------
  assign pcnt_en = 1'b1;
  assign pcnt_ov = pcnt_r;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      pcnt_r <= 1'b0;
    end
    else begin
      if (tg_rst) pcnt_r <= 1'b0;
      else if (pcnt_en) begin
        if (pcnt_ov) pcnt_r <= 1'b0;
        else         pcnt_r <= 1'b1;
      end
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      de_r <= 1'b0;
    end
    else begin
      if (pcnt_en & pcnt_ov) de_r <= hdp & vdp;
    end
  end


// ----- FIFO Signals ---------------------------------------------------
  assign fifo_ren = ((vdp & pcnt_ov)                  & 
                     (hcnt_r[9:0] >= hcnt_hndp1[9:0]) &
                     (hcnt_r[9:0] < hcnt_hdp[9:0])) ? 1'b1 : 1'b0;
 
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      scnt_r[2:0] <= 3'b000;
    end
    else begin
      if (pcnt_en & pcnt_ov) begin
        if (fifo_ren) scnt_r[2:0] <= scnt_r[2:0] + 3'b001;
        else          scnt_r[2:0] <= 3'b000;
      end  
    end
  end

  assign fifo_rdreq = (fifo_ren & (scnt_r[2:0] == 3'b000))? 1'b1 : 1'b0;
  
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      raddr_r[12:0] <= 13'h0000;
    end
    else begin
      if (~vsync_r) begin
        raddr_r[12:0] <= 13'h0000;
      end  
      else begin
        if (fifo_rdreq & fifo_rdack) begin
          if (raddr_r[12:0] == 13'h12bf)
            raddr_r[12:0] <= 13'h0000;
          else
            raddr_r[12:0] <= raddr_r[12:0] + 13'h0001;
        end
      end
    end
  end

  assign fifo_raddr[12:0] = raddr_r[12:0];

// ----- DATA Signals ---------------------------------------------------

  assign fifo_rdata_i[7:0] = ((vcnt_r[8:0] == 9'h03b) && (hcnt_r[9:0] < 10'h048)) ? 8'hff : 8'h00;
//                             ((vcnt_r[8:0] == 9'h001) && (hcnt_r[9:0] < 10'h100)) ? 8'hff : 8'h00;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
        latch_en_r <= 1'b0;
        fifo_data_r <= 8'h00;
        data_r[7:0] <= 8'h00;
    end
    else begin
      latch_en_r <= fifo_rdreq & fifo_rdack;
          
      if (latch_en_r) fifo_data_r <= fifo_rdata[7:0]; 

      if (pcnt_ov) begin
        if (scnt_r[2:0] == 3'b001) data_r[7:0] <= fifo_data_r[7:0];
        else                       data_r[7:0] <= {data_r[6:0], 1'b0};
      end  

    end
  end
  
// Output signal
  assign tft_vsync = vsync_r;
  assign tft_hsync = hsync_r[1];
  assign tft_dotclk = ~pcnt_r;
  assign tft_enable = de_r;


  assign tft_r[5] = data_r[7] ? 1'b1: 1'b0;
  assign tft_r[4] = data_r[7] ? 1'b1: 1'b0;
  assign tft_r[3] = data_r[7] ? 1'b1: 1'b0;
  assign tft_r[2] = data_r[7] ? 1'b1: 1'b0;
  assign tft_r[1] = data_r[7] ? 1'b1: 1'b0;
  assign tft_r[0] = data_r[7] ? 1'b1: 1'b0;

  assign tft_g[5] = data_r[7] ? 1'b1: 1'b0;
  assign tft_g[4] = data_r[7] ? 1'b1: 1'b0;
  assign tft_g[3] = data_r[7] ? 1'b1: 1'b0;
  assign tft_g[2] = data_r[7] ? 1'b1: 1'b0;
  assign tft_g[1] = data_r[7] ? 1'b1: 1'b0;
  assign tft_g[0] = data_r[7] ? 1'b1: 1'b0;

  assign tft_b[5] = data_r[7] ? 1'b1: 1'b1;
  assign tft_b[4] = data_r[7] ? 1'b1: 1'b1;
  assign tft_b[3] = data_r[7] ? 1'b1: 1'b1;
  assign tft_b[2] = data_r[7] ? 1'b1: 1'b1;
  assign tft_b[1] = data_r[7] ? 1'b1: 1'b1;
  assign tft_b[0] = data_r[7] ? 1'b1: 1'b1;


/*
  assign tft_r[5] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_r[4] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_r[3] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_r[2] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_r[1] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_r[0] = fifo_rdata_i[7] ? 1'b1: 1'b0;

  assign tft_g[5] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_g[4] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_g[3] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_g[2] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_g[1] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_g[0] = fifo_rdata_i[7] ? 1'b1: 1'b0;

  assign tft_b[5] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_b[4] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_b[3] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_b[2] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_b[1] = fifo_rdata_i[7] ? 1'b1: 1'b0;
  assign tft_b[0] = fifo_rdata_i[7] ? 1'b1: 1'b0;
*/















endmodule

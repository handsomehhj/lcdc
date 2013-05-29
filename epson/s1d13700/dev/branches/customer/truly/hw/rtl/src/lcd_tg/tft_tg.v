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
  stn_fpline,

  fifo_rdreq, fifo_rdack,
  fifo_raddr,
  fifo_rdata,

  color_sel,

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
  input         stn_fpline;      // High  STN panel line

  output        fifo_rdreq;      // High  FIFO read request
  input         fifo_rdack;      // High  FIFO read ack
  output [12:0] fifo_raddr;
  input  [7:0]  fifo_rdata;

  input  [2:0]  color_sel;       //       TFT color select 

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
  wire        stn_frame_rst;
  wire        stn_line_rst;
  wire        stn_valid_line;
  wire        stn_fifo_en;

  wire        hcnt_ov;
  wire        hcnt_ov_fifo, hcnt_ov_ram;
  wire        pcnt_en;

  wire [9:0]  reg_hsync;

  wire [9:0]  hcnt_hdp;
  wire [9:0]  hcnt_hndp1;  
  wire [9:0]  hcnt_hndp2;
  wire        hcnt_th;
  wire        vcnt_th;
  wire        vdp, hdp;

  wire        fifo_ren;

  wire [17:0] fore_color;
  wire [17:0] back_color;


  reg  [2:0]  stn_frame_r;
  reg  [2:0]  stn_line_r;
  reg  [7:0]  stn_vcnt_r;
  reg  [9:0]  stn_hcnt_r;

  reg  [8:0]  vcnt_r;            // VSYNC counter 
  reg  [10:0] hcnt_r;            // HSYNC counter
  reg         pcnt_r;            // PIXEL counter
  reg  [2:0]  mcnt_r;
  reg         hcnt_th_r;

  reg  [9:0]  hcnt_r_tst;

  reg  [2:0]  scnt_r;            // Shifter counter

  reg         vsync_r;
  reg  [1:0]  hsync_r;
  reg  [1:0]  de_r;
  reg  [1:0]  dclk_r;
  reg  [7:0]  data_r;
  reg  [7:0]  fifo_data_r;
  reg  [12:0] raddr_r;

  reg  [12:0] raddr_fifo_r;
  reg  [12:0] raddr_ram_r;
  


  reg         rdreq_r;
  reg         latch_en_r;

  wire [7:0] fifo_rdata_i;

//==========================================================================
//      Logic description
//==========================================================================
//  assign reg_hsync[9:0] = (reg_tcr[7:0] == 8'h34)? 10'h198 :
//                          (reg_tcr[7:0] == 8'h48)? 10'h1bf : 10'h20f;
  assign reg_hsync[9:0] = (reg_tcr[7:0] == 8'h34)? 10'h198 :
                          (reg_tcr[7:0] == 8'h48)? 10'h1bf : 10'h20f;

// ----- Sync STN frame -------------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_frame_r[2:0] <= 3'b000;
    end
    else begin
      if (pcnt_en) stn_frame_r[2:0] <= {stn_frame_r[1:0], stn_fpframe};
    end
  end

  assign stn_frame_rst = ~stn_frame_r[1] & stn_frame_r[2];

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_vcnt_r[7:0] <= 8'h00;
    end
    else begin
      if (pcnt_en & stn_line_rst) begin
        if (stn_fpframe) stn_vcnt_r[7:0] <= 8'h00;
        else             stn_vcnt_r[7:0] <= stn_vcnt_r[7:0] + 8'h01;
      end
    end
  end

  /* 1st 120 line is fifo */
  assign stn_fifo_en = (stn_vcnt_r[7:0] < 8'h89)? 1'b1: 1'b0;

// ----- Sync STN line --------------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_line_r[2:0] <= 3'b000;
    end
    else begin
      if (pcnt_en) stn_line_r[2:0] <= {stn_line_r[1:0], stn_fpline};
    end
  end

  assign stn_valid_line = (stn_hcnt_r[9:0] > 10'h4f)? 1'b1 : 1'b0;
  assign stn_line_rst = ~stn_line_r[1] & stn_line_r[2] & stn_valid_line;
  
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      stn_hcnt_r[9:0] <= 10'h000;
    end
    else begin
      if (pcnt_en) begin
        if (stn_frame_rst) stn_hcnt_r[9:0] <= 10'h000;
        else begin
          if (~stn_line_r[1] & stn_line_r[2] & stn_valid_line)
            stn_hcnt_r[9:0] <= 10'h000;
          else
            stn_hcnt_r[9:0] <= stn_hcnt_r[9:0] + 10'h001;
        end
      end
    end
  end

// ----- VSYNC counter --------------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      vcnt_r[8:0] <= 9'h000;
    end
    else begin
      if (pcnt_en & hcnt_ov) begin
        if (stn_fpframe) vcnt_r[8:0] <= 9'h000;
        else             vcnt_r[8:0] <= vcnt_r[8:0] + 9'h001;
      end
    end
  end

// Generate VSYNC and VDP signal
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      vsync_r <= 1'b1;
    end
    else begin
      if (pcnt_en & hcnt_ov) begin
        if (stn_fifo_en & (vcnt_r[8:0] == 9'h00)) vsync_r <= 1'b0;
        else                                      vsync_r <= 1'b1;
      end
    end
  end

  assign vdp = ((vcnt_r[8:0] > 9'h012) && 
                (vcnt_r[8:0] < 9'h103)) ? 1'b1 : 1'b0;

  assign vcnt_th = (vcnt_r[8:0] < 9'h107)? 1'b0 : 1'b1; 

// ----- HSYNC counter --------------------------------------------------
  assign hcnt_ov_fifo = stn_line_rst;
  assign hcnt_ov_ram  = (hcnt_r[10:0] == {1'b0, reg_hsync[9:0]})? 1'b1 : 1'b0;
  assign hcnt_ov      = stn_fifo_en ? hcnt_ov_fifo : hcnt_ov_ram;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      hcnt_r[10:0] <= 11'h000;
    end
    else begin
      if (pcnt_en) begin  
        if (hcnt_ov) hcnt_r[10:0] <= 11'h000;
        else         hcnt_r[10:0] <= hcnt_r[10:0] + 11'h001;
      end
    end
  end

  assign hcnt_th = (hcnt_r[10:0] < 11'h198)? 1'b1 : 1'b0; 

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      hsync_r[1:0] <= 2'b1;
    end
    else begin
      if (pcnt_en) hsync_r[0] <= ~hcnt_ov;  
      if (pcnt_en) hsync_r[1] <= hsync_r[0];  
    end
  end

  assign hdp = ((hcnt_r[10:0] > 11'h043) &
                (hcnt_r[10:0] < 11'h184)) ? 1'b1 : 1'b0;
 
// ----- PIXEL counter --------------------------------------------------
  assign pcnt_en = pcnt_r;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      pcnt_r <= 1'b0;
    else begin
      pcnt_r <= ~pcnt_r;
    end
  end

// To avoid too long line
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      mcnt_r[2:0] <= 3'b000;
    else begin
      if (pcnt_en) begin
        if (hcnt_th) mcnt_r[2:0] <= 3'b000;
        else         mcnt_r[2:0] <= mcnt_r[2:0] + 3'b001;
      end
    end
  end

  always @(negedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) 
      hcnt_th_r <= 1'b1;
    else
      if (pcnt_en) hcnt_th_r <= hcnt_th;
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      de_r[1:0] <= 2'b00;
    end
    else begin
      if (pcnt_en) de_r[1:0] <= {de_r[0], hdp & vdp};
    end
  end


// ----- FIFO Signals ---------------------------------------------------
  assign fifo_ren = vdp & hdp;
 
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      scnt_r[2:0] <= 3'b000;
    end
    else begin
      if (pcnt_en) begin
        if (fifo_ren) scnt_r[2:0] <= scnt_r[2:0] + 3'b001;
        else          scnt_r[2:0] <= 3'b000;
      end  
    end
  end

  assign fifo_rdreq = (fifo_ren & (scnt_r[2:0] == 3'b000))? 1'b1 : 1'b0;


  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      raddr_fifo_r[12:0] <= 13'h0000;
      raddr_ram_r[12:0]  <= 13'h0500;
    end
    else begin
      if (pcnt_en) begin
        if (~stn_fifo_en) 
          raddr_fifo_r[12:0] <= 13'h0000;
        else if (fifo_rdreq & fifo_rdack) begin
          if (raddr_fifo_r[12:0] >= 13'h04ff)
            raddr_fifo_r[12:0] <= 13'h0000;
          else
            raddr_fifo_r[12:0] <= raddr_fifo_r[12:0] + 13'h0001;
        end
      end

      if (pcnt_en) begin
        if (stn_fifo_en) 
          raddr_ram_r[12:0] <= 13'h0500;
        else if (fifo_rdreq & fifo_rdack) begin
          if (raddr_ram_r[12:0] >= 13'h17bf)
            raddr_fifo_r[12:0] <= 13'h0500;
          else
            raddr_ram_r[12:0] <= raddr_ram_r[12:0] + 13'h0001;
        end
      end
    end
  end


  assign fifo_raddr[12:0] = stn_fifo_en ? raddr_fifo_r[12:0]
                                        : raddr_ram_r[12:0];

// ----- DATA Signals ---------------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
        latch_en_r <= 1'b0;
        fifo_data_r <= 8'h00;
        data_r[7:0] <= 8'h00;
    end
    else begin
      latch_en_r <= fifo_rdreq & fifo_rdack;
          
      if (latch_en_r) fifo_data_r <= fifo_rdata[7:0]; 

      if (pcnt_en) begin
        if (scnt_r[2:0] == 3'b001) data_r[7:0] <= fifo_data_r[7:0];
        else                       data_r[7:0] <= {data_r[6:0], 1'b0};
      end  

    end
  end



// Color select
  assign fore_color[17:0] = FC_FORE_COLOR(color_sel[2:0]);
  assign back_color[17:0] = FC_BACK_COLOR(color_sel[2:0]);

  // Function body
  function[17:0] FC_FORE_COLOR;
    input [2:0]  fc_color_sel;
    begin
      case (fc_color_sel[2:0]) // synopsys parallel_case
      // ------------------------------------------------------------
        3'b000: FC_FORE_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b11_1111}; 
        3'b001: FC_FORE_COLOR[17:0] = {6'b11_1111, 6'b11_0000, 6'b00_0000}; 
        3'b010: FC_FORE_COLOR[17:0] = {6'b11_1111, 6'b11_1111, 6'b11_1111}; 
        3'b011: FC_FORE_COLOR[17:0] = {6'b11_1111, 6'b00_0000, 6'b00_0000}; 
        3'b100: FC_FORE_COLOR[17:0] = {6'b11_1111, 6'b11_1111, 6'b11_1111}; 
        3'b101: FC_FORE_COLOR[17:0] = {6'b11_1111, 6'b11_1111, 6'b00_0000}; 
        3'b110: FC_FORE_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b11_1111};
        3'b111: FC_FORE_COLOR[17:0] = {6'b11_1111, 6'b00_0000, 6'b00_0000}; 
        default: FC_FORE_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b00_0000};
      endcase
    end
  endfunction
  
  // Function body
  function[17:0] FC_BACK_COLOR;
    input [2:0]  fc_color_sel;
    begin
      case (fc_color_sel[2:0]) // synopsys parallel_case
      // ------------------------------------------------------------
        3'b000: FC_BACK_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b00_0000}; 
        3'b001: FC_BACK_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b00_0000};
        3'b010: FC_BACK_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b00_0000};
        3'b011: FC_BACK_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b00_0000};
        3'b100: FC_BACK_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b11_1111};
        3'b101: FC_BACK_COLOR[17:0] = {6'b11_0010, 6'b11_0010, 6'b11_0000}; 
        3'b110: FC_BACK_COLOR[17:0] = {6'b11_0010, 6'b11_0010, 6'b11_0000}; 
        3'b111: FC_BACK_COLOR[17:0] = {6'b11_0010, 6'b11_0010, 6'b11_0000};
        default: FC_BACK_COLOR[17:0] = {6'b00_0000, 6'b00_0000, 6'b00_0000};
      endcase
    end
  endfunction


// Output signal
  assign tft_vsync  = vsync_r;
  assign tft_hsync  = hsync_r[1] | vcnt_th;
//  assign tft_hsync  = hsync_r[1];
//  assign tft_dotclk = vcnt_th ? 1'b0 : (hcnt_th_r ? ~pcnt_r: 1'b0);
  assign tft_dotclk = hcnt_th_r ? ~pcnt_r: 1'b0;
  assign tft_enable = de_r[1];

  assign tft_r[5:0] = data_r[7] ? fore_color[17:12] : back_color[17:12];
  assign tft_g[5:0] = data_r[7] ? fore_color[11:6]  : back_color[11:6];
  assign tft_b[5:0] = data_r[7] ? fore_color[5:0]   : back_color[5:0];



endmodule

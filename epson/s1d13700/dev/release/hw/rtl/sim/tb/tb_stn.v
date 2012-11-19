// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : tb_stn.v
// Author   : Handsome Huang
// Abstract : STN panel timing (fixed for 320*240 resolution)
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/09    Handsome     New creation
// =========================================================================

// A.C spec
//`define tBPS    tC3     14000   // High-speed clock cycle time
//`define tCD0    5000    // CMU_CLK output delay time
//`define tCD1    5000    // CMU_CLK output delay time
//`define tCD2    5000    // CMU_CLK output delay time
//`define tCD3    5000    // CMU_CLK output delay time

//`define tAD     0:0:14000                          // Address delay time
//`define tCED    0:0:14000                          // #CEx delay time
//`define tRDD    0:0:14000                          // Read delay time
//`define tWRD    0:0:14000                          // Write delay time
//`define tWRDD   0:0:14000                          // Write data delay time
//`define tWRDH   `CYCLE-2000:`CYCLE+0:`CYCLE+14000  // Write data hold time

module stn (
  P_RST_X,
  P_CLK,

  P_FPFRAME,
  P_FPLINE,
  P_FPSHIFT,

  P_FPDAT3,
  P_FPDAT2,
  P_FPDAT1,
  P_FPDAT0,

  P_CNF1,
  P_CNF0,

  reg_tcr
);

//======================================================================
//      Signals
//======================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ------------------------------
  input         P_RST_X;         // LOW   Reset, active low
  input         P_CLK;           //       Clock

  output        P_FPFRAME;       // High  STN panel frame
  output        P_FPLINE;        // High  STN panel line
  output        P_FPSHIFT;       //       STN panel shift clock

  output        P_FPDAT3;        //       STN panel dat3
  output        P_FPDAT2;        //       STN panel dat2
  output        P_FPDAT1;        //       STN panel dat1
  output        P_FPDAT0;        //       STN panel dat0

  input         P_CNF1;          //       STN panel timing configuration 1
  input         P_CNF0;          //       STN panel timing configuration 0

  input  [7:0]  reg_tcr;
  
//=========================================================================
//     Wires and Regs
//=========================================================================
  wire        rst_x;
  wire        clk;

  wire [1:0]  cnf;

  wire        pcnt_en;
  wire        pcnt_ov;
  wire [3:0]  pcnt_cnf;

  wire        hcnt_en;
  wire        hcnt_ov;
  wire        hcnt_hdp;

  wire        vcnt_en;
  wire        vcnt_ov;

  wire [3:0]  dat_i;

  wire [7:0]  reg_tcr;
  wire [7:0]  hdp_start;
  wire [7:0]  hdp_end;


  reg  [3:0]  pcnt_r;
  reg  [7:0]  hcnt_r;
  reg  [7:0]  vcnt_r;

  reg         shift_r;
  reg         line_r;
  reg  [3:0]  frame_r;
  
  reg  [3:0]  dat_r;

//=========================================================================
//      Logic description
//=========================================================================
  assign rst_x = P_RST_X;
  assign clk   = P_CLK;

  assign cnf[1] = P_CNF1;
  assign cnf[0] = P_CNF0;
  
// ----- VSYNC counter --------------------------------------------------
  assign vcnt_en = hcnt_en & hcnt_ov;   
  assign vcnt_ov = (vcnt_r[7:0] == 8'hef)? 1'b1 : 1'b0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      vcnt_r[7:0] <= 8'h00;
    end
    else begin
      if (vcnt_en) begin
        if (vcnt_ov) vcnt_r[7:0] <= 8'h00;
        else         vcnt_r[7:0] <= vcnt_r[7:0] + 8'h01;
      end
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      frame_r[3:0] <= 3'b000;
    end
    else begin
      if (vcnt_en) frame_r[0] <= vcnt_ov;
      if (hcnt_en) frame_r[1] <= frame_r[0];
      if (hcnt_en) frame_r[2] <= frame_r[1];
      if (hcnt_en) frame_r[3] <= frame_r[2];
    end
  end
  
// ----- HSYNC counter --------------------------------------------------
  assign hdp_start[7:0] = (reg_tcr[7:0] - 8'h30 + 8'h01) * 2;
  assign hdp_end[7:0]   = (reg_tcr[7:0] * 2) + 8'h01;

  assign hcnt_en  = pcnt_en & pcnt_ov;
  assign hcnt_ov  = (hcnt_r[7:0] == hdp_end[7:0])? 1'b1 : 1'b0;
  assign hcnt_hdp = ((hcnt_r[7:0] >= hdp_start[7:0]) & 
                     (hcnt_r[7:0] <= hdp_end[7:0])) ? 1'b1 : 1'b0; 
//  assign hcnt_ov  = (hcnt_r[7:0] == 8'h69)? 1'b1 : 1'b0;
//  assign hcnt_hdp = ((hcnt_r[7:0] >= 8'h1a) & 
//                     (hcnt_r[7:0] <= 8'h69)) ? 1'b1 : 1'b0; 


  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      hcnt_r[7:0] <= 8'h00;
    end
    else begin
      if (hcnt_en) begin
        if (hcnt_ov) hcnt_r[7:0] <= 8'h00;
        else         hcnt_r[7:0] <= hcnt_r[7:0] + 8'h01;
      end
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      line_r <= 1'b0;
    end
    else begin
      if (hcnt_en) line_r <= hcnt_ov;
    end
  end

// ----- PIXEL counter --------------------------------------------------
  assign pcnt_en = 1'b1;
  assign pcnt_cnf[3:0] = (cnf[1:0]==2'b00) ? 4'h3 :
                         (cnf[1:0]==2'b01) ? 4'h7 :
                         (cnf[1:0]==2'b10) ? 4'hf :
                                             4'b0; 

  assign pcnt_ov = (pcnt_r[3:0] == pcnt_cnf[3:0]) ? 1'b1 : 1'b0;

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      pcnt_r[3:0] <= 4'h0;
    end
    else begin
      if (pcnt_en) begin
        if (pcnt_ov) pcnt_r[3:0] <= 4'h0;
        else         pcnt_r[3:0] <= pcnt_r[3:0] + 4'h1;
      end
    end
  end

  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      shift_r <= 1'b0;
    end
    else begin
      if (hcnt_hdp) begin
        if (pcnt_r[3:0] == {1'b0, pcnt_cnf[3:1]}) shift_r <= 1'b0;
        else if (pcnt_r[3:0] == pcnt_cnf[3:0])    shift_r <= 1'b1;
      end
      else begin
        if ((pcnt_r[3:0] == {1'b0, pcnt_cnf[3:1]}) |
            (pcnt_r[3:0] == pcnt_cnf[3:0]))
          shift_r <= 1'b0;
      end  
    end
  end


  assign P_FPFRAME = frame_r[3];
  assign P_FPLINE  = line_r;
  assign P_FPSHIFT = shift_r;

  

  assign P_FPDAT3 = dat_i[3];
  assign P_FPDAT2 = dat_i[2];
  assign P_FPDAT1 = dat_i[1];
  assign P_FPDAT0 = dat_i[0];

  assign dat_i[3:0] = ((vcnt_r[7:0] == 8'h76) & (hcnt_r[7:0] == 8'h43))? 4'b1111 : 4'b0000;


  always @(posedge shift_r or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      dat_r <= 1'b0;
    end
    else begin
      dat_r[3:0] = ~dat_r[3:0];
    end
  end



endmodule


// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : uart_transfer.v
// Author   : Handsome Huang
// Abstract : UART transfer
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/08    Handsome     New creation
//
// =========================================================================
module uart_transfer (
  clk,
  rst_x,

  uart_req, uart_ack,
  uart_dat,

  uart_tm_ov,
  uart_tm_en,

  uart_sout
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         uart_req;        // High  UART transfer request
  output        uart_ack;        // High  UART transfer acknowledge
  input  [17:0] uart_dat;        //       UART transfer data

  input         uart_tm_ov;      // High  UART timer overflow
  output        uart_tm_en;      // High  UART timer enable

  output        uart_sout;       //       UART TX

// =====================================================================
//      Parameters
// =====================================================================
  parameter IDLE  = 6'b00_0000;
  parameter START = 6'b00_0001;
  parameter BIT00 = 6'b00_0010;
  parameter BIT01 = 6'b00_0011;
  parameter BIT02 = 6'b00_0100;
  parameter BIT03 = 6'b00_0101;
  parameter BIT04 = 6'b00_0110;
  parameter BIT05 = 6'b00_0111;
  parameter BIT06 = 6'b00_1000;
  parameter BIT07 = 6'b00_1001;
  parameter BIT08 = 6'b00_1010;
  parameter BIT09 = 6'b00_1011;
  parameter BIT10 = 6'b00_1100;
  parameter BIT11 = 6'b00_1101;
  parameter BIT12 = 6'b00_1110;
  parameter BIT13 = 6'b00_1111;
  parameter BIT14 = 6'b01_0000;
  parameter BIT15 = 6'b01_0001;
  parameter BIT16 = 6'b01_0010;
  parameter BIT17 = 6'b01_0011;
  parameter BIT18 = 6'b01_0100;
  parameter BIT19 = 6'b01_0101;
  parameter BIT20 = 6'b01_0110;
  parameter BIT21 = 6'b01_0111;
  parameter BIT22 = 6'b01_1000;
  parameter BIT23 = 6'b01_1001;
  parameter BIT24 = 6'b01_1010;
  parameter BIT25 = 6'b01_1011;
  parameter BIT26 = 6'b01_1100;
  parameter BIT27 = 6'b01_1101;
  parameter BIT28 = 6'b01_1110;
  parameter BIT29 = 6'b01_1111;
  parameter BIT30 = 6'b10_0000;
  parameter BIT31 = 6'b10_0001;


//==========================================================================
//     Wires & Regs
//==========================================================================
  wire [5:0]  uart_sta_i;

  reg  [5:0]  uart_sta_r;
  reg  [33:0] uart_shift_r;

//==========================================================================
//      Logic description
//==========================================================================

// ----- State Machine ----------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      uart_sta_r[5:0] <= IDLE;
    else begin
      uart_sta_r[5:0] <= uart_sta_i[5:0];
    end
  end

  // Call function  
  assign uart_sta_i[5:0] = fc_sta_i(uart_sta_r[5:0], uart_req, uart_tm_ov); 

  // Function body
  function[5:0] fc_sta_i;
    input [5:0] fc_sta_r;
    input       fc_req;
    input       fc_tm_ov;
    begin
      case (fc_sta_r[5:0])   // synopsys parallel_case
      // ------------------------------------------------------------
        IDLE:  if (fc_req) fc_sta_i[5:0] = START;
               else        fc_sta_i[5:0] = IDLE;
      // ------------------------------------------------------------
        START: if (fc_tm_ov) fc_sta_i[5:0] = BIT00;
               else          fc_sta_i[5:0] = START;
      // ------------------------------------------------------------
        BIT00: if (fc_tm_ov) fc_sta_i[5:0] = BIT01;
               else          fc_sta_i[5:0] = BIT00;
      // ------------------------------------------------------------
        BIT01: if (fc_tm_ov) fc_sta_i[5:0] = BIT02;
               else          fc_sta_i[5:0] = BIT01;
      // ------------------------------------------------------------
        BIT02: if (fc_tm_ov) fc_sta_i[5:0] = BIT03;
               else          fc_sta_i[5:0] = BIT02;
      // ------------------------------------------------------------
        BIT03: if (fc_tm_ov) fc_sta_i[5:0] = BIT04;
               else          fc_sta_i[5:0] = BIT03;
      // ------------------------------------------------------------
        BIT04: if (fc_tm_ov) fc_sta_i[5:0] = BIT05;
               else          fc_sta_i[5:0] = BIT04;
      // ------------------------------------------------------------
        BIT05: if (fc_tm_ov) fc_sta_i[5:0] = BIT06;
               else          fc_sta_i[5:0] = BIT05;
      // ------------------------------------------------------------
        BIT06: if (fc_tm_ov) fc_sta_i[5:0] = BIT07;
               else          fc_sta_i[5:0] = BIT06;
      // ------------------------------------------------------------
        BIT07: if (fc_tm_ov) fc_sta_i[5:0] = BIT08;
               else          fc_sta_i[5:0] = BIT07;
      // ------------------------------------------------------------
        BIT08: if (fc_tm_ov) fc_sta_i[5:0] = BIT09;
               else          fc_sta_i[5:0] = BIT08;
      // ------------------------------------------------------------
        BIT09: if (fc_tm_ov) fc_sta_i[5:0] = BIT10;
               else          fc_sta_i[5:0] = BIT09;        
      // ------------------------------------------------------------
        BIT10: if (fc_tm_ov) fc_sta_i[5:0] = BIT11;
               else          fc_sta_i[5:0] = BIT10;
      // ------------------------------------------------------------
        BIT11: if (fc_tm_ov) fc_sta_i[5:0] = BIT12;
               else          fc_sta_i[5:0] = BIT11;                 
      // ------------------------------------------------------------
        BIT12: if (fc_tm_ov) fc_sta_i[5:0] = BIT13;
               else          fc_sta_i[5:0] = BIT12;
      // ------------------------------------------------------------
        BIT13: if (fc_tm_ov) fc_sta_i[5:0] = BIT14;
               else          fc_sta_i[5:0] = BIT13;
      // ------------------------------------------------------------
        BIT14: if (fc_tm_ov) fc_sta_i[5:0] = BIT15;
               else          fc_sta_i[5:0] = BIT14;
      // ------------------------------------------------------------
        BIT15: if (fc_tm_ov) fc_sta_i[5:0] = BIT16;
               else          fc_sta_i[5:0] = BIT15;
      // ------------------------------------------------------------
        BIT16: if (fc_tm_ov) fc_sta_i[5:0] = BIT17;
               else          fc_sta_i[5:0] = BIT16;
      // ------------------------------------------------------------
        BIT17: if (fc_tm_ov) fc_sta_i[5:0] = BIT18;
               else          fc_sta_i[5:0] = BIT17;
      // ------------------------------------------------------------
        BIT18: if (fc_tm_ov) fc_sta_i[5:0] = BIT19;
               else          fc_sta_i[5:0] = BIT18;
      // ------------------------------------------------------------
        BIT19: if (fc_tm_ov) fc_sta_i[5:0] = BIT20;
               else          fc_sta_i[5:0] = BIT19;
      // ------------------------------------------------------------
        BIT20: if (fc_tm_ov) fc_sta_i[5:0] = BIT21;
               else          fc_sta_i[5:0] = BIT20;
      // ------------------------------------------------------------
        BIT21: if (fc_tm_ov) fc_sta_i[5:0] = BIT22;
               else          fc_sta_i[5:0] = BIT21;
      // ------------------------------------------------------------
        BIT22: if (fc_tm_ov) fc_sta_i[5:0] = BIT23;
               else          fc_sta_i[5:0] = BIT22;
      // ------------------------------------------------------------
        BIT23: if (fc_tm_ov) fc_sta_i[5:0] = BIT24;
               else          fc_sta_i[5:0] = BIT23;
      // ------------------------------------------------------------
        BIT24: if (fc_tm_ov) fc_sta_i[5:0] = BIT25;
               else          fc_sta_i[5:0] = BIT24;
      // ------------------------------------------------------------
        BIT25: if (fc_tm_ov) fc_sta_i[5:0] = BIT26;
               else          fc_sta_i[5:0] = BIT25;
      // ------------------------------------------------------------
        BIT26: if (fc_tm_ov) fc_sta_i[5:0] = BIT27;
               else          fc_sta_i[5:0] = BIT26;
      // ------------------------------------------------------------
        BIT27: if (fc_tm_ov) fc_sta_i[5:0] = BIT28;
               else          fc_sta_i[5:0] = BIT27;
      // ------------------------------------------------------------
        BIT28: if (fc_tm_ov) fc_sta_i[5:0] = BIT29;
               else          fc_sta_i[5:0] = BIT28;
      // ------------------------------------------------------------
        BIT29: if (fc_tm_ov) fc_sta_i[5:0] = BIT30;
               else          fc_sta_i[5:0] = BIT29;
      // ------------------------------------------------------------
        BIT30: if (fc_tm_ov) fc_sta_i[5:0] = BIT31;
               else          fc_sta_i[5:0] = BIT30;
      // ------------------------------------------------------------
        BIT31: if (fc_tm_ov) fc_sta_i[5:0] = IDLE;
               else          fc_sta_i[5:0] = BIT31;
      // ------------------------------------------------------------
        default: fc_sta_i = IDLE;
      endcase
    end
  endfunction


  assign uart_ack = ((uart_sta_r[5:0] == BIT31) & uart_tm_ov)? 1'b1 : 1'b0;

// ----- Shift Register ---------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      uart_shift_r[33:0] <= 34'h3_ffff_ffff;
    else begin
      if (uart_req & (uart_sta_r[5:0] == IDLE))
        uart_shift_r[33:0] <= {3'b111, 6'h00, uart_dat[17:16], 1'b0,
                               2'b11, uart_dat[15:8], 1'b0,
                               2'b11, uart_dat[7:0], 1'b0};
      else begin
        if ((uart_sta_r[5:0] != IDLE) & uart_tm_ov)
          uart_shift_r[33:0] <= {1'b0, uart_shift_r[33:1]};
      end
    end
  end

  assign uart_sout = uart_shift_r[0];


  assign uart_tm_en = (uart_sta_r[5:0] != IDLE)? 1'b1 : 1'b0;




endmodule


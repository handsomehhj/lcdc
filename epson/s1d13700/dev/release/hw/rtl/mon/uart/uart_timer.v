// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : uart_timer.v
// Author   : Handsome Huang
// Abstract : UART BAUD rate timer
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/09    Handsome     New creation
//
// =========================================================================
module uart_timer (
  clk,
  rst_x,

  uart_tm_en,
  uart_tm_ov
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         uart_tm_en;      // High  UART timer enable
  output        uart_tm_ov;      // High  UART timer overflow

//==========================================================================
//     Wires & Regs
//==========================================================================
  reg  [7:0] tm_cnt_r;

//==========================================================================
//      Logic description
//==========================================================================

  assign uart_tm_ov = (tm_cnt_r[7:0] == 8'h86)? 1'b1 : 1'b0;

// ----- BAUD Rate Timer --------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      tm_cnt_r[7:0] <= 8'h00;
    else begin
      if ((~uart_tm_en) | uart_tm_ov) 
        tm_cnt_r[7:0] <= 8'h00;
      else             
        tm_cnt_r[7:0] <= tm_cnt_r[7:0] + 8'h01;
    end
  end

endmodule


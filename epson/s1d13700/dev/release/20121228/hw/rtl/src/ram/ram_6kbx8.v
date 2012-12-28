// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : ram_6kbx8.v
// Author   : Handsome Huang
// Abstract : 6KB RAM
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/09/16    Handsome     New creation
//
// =========================================================================
module ram_6kbx8 (
  clk,
  rst_x,
  ce, we, addr,
  di, do
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         clk;             //       Clock
  input         rst_x;           // Low   Reset
  
  input         ce;              // High  Chip enable
  input         we;              // High  Write enable
  input  [12:0] addr;            //       Address
  input  [7:0]  di;              //       Data input
  output [7:0]  do;              //       Data output

//==========================================================================
//     Wires & Regs
//==========================================================================
  wire [2:0] sel;

  wire [7:0] do_0;
  wire [7:0] do_1;
  wire [7:0] do_2;

  reg  [1:0] addr_r;

//==========================================================================
//      Logic description
//==========================================================================
  assign sel[0] = (ce & (addr[12:11] == 2'b00))? 1'b1 : 1'b0;
  assign sel[1] = (ce & (addr[12:11] == 2'b01))? 1'b1 : 1'b0;
  assign sel[2] = (ce & (addr[12:11] == 2'b10))? 1'b1 : 1'b0;
  
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0) begin
      addr_r[1:0] <= 2'b00;
    end
    else begin
      addr_r[1:0] <= addr[12:11];  
    end
  end

  assign do[7:0] = (addr_r[1:0] == 2'b00) ? do_0[7:0] :
                   (addr_r[1:0] == 2'b01) ? do_1[7:0] :
                   (addr_r[1:0] == 2'b10) ? do_2[7:0] :
                                            8'h00;

//=======================================================================
//      RAM block
//=======================================================================
  RAMB16_S9 A_FIFO_RAM0 (
    .CLK   ( clk        ), 
    .SSR   ( 1'b0       ),

    .EN    ( sel[0]     ),
    .WE    ( we         ),
    .ADDR  ( addr[10:0] ), 

    .DI    ( di[7:0]    ), 
    .DIP   ( 1'b0       ),
    .DO    ( do_0[7:0]  ), 
    .DOP   (            )
  );

  RAMB16_S9 A_FIFO_RAM1 (
    .CLK   ( clk        ), 
    .SSR   ( 1'b0       ),

    .EN    ( sel[1]     ),
    .WE    ( we         ),
    .ADDR  ( addr[10:0] ), 

    .DI    ( di[7:0]    ), 
    .DIP   ( 1'b0       ),
    .DO    ( do_1[7:0]  ), 
    .DOP   (            )
  );

  RAMB16_S9 A_FIFO_RAM2 (
    .CLK   ( clk        ), 
    .SSR   ( 1'b0       ),

    .EN    ( sel[2]     ),
    .WE    ( we         ),
    .ADDR  ( addr[10:0] ), 

    .DI    ( di[7:0]    ), 
    .DIP   ( 1'b0       ),
    .DO    ( do_2[7:0]  ), 
    .DOP   (            )
  );

endmodule

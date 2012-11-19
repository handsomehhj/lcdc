// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : ram_2kbx18.v
// Author   : Handsome Huang
// Abstract : 6KB RAM
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/07    Handsome     New creation
//
// =========================================================================
module ram_2kbx18 (
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
  input  [10:0] addr;            //       Address
  input  [17:0] di;              //       Data input
  output [17:0] do;              //       Data output

//==========================================================================
//      Logic description
//==========================================================================
  RAMB16_S9 A_FIFO_RAM_LSB (
    .CLK   ( clk        ), 
    .SSR   ( 1'b0       ),

    .EN    ( ~ce        ),
    .WE    ( ~we        ),
    .ADDR  ( addr[10:0] ), 

    .DI    ( di[7:0]    ), 
    .DIP   ( di[8]      ),
    .DO    ( do[7:0]    ), 
    .DOP   ( do[8]      )
  );

  RAMB16_S9 A_FIFO_RAM_MSB (
    .CLK   ( clk        ), 
    .SSR   ( 1'b0       ),

    .EN    ( ~ce        ),
    .WE    ( ~we        ),
    .ADDR  ( addr[10:0] ), 

    .DI    ( di[16:9]   ), 
    .DIP   ( di[17]     ),
    .DO    ( do[16:9]   ), 
    .DOP   ( do[17]     )
  );

endmodule



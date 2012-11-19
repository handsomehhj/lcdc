// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
//
//     This confidential and proprietary source code may be used only as
//     authorized by a licensing agreement from SEIKO EPSON CORPORATION.
//
//                (C) COPYRIGHT 2005 SEIKO EPSON CORPORATION.
//            (C) COPYRIGHT 2005 SHANGHAI EPSON ELECTRONIC CO.,LTD.
//                          ALL RIGHTS RESERVED
//
//     The entire notice above must be reproduced on all authorized copies
//     and any such reproduction must be pursuant to a licensing agreement
//     from SEIKO EPSON CORPORATION.
//
// File     : tb_clk.v
// Author   : Handsome Huang
// Abstract : Clock test bench
// 
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2010/05/17    Handsome     New creation
//
// =========================================================================

module clk (
  P_MCLK,
  P_RST_X
);


//======================================================================
//      Signals
//======================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ------------------------------
  output        P_MCLK;          //       System clock
  output        P_RST_X;         // Low   Reset output

// =====================================================================
//      Parameters
// =====================================================================
  parameter MCLK_CYC = 39_000;     // 25.6MHz

// =====================================================================
//      Registers
// =====================================================================
  reg        mclk_r;
  reg        rst_x_r;

//======================================================================
//      Logic description
//======================================================================
  assign P_RST_X = rst_x_r;
  assign P_MCLK  = mclk_r;

//--------------------------------------------------------------------
//  Clock Generator
//-------------------------------------------------------------------- 
  initial begin
                        mclk_r = 1'b0;
    #(MCLK_CYC - 5_000) mclk_r = 1'b1;
    forever begin
      #(MCLK_CYC / 2)   mclk_r = ~mclk_r;
    end
  end

//--------------------------------------------------------------------
//  Reset Generator
//-------------------------------------------------------------------- 
  initial begin
                       rst_x_r = 1'b0;
    #(MCLK_CYC * 0.5);
    #(MCLK_CYC * 28)   rst_x_r = 1'b1;
    #(MCLK_CYC * 14)   rst_x_r = 1'b0;
    #(MCLK_CYC * 28)   rst_x_r = 1'b1;

    $display("########################################");
    $display("######       RESET_X <= '1'       ######");
    $display("########################################");
    $display();

  end // initial begin

endmodule // tb_clk

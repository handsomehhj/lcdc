// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// =========================================================================
// File     : uart_if.v
// Author   : Handsome Huang
// Abstract : UART I/F, read transfer data from the FIFO
// =========================================================================
// Modification History:
// Date          By           Changes Description
// ----------------------------------------------------------------------
// 2012/11/08    Handsome     New creation
//
// =========================================================================
module uart_if (
  clk,
  rst_x,

  empty, 
  
  rdreq, rdack,
  raddr, 
  rdata,

  uart_req, uart_ack,
  uart_dat
);

//==========================================================================
//      Signals
//==========================================================================
// dir   bit    signal name         act   description
//------ ------ ----------------    ----  ----------------------------------
  input         rst_x;           // Low   Reset, active low
  input         clk;             //       Clock

  input         empty;           // High  FIFO empty flag

  output        rdreq;           // High  Read request
  input         rdack;           // High  Read acknowledge
  output [10:0] raddr;           //       Read address
  input  [17:0] rdata;           //       Read data

  output        uart_req;        // High  UART transfer request
  input         uart_ack;        // High  UART transfer acknowledge
  output [17:0] uart_dat;        //       UART transfer data
    
// =====================================================================
//      Parameters
// =====================================================================
  parameter IDLE  = 2'b00;
  parameter READ  = 2'b01;
  parameter SEND  = 2'b11;

//==========================================================================
//     Wires & Regs
//==========================================================================
  wire [1:0]  sta_i;
  wire        rd_en, send_en;

  reg  [1:0]  sta_r;
  reg  [10:0] raddr_r;

//==========================================================================
//      Logic description
//==========================================================================

// ----- State Machine ----------------------------------------------
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      sta_r[1:0] <= IDLE;
    else begin
      sta_r[1:0] <= sta_i[1:0];
    end
  end

  // Call function  
  assign rd_en = rdreq & rdack;
  assign send_en = uart_req & uart_ack;

  assign sta_i[1:0] = fc_sta_i(sta_r[1:0], 
                               empty, rd_en, send_en, rdata[17:14]);

  // Function body
  function[1:0] fc_sta_i;
    input [1:0] fc_sta_r;
    input       fc_empty;
    input       fc_read;
    input       fc_send;
    input [3:0] fc_data;    
    begin
      case (fc_sta_r[1:0])   // synopsys parallel_case
      // ------------------------------------------------------------
        IDLE:  if (~fc_empty) fc_sta_i[1:0] = READ;
               else           fc_sta_i[1:0] = IDLE;
      // ------------------------------------------------------------
        READ:  if (fc_read)   fc_sta_i[1:0] = SEND;
               else           fc_sta_i[1:0] = READ;
      // ------------------------------------------------------------
        SEND:  if (fc_send) fc_sta_i[1:0] = IDLE;
               else         fc_sta_i[1:0] = SEND;
      // ------------------------------------------------------------
        default: fc_sta_i = IDLE;
      endcase
    end
  endfunction

  // FIFO read address generator
  always @(posedge clk or negedge rst_x) begin
    if (rst_x == 1'b0)
      raddr_r[10:0] <= 11'h000;
    else begin
      if (send_en) raddr_r[10:0] <= raddr_r[10:0] + 11'h001;
    end
  end


  assign rdreq = (sta_r[1:0] == READ)? 1'b1 : 1'b0;
  assign raddr[10:0] = raddr_r[10:0];

  assign uart_req = (sta_r[1:0] == SEND)? 1'b1 : 1'b0;
  assign uart_dat[17:0] = rdata[17:0];


endmodule


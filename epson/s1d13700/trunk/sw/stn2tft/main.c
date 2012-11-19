// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// $HeadURL$
// =========================================================================
//
//     This confidential and proprietary source code may be used only as
//     authorized by a licensing agreement from SEIKO EPSON CORPORATION.
//
//                (C) COPYRIGHT 2003 SEIKO EPSON CORPORATION.
//            (C) COPYRIGHT 2003 SHANGHAI EPSON ELECTRONIC CO.,LTD.
//                          ALL RIGHTS RESERVED
//
//     The entire notice above must be reproduced on all authorized copies
//     and any such reproduction must be pursuant to a licensing agreement
//     from SEIKO EPSON CORPORATION.
//
// File     : dac.c
// Author   : Handsome Huang
// Abstract : PRT17801 DAC testing sample
//
// Modification History:
// Date        By            Change Description
// ------------------------------------------------------------------------
// 2008/01/30  Handsome      First design.
//
// ========================================================================
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "stn2tft.h"
#include "logo.h"

/**************************************************************************
* Function Name: int main(void)
***************************************************************************
* Summary:
*  Testing STN2TFT LCD controller.
*
* Parameters:
*  None.
*
* Return:
*  None.
*
* Note:
*  None
**************************************************************************/
int main(void)
{
    unsigned int i, j, t, l;
    unsigned char buf[40];

/* Waiting for FPGA downloading */
    for (i=0; i<10000; i++)
    {
        for(j=0; j<10; j++)
        {
            asm("nop");
        }
    }

    LCDC_initial();

    for (i=0; i<40; i++)
    {
        buf[i] = 0;
    }

    for (i=0; i<240; i++)
    {
        LCDC_WriteDisplayRam((i*40), 40, buf);
    }

    for (i=240; i<480; i++)
    {
        LCDC_WriteDisplayRam((i*40), 40, buf);
    }

    buf[0] = 0x01;

//    for (i=118; i<119; i++)
//    {
//        LCDC_WriteDisplayRam((i*40), 1, buf);
//    }


//    LCDC_WriteDisplayRam(0x257f, 1, buf);
    LCDC_DisplayOnOff(0x01);

//    for (i=0; i<8; i++)
//	{

    LCDC_WriteDisplayRam(0, 39, buf);
    LCDC_WriteDisplayRam(80, 39, buf);

//    LCDC_DisplayOnOff(0x01);

//    LCDC_WriteDisplayRam(160, 40, buf);
//    LCDC_WriteDisplayRam(240, 40, buf);

    	//	}


//    LCDC_WriteDisplayRam(1, 39, buf);
//    LCDC_WriteDisplayRam(81, 39, buf);


//    LCDC_WriteDisplayRam(0, 40*240, (unsigned char *)bmpData);

    while(1);

    for(l=0; l<1; l++)
    {
//    	for (i=0; i<40; i++)
    	for (i=0; i<1; i++)
    	{
    		for(j=0; j<8; j++)
    		{
    			buf[i] |= (unsigned char )0x1<<j;
    			LCDC_WriteDisplayRam(0, 40, buf);
        		for(t=0; t<0xff0;t++)
        			asm("nop");

    			buf[i]=0x0;
    		}
    		for(t=0; t<0xfff0;t++)
    			asm("nop");
    	}
    }


    while(1);
}














void i2s_ch0_int(void) __attribute__ ((interrupt_handler));

  unsigned short point;
  const signed short data_left[] = {
    (signed short)0x0,
    (signed short)0x10b4,
    (signed short)0x2120,
    (signed short)0x30fb,
    (signed short)0x3fff,
    (signed short)0x4deb,
    (signed short)0x5a81,
    (signed short)0x658b,
    (signed short)0x6ed9,
    (signed short)0x7640,
    (signed short)0x7ba2,
    (signed short)0x7ee6,
    (signed short)0x7ffe,
    (signed short)0x7ee6,
    (signed short)0x7ba2,
    (signed short)0x7640,
    (signed short)0x6ed9,
    (signed short)0x658b,
    (signed short)0x5a81,
    (signed short)0x4deb,
    (signed short)0x3fff,
    (signed short)0x30fb,
    (signed short)0x2120,
    (signed short)0x10b5,
    (signed short)0x0,
    (signed short)0xef4c,
    (signed short)0xdee0,
    (signed short)0xcf05,
    (signed short)0xc001,
    (signed short)0xb215,
    (signed short)0xa57f,
    (signed short)0x9a75,
    (signed short)0x9128,
    (signed short)0x89c0,
    (signed short)0x845e,
    (signed short)0x811a,
    (signed short)0x8002,
    (signed short)0x811a,
    (signed short)0x845e,
    (signed short)0x89c0,
    (signed short)0x9127,
    (signed short)0x9a75,
    (signed short)0xa57f,
    (signed short)0xb215,
    (signed short)0xc001,
    (signed short)0xcf05,
    (signed short)0xdee0,
    (signed short)0xef4b
  };
/*
  const signed short data_right[] = {
	(signed short)0x7ffe,
	(signed short)0x7ee6,
	(signed short)0x7ba2,
	(signed short)0x7640,
	(signed short)0x6ed9,
	(signed short)0x658b,
	(signed short)0x5a81,
	(signed short)0x4deb,
	(signed short)0x3fff,
	(signed short)0x30fb,
	(signed short)0x2120,
	(signed short)0x10b5,
	(signed short)0x0,
	(signed short)0xef4c,
	(signed short)0xdee0,
	(signed short)0xcf05,
	(signed short)0xc001,
	(signed short)0xb215,
	(signed short)0xa57f,
	(signed short)0x9a75,
	(signed short)0x9128,
	(signed short)0x89c0,
	(signed short)0x845e,
	(signed short)0x811a,
	(signed short)0x8002,
	(signed short)0x811a,
	(signed short)0x845e,
	(signed short)0x89c0,
	(signed short)0x9127,
	(signed short)0x9a75,
	(signed short)0xa57f,
	(signed short)0xb215,
	(signed short)0xc001,
	(signed short)0xcf05,
	(signed short)0xdee0,
	(signed short)0xef4b,
	(signed short)0x0,
	(signed short)0x10b4,
	(signed short)0x2120,
	(signed short)0x30fb,
	(signed short)0x3fff,
	(signed short)0x4deb,
	(signed short)0x5a81,
	(signed short)0x658b,
	(signed short)0x6ed8,
	(signed short)0x7640,
	(signed short)0x7ba2,
	(signed short)0x7ee6
  };
*/
  const signed short data_right[] = {
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x0000,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0x7fff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0xffff,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000,
	(signed short)0x8000
  };

void init_port(void)
{
  // #CS --> low (select I2C address)
  *(volatile unsigned char *)0x4408 &= 0xfb; // P42 low
  *(volatile unsigned char *)0x4409 |= 0x04; // P42 output
  *(volatile unsigned char *)0x4428 &= 0xcf; // P42 function

  // I2C function
  *(volatile unsigned char *)0x442a &= 0xf5; // P50/P51 function
  *(volatile unsigned char *)0x442a |= 0x05;

  // I2S function
  *(volatile unsigned char *)0x4424 = 0x55;  // P20~P23 function
}





void init_i2c(void)
{
  *(volatile unsigned char *)0x4266 = 0x00;  // T8 stop
  *(volatile unsigned char *)0x4260 = 0x02;  // PCLK/4
  *(volatile unsigned char *)0x4262 = 0x40;  //
  *(volatile unsigned char *)0x4266 = 0x03;  // T8 run

  *(volatile unsigned char *)0x4340 = 0x01;  // I2C enable
}

void i2c_send_start(unsigned char address)
{
  unsigned short i;

  i = address | 0x200;
  *(volatile unsigned short *)0x4344 = i;
  *(volatile unsigned char *)0x4342 = 0x01;
  while(((*(volatile unsigned short *)0x4344) & 0x0200) != 0x0);
  while(((*(volatile unsigned short *)0x4342) & 0x0100) != 0x0);
  while(((*(volatile unsigned short *)0x4344) & 0x0100) != 0x0);
}

void i2c_send_byte(unsigned char data)
{
  unsigned short i;

  i = data | 0x200;
  *(volatile unsigned short *)0x4344 = i;
  while(((*(volatile unsigned short *)0x4344) & 0x0200) != 0x0);
  while(((*(volatile unsigned short *)0x4342) & 0x0100) != 0x0);
  while(((*(volatile unsigned short *)0x4344) & 0x0100) != 0x0);
}

void i2c_send_stop(unsigned char data)
{
  unsigned short i;

  i = data | 0x200;
  *(volatile unsigned short *)0x4344 = i;
  *(volatile unsigned short *)0x4342 = 0x02;
  while(((*(volatile unsigned short *)0x4342) & 0x02) != 0x0);
}

void init_dac(void)
{
  i2c_send_start(0x34);
  i2c_send_byte(0x1e);
  i2c_send_stop(0x00);

  i2c_send_start(0x34);
  i2c_send_byte(0x08);
  i2c_send_stop(0x12);

  i2c_send_start(0x34);
  i2c_send_byte(0x0a);
  i2c_send_stop(0x00);

  i2c_send_start(0x34);
  i2c_send_byte(0x10);
  i2c_send_stop(0x80);

  i2c_send_start(0x34);
  i2c_send_byte(0x0e);
  i2c_send_stop(0x01);

  i2c_send_start(0x34);
  i2c_send_byte(0x12);
  i2c_send_stop(0x01);

  i2c_send_start(0x34);
  i2c_send_byte(0x05);
  i2c_send_stop(0xfa);

  i2c_send_start(0x34);
  i2c_send_byte(0x07);
  i2c_send_stop(0xfa);

  i2c_send_start(0x34);
  i2c_send_byte(0x0c);
  i2c_send_stop(0x07);
}

void init_i2s(void)
{

  *(volatile unsigned short *)0x42f2 = 0x0101;  // Interrupt level
  *(volatile unsigned short *)0x42e0 = 0x3000;  // Interrupt clear
  *(volatile unsigned short *)0x42e2 = 0x1000;  // I2S interrupt enable
  *(volatile unsigned short *)0x4304 = 0x01;    // Interrupt enable

  *(volatile unsigned short *)0x5304 = 0x04;    // 48MHz/4=12MHz
  *(volatile unsigned short *)0x5306 = 0x001d;
  *(volatile unsigned short *)0x5300 = 0x0114;
  *(volatile unsigned short *)0x530c = 0x0001;  // Interrupt enable
  *(volatile unsigned short *)0x5308 = 0x0001;  // Start
}

void i2s_ch0_int(void)
{
  *(volatile unsigned short *)0x42e0 = 0x1000;  // Interrupt clear
  while((*(volatile unsigned short *)0x530a & 0x02) != 0x02) {
  	*(volatile unsigned short *)0x5310 = data_left[point];
  	*(volatile unsigned short *)0x5310 = data_left[point];
  	point++;
  	*(volatile unsigned short *)0x5310 = data_left[point];
  	*(volatile unsigned short *)0x5310 = data_left[point];
  	point++;
  }
  if (point == 48) point = 0;
}



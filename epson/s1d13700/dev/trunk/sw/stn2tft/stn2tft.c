// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// $HeadURL$
// =========================================================================
// File     : stn2tft.c
// Author   : Handsome Huang
// Abstract : LCDC related subroutine.
//
// Modification History:
// Date        By            Change Description
// ------------------------------------------------------------------------
// 2012/09/06  Handsome      First design.
//
// ========================================================================

#include "stn2tft.h"


/**************************************************************************
* Function Name: void LCDC_Init(void)
***************************************************************************
* Summary:
*   Initializes the LCD controller.
*
* Parameters:
*   void
*
* Return:
*   void
**************************************************************************/
void LCDC_initial(void)
{
    unsigned short address;

	LCDC_SystemSet(XRES, YRES);

    LCDC_Scroll(0x0000, 0x2580, 0x0960, 240);

    LCDC_HDotScroll(0x00);
    LCDC_SetOverlay(0x0c);

    LCDC_DisplayOnOff(0x00);
    LCDC_SetCursorMode(0x8604);

    LCDC_SetAddress(0x0234);

    LCDC_DisplayOnOff(0x01);

    address = LCDC_GetAddress();

    LCDC_SetAddress(address);

    delayUs(100);
}


/**************************************************************************
* Function Name:
* void LCDC_SystemSet(unsigned short xRes, unsigned short yRes)
***************************************************************************
* Summary:
*   Initializes the device, sets the window sizes, and selects the LCD
*   interface format.
*
* Parameters:
*   xRes -- X resolution.
*   yRes -- Y resolution.
*
* Return:
*   void
**************************************************************************/
void LCDC_SystemSet(unsigned short xRes, unsigned short yRes)
{
    unsigned char charPerLine;
    unsigned char linePerFrame;

    charPerLine  = (unsigned char)(xRes >> 3);
    linePerFrame = (unsigned char)(yRes);

    LCD_WCMD(0x40);              /* System set command                */
    LCD_WDAT(0x30);              /* REG[0x00]                         */
    LCD_WDAT(0x87);              /* REG[0x01]                         */
    LCD_WDAT(0x07);              /* REG[0x02]                         */
    LCD_WDAT(charPerLine-1);     /* REG[0x03] -- C/R = 320/8-1 = 0x27 */
    LCD_WDAT(charPerLine+32);    /* REG[0x04] -- TC/R >= C/R + 2      */
    LCD_WDAT(linePerFrame-1);    /* REG[0x05] -- L/F = 240 - 1        */
    LCD_WDAT(charPerLine);       /* REG[0x06] -- AFL = 320/8          */
    LCD_WDAT(0x00);              /* REG[0x07] -- AFH = 00             */
}


/**************************************************************************
* Function Name: void LCDC_Scroll()
***************************************************************************
* Summary:
*   Set the start address of each layer.
*
* Parameters:
*   layer1StartAddress -- Layer1 start address.
*   layer2StartAddress -- Layer2 start address.
*   layer3StartAddress -- Layer3 start address.
*   yRes               -- Y resolution.
*
* Return:
*   void
**************************************************************************/
void LCDC_Scroll(unsigned short layer1StartAddress,
                 unsigned short layer2StartAddress,
                 unsigned short layer3StartAddress,
                 unsigned short yRes)
{
	/* Scroll command   */
    LCD_WCMD(0x44);

    /* Layer 1 start address */
    LCD_WDAT((unsigned char)(layer1StartAddress&0xff));       /* REG[0x0B] */
    LCD_WDAT((unsigned char)((layer1StartAddress>>8)&0xff));  /* REG[0x0C] */
    LCD_WDAT((unsigned char)(yRes&0xff));                     /* REG[0x0D] */

    /* Layer 2 start address */
    LCD_WDAT((unsigned char)(layer2StartAddress&0xff));       /* REG[0x0E] */
    LCD_WDAT((unsigned char)((layer2StartAddress>>8)&0xff));  /* REG[0x0F] */
    LCD_WDAT((unsigned char)(yRes&0xff));                     /* REG[0x10] */

    /* Layer 3 start address */
    LCD_WDAT((unsigned char)(layer3StartAddress&0xff));       /* REG[0x11] */
    LCD_WDAT((unsigned char)((layer3StartAddress>>8)&0xff));  /* REG[0x12] */

    /* Layer 4 start address */
    LCD_WDAT(0x00);                                           /* REG[0x13] */
    LCD_WDAT(0x00);                                           /* REG[0x14] */
}

/**************************************************************************
* Function Name: void LCDC_HDotScroll(unsigned char scrollPixel)
***************************************************************************
* Summary:
*   Set the horizontal pixel scroll.
*
* Parameters:
*   void
*
* Return:
*   void
**************************************************************************/
void LCDC_HDotScroll(unsigned char scrollPixel)
{
    LCD_WCMD(0x5A);                              /* Scroll command   */
    LCD_WDAT(scrollPixel);
}

/**************************************************************************
* Function Name: void LCDC_SetOverlay(unsigned char mode)
***************************************************************************
* Summary:
*   Set LCDC overlay mode.
*
* Parameters:
*   unsigned char -- Overlay mode.
*
* Return:
*   void
**************************************************************************/
void LCDC_SetOverlay(unsigned char mode)
{
    LCD_WCMD(0x5B);                              /* Scroll command   */
    LCD_WDAT(mode);
}

/**************************************************************************
* Function Name: void LCDC_DisplayOnOff(unsigned char displayOn)
***************************************************************************
* Summary:
*   Display on/off control.
*
* Parameters:
*   unsigned char -- display On
*
* Return:
*   void
**************************************************************************/
void LCDC_DisplayOnOff(unsigned char displayOn)
{
    if (displayOn == 0)
    {
        LCD_WCMD(0x58);                           /* Scroll command   */
        LCD_WDAT(0x04);                           /* Display off      */
    }
    else
    {
        LCD_WCMD(0x59);                           /* Scroll command   */
        LCD_WDAT(0x14);                           /* Display on       */
    }

}

/**************************************************************************
* Function Name:
* void LCDC_SetAddress(unsigned short address)
***************************************************************************
* Summary:
*   Set cursor address.
*
* Parameters:
*   unsigned short address -- Cursor start address.
*
* Return:
*   void
**************************************************************************/
void LCDC_SetAddress(unsigned short address)
{
    LCD_WCMD(0x46);
    LCD_WDAT((unsigned char)(address&0xff));
    LCD_WDAT((unsigned char)((address>>8)&0xff));
}


/**************************************************************************
* Function Name:
* unsigned short LCDC_GetAddress(void)
***************************************************************************
* Summary:
*   Get cursor address.
*
* Parameters:
*  void
*
* Return:
*   unsigned short -- Cursor address.
**************************************************************************/
unsigned short LCDC_GetAddress(void)
{
    unsigned char addrLower;
    unsigned char addrUpper;
    unsigned short address;

    LCD_WCMD(0x47);
    addrLower = LCD_RDAT;
    addrUpper = LCD_RDAT;

    address = ((unsigned short)addrLower<<8) | (unsigned short)addrUpper;

    return address;
}




/**************************************************************************
* Function Name:
* void LCDC_SetCursorMode(unsigned short mode)
***************************************************************************
* Summary:
*   Set cursor mode.
*
* Parameters:
*   unsigned short mode -- Cursor mode.
*
* Return:
*   void
**************************************************************************/
void LCDC_SetCursorMode(unsigned short mode)
{
    LCD_WCMD(0x5d);
    LCD_WDAT((unsigned char)(mode&0xff));
    LCD_WDAT((unsigned char)((mode>>8)&0xff));
}


/**************************************************************************
* Function Name:
* void LCDC_WriteDisplayRam(unsigned short addr, unsigned short len,
*                           unsigned char *buf)
***************************************************************************
* Summary:
*   Write display memory.
*
* Parameters:
*  unsigned short addr -- Display memory start address
*  unsigned short len  -- Write length
*  unsigned char *buf  -- Memory buffer pointer.
*
* Return:
*   void
**************************************************************************/
void LCDC_WriteDisplayRam(unsigned short addr, unsigned short len,
                          unsigned char *buf)
{
    unsigned short i;

	/* Set start address */
    LCDC_SetAddress(addr);

    LCD_WCMD(0x42);

    for(i=0; i<len; i++ )
    {
        LCD_WDAT(*(buf+i));
    }
}

















/**************************************************************************
* Function Name: void delayUs(unsigned short time)
***************************************************************************
* Summary:
*   Us delay (not accurate).
*
* Parameters:
*   unsigned short -- Delay time.
*
* Return:
*   void
**************************************************************************/
void delayUs(unsigned short time)
{
    unsigned short i, j;
    for (i=0; i<time; i++)
    {
        for (j=0; j<10; j++)
	    {
            asm("nop");
            asm("nop");
            asm("nop");
            asm("nop");
            asm("nop");
	    }
    }
}





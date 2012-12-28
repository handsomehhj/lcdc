// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// $HeadURL$
// =========================================================================
// File     : vector.c
// Author   : Handsome Huang
// Abstract : Header file.
//
// Modification History:
// Date        By            Change Description
// ------------------------------------------------------------------------
// 2012/09/06  Handsome      First design.
//
// ========================================================================
#ifndef STN2TFT_H_
#define STN2TFT_H_

#define XRES           320
#define YRES           240

#define LCD_WDAT(X)    *(volatile unsigned char *)0x00d00000 = X; \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop")

#define LCD_RDAT       *(volatile unsigned char *)0x00d00001;     \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop")

#define LCD_WCMD(X)    *(volatile unsigned char *)0x00d00001 = X; \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop");                                \
                       asm("nop")



void LCDC_initial(void);
void LCDC_SystemSet(unsigned short xRes, unsigned short yRes);
void LCDC_Scroll(unsigned short layer1StartAddress,
                 unsigned short layer2StartAddress,
                 unsigned short layer3StartAddress,
                 unsigned short yRes);
void LCDC_HDotScroll(unsigned char scrollPixel);
void LCDC_SetOverlay(unsigned char mode);
void LCDC_DisplayOnOff(unsigned char displayOn);
void LCDC_SetAddress(unsigned short address);
unsigned short LCDC_GetAddress(void);
void LCDC_SetCursorMode(unsigned short mode);
void LCDC_WriteDisplayRam(unsigned short addr,
		                  unsigned short len,
                          unsigned char *buf);




void delayUs(unsigned short time);



#endif /* STN2TFT_H_ */

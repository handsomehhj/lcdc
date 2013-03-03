// =========================================================================
// Subversion Control:
// $Revision$
// $Date$
// $HeadURL$
// =========================================================================
// File     : vector.c
// Author   : Handsome Huang
// Abstract : S1C17801 vector table
//
// Modification History:
// Date        By            Change Description
// ------------------------------------------------------------------------
// 2012/09/06  Handsome      First design.
//
// ========================================================================

void boot(void);
void dummy(void);
void _init_cmu(void);
void _init_gpio(void);
void _init_sramc(void);
void _exit(void);


extern int main(void);

const unsigned long vector[] =
{                                   // Addr   Num   Channel
    (unsigned long)boot,            // 0x00    0    Boot
    (unsigned long)dummy,           // 0x04    1    Address error
    (unsigned long)dummy,           // 0x08    2    NMI
    (unsigned long)dummy,           // 0x0c    3    REV
    (unsigned long)dummy,           // 0x10    4    Port 0
    (unsigned long)dummy,           // 0x14    5    Port 1
    (unsigned long)dummy,           // 0x18    6    Port 2
    (unsigned long)dummy,           // 0x1c    7    Port 3
    (unsigned long)dummy,           // 0x20    8    T16-0 interrupt
    (unsigned long)dummy,           // 0x24    9    T16-1 interrupt
    (unsigned long)dummy,           // 0x28    10   A/D, out of range
    (unsigned long)dummy,           // 0x2c    11   A/D, end of conversion
    (unsigned long)dummy,           // 0x30    12   T16-0 (SOC)/ Port 4
    (unsigned long)dummy,           // 0x34    13   T16-1 (SOC)/ Port 5
    (unsigned long)dummy,           // 0x38    14   T16-2 (SOC)/ Port 6
    (unsigned long)dummy,           // 0x3c    15   T16-3 (SOC)/ Port 7
    (unsigned long)dummy,           // 0x40    16   UART-0 / Port 4
    (unsigned long)dummy,           // 0x44    17   UART-1 / Port 5
    (unsigned long)dummy,           // 0x48    18   SPI-0  / Port 6
    (unsigned long)dummy,           // 0x4c    19   I2C    / Port 7
    (unsigned long)dummy,           // 0x50    20   RTC
    (unsigned long)dummy,           // 0x54    21   T8-0 underflow
    (unsigned long)dummy,           // 0x58    22   T8-1 underflow
    (unsigned long)dummy,           // 0x5c    23   T8-2 underflow
    (unsigned long)dummy,           // 0x60    24   T8-3 underflow
    (unsigned long)dummy,           // 0x64    25   LCDC frame interrupt
    (unsigned long)dummy,           // 0x68    26   SPI-1
    (unsigned long)dummy,           // 0x6c    27   USB interrupt
    (unsigned long)dummy,           // 0x70    28   I2S FIFO empty
    (unsigned long)dummy,           // 0x74    29   I2S FIFO full
    (unsigned long)dummy,           // 0x78    30   REMC
    (unsigned long)dummy            // 0x7c    31   REV
};


/**************************************************************************
* Function Name: void _init_cmu(void)
***************************************************************************
* Summary:
*  Initialize the CMU.
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
void _init_cmu(void)
{
    // Set the pre-scaler on
    *(volatile unsigned char *)0x4020 = 0x01;
}


/**************************************************************************
* Function Name: void _init_gpio(void)
***************************************************************************
* Summary:
*  Initialize the bus related GPIO.
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
void _init_gpio(void)
{
    /* Select #CE3 ~ #CE0 */
    *(volatile unsigned char *)0x4434 = 0x55;

    /* Select #WRH, #WRL, #RD */
    *(volatile unsigned char *)0x4435 = 0x15;

    /* Select D7 ~ D0 */
    *(volatile unsigned char *)0x4432 = 0x55;
    *(volatile unsigned char *)0x4433 = 0x55;

    /* Select A22 ~ A0 */
    *(volatile unsigned char *)0x442c = 0x55;
    *(volatile unsigned char *)0x442d = 0x55;
    *(volatile unsigned char *)0x442e = 0x55;
    *(volatile unsigned char *)0x442f = 0x55;
    *(volatile unsigned char *)0x4430 = 0x55;
    *(volatile unsigned char *)0x4431 = 0x55;
}

/**************************************************************************
* Function Name: void _init_sramc(void)
***************************************************************************
* Summary:
*  Initialize the SRAM controller.
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
void _init_sramc(void)
{
    /* Wait cycle setting */
    *(volatile unsigned short *)0x5000 = 0xffff;

    /* Bus size setting */
    *(volatile unsigned short *)0x5004 = 0x0002;

    /* A0/BSL mode setting */
    *(volatile unsigned short *)0x5008 = 0x0002;
}



/**************************************************************************
* Function Name: void boot(void)
***************************************************************************
* Summary:
*  Booting program.
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
void boot(void)
{
    asm("xld    %r0, 0x0ffc");
    asm("ld.a   %sp, %r0");

    _init_cmu();
    _init_gpio();
    _init_sramc();

    main();

    _exit();
}

/**************************************************************************
* Function Name: void _dummy(void)
***************************************************************************
* Summary:
*  Dummy loop for infinity interrupt vector.
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
void dummy(void)
{
INT_LOOP:
    goto INT_LOOP;
    asm("reti");
}

/**************************************************************************
* Function Name: void _exit(void)
***************************************************************************
* Summary:
*  Execute infinity loop.
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
void _exit(void)
{
    while(1);
}













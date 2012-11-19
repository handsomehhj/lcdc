/****************************************************************************
* Subversion Control:
* $Revision: 49 $
* $Author: hjh $
* $Date: 2012-03-08 12:03:26 +0800 (周四, 2012-03-08) $
*****************************************************************************
*   This software, and associated documentation or materials belong to
*    mxnTouch TECHNOLOGY COPRORATION, may be used only as authorized
*    by a licensing agreement from mxnTouch TECHNOLOGY CORPORATION.
*
*           (C) COPYRIGHT 2011 mxnTouch TECHNOLOGY CORPORATION.
*                        ALL RIGHTS RESERVED
*
*   The entire notice above must be reproduced on all authorized copies
*   and any such reproduction must be pursuant to a licensing agreement
*   from mxnTouch TECHNOLOGY CORPORATION.
*****************************************************************************
* Description:
*   SPI serial flash command implementation.
*
* Document:
*   None
*
* Dependency:
*   None
*
* Environment:
*   Mingw GCC 4.5.2 (Win32 only)
*****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

#include "hid_drv.h"
#include "ssf.h"


/**************************************************************************
* Function Name: BOOL ssfErase(HANDLE hidHandle, BYTE mode, DWORD addr)
***************************************************************************
* Summary:
*   Erase the SPI serial flash.
*
* Parameters:
*   HANDLE hidHandle -- HID device handle.
*   BYTE mode        -- Erase mode
*                         0 --> Chip erase
*                         1 --> 64KB block erase
*                         2 --> 32KB block erase
*                         3 --> 4KB sector erase
*   DWORD addr       -- Address of block/sector
*
* Return:
*  TRUE  -- Success
*  FALSE -- Failure
**************************************************************************/
BOOL ssfErase(HANDLE hidHandle, BYTE mode, DWORD addr)
{
    WORD len;
    BYTE buffer[512];

    len = ERASE_LEN;

    buffer[CMD_CMD_ADDR]         = CMD_SSF_ERASE;
    buffer[CMD_LEN_ADDR+CMD_LSB] = len & 0xff;
    buffer[CMD_LEN_ADDR+CMD_MSB] = (len >> 8) & 0xff;

    buffer[CMD_DAT_ADDR+ERASE_MODE] = mode;
    buffer[CMD_DAT_ADDR+ERASE_ADDR+CMD_LLSB] = addr & 0xff;
    buffer[CMD_DAT_ADDR+ERASE_ADDR+CMD_LMSB] = (addr >> 8 ) & 0xff;
    buffer[CMD_DAT_ADDR+ERASE_ADDR+CMD_MLSB] = (addr >> 16) & 0xff;
    buffer[CMD_DAT_ADDR+ERASE_ADDR+CMD_MMSB] = (addr >> 24) & 0xff;

    /* Sending the command */
    if (TRUE != sendCommand(hidHandle, buffer))
    {
        printf("Can not send the command!!!\n");
        return FALSE;
    }

    if (TRUE != receiveStatus(hidHandle, buffer))
    {
        printf("Error!!!, error code is %x\n", buffer[STA_STA_ADDR]);
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

/**************************************************************************
* Function Name: BOOL ssfProgram(HANDLE hidHandle, DWORD addr, WORD length,
*                                BYTE *pData)
***************************************************************************
* Summary:
*   Program the SPI serial flash.
*
* Parameters:
*   HANDLE hidHandle -- HID device handle.
*   DWORD addr       -- Starting address
*   WORD length      -- Total bytes.
*   BYTE *pData      -- Data buffer pointer
*
* Return:
*  TRUE  -- Success
*  FALSE -- Failure
**************************************************************************/
BOOL ssfProgram(HANDLE hidHandle, DWORD addr, WORD length, BYTE *pData)
{
    DWORD i;
    BYTE buffer[512+7+4];
    WORD len;

    if (length >= 512)
    {
        printf("Do not support larger than 512 bytes programming\n");
        return FALSE;
    }

    len = PROG_LEN(length);

    buffer[CMD_CMD_ADDR]         = CMD_SSF_PROG;
    buffer[CMD_LEN_ADDR+CMD_LSB] = len & 0xff;
    buffer[CMD_LEN_ADDR+CMD_MSB] = (len >> 8) & 0xff;

    buffer[CMD_DAT_ADDR+PROG_ADDR+CMD_LLSB] = addr & 0xff;
    buffer[CMD_DAT_ADDR+PROG_ADDR+CMD_LMSB] = (addr >> 8 ) & 0xff;
    buffer[CMD_DAT_ADDR+PROG_ADDR+CMD_MLSB] = (addr >> 16) & 0xff;
    buffer[CMD_DAT_ADDR+PROG_ADDR+CMD_MMSB] = (addr >> 24) & 0xff;

    for (i=0; i<length; i++)
    {
        buffer[CMD_DAT_ADDR+PROG_DATA+i] = *pData++;
    }

    /* Sending the command */
    if (TRUE != sendCommand(hidHandle, buffer))
    {
        printf("Can not send the command!!!\n");
        return FALSE;
    }

    if (TRUE != receiveStatus(hidHandle, buffer))
    {
        printf("Error!!!, error code is %x\n", buffer[STA_STA_ADDR]);
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

/**************************************************************************
* Function Name: BOOL ssfVerify(HANDLE hidHandle, DWORD addr, WORD length,
*                               BYTE *pData)
***************************************************************************
* Summary:
*   Verify the data of the SPI serial flash.
*
* Parameters:
*   HANDLE hidHandle -- HID device handle.
*   DWORD addr       -- Starting address
*   WORD length      -- Total bytes.
*   BYTE *pData      -- Data buffer pointer
*
* Return:
*  TRUE  -- Success
*  FALSE -- Failure
**************************************************************************/
BOOL ssfVerify(HANDLE hidHandle, DWORD addr, WORD length, BYTE *pData)
{
    DWORD i;
    BYTE buffer[512+7+4];
    WORD len;
    BYTE *p;

    p = pData;

    if (length >= 512)
    {
        printf("Do not support larger than 512 bytes...\n");
        return FALSE;
    }

    len = VERIFY_LEN(length);

    buffer[CMD_CMD_ADDR]         = CMD_SSF_VERIFY;
    buffer[CMD_LEN_ADDR+CMD_LSB] = len & 0xff;
    buffer[CMD_LEN_ADDR+CMD_MSB] = (len >> 8) & 0xff;

    buffer[CMD_DAT_ADDR+VERIFY_ADDR+CMD_LLSB] = addr & 0xff;
    buffer[CMD_DAT_ADDR+VERIFY_ADDR+CMD_LMSB] = (addr >> 8 ) & 0xff;
    buffer[CMD_DAT_ADDR+VERIFY_ADDR+CMD_MLSB] = (addr >> 16) & 0xff;
    buffer[CMD_DAT_ADDR+VERIFY_ADDR+CMD_MMSB] = (addr >> 24) & 0xff;

    for (i=0; i<length; i++)
    {
        buffer[CMD_DAT_ADDR+VERIFY_DATA+i] = *p++;
    }

    /* Sending the command */
    if (TRUE != sendCommand(hidHandle, buffer))
    {
        printf("Can not send the command!!!\n");
        return FALSE;
    }

    if (TRUE != receiveStatus(hidHandle, buffer))
    {
        printf("Error!!!, error code is %x\n", buffer[STA_STA_ADDR]);
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

/**************************************************************************
* Function Name: BOOL ssfRead(HANDLE hidHandle, DWORD addr, WORD length,
*                             BYTE *pData)
***************************************************************************
* Summary:
*   Read the data from the SPI serial flash.
*
* Parameters:
*   HANDLE hidHandle -- HID device handle.
*   DWORD addr       -- Starting address
*   WORD length      -- Total bytes.
*   BYTE *pData      -- Data buffer pointer
*
* Return:
*  TRUE  -- Success
*  FALSE -- Failure
**************************************************************************/
BOOL ssfRead(HANDLE hidHandle, DWORD addr, WORD length, BYTE *pData)
{
    DWORD i;
    BYTE buffer[512+7+4];
    WORD len;
    BYTE *p;

    p = pData;

    if (length >= 512)
    {
        printf("Do not support larger than 512 bytes...\n");
        return FALSE;
    }

    len = READ_LEN;

    buffer[CMD_CMD_ADDR]         = CMD_SSF_READ;
    buffer[CMD_LEN_ADDR+CMD_LSB] = len & 0xff;
    buffer[CMD_LEN_ADDR+CMD_MSB] = (len >> 8) & 0xff;

    buffer[CMD_DAT_ADDR+READ_ADDR+CMD_LLSB] = addr & 0xff;
    buffer[CMD_DAT_ADDR+READ_ADDR+CMD_LMSB] = (addr >> 8 ) & 0xff;
    buffer[CMD_DAT_ADDR+READ_ADDR+CMD_MLSB] = (addr >> 16) & 0xff;
    buffer[CMD_DAT_ADDR+READ_ADDR+CMD_MMSB] = (addr >> 24) & 0xff;

    buffer[CMD_DAT_ADDR+READ_NUM+CMD_LSB] = length & 0xff;
    buffer[CMD_DAT_ADDR+READ_NUM+CMD_MSB] = (length >> 8 ) & 0xff;

    /* Sending the command */
    if (TRUE != sendCommand(hidHandle, buffer))
    {
        printf("Can not send the command!!!\n");
        return FALSE;
    }

    if (TRUE != receiveStatus(hidHandle, buffer))
    {
        printf("Error!!!, error code is %x\n", buffer[STA_STA_ADDR]);
        return FALSE;
    }
    else
    {
        p = pData;

        for (i=0; i<length; i++)
        {
            *p++ = buffer[STA_DAT_ADDR+i];
        }

        return TRUE;
    }
}






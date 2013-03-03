/****************************************************************************
* Subversion Control:
* $Revision$
* $Author$
* $Date$
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
*   Hex file reading API.
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

#include "hex.h"

/**************************************************************************
* Function Name: BYTE atod(BYTE Ascii);
***************************************************************************
* Summary:
*  ASCII to digital
*
* Parameters:
*  BYTE ASCII -- ASCII Character
*
* Return:
*  BYTE -- Digital number.
**************************************************************************/
BYTE atod(CHAR Ascii)
{
    if ((Ascii >= 0x30) && (Ascii <= 0x39))
    {
        return (Ascii - 0x30);
    }
    else if ((Ascii >= 0x41) && (Ascii <= 0x46))
    {
        return (Ascii- 0x37);
    }
    else if ((Ascii >= 0x61) && (Ascii <= 0x66))
    {
        return (Ascii - 0x57);
    }
    else
    {
        return 0;
    }
}

/**************************************************************************
* Function Name: BOOL hexRead(CHAR *pHexFile, HEX_DATA *pHexData)
***************************************************************************
* Summary:
*  Read the hex data and information, check the format of the hex file
*
* Parameters:
*  CHAR *pHexFile     -- Filename of the CYACD file.
*  HEX_DATA *pHexData -- Hex data pointer.
*
* Return:
*  TRUE  -- Success
*  FALSE -- Failure (HEX format error)
**************************************************************************/
BOOL hexRead(CHAR *pHexFile, HEX_DATA *pHexData)
{
    DWORD i;
    FILE *fp;
    CHAR lineBuf[150];
    WORD rowAddr, pageAddr;
    BYTE rowLength, rowMode;

    BYTE lineCheckSum;

    /* open the hex file */
    if ((fp = fopen(pHexFile, "r")) == NULL)
    {
        return FALSE;
    }

    /* Initialize data to 0, to avoid checksum problem */
    for (i=0; i<0x10000; i++)
    {
        pHexData->hexData[i] = 0xff;
    }

    for (i=0; i<0x80; i++)
    {
        pHexData->securityData[i] = 0;
    }

    pHexData->hexChecksum = 0;

    /* Start reading data */
    pageAddr = 0;

    while(fgets(lineBuf, 150, fp) != NULL)
    {
        /* Check array ID     */
        if (lineBuf[0] != ':')
        {
            return FALSE;
        }

        /* Get the row length */
        rowLength = atod(lineBuf[1])*16 + atod(lineBuf[2]);

        /* Get line data */
        rowAddr   = atod(lineBuf[3])*4096 + atod(lineBuf[4])* 256 +
                    atod(lineBuf[5])*16   + atod(lineBuf[6]);

        rowMode   = atod(lineBuf[7])*16 + atod(lineBuf[8]);

        lineCheckSum = 0;
        lineCheckSum += atod(lineBuf[1])*16 + atod(lineBuf[2]);
        lineCheckSum += atod(lineBuf[3])*16 + atod(lineBuf[4]);
        lineCheckSum += atod(lineBuf[5])*16 + atod(lineBuf[6]);
        lineCheckSum += atod(lineBuf[7])*16 + atod(lineBuf[8]);

        for (i=0; i<rowLength; i++)
        {
            lineBuf[i] = atod(lineBuf[i*2+9])*16 + atod(lineBuf[i*2+10]);
            lineCheckSum += lineBuf[i];

            switch (pageAddr)
            {
                case 0x0000:
                    if (rowMode == 0x00)
                    {
                        pHexData->hexData[rowAddr+i] = lineBuf[i];
                    }
                    break;

                case 0x0010:
                    if (rowMode == 0x00)
                    {
                        pHexData->securityData[rowAddr+i] = lineBuf[i];
                    }
                    break;

                case 0x0020:
                    if (rowMode == 0x00)
                    {
                        pHexData->hexChecksum = pHexData->hexChecksum *256;
                        pHexData->hexChecksum += (BYTE)lineBuf[i];
                    }
                    break;

                default:
                    break;
            }
        }

        lineCheckSum += atod(lineBuf[rowLength*2+9])*16 +
                        atod(lineBuf[rowLength*2+10]);

        if (lineCheckSum != 0)
        {
            return FALSE;
        }

        if (rowMode == 0x04)
        {
            pageAddr = atod(lineBuf[9])*4096 + atod(lineBuf[10])* 256 +
                       atod(lineBuf[11])*16  + atod(lineBuf[12]);
        }
        else if (rowMode == 0x01)
        {
            break;
        }
    }

    fclose(fp);

    return TRUE;
}


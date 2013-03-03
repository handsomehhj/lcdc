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
*   Program hex file to SPI serial flash
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
#include "ctrl.h"
#include "ssf.h"
#include "hex.h"

/**************************************************************************
* Function Name: BOOL programHex(CHAR *pHexFile)
***************************************************************************
* Summary:
*  Upgrade target APP f/w from the start row.
*
* Parameters:
*  CHAR *pHexFile -- HEX file name.
*
* Return:
*  TRUE  -- Success
*  FALSE -- Failure
**************************************************************************/
BOOL programHex(CHAR *pHexFile, INT appAddr)
{
//    BYTE seed;
    DWORD i, j, k;
    HANDLE hidHandle;
    BYTE *p;
    DWORD addr;
    BYTE buffer[512];
    BYTE checksum;

    /* Same as TT Bridge */
    WORD vid = 0x4b4;

    /* Same as TT Bridge */
    WORD pid = 0x8052;

/*********************************************************************
    String Descriptor: "Cypress Semiconductor"
 *********************************************************************/
    CHAR vendorName[] = {
        'C', 0, 'y', 0, 'p', 0, 'r', 0, 'e', 0, 's', 0, 's', 0, ' ', 0,
        'S', 0, 'e', 0, 'm', 0, 'i', 0, 'c', 0, 'o', 0, 'n', 0, 'd', 0,
        'u', 0, 'c', 0, 't', 0, 'o', 0,'r', 0
    };
/*********************************************************************
    String Descriptor: "True Touch Development Tools"
*********************************************************************/
    CHAR productName[] = {
        'T', 0, 'r', 0, 'u', 0, 'e', 0, ' ', 0, 'T', 0, 'o', 0, 'u', 0,
        'c', 0, 'h', 0, ' ', 0, 'D', 0, 'e', 0, 'v', 0, 'e', 0, 'l', 0,
        'o', 0, 'p', 0, 'm', 0, 'e', 0, 'n', 0, 't', 0, ' ', 0, 'T', 0,
        'o', 0, 'o', 0, 'l', 0, 's', 0
    };
/*********************************************************************/

    HEX_DATA sHexData;

    /* Read the Hex file */
    if (FALSE == hexRead(pHexFile, &sHexData))
    {
        printf("Open HEX file error!!!\n");
        return FALSE;
    }

    /* Open the USB device */
    hidHandle = openHidDevice(vid, vendorName, pid, productName);
    if (INVALID_HANDLE_VALUE == hidHandle)
    {
        printf("Can not open the HID device, please check connection!!!\n");
        printf("\n");
        return FALSE;
    }

    if (FALSE == ctrlSetOnline(hidHandle))
    {
        printf("Switch to online mode failure\n");
        return FALSE;
    }
    else
    {
        printf("Switch to online mode\n");
    }

    /* Erase the SPI serial flash */

    if (FALSE == ssfErase(hidHandle, 0, 0))
    {
        printf("SPI serial flash erase error...\n");
        return FALSE;
    }

    printf("Erase successful\n");

    /* Program hex data, total 32KB */
    addr = appAddr;
    p = &(sHexData.hexData[0]);

    for (i=0; i<512; i++)    /* Total 512 row, each row 128B */
    {
        /* Encryption */
//        seed = (BYTE)(i+1);
        for (j=0; j<128; j++)
        {
            buffer[j] = *p++;
//            buffer[j] = buffer[j] ^ seed;
//            seed++;
        }

        if (FALSE == ssfProgram(hidHandle, addr, 128, buffer))
        {
            printf("Program error at 0x%x row\n", (WORD)(addr>>7));
            return FALSE;
        }

        printf("Row %x programming successful\n", (WORD)(addr>>7));
        if (addr == 0xff80)
        {
            printf("Final row\n");
        }

        addr+=128;
    }

   addr = appAddr;

    for (i=0; i<4; i++)
    {
        if (FALSE == ssfRead(hidHandle, addr, 0x80, buffer))
        {
            printf("Read error!!!\n");
            return FALSE;
        }
        else
        {
            for (j=0; j<8; j++)
            {
                checksum = 0x10;
                printf(":10%04X00", (unsigned int)(addr+j*0x10));
                for (k=(j*0x10); k<(j*0x10+0x10); k++)
                {
                    checksum += buffer[k];
                    printf("%02X", buffer[k]);
                }

                checksum += ((unsigned int)addr+j*0x10) & 0xff;
                checksum += ((unsigned int)addr+j*0x10) >> 8;
                checksum = (~checksum +1) &0xff;
                printf("%02X\n", (unsigned int)checksum);
            }
        }

        addr+=0x80;

    }

    /* Verification */
    addr = appAddr;
    p = &(sHexData.hexData[0]);

    for(i=0; i<512; i++)
    {
        /* Encryption */
//        seed = (BYTE)(i+1);
        for (j=0; j<128; j++)
        {
            buffer[j] = *p++;
//            buffer[j] = buffer[j] ^ seed;
//            seed++;
        }
        p-=128;

        if (FALSE == ssfVerify(hidHandle, addr, 128, buffer))
        {
            printf("Verify error at 0x%x row\n", (WORD)(addr>>7));
            return FALSE;
        }

        printf("Verify row 0x%x successful\n", (WORD)(addr>>7));

        addr+=128;
        p+=128;
    }

#if 0
    p = &(sHexData.securityData[0]);

    /* Encryption */
    seed = 0x56;
    for (j=0; j<128; j++)
    {
        buffer[j] = *p++;
        buffer[j] = buffer[j] ^ seed;
        seed++;
    }

    if (FALSE == ssfVerify(hidHandle, addr, 0x80, buffer))
    {
        printf("Program security data error\n");
        return FALSE;
    }

    buffer[0] = (BYTE)(sHexData.hexChecksum & 0xff);
    buffer[1] = (BYTE)((sHexData.hexChecksum >> 8) & 0xff);
    addr+=128;

    if (FALSE == ssfVerify(hidHandle, addr, 0x4, buffer))
    {
        printf("Program checksum error\n");
        return FALSE;
    }

    printf("Security & checksum data verification successful\n");
#endif
    return TRUE;
}





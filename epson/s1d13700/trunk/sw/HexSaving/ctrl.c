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
*   Control command implementation.
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


/**************************************************************************
* Function Name: BOOL ctrlSetOnline(HANDLE hidHandle)
***************************************************************************
* Summary:
*   Set to online mode.
*
* Parameters:
*   HANDLE hidHandle -- HID device handle.
*
* Return:
*  TRUE  -- Success
*  FALSE -- Failure
**************************************************************************/
BOOL ctrlSetOnline(HANDLE hidHandle)
{
    WORD len;
    BYTE buffer[512];

    len = CTRL_MODE_PD_LEN;

    buffer[CMD_CMD_ADDR]         = CMD_CTRL_MODE;
    buffer[CMD_LEN_ADDR+CMD_LSB] = len & 0xff;
    buffer[CMD_LEN_ADDR+CMD_MSB] = (len >> 8) & 0xff;

    buffer[CMD_DAT_ADDR+CTRL_MODE_PA_MODE] = CTRL_MODE_PD_ONLINE;

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

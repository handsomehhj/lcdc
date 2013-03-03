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
*   Header file of ctrl.c
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
#ifndef __CTRL_H
#define __CTRL_H

/**************************************************************************
* Macro Definition
***************************************************************************/
#define CMD_CTRL_MODE          0x01

/**************************************************************************
* Command Parameter Definition
***************************************************************************/
#define CMD_LSB                0
#define CMD_MSB                1

#define CMD_LLSB               0
#define CMD_LMSB               1
#define CMD_MLSB               2
#define CMD_MMSB               3


#define CTRL_MODE_PA_MODE      0x0           /* Parameter offset    */

#define CTRL_MODE_PD_LEN       0x1
#define CTRL_MODE_PD_ONLINE    0x1

/**************************************************************************
* Global Function Declaration
***************************************************************************/
BOOL ctrlSetOnline(HANDLE hidHandle);




#endif/* __CTRL_H */



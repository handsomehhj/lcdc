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
*   Header file of ssf.c
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
#ifndef __SSF_H
#define __SSF_H

/**************************************************************************
* Macro Definition
***************************************************************************/
#define CMD_SSF_ERASE          0x82
#define CMD_SSF_PROG           0x83
#define CMD_SSF_READ           0x84
#define CMD_SSF_VERIFY         0x85


#define CMD_SUCCESS            0x0000


/**************************************************************************
* Command Parameter Definition
***************************************************************************/
#define CMD_LSB                0
#define CMD_MSB                1

#define CMD_LLSB               0
#define CMD_LMSB               1
#define CMD_MLSB               2
#define CMD_MMSB               3



#define ERASE_LEN              0x5           /* Command length      */
#define ERASE_MODE             0x0           /* Parameter offset    */
#define ERASE_ADDR             0x1

#define PROG_LEN(x)            (0x04 + (x))  /* Command base length */
#define PROG_ADDR              0x0           /* Parameter offset    */
#define PROG_DATA              0x4

#define READ_LEN               0x6
#define READ_ADDR              0x0           /* Parameter offset    */
#define READ_NUM               0x4

#define VERIFY_LEN(x)          (0x04 + (x))  /* Command base length */
#define VERIFY_ADDR            0x0           /* Parameter offset    */
#define VERIFY_DATA            0x4




/**************************************************************************
* Status Definition
***************************************************************************/

/**************************************************************************
* Global Function Declaration
***************************************************************************/
BOOL ssfErase(HANDLE hidHandle, BYTE mode, DWORD addr);
BOOL ssfProgram(HANDLE hidHandle, DWORD addr, WORD length, BYTE *pData);
BOOL ssfRead(HANDLE hidHandle, DWORD addr, WORD length, BYTE *pData);
BOOL ssfVerify(HANDLE hidHandle, DWORD addr, WORD length, BYTE *pData);








#endif/* __SSF_H */



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
*  Header file of hex.c
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
#ifndef __HEX_H
#define __HEX_H

/**************************************************************************
* Bootloader Revision Struct Definition
***************************************************************************/
typedef struct
{
    BYTE hexData[0x10000];          /* Total 32KB data          */
    BYTE securityData[0x80];        /* Total 128B security data */
    WORD hexChecksum;               /* APP checksum             */
}HEX_DATA;


/**************************************************************************
* Global Function Declaration
***************************************************************************/
BOOL hexRead(CHAR *pCyacdFile, HEX_DATA *pHexData);




#endif/* __HEX_H */



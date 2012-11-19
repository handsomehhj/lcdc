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
*   This is head file of the checksum.c
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

#ifndef __CHECKSUM_H
#define __CHECKSUM_H

/**************************************************************************
* Global Function Declaration
***************************************************************************/
WORD checksum(WORD wLength, BYTE *pBuf);

#endif/* __CHECKSUM_H */





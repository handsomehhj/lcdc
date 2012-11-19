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
*  Header file of hid_drv.c
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
#ifndef __HID_DRV_H
#define __HID_DRV_H

/**************************************************************************
* Packet format definitions
***************************************************************************
* [1-byte] [1-byte ] [2-byte] [n-byte] [ 2-byte ] [1-byte]
* [ SOP  ] [Command] [ Size ] [ Data ] [Checksum] [ EOP  ]  -- Command
* [ SOP  ] [Status ] [ Size ] [ Data ] [Checksum] [ EOP  ]  -- Status
***************************************************************************/
/* Command/Status offset definition */
#define MAX_CMD_BUF       512            /* Limited by PSOC3       */
#define MAX_STA_BUF       512            /* Limited by PSOC3       */

#define CMD_SOP_ADDR      0x00           /* Start of packet offset */
#define CMD_CMD_ADDR      0x01           /* Command offset         */
#define CMD_LEN_ADDR      0x02           /* Packet size offset     */
#define CMD_DAT_ADDR      0x04           /* Packet data offset     */
#define CMD_SUM_ADDR(x)   (0x04 + (x))   /* Packet checksum offset */
#define CMD_EOP_ADDR(x)   (0x06 + (x))   /* End of packet offset   */

#define STA_SOP_ADDR      0x00           /* Start of packet offset */
#define STA_STA_ADDR      0x01           /* Status offset          */
#define STA_LEN_ADDR      0x02           /* Packet size offset     */
#define STA_DAT_ADDR      0x04           /* Packet data offset     */
#define STA_SUM_ADDR(x)   (0x04 + (x))   /* Packet checksum offset */
#define STA_EOP_ADDR(x)   (0x06 + (x))   /* End of packet offset   */

#define MIN_STA_LEN       7
#define MIN_CMD_LEN       7
#define SOP               0x01           /* Start of Packet        */
#define EOP               0x17           /* End of Packet          */

#define STA_SUCCESS       0x00

/* Command/Status is LSB first */
#define CMD_LSB           0
#define CMD_MSB           1
#define STA_LSB           0
#define STA_MSB           1


/**************************************************************************
* HID definition
***************************************************************************/
#define RPT_SIZE          0x40           /* Report size depending on HID */









/**************************************************************************
* Global Function Declaration
***************************************************************************/
HANDLE openHidDevice(WORD vid, CHAR *vendorName, WORD pid, CHAR *productName);
BOOL sendCommand(HANDLE hidHandle, BYTE *pCmdBuffer);
BOOL receiveStatus(HANDLE hidHandle, BYTE *pStaBuffer);
void closeHidDevice(HANDLE hidHandle);









#endif/* __HID_DRV_H */



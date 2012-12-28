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
*   HID driver (For USB bootloader). The vendor ID is fixed to 0x4b4, while
*   the product ID is fixed to 0xf126. (Compatible with TTBridge)
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

#include <setupapi.h>
#include <ddk/hidsdi.h>
#include <ddk/hidpi.h>

#include "checksum.h"
#include "hid_drv.h"


/****************************************************************************
* Function Name: HANDLE openHidDevice(WORD vid, CHAR *vendorName,
*                                     WORD pid, CHAR *productName)
*****************************************************************************
* Summary:
*  Open HID device according to the vendor ID and product ID. The function
*  also verify the vendor name and the product name. Only all matched, the
*  HID device will be considered as target device.
*
* Parameters:
*  WORD vid          -- Vendor ID    (0x4b4 for Cypress)
*  CHAR *vendorName  -- Vendor name  ("Cypress Semiconductor")
*  WORD pid           -- Product ID   (0xf126 for TT Bridge bootloader)
*  CHAR *productName -- Product name ("Bootloader")
*
* Return:
*  HID device handle (NULL for failure)
****************************************************************************/
HANDLE openHidDevice(WORD vid, CHAR *vendorName, WORD pid, CHAR *productName)
{

    WORD i;
    DWORD size;
    CHAR buffer[512];
    GUID hidGuid;
    HDEVINFO deviceInfoList;
    SP_DEVICE_INTERFACE_DATA deviceInfo;
    SP_DEVICE_INTERFACE_DETAIL_DATA *deviceDetails = NULL;
    HANDLE hidHandle = INVALID_HANDLE_VALUE;
    HIDD_ATTRIBUTES deviceAttributes;

    /* Get GUID of HID devices */
    HidD_GetHidGuid(&hidGuid);
    deviceInfoList = SetupDiGetClassDevs(&hidGuid,
                                         NULL,
                                         NULL,
                                         DIGCF_PRESENT |
                                         DIGCF_INTERFACEDEVICE);

    deviceInfo.cbSize = sizeof(deviceInfo);

    for(i=0;;i++)
    {
        if(hidHandle != INVALID_HANDLE_VALUE)
        {
            CloseHandle(hidHandle);
            hidHandle = INVALID_HANDLE_VALUE;
        }

        if(!SetupDiEnumDeviceInterfaces(deviceInfoList, 0, &hidGuid, i,
                                        &deviceInfo))
        {
            /* no more entries, quit loop */
            break;
        }

        /* To get the actual size, first do a dummy call */
        SetupDiGetDeviceInterfaceDetail(deviceInfoList, &deviceInfo,
                                        NULL, 0, &size, NULL);
        if(deviceDetails != NULL)
        {
            /* Release previous space */
            free(deviceDetails);
        }

        deviceDetails = malloc(size);
        deviceDetails->cbSize = sizeof(*deviceDetails);

        /* This is the real call */
        SetupDiGetDeviceInterfaceDetail(deviceInfoList, &deviceInfo,
                                        deviceDetails, size, &size, NULL);

        /* Attempt opening for R/W, if it can not be opened, */
        /* It is not the target HID device                   */
        hidHandle = CreateFile(deviceDetails->DevicePath,
                               GENERIC_READ|GENERIC_WRITE,
                               FILE_SHARE_READ|FILE_SHARE_WRITE,
                               NULL,
                               OPEN_EXISTING,
                               FILE_FLAG_OVERLAPPED,
                               NULL);

        if(hidHandle == INVALID_HANDLE_VALUE)
        {
            continue;
        }

        /* Check vendor ID & product ID */
        deviceAttributes.Size = sizeof(deviceAttributes);
        HidD_GetAttributes(hidHandle, &deviceAttributes);

        if((deviceAttributes.VendorID != vid) ||
           (deviceAttributes.ProductID != pid))
        {
            /* The hidHandle will be closed in next loop */
            continue;
        }

        /* Check vendor string and product string */
        if((vendorName != NULL) && (productName != NULL))
        {
            if(!HidD_GetManufacturerString(hidHandle, buffer, sizeof(buffer)))
            {
                /* Can not get the vendor name, not target device */
                continue;
            }

            if(strcmp(vendorName, buffer) != 0)
            {
                continue;
            }

            if(!HidD_GetProductString(hidHandle, buffer, sizeof(buffer)))
            {
                /* Can not get the product name, not target device */
                continue;
            }

            if(strcmp(productName, buffer) != 0)
            {
                continue;
            }
        }

        /* Found the target device, quit loop */
        printf("device attributes: vid=0x%x pid=0x%x\n",
                deviceAttributes.VendorID,
                deviceAttributes.ProductID);
        break;
    }

    SetupDiDestroyDeviceInfoList(deviceInfoList);

    if(deviceDetails != NULL)
    {
        free(deviceDetails);
    }

    return hidHandle;
}


/****************************************************************************
* Function Name: void closeHidDevice(HANDLE hidHandle)
*****************************************************************************
* Summary:
*  Close the HID device.
*
* Parameters:
*  HANDLE hidHandle -- HID device handle
*
* Return:
*  void
****************************************************************************/
void closeHidDevice(HANDLE hidHandle)
{
    CloseHandle(hidHandle);
}


/****************************************************************************
* Function Name: BOOL sendCommand(HANDLE hidHandle, BYTE *pCmdBuffer)
*****************************************************************************
* Summary:
*   Send the command via the HID port.
*
* Parameters:
*   HANDLE hidHandle -- Handle of HID device
*   BYTE *pCmdBuffer -- Command buffer pointer.
*
* Return:
*   TRUE  -- Sent command.
*   FALSE -- Timeout.
*****************************************************************************/
BOOL sendCommand(HANDLE hidHandle, BYTE *pCmdBuffer)
{
    DWORD i, j;
    WORD wLoopTimes;
    WORD wLength;
    WORD wChecksum;
    BYTE buffer[RPT_SIZE+1];
    BYTE *pData;

    COMSTAT comStat;
    DWORD dwErrorFlags;
    OVERLAPPED overLapStat;

    /* Get the command length, LSB first              */
    wLength = (*(pCmdBuffer+CMD_LEN_ADDR+CMD_MSB))*256 +
              (*(pCmdBuffer+CMD_LEN_ADDR+CMD_LSB));

    /* Add command SOP */
    *(pCmdBuffer+CMD_SOP_ADDR) = SOP;

    /* Add checksum */
    wChecksum = checksum(CMD_SUM_ADDR(wLength), pCmdBuffer);

    *(pCmdBuffer+CMD_SUM_ADDR(wLength)+CMD_LSB) = (BYTE)(wChecksum&0xff);
    *(pCmdBuffer+CMD_SUM_ADDR(wLength)+CMD_MSB) = (BYTE)(wChecksum>>8);

    /* Add command EOP */
    *(pCmdBuffer+CMD_EOP_ADDR(wLength)) = EOP;

    /* Calculate the looping times */
    wLoopTimes = (wLength + MIN_CMD_LEN - 1) / RPT_SIZE;

    /* Start transfer, initialize the data pointer */
    pData = pCmdBuffer;

    for (i=0; i<=wLoopTimes; i++)
    {
        for (j=1; j<RPT_SIZE+1; j++)
        {
            buffer[0] = 0;            /* Report ID is fixed to 0 */
            buffer[j] = *pData++;     /* Prepare data buffer     */
        }

        memset(&overLapStat, 0, sizeof(OVERLAPPED));
        overLapStat.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);

        /* Clear the error status */
        ClearCommError(hidHandle, &dwErrorFlags, &comStat);

        /* Send the command data */
        if (FALSE == WriteFile(hidHandle, buffer, RPT_SIZE+1, &j, &overLapStat))
        {
            /* ERROR_IO_PENDING indicates under writing */
            if(ERROR_IO_PENDING == GetLastError())
            {
                /* Wait until timeout (2000ms) or finish writing */
                WaitForSingleObject(overLapStat.hEvent, 2000);
                if (FALSE == GetOverlappedResult(hidHandle, &overLapStat,
                                                 &j, FALSE))
                {
                    return FALSE;
                }

                /* Check sending bytes, should be same as RPT_SIZE + 1 */
                if ((RPT_SIZE+1) != j)
                {
                    return FALSE;
                }
            }
            else
            {
                return FALSE;
            }
        }
    }

    return TRUE;
}


/****************************************************************************
* Function Name: BOOL receiveStatus(HANDLE hidHandle, BYTE *pStaBuffer)
*****************************************************************************
* Summary:
*   Receive the status from HID port.
*
* Parameters:
*   HANDLE hidHandle -- Handle of HID device
*   BYTE *pStaBuffer -- Status buffer pointer.
*
* Return:
*   TRUE  -- Received status
*   FALSE -- Receive error.
*****************************************************************************/
BOOL receiveStatus(HANDLE hidHandle, BYTE *pStaBuffer)
{
    DWORD i;
    WORD wStaBufOffset = 0;
    WORD wLength = 0;
    WORD wChecksum;
    BYTE buffer[RPT_SIZE+1];
    BYTE *pData;

    COMSTAT comStat;
    DWORD dwErrorFlags;
    OVERLAPPED overLapStat;

    pData = pStaBuffer;

    while(1)
    {
        memset(&overLapStat, 0, sizeof(OVERLAPPED));
        overLapStat.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);

        /* Clear the error status */
        ClearCommError(hidHandle, &dwErrorFlags, &comStat);

        if (FALSE == ReadFile(hidHandle, buffer, RPT_SIZE+1, &i, &overLapStat))
        {
            /* ERROR_IO_PENDING indicates under reading */
            if(ERROR_IO_PENDING == GetLastError())
            {
                /* Wait until timeout (2000ms) or finish reading */
                WaitForSingleObject(overLapStat.hEvent, 2000);
                if (FALSE == GetOverlappedResult(hidHandle, &overLapStat,
                                                 &i, FALSE))
                {
                    return FALSE; /* Error */
                }
            }
            else
            {
                return FALSE;  /* Error */
            }
        }

        PurgeComm(hidHandle, PURGE_TXABORT | PURGE_RXABORT |
                             PURGE_TXCLEAR | PURGE_RXCLEAR);

        /* Check report size */
        if ((RPT_SIZE+1) != i)
        {
            return FALSE;     /* Not target report */
        }

        /* Save to status buffer */
        for (i=0; i<RPT_SIZE; i++)
        {
            *pData++ = buffer[i+1];
        }

        if (wStaBufOffset == 0x0)
        {
            /* Get packet length */
            wLength = (buffer[STA_LEN_ADDR+1+CMD_MSB])*256 +
                      (buffer[STA_LEN_ADDR+1+CMD_LSB]);

        }

        wStaBufOffset += RPT_SIZE;

        if (wStaBufOffset >= (wLength+MIN_STA_LEN))
        {
            /* Receiving finish */
            wStaBufOffset = 0;
            break;
        }

    }

    /* Check packet SOP */
    if (SOP != *(pStaBuffer+STA_SOP_ADDR))
    {
        return FALSE;
    }

    /* Check packet status */
    if (STA_SUCCESS != *(pStaBuffer+STA_STA_ADDR))
    {
        return FALSE;     /* Status error */
    }

    /* Check packet checksum */
    wChecksum = (*(pStaBuffer+STA_SUM_ADDR(wLength)+STA_MSB))*256 +
                (*(pStaBuffer+STA_SUM_ADDR(wLength)+STA_LSB));

    if (wChecksum != checksum(STA_SUM_ADDR(wLength), pStaBuffer))
    {
        return FALSE;
    }

    /* Check packet EOP      */
    if (EOP != *(pStaBuffer+STA_EOP_ADDR(wLength)))
    {
        return FALSE;
    }

    return TRUE;
}


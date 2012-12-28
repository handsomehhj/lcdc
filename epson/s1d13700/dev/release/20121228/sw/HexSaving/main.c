/****************************************************************************
* Subversion Control:
* $Revision: 50 $
* $Author: hjh $
* $Date: 2012-03-08 12:05:07 +0800 (周四, 2012-03-08) $
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
*  Main Loop.
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
#include <getopt.h>
#include <windows.h>

#include "program.h"

void PrintUsage(char *ProgName)
{
    printf("Usage:%s [options] [target] ...\n", ProgName);
    printf("Options:\n");
    printf("-h --help:  Display this usage information.\n"
           "-i --input: Hex file.\n"
           "-a --app:   Application number");
    exit(1);
}

INT main (INT argc, char *argv[])
{
    INT iOpt;
    char *progName;
    char *hexFile = NULL;
    char *appNum = NULL;
    int appAddr = 0x0;

    const char* const short_options="hi:a:";
    const struct option long_options[]={
        {"help",   0, NULL, 'h'},
        {"input",  1, NULL, 'c'},
        {"app",    1, NULL, 'a'},
        {NULL,     0, NULL,  0 }
    };

    progName = argv[0];
    while(strrchr(progName, '\\') != NULL)
    {
        progName = strrchr(progName, '\\') + 1;
    }

    do{
        iOpt=getopt_long(argc, argv, short_options, long_options, NULL);
        switch (iOpt)
        {
            case 'h': PrintUsage(progName);

            case 'i': hexFile = optarg;
                      break;
            case 'a': appNum = optarg;

        }
    }while(iOpt != -1);

    if (NULL == hexFile) PrintUsage(progName);

    if (*appNum == '1')
    {
        appAddr = 0x10000;
    }

    if (TRUE == programHex(hexFile, appAddr))
    {
        printf("Successfull...\n");
    }




    return 0;
}

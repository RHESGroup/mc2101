/**
 * @file  qscanf.c
 * @version 1.0 
 * @date 5 Sep, 2022
 * @copyright Copyright (C) 2022 CINI Cybersecurity National Laboratory and University of Teheran 
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 3.0 of the License, or (at your option) any
 * later version.
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from https://www.gnu.org/licenses/lgpl-3.0.txt
 * @brief basic scanf example library
 *
 */

#include "string_lib.h"
#include "uart.h"
#include <stdarg.h>

/* the following should be enough for 32 bit*/
#define SCAN_BUF_LEN 12

/* limit the input of each string to max 25 chars*/
#define SCAN_STR_MAX 25

/*special chars (whitespaces)*/
#define SPC ' '
#define TAB '\t'
#define LF  '\n'
#define VT  '\v'
#define FF  '\f'
#define CR  '\r'


static int atoi(char *str, int sign)
{
    register int res = 0;
    for (int i = sign; str[i] != '\0'; i++){
        //res=res*10 + str[i]-'0';
        res = (res<<3) + (res<<1);
        res +=  str[i] - '0';
    }
    if (sign) 
        res = -res;
    return res;
}



static void scans(char *buffer)
{
    register char chread;
    register int i;
    for(i=0; i<SCAN_STR_MAX-1; i++)
    {
        chread=uart_getchar();
        if(chread==CR)  break;
        buffer[i]=chread;
    }
    buffer[i]='\0';
}

static void scani(int *i)
{
    char scan_buf[SCAN_BUF_LEN];
    register char chread;
    register int j;
    for (j=0; j<SCAN_BUF_LEN ; j++) {
        chread=uart_getchar();
        if(chread==CR)  break;
        scan_buf[j]=chread;
    }
    scan_buf[j]='\0';
    if (scan_buf[0]=='-')  
        j=1;
    else 
        j=0;
    *i=atoi(scan_buf,j);
}

//simple scanf function, pattern recognized: '%d' '%s' '%c' '%u'
static int qscanf(const char *format, va_list va)
{
    register int sc = 0;
    for (; *format != 0; ++format) {
        if (*format == '%') {
            ++format;
            if (*format == '\0') break;
            if( *format == 's' ) {
                scans (va_arg(va, char*));
                sc++;
                continue;
            }
            if( *format == 'd' ) {
                scani (va_arg(va, int*));
                sc++;
                continue;
            }
            if( *format == 'u' ) {
                scani (va_arg(va, int*));
                sc++;
                continue;
            }
            if( *format == 'c' ) {
                scans (va_arg(va, char*));
                sc++;
                continue;
            }
            //if here, means that specifier is wrong 
            break;
        }
    }
    return sc;
}




int scanf(const char *format, ...)
{
    int pc;
    va_list va;
    va_start(va, format);
    pc = qscanf(format, va);
    va_end(va);
    return pc;
}





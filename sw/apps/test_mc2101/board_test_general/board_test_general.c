/**
 * @file  board_test_general.c
 * @version 1.0 
 * @date 12 Sep, 2022
 * @copyright Copyright (C) 2022 CINI Cybersecurity National Laboratory
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
 * @brief general board pin assignment test
 *
 */
 
#include "string_lib.h"
#include "uart.h"
#include "gpio.h"
#include "board.h"

void waste_time()
{
    for(int i=0; i<100000;i++) 
        asm volatile("nop");
}

int main(void)
{
    int choice;
    
    board_setup();
    
    //tests performed
    printf("TEST PROCEDURES:\r\n");
    printf("    TEST[0]: LEDs are output pins\r\n");
    printf("    TEST[1]: KEYs are input pins\r\n");
    printf("    TEST[2]: SWITCHs are input pins\r\n");
    
    //TEST[0]
    for(int i=LEDR0; i<=LEDR9; i++)
    {
        if(get_pin_direction(i)!=GPIO_OUT)
        {
            printf("Test[0] FAIL\r\n");
            return 1;
        }
    }    
    printf("Test[0] PASS\r\n");
    
    //TEST[1]
    for(int i=KEY1; i<=KEY3; i++)
    {
        if(get_pin_direction(i)!=GPIO_IN)
        {
            printf("Test[1] FAIL\r\n");
            return 1;
        }
    }
    printf("Test[1] PASS\r\n");
    
    //TEST[2]
    for(int i=SW0; i<=SW9; i++)
    {
        if(get_pin_direction(i)!=GPIO_IN)
        {
            printf("Test[2] FAIL\r\n");
            return 1;
        }
    }
    printf("Test[2] PASS\r\n");
    
    while(1) {
        printf("Enter led[0-9] to switch:\r\n");
        scanf("%d",&choice);
        switch(choice) 
        {
            case 0:
                printf("LEDR0\r\n"); 
                set_pin_value(LEDR0,!get_pin_value(LEDR0));
                break;
            case 1:
                printf("LEDR1\r\n"); 
                set_pin_value(LEDR1,!get_pin_value(LEDR1)); 
                break;
            case 2:
                printf("LEDR2\r\n"); 
                set_pin_value(LEDR2,!get_pin_value(LEDR2));
                break;
            case 3:
                printf("LEDR3\r\n"); 
                set_pin_value(LEDR3,!get_pin_value(LEDR3)); 
                break;
            case 4:
                printf("LEDR4\r\n"); 
                set_pin_value(LEDR4,!get_pin_value(LEDR4)); 
                break;
            case 5:
                printf("LEDR5\r\n"); 
                set_pin_value(LEDR5,!get_pin_value(LEDR5));
                break;
            case 6:
                printf("LEDR6\r\n"); 
                set_pin_value(LEDR6,!get_pin_value(LEDR6));
                break;
            case 7:
                printf("LEDR7\r\n"); 
                set_pin_value(LEDR7,!get_pin_value(LEDR7));
                break;
            case 8:
                printf("LEDR8\r\n"); 
                set_pin_value(LEDR8,!get_pin_value(LEDR8));
                break;
            case 9:
                printf("LEDR9\r\n"); 
                set_pin_value(LEDR9,!get_pin_value(LEDR9));
                break;
            default: printf("Unknown LED\r\n"); return 1;
        }
        waste_time();
    }
    return 0;
}

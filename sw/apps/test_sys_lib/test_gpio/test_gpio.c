#include "system.h"
#include "gpio.h"

int main(void)
{
    /*set gpio directions*/
    //GPIO(0)=OUTPUT
    set_pin_direction(0, GPIO_OUT);
    //GPIO(10)=OUTPUT
    set_pin_direction(10, GPIO_OUT);
    //GPIO(20)=INPUT
    set_pin_direction(20, GPIO_IN);
    //GPIO(30)=INPUT
    set_pin_direction(30, GPIO_IN);
    //check PADDIR register
    if (get_pin_direction(0)!=GPIO_OUT)
        return 1;
    if (get_pin_direction(10)!=GPIO_OUT)
        return 1;
    if (get_pin_direction(20)!=GPIO_IN)
        return 1;
    if (get_pin_direction(30)!=GPIO_IN)
        return 1;
    //if here, tests passed
    /*set output pins value*/
    set_pin_value(0, GPIO_PIN_LOW);
    set_pin_value(10, GPIO_PIN_HIGH);
    //PADIN bits 0 and 10 should mirror output values
    if(get_pin_value(0)!=GPIO_PIN_LOW)
        return 1;
    if(get_pin_value(10)!=GPIO_PIN_HIGH)
        return 1;
    //if here, tests passed
    /*enable interrupts on input pins*/
    set_pin_irq_enable(20, GPIO_INT_ENABLE);
    set_pin_irq_enable(30, GPIO_INT_ENABLE);
    //check INTEN register
    if(get_pin_irq_enable(20)!=GPIO_INT_ENABLE)
        return 1;
    if(get_pin_irq_enable(30)!=GPIO_INT_ENABLE)
        return 1;
    if(get_pin_irq_enable(21)==GPIO_INT_ENABLE)
        return 1;
    //if here, tests passed;
    /*set inttype of pins 20,30 to RISE,FALL*/
    set_pin_irq_type(20, GPIO_IRQ_RISE);
    set_pin_irq_type(20, GPIO_IRQ_FALL);
    //check TYPE registers
    if(get_pin_irq_type(20)!=GPIO_IRQ_RISE)
        return 1;
    if(get_pin_irq_type(30)!=GPIO_IRQ_FALL)
        return 1;
    //if here, tests passed
    return 0;
}
















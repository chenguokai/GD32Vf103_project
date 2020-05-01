/*
 * This file provide abstraction of the timer
 * Provide functions for timer init and interrupt handler
*/

#include "gd32vf103.h"
#include "gd32vf103_eclic.h"

/* configure the TIMER peripheral */
#define USTICK 500000
static uint64_t SystemClockSpeed;
static uint64_t Period;
static uint64_t NextInterruptTime;
int a;
void timer_begin() {
    SystemClockSpeed = 108000000/8; // the GD32VF103 divides the high speed clock by 8
    Period = USTICK;
    Period = Period * SystemClockSpeed;
    Period = Period / 100000;
    NextInterruptTime = Period;
    // Zero the clock to start with
    *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIME + 4)=0;
    *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIME )=0;
    *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP + 4)=NextInterruptTime >> 32;
    *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP ) = NextInterruptTime & 0xffffffff;
    //eclic_set_irq_level(CLIC_INT_TMR, 0);
    //eclic_irq_enable(CLIC_INT_TMR, 1, 1);
    eclic_enable_interrupt(CLIC_INT_TMR);
}
void timer_OnInterrupt() {
    // At each interrupt the Timer compare register has to be updated to the next
    // interrupt time.
    NextInterruptTime += Period;
    *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP + 4)=NextInterruptTime >> 32;
    *(volatile uint32_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP ) = NextInterruptTime & 0xffffffff;
    ++a;
    if (a & 1) {
        gpio_bit_reset(GPIOA, GPIO_PIN_1);
    } else {
        gpio_bit_set(GPIOA, GPIO_PIN_1);
    }
}

void eclic_mtip_handler() {
    timer_OnInterrupt();
}

uint64_t gettime() {
    return *(volatile uint64_t *)(TIMER_CTRL_ADDR + TIMER_MTIMECMP );
}




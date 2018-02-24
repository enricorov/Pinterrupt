
//-------------------------------------------------------------------------
//              6 is IN, 16 is OUT
//-------------------------------------------------------------------------

extern void PUT32 ( unsigned int, unsigned int );
extern unsigned int GET32 ( unsigned int );
extern void enable_irq ( void );

#define ARM_TIMER_LOD 0x3F00B400
#define ARM_TIMER_VAL 0x3F00B404
#define ARM_TIMER_CTL 0x3F00B408
#define ARM_TIMER_CLI 0x3F00B40C
#define ARM_TIMER_RIS 0x3F00B410
#define ARM_TIMER_MIS 0x3F00B414
#define ARM_TIMER_RLD 0x3F00B418
#define ARM_TIMER_DIV 0x3F00B41C
#define ARM_TIMER_CNT 0x3F00B420

#define SYSTIMERCLO 0x3F003004
#define GPFSEL0 0x3F200000
#define GPFSEL1 0x3F200004
#define GPSET0  0x3F20001C
#define GPCLR0  0x3F200028

#define GPAREN0 0x3F20007C      		//Asynchronous Detect
#define GPAREN1 0x3F200080
#define GPLEV0  0x3F200034      		//return the level of the pin
#define GPLEV1  0x3F200038
#define GPEDS0  0x3F200040      		//event detect status register
#define GPEDS1  0x3F200044
#define GPREN0  0x3F20004C      		//synchronous detect
#define GPREN1  0x3F200050


#define IRQ_BASIC 0x3F00B200
#define IRQ_PEND1 0x3F00B204
#define IRQ_PEND2 0x3F00B208
#define IRQ_FIQ_CONTROL 0x3F00B210
#define IRQ_ENABLE_BASIC 0x3F00B218
#define IRQ_DISABLE_BASIC 0x3F00B224

#define IRQ_ENABLE_2    0x3F00B214
#define IRQ_DISABLE_2   0x3F00B220

#define TIME_INT 1000000        		// in microsec

int notmain ( void )
{
    unsigned int temp;

    temp=GET32(GPFSEL1);              	// 16 is OUT
    temp&=~(7<<18);
    temp|=1<<18;
    PUT32(GPFSEL1,temp);

    temp=GET32(GPFSEL1);              	// 19 is OUT
    temp&=~(7<<27);
    temp|=1<<27;
    PUT32(GPFSEL1,temp);
    PUT32(GPSET0,1<<19);
    
    temp=GET32(GPFSEL0);              	// 6 is IN
    temp&=~(7<<18);
    temp = GET32(GPAREN0);
    temp|=1<<6;
    
    PUT32(GPAREN0, temp);
    
    PUT32(IRQ_ENABLE_2, 1<<17);     	// enabling interrupts
    PUT32(IRQ_ENABLE_BASIC,1);			
	
    PUT32(ARM_TIMER_CTL,0x003E0000);	// 0x3E is the reset for the counter
    PUT32(ARM_TIMER_LOD,TIME_INT-1);	// 1000000 is equal to 1 second
    PUT32(ARM_TIMER_RLD,TIME_INT-1);	// RLD is copied tO LOD when it reaches 0
    PUT32(ARM_TIMER_DIV,0x000000F9);	// dividing APB_CLK by 0xF9 + 1 (250) -> 1 MHz (this signal is timer_clk)
    PUT32(ARM_TIMER_CLI,0);				// writing here clears the interrupt (write only)
    PUT32(ARM_TIMER_CTL,0x003E00A2);	// 23bit counting mode, no timer_clk prescaling, enabling interrupts and the timer
    PUT32(IRQ_ENABLE_BASIC,1);			// enabling interrupts
    
    enable_irq();
    while(1) continue;
	
    return(0);
}
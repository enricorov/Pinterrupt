;@-------------------------------------------------------------------------
;@-------------------------------------------------------------------------

.globl _start
_start:
    ldr pc,reset_handler
    ldr pc,undefined_handler
    ldr pc,swi_handler
    ldr pc,prefetch_handler
    ldr pc,data_handler
    ldr pc,unused_handler
    ldr pc,irq_handler
    ldr pc,fiq_handler
reset_handler:      .word reset
undefined_handler:  .word hang
swi_handler:        .word hang
prefetch_handler:   .word hang
data_handler:       .word hang
unused_handler:     .word hang
irq_handler:        .word irq
fiq_handler:        .word hang

.equ GPEDS0, 0x3F200040
.equ GPCLR0, 0x3F200028
.equ GPSET0, 0x3F20001C
.equ GPFSEL1, 0x3F200004
.equ IRQ_BASIC, 0x3F00B200
.equ ARM_TIMER_CLI, 0x3F00B40C
.equ GPLVL0,    0x3F200034
.equ GPLVL1,    0x3F200038


reset:
	
    mrs r0,cpsr        				;@ moving to HYPERVISOR mode
    bic r0,r0,#0x1F
    orr r0,r0,#0x13
    msr spsr_cxsf,r0
    add r0,pc,#4
    msr ELR_hyp,r0
    eret

    mov r0,#0x8000
    mov r1,#0x0000
    ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}
    ldmia r0!,{r2,r3,r4,r5,r6,r7,r8,r9}
    stmia r1!,{r2,r3,r4,r5,r6,r7,r8,r9}

    ;@ (PSR_IRQ_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD2
    msr cpsr_c,r0
    mov sp,#0x8000

    ;@ (PSR_FIQ_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)
    mov r0,#0xD1
    msr cpsr_c,r0
    mov sp,#0x4000

;@ 	The following are used to set the stack for alternative operating modes.
;@  In the present case, they are commented, thus ignored.
	
    ;@ (PSR_SVC_MODE|PSR_FIQ_DIS|PSR_IRQ_DIS)		
    ;@ mov r0,#0xD3
    ;@ msr cpsr_c,r0
    ;@ mov sp,#0x8000000

    ;@ SVC MODE, IRQ ENABLED, FIQ DIS
    ;@mov r0,#0x53
    ;@msr cpsr_c, r0
    
    bl notmain
    
    
hang: b hang

.globl PUT32
PUT32:
    str r1,[r0]
    bx lr

.globl GET32
GET32:
    ldr r0,[r0]
    bx lr

.globl enable_irq
enable_irq:
    mrs r0,cpsr
    bic r0,r0,#0x80
    msr cpsr_c,r0
    bx lr

irq:
    push {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	
	LDR    R0, =GPEDS0         	;@ loading entry from memory
	LDR    R1, [R0]            	;@ loading value pointed by R0
	AND    R2, R1, #0x40       	;@ interrupt from pin 6?
	CMP    R2, #0	           	;@ if not, branch to TIMER_INT			
	BLE    TIMER_INT
	
GPIO_INT:

	ORR    R2, R1, #0x40       	;@ clearing GPIO interrupt, pin 6
	STR    R2, [R0]                
	
	LDR    R4, =GPLVL0         	;@ getting pin level for toggling
	LDR    R3, [R4]
	AND    R3, #0x10000        	;@ targeting pin 16
	CMP    R3, #0              	;@ branching to toggle
	BEQ    SET_16

CLR_16:
	LDR    R5, =GPCLR0         	;@ reading from memory
	LDR    R6, [R5]		       
	ORR    R6, #0x10000	       	;@ targeting pin 16
	STR    R6, [R5]                
	B      END_INT		       	;@ end
	
SET_16:
	LDR    R5, =GPSET0
	LDR    R6, [R5]    	       	;@ reading from memory
	ORR    R6, #0x10000			
	STR    R6, [R5]
    B      END_INT
        
        
        
TIMER_INT:
	
	LDR    R0, =ARM_TIMER_CLI  	;@ reading from memory
	LDR    R1, [R0]           
	
    ORR    R2, R1, #0      		;@ clearing timer interrupt
	STR    R2, [R0] 
	
    LDR    R4, =GPLVL0     		;@ getting pin level for toggling
	LDR    R3, [R4]
	AND    R3, #0x80000        	;@ targeting pin 19
	CMP    R3, #0              	;@ branching to toggle
	BEQ    SET_19
	
CLR_19:
	LDR    R5, =GPCLR0         	;@ reading from memory
	LDR    R6, [R5]		       
	ORR    R6, #0x80000	       	;@ targeting pin 16
	STR    R6, [R5]                
	B      END_INT		       	;@ end
	
SET_19:
	LDR    R5, =GPSET0
	LDR    R6, [R5]		       	;@ reading from memory
	ORR    R6, #0x80000			
	STR    R6, [R5]
    B      END_INT

END_INT:

    pop  {r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
    subs pc,lr,#4

# Pinterrupt

Video tutorial/presentation for this project here: https://youtu.be/ikpliEVBN0k

The purpose of this project, developed for the Computer Architectures course (AY 2017/18) at Politecnico di Torino, is to estimate the time delay of an interrupt and its standard deviation, on a Raspberry Pi 3 board PC.
The input triggering the interrupt is a square wave, exploiting the GPIO synchronous rising edge event detectors. At each interrupt occurrence, a GPIO pin is toggled. 
The code is fully bare metal, i.e. with no kernel nor OS. Really, the compiled code is put in place of the kernel, and the CPU loads it in RAM and executes it. This simplification minimizes the load on the processor core, minimizing the delay as well. 

Both the input signal and the output are then displayed on the oscilloscope, in order to evaluate the delay and estimate the uncertainty. The result we got is (2.1 +/-  0.3) us. The interrupt is accurately handled for frequencies up to 470 kHZ.

Pin 6 is set as input, by writing on the the Function Select Register the appropriate value. Same for pin 16, which is the output.
Then, as we need to capture the rising edge of the input, the "Rising Edge Detect Enable Registers" has been activated for pin 6. The interrupts are generated when the rising edge is detected, and a corresponding pin is set in the "Event Detect Status Register". 
In the handler, the pin state is checked in order to verify the source of the interrupt, since an additional timer IRQ is present to disturb the processor. Once everything's done, the interrupt is cleared by (re)setting the "Event Detect Status Register".
At this point the interrupt can be handled, toggling pin 16. In order to do so, "Pin Level Register" is read and NOTed, then either "Pin Output Clear Register" or "Pin Output Set Register" are accessed, depending on the current value.
The two registers allow us modification to the value of the output pin by either pulling it down or up.

A similar procedure is performed for the timer interrupt, on pin 19.

The processor will indefinitely run this piece of code, due to the final [while(1) continue].


# WARNING:

- Broadcom didn't release any datasheet for the Pi3 SoC (BCM2837). You'll have to refer to the BCM2835 datasheet, bearing in mind that the base address for peripherals is 0x3F000000 and NOT 0x7E000000.
- You need arm-none-eabi toolchain to compile the code.
- Rename the *.bin file to kernel7.img, otherwise the Pi won't boot it.
- You also need 'start.elf' and 'bootcode.bin' in the microSD root. Get them from here https://github.com/raspberrypi/firmware/tree/master/boot

# CONTACTS

* [Enrico Rovere](mailto:s252783@studenti.polito.it)
* [Giulio Roggero](mailto:s251311@studenti.polito.it)

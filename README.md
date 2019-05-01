## VHDL implementation of a SPI slave'ed 6 digit 7-segment display ##

### Overview ###

Verilog-based project that exposes a 6-digit seven segment display that can be addressed over a spi bus. Board design available [here](https://circuitmaker.com/Projects/Details/Andrew-Tayman/MC74ACT14-Seven-Segment)

### Main Features ###
![](https://raw.githubusercontent.com/dretay/disp_hex_mux/master/IMG_3861.jpg)
- Charlieplex'd 6 digit display for efficient pin use. 
- Board includes a simple hex inverter with schmitt trigger to help with higher speed refresh rates. 
- Each segment individually addressable. For example, here is how to setup a buspirate and use it to display abc123:

```
HiZ>m
1. HiZ
2. 1-WIRE
3. UART
4. I2C
5. SPI
6. 2WIRE
7. 3WIRE
8. LCD
x. exit(without change)

(1)>5
Set speed:
 1. 30KHz
 2. 125KHz
 3. 250KHz
 4. 1MHz

(1)>1
Clock polarity:
 1. Idle low *default
 2. Idle high

(1)>
Output clock edge:
 1. Idle to active
 2. Active to idle *default

(2)>
Input sample phase:
 1. Middle *default
 2. End

(1)>
CS:
 1. CS
 2. /CS *default

(2)>
Select output type:
 1. Open drain (H=Hi-Z, L=GND)
 2. Normal (H=3.3V, L=GND)

(1)>2

SPI>[0x01 0x0a 0x02 0x0b 0x03 0x0c 0x04 0x01 0x05 0x02 0x06 0x03]
```

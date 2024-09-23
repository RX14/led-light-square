CPU     = 0x0030_u64
CLKCTRL = 0x0060_u64
PORTA   = 0x0400_u64
TCA0    = 0x0A00_u64

CPU_CCP = Pointer(UInt8).new(CPU &+ 0x04)

CLKCTRL_MCLKCTRLB = Pointer(UInt8).new(CLKCTRL &+ 0x01)

PORTA_DIR = Pointer(UInt8).new(PORTA &+ 0x00)

TCA0_CTRLA = Pointer(UInt8).new(TCA0 &+ 0x00)
TCA0_CTRLB = Pointer(UInt8).new(TCA0 &+ 0x01)
TCA0_PER   = Pointer(UInt16).new(TCA0 &+ 0x26)
TCA0_CMP0  = Pointer(UInt16).new(TCA0 &+ 0x28)
TCA0_CMP1  = Pointer(UInt16).new(TCA0 &+ 0x2A)

CPU_CCP.value = 0xD8
CLKCTRL_MCLKCTRLB.value = 0

PORTA_DIR.value = 0xA

TCA0_CTRLB.value = 0b00110011
TCA0_PER.value = 0xffff
TCA0_CMP0.value = LED_6500_MIN &+ 3250
TCA0_CMP1.value = LED_2700_MIN &+ 1500
TCA0_CTRLA.value = 0b1

LED_6500_MIN =   28_u16
LED_2700_MIN =    9_u16
LED_6500_MAX = 5000_u16
LED_2700_MAX = 2630_u16

while true
end

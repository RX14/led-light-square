require "./bindings/*"
require "./rp2040/*"

RP2040::Bootup.init

# LED = GPIO25

IO_BANK0::GPIO25_CTRL.funcsel = :sio_25
SIO::GPIO_OE_SET.gpio_oe_set = 1_u32 << 25

loop do
  50000.times do
    XOSC::COUNT.count = 255
    while XOSC::COUNT.count != 0
    end
  end
  SIO::GPIO_OUT_XOR.gpio_out_xor = 1_u32 << 25
end

require "./bindings/*"

# LED = GPIO25

RESETS::RESET.set(
  io_bank0: false,
  pads_bank0: false,
)
until RESETS::RESET_DONE.io_bank0 && RESETS::RESET_DONE.pads_bank0
end

IO_BANK0::GPIO25_CTRL.funcsel = :sio25
SIO::GPIO_OE_SET.gpio_oe_set = 1_u32 << 25

loop do
  10000.times do
    XOSC::COUNT.count = 255
    while XOSC::COUNT.count != 0
    end
  end
  SIO::GPIO_OUT_XOR.gpio_out_xor = 1_u32 << 25
end

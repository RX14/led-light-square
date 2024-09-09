require "./bindings/*"

# Pass `{subsystem: true}` to take out of reset.
def unreset_and_wait(**args)
  # RESET.set(subsystem: false) takes a system out of reset
  RESETS::RESET.set(**args.transform_values { |v| !v })

  # Make a mask from the subsystems we are operating on
  reset_mask = RESETS::RESET.new(0).copy_with(**args).to_int

  until RESETS::RESET_DONE.value.to_int.bits_set? reset_mask
  end
end

# LED = GPIO25

# Reset all peripherals, except...
all_resets = RESETS::RESET.reset_value
RESETS::RESET.value = all_resets.copy_with(
  # Don't reset QSPI I/O, XIP needs that
  io_qspi: false,
  pads_qspi: false,
  # Don't reset PLLs, we could be running from them in a warm reset
  pll_usb: false,
  pll_sys: false,
  # Don't reset USB, syscfg, it affects USB SWD running on core 1
  usbctrl: false,
  syscfg: false,
)

# Remove resets from all peripherals which can only be clocked by clk_sys and
# clk_ref.
unreset_and_wait(
  timer: true,
  tbman: true,
  sysinfo: true,
  syscfg: true,
  pwm: true,
  pll_usb: true,
  pll_sys: true,
  pio1: true,
  pio0: true,
  pads_qspi: true,
  pads_bank0: true,
  jtag: true,
  io_qspi: true,
  io_bank0: true,
  i2c1: true,
  i2c0: true,
  dma: true,
  busctrl: true,
)

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

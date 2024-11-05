module RP2040
  # Pass `{subsystem: true}` to take out of reset.
  def self.unreset_and_wait(**args)
    # RESET.set(subsystem: false) takes a system out of reset
    RESETS::RESET.set(**args.transform_values { |v| !v })

    # Make a mask from the subsystems we are operating on
    reset_mask = RESETS::RESET.new(0).copy_with(**args).to_int

    until RESETS::RESET_DONE.value.to_int.bits_set? reset_mask
    end
  end

  def self.init_resets
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
  end
end

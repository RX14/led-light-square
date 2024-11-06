module RP2040::Bootup
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
    Resets.unreset(
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

  def self.init_clocks
    # Disable resus, in case it was left on before reset
    CLOCKS::CLK_SYS_RESUS_CTRL.enable = false

    # TODO: non-default XOSC startup delay

    XOSC::CTRL.set(enable: :enable, freq_range: :val_1_15MHZ)
    until XOSC::STATUS.stable
    end

    # Select known-good sources for CLK_SYS and CLK_REF, in case they are selecting
    # PLLs we are about to configure.
    ClockGenerator::CLK_SYS.switch_to(src: :clk_ref)
    ClockGenerator::CLK_REF.switch_to(src: :xosc_clksrc)

    # Configure CPU clock
    PLL::SYS.configure
    ClockGenerator::CLK_SYS.switch_to(aux_src: :clksrc_pll_sys)
  end

  def self.init
    init_resets
    init_clocks
  end
end

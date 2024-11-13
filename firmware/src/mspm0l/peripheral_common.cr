module MSPM0L
  def self.peripheral_set_power(gprcm : GPRCM.class, enable : Bool) : Bool forall GPRCM
    if enable
      GPRCM::PWREN.set(key: :key, enable: :enable)
    else
      GPRCM::PWREN.set(key: :key, enable: :disable)
    end

    # Wait 4 ULPCLK cycles before accessing any other registers.
    # ULPCLK seems to always be equal to CPU clock when the CPU is running.
    asm("nop; nop; nop; nop" :::: "volatile")

    enable
  end

  def self.peripheral_get_power(gprcm : GPRCM.class) : Bool forall GPRCM
    GPRCM::PWREN.enable.enable?
  end

  def self.ensure_power(gprcm : GPRCM.class) : Nil forall GPRCM
    # non-volatile load, we assume interrupts don't mess with PWREN
    pwren = GPRCM::PWREN.pointer.load
    unless GPRCM::PWREN.new(pwren).enable.enable?
      peripheral_set_power(GPRCM, true)
    end
  end
end

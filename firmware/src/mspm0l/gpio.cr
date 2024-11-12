struct MSPM0L::GPIO
  def self.peripheral_power=(enable : Bool) : Bool
    MSPM0L.peripheral_set_power(GPIOA::GPRCM0, enable)
  end

  def self.peripheral_power : Bool
    MSPM0L.peripheral_get_power(GPIOA::GPRCM0)
  end

  def self.[](num : UInt32) : GPIO
    GPIO.new(num)
  end

  def initialize(@num : UInt32)
  end

  protected def ensure_power : Nil
    unless GPIO.peripheral_power
      GPIO.peripheral_power = true
    end
  end

  enum Direction
    Input
    Output
  end

  def direction : Direction
    ensure_power

    GPIOA::DOE31_0.value.to_int.bit?(@num)
  end

  def output! : Output
    ensure_power

    GPIOA::DOESET31_0.value = GPIOA::DOESET31_0.new(1_u32 << @num)
    Output.new(@num)
  end

  struct Output
    def initialize(@num : UInt32)
    end

    def high=(state : Bool) : Bool
      if state
        GPIOA::DOUTSET31_0.value = GPIOA::DOUTSET31_0.new(1_u32 << @num)
      else
        GPIOA::DOUTCLR31_0.value = GPIOA::DOUTCLR31_0.new(1_u32 << @num)
      end

      state
    end
  end
end

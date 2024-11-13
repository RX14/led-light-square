module MSPM0L::GPIO
  def self.peripheral_power=(enable : Bool) : Bool
    MSPM0L.peripheral_set_power(GPIOA::GPRCM0, enable)
  end

  def self.peripheral_power : Bool
    MSPM0L.peripheral_get_power(GPIOA::GPRCM0)
  end

  def self.[](num : UInt32) : GPIO
    GPIO.new(num)
  end

  enum Direction
    Input
    Output
  end

  module Impl
    abstract def gpio_num : Int32

    def direction : Direction
      MSPM0L.ensure_power(GPIOA::GPRCM0)

      GPIOA::DOE31_0.value.to_int.bit?(gpio_num)
    end

    def output! : Output
      MSPM0L.ensure_power(GPIOA::GPRCM0)

      GPIOA::DOESET31_0.value = GPIOA::DOESET31_0.new(1_u32 << gpio_num)
      Output.new(gpio_num)
    end

    module Output
      abstract def gpio_num : Int32

      def high=(state : Bool) : Bool
        if state
          GPIOA::DOUTSET31_0.value = GPIOA::DOUTSET31_0.new(1_u32 << gpio_num)
        else
          GPIOA::DOUTCLR31_0.value = GPIOA::DOUTCLR31_0.new(1_u32 << gpio_num)
        end

        state
      end
    end
  end

  {% for i in 0..31 %}
    module GPIO{{i}}
      extend Impl

      def self.gpio_num : Int32
        {{i}}
      end

      module Output
        extend Impl::Output

        def self.gpio_num : Int32
          {{i}}
        end

        def self.new(gpio_num : Int32) : Output
          Output
        end
      end
    end
  {% end %}
end

require "./bindings/*"
require "./mspm0l/*"

MSPM0L.init

BASE_6500K  =   91
RANGE_6500K = 9910

BASE_2700K  =   85
RANGE_2700K = 3955

SET_6500K = BASE_6500K + (RANGE_6500K >> 1)
SET_2700K = BASE_2700K + (RANGE_2700K >> 0)

# 6500K PWM -> TIMG0_C0
IOMUX::PINCM23.set(pf: 4, pc: :connected, inena: :enable)

# 2700K PWM -> TIMG0_C1
IOMUX::PINCM13.set(pf: 3, pc: :connected, inena: :enable)

MSPM0L::Timer::G0.configure_clock(source: :busclk)
MSPM0L::Timer::G0.count_mode = :up
MSPM0L::Timer::G0.repeat = true
MSPM0L::Timer::G0.advance_source = :timclk
MSPM0L::Timer::G0.max = 65535

MSPM0L::Timer::G0::CC0.value = SET_6500K.to_u16!
MSPM0L::Timer::G0::CC0.pin_dir = :output
MSPM0L::Timer::G0::CC0.zero_pin_action = :set_high
MSPM0L::Timer::G0::CC0.compare_up_pin_action = :set_low

MSPM0L::Timer::G0::CC1.value = SET_2700K.to_u16!
MSPM0L::Timer::G0::CC1.pin_dir = :output
MSPM0L::Timer::G0::CC1.zero_pin_action = :set_high
MSPM0L::Timer::G0::CC1.compare_up_pin_action = :set_low

MSPM0L::Timer::G0.count_enable = true

MSPM0L::Opamp0.set(
  gain_bandwidth: :high,
  rri: true,
  noninverting_source: :pin0,
  inverting_source: :pin0,
  enable: true
)

MSPM0L::Opamp1.set(
  gain_bandwidth: :high,
  rri: true,
  noninverting_source: :pin0,
  inverting_source: :pin0,
  enable: true
)

until MSPM0L::Opamp0.ready? && MSPM0L::Opamp1.ready?
end

MSPM0L::Opamp0.set(output_pin_enabled: true)
MSPM0L::Opamp1.set(output_pin_enabled: true)

while true
end

# comm_bus = MSPM0L::GPIO11.output!

# while true
#   comm_bus.high = false
#   100_000.times { asm("nop" :::: "volatile") }
#   comm_bus.high = true
#   100_000.times { asm("nop" :::: "volatile") }
# end

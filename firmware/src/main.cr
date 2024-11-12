require "./bindings/*"
require "./mspm0l/*"

MSPM0L.init

commbus = MSPM0L::GPIO[11].output!
IOMUX::PINCM11.set(pf: 1, pc: :connected, inena: :enable)

while true
  commbus.high = false
  100_000.times { asm("nop" :::: "volatile") }
  commbus.high = true
  100_000.times { asm("nop" :::: "volatile") }
end

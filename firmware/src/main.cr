require "./bindings/*"
require "./mspm0l/*"

MSPM0L.init

IOMUX::PINCM11.set(pf: 1, pc: :connected, inena: :enable)

while true
end

# comm_bus = MSPM0L::GPIO11.output!

# while true
#   comm_bus.high = false
#   100_000.times { asm("nop" :::: "volatile") }
#   comm_bus.high = true
#   100_000.times { asm("nop" :::: "volatile") }
# end

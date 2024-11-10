require "./bindings/*"
require "./mspm0l/*"
MSPM0L.init

IOMUX::IOMUX_PINCM8.set(pf: 1, pc: :connected, inena: :enable)
GPIOA::GPIOA_GPRCM0::GPIOA_PWREN.set(key: :key, enable: :enable)
GPIOA::GPIOA_DOE31_0.dio8 = :enable
GPIOA::GPIOA_DOUT11_8.dio8 = :one

while true
end

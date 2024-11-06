module RP2040::PLL
  module Impl(REG)
    def configure(refdiv : UInt8 = 1, vco_freq : UInt32 = 1_500_000_000, postdiv1 : UInt8 = 6, postdiv2 : UInt8 = 2)
      # 12MHz XOSC input
      # ref_freq = 12_000_000 / refdiv

      # Feedback divisor divides VCO and is compared to ref_freq
      # fb_div = vco_freq / ref_freq
      fb_div = 125_u16

      if REG::CS.lock &&
         refdiv == REG::CS.refdiv &&
         fb_div == REG::FBDIV_INT.fbdiv_int &&
         postdiv1 == REG::PRIM.postdiv1 &&
         postdiv2 == REG::PRIM.postdiv2
        # Already set up
        return
      end

      # Reset and un-reset PLL
      case PLL
      when PLL_SYS
        RESETS::RESET.pll_sys = true
        Resets.unreset(pll_sys: true)
      when PLL_USB
        RESETS::RESET.pll_usb = true
        Resets.unreset(pll_usb: true)
      end

      REG::CS.refdiv = refdiv
      REG::FBDIV_INT.fbdiv_int = fb_div

      REG::PWR.set(
        pd: false,   # General powerdown -> off
        vcopd: false # VCO powerdown -> off
      )

      # Wait for lock
      until REG::CS.lock
      end

      # Set up post-dividers
      REG::PRIM.set(
        postdiv1: postdiv1,
        postdiv2: postdiv2
      )

      REG::PWR.postdivpd = false # Post-dividers powerdown -> off
    end
  end

  module SYS
    extend Impl(PLL_SYS)
  end
end

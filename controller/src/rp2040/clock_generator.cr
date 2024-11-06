module RP2040::ClockGenerator
  module Glitchless(CTRL, DIV, SEL)
    def switch_to(*, src : CTRL::SRC)
      # Set the glitchless mux
      CTRL.src = src

      # Wait for switch_to
      until SEL.value.to_int.bits_set? 1_u32 << src.to_int
      end
    end

    def switch_to(*, aux_src : CTRL::AUXSRC)
      # Switch_To the glitchless mux to the default clocksource if the aux mux is
      # already in use (SRC 1 is always the aux mux)
      switch_to(src: CTRL::SRC.reset_value) if CTRL.src.to_int == 1

      CTRL.auxsrc = aux_src

      # Switch_To the glitchless mux to the aux mux (SRC 1 is always the aux mux)
      switch_to(src: CTRL::SRC.new!(0x1))
    end
  end

  module CLK_SYS
    extend Glitchless(CLOCKS::CLK_SYS_CTRL, CLOCKS::CLK_SYS_DIV, CLOCKS::CLK_SYS_SELECTED)
  end

  module CLK_REF
    extend Glitchless(CLOCKS::CLK_REF_CTRL, CLOCKS::CLK_REF_DIV, CLOCKS::CLK_REF_SELECTED)
  end
end

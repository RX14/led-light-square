module MSPM0L::Timer
  enum ClockSource
    BUSCLK
    MFCLK
    LFCLK
  end

  enum CountMode
    Up
    Down
    UpDown
  end

  enum AdvanceSource
    TIMCLK
    Pin0Rise
    Pin0Fall
    Pin0Edge
    Pin0High
    Pin1Rise
    Pin1Fall
    Pin1Edge
    Pin1High

    def pin0?
      case self
      when Pin0Rise, Pin0Fall, Pin0Edge, Pin0High
        true
      else
        false
      end
    end

    def pin1?
      case self
      when Pin1Rise, Pin1Fall, Pin1Edge, Pin1High
        true
      else
        false
      end
    end
  end

  enum PinAction
    Disabled
    SetHigh
    SetLow
    Toggle
  end

  module Impl(TIMx)
    def peripheral_power=(enable : Bool) : Bool
      MSPM0L.peripheral_set_power(TIMx::GPRCM0, enable)
    end

    def peripheral_power : Bool
      MSPM0L.peripheral_get_power(TIMx::GPRCM0)
    end

    def configure_clock(*, source : ClockSource, clkdiv : Int32 = 1, prescale : Int32 = 1)
      MSPM0L.ensure_power(TIMx::GPRCM0)

      panic("Invalid timer clkdiv value") unless 1 <= clkdiv <= 8
      panic("Invalid timer prescale value") unless 1 <= prescale <= 256

      clksel = TIMx::CLKSEL.new(0)

      case source
      in .busclk?
        clksel = clksel.copy_with(busclk_sel: :enable)
      in .mfclk?
        clksel = clksel.copy_with(mfclk_sel: :enable)
      in .lfclk?
        clksel = clksel.copy_with(lfclk_sel: :enable)
      end

      TIMx::CLKSEL.value = clksel

      TIMx::CLKDIV.ratio = TIMx::CLKDIV::RATIO.new(clkdiv.to_u8! - 1)
      TIMx::COMMONREGS0::CPS.pcnt = (prescale - 1).to_u8!

      TIMx::COMMONREGS0::CCLKCTL.clken = :enabled
    end

    def count_mode=(cm : CountMode) : CountMode
      MSPM0L.ensure_power(TIMx::GPRCM0)

      case cm
      in .up?
        TIMx::COUNTERREGS0::CTRCTL.cm = :up
      in .down?
        TIMx::COUNTERREGS0::CTRCTL.cm = :down
      in .up_down?
        TIMx::COUNTERREGS0::CTRCTL.cm = :up_down
      end

      cm
    end

    def count_mode : CountMode
      MSPM0L.ensure_power(TIMx::GPRCM0)

      case TIMx::COUNTERREGS0::CTRCTL.cm
      in .up?      then CountMode::Up
      in .down?    then CountMode::Down
      in .up_down? then CountMode::UpDown
      end
    end

    def repeat=(repeat : Bool) : Bool
      MSPM0L.ensure_power(TIMx::GPRCM0)

      if repeat
        TIMx::COUNTERREGS0::CTRCTL.repeat = :val_1
      else
        TIMx::COUNTERREGS0::CTRCTL.repeat = :val_0
      end

      repeat
    end

    def repeat : Bool
      MSPM0L.ensure_power(TIMx::GPRCM0)

      TIMx::COUNTERREGS0::CTRCTL.repeat.val_1?
    end

    def advance_source=(advance_source : AdvanceSource)
      MSPM0L.ensure_power(TIMx::GPRCM0)

      case advance_source
      when .timclk?, .pin0?
        TIMx::COUNTERREGS0::CTRCTL.cac = :ccctl0_acond
        ccctl = TIMx::COUNTERREGS0::CCCTL_01_0
      when .pin1?
        TIMx::COUNTERREGS0::CTRCTL.cac = :ccctl1_acond
        ccctl = TIMx::COUNTERREGS0::CCCTL_01_1
      else
        panic("Unknown advance source")
      end

      case advance_source
      in .timclk?
        ccctl.acond = :timclk
      in .pin0_rise?, .pin1_rise?
        ccctl.acond = :cc_trig_rise
      in .pin0_fall?, .pin1_fall?
        ccctl.acond = :cc_trig_fall
      in .pin0_edge?, .pin1_edge?
        ccctl.acond = :cc_trig_edge
      in .pin0_high?, .pin1_high?
        ccctl.acond = :cc_trig_high
      end
    end

    def advance_source : AdvanceSource
      MSPM0L.ensure_power(TIMx::GPRCM0)

      case TIMx::COUNTERREGS0::CTRCTL.cac
      when .ccctl0_acond?
        case TIMx::COUNTERREGS0::CCCTL_01_0.acond
        in .timclk?       then AdvanceSource::TIMCLK
        in .cc_trig_rise? then AdvanceSource::Pin0Rise
        in .cc_trig_fall? then AdvanceSource::Pin0Fall
        in .cc_trig_edge? then AdvanceSource::Pin0Edge
        in .cc_trig_high? then AdvanceSource::Pin0High
        end
      when .ccctl1_acond?
        case TIMx::COUNTERREGS0::CCCTL_01_1.acond
        in .timclk?       then AdvanceSource::TIMCLK
        in .cc_trig_rise? then AdvanceSource::Pin1Rise
        in .cc_trig_fall? then AdvanceSource::Pin1Fall
        in .cc_trig_edge? then AdvanceSource::Pin1Edge
        in .cc_trig_high? then AdvanceSource::Pin1High
        end
      else
        panic("Unsupported CTRCTL::CAC")
      end
    end

    def load_value=(val : UInt16) : UInt16
      MSPM0L.ensure_power(TIMx::GPRCM0)

      TIMx::COUNTERREGS0::LOAD.ld = val
    end

    def load_value : UInt16
      MSPM0L.ensure_power(TIMx::GPRCM0)

      TIMx::COUNTERREGS0::LOAD.ld
    end

    def max=(max : UInt16) : UInt16
      self.load_value = max
    end

    def max : UInt16
      self.load_value
    end

    def count_enable=(enable : Bool) : Bool
      if enable
        TIMx::COUNTERREGS0::CTRCTL.en = :abled
      else
        TIMx::COUNTERREGS0::CTRCTL.en = :disabled
      end

      enable
    end

    def count_enable : Bool
      TIMx::COUNTERREGS0::CTRCTL.en.abled?
    end

    module CC(TIMx, CC, CCACT)
      def value=(val : UInt16) : UInt16
        MSPM0L.ensure_power(TIMx::GPRCM0)

        CC.ccval = val
      end

      def value : UInt16
        MSPM0L.ensure_power(TIMx::GPRCM0)

        CC.ccval
      end

      def pin_dir=(dir : GPIO::Direction) : GPIO::Direction
        MSPM0L.ensure_power(TIMx::GPRCM0)

        case CC::ADDRESS
        when TIMx::COUNTERREGS0::CC_01_0::ADDRESS
          case dir
          in .output? then TIMx::COMMONREGS0::CCPD.c0_ccp0 = :output
          in .input?  then TIMx::COMMONREGS0::CCPD.c0_ccp0 = :input
          end
        when TIMx::COUNTERREGS0::CC_01_1::ADDRESS
          case dir
          in .output? then TIMx::COMMONREGS0::CCPD.c0_ccp1 = :output
          in .input?  then TIMx::COMMONREGS0::CCPD.c0_ccp1 = :input
          end
        else
          panic("Unknown CC instance in pin_dir=")
        end

        dir
      end

      def pin_dir : GPIO::Direction
        MSPM0L.ensure_power(TIMx::GPRCM0)

        case CC::ADDRESS
        when TIMx::COUNTERREGS0::CC_01_0::ADDRESS
          case TIMx::COMMONREGS0::CCPD.c0_ccp0
          in .output? then GPIO::Direction::Output
          in .input?  then GPIO::Direction::Input
          end
        when TIMx::COUNTERREGS0::CC_01_1::ADDRESS
          case TIMx::COMMONREGS0::CCPD.c0_ccp1
          in .output? then GPIO::Direction::Output
          in .input?  then GPIO::Direction::Input
          end
        else
          panic("Unknown CC instance in pin_dir")
        end
      end

      def zero_pin_action=(action : PinAction) : PinAction
        MSPM0L.ensure_power(TIMx::GPRCM0)

        case action
        in .disabled? then CCACT.zact = :disabled
        in .set_high? then CCACT.zact = :ccp_high
        in .set_low?  then CCACT.zact = :ccp_low
        in .toggle?   then CCACT.zact = :ccp_toggle
        end

        action
      end

      def zero_pin_action : PinAction
        MSPM0L.ensure_power(TIMx::GPRCM0)

        case CCACT.zact
        in .disabled?   then PinAction::Disabled
        in .ccp_high?   then PinAction::SetHigh
        in .ccp_low?    then PinAction::SetLow
        in .ccp_toggle? then PinAction::Toggle
        end
      end

      def compare_up_pin_action=(action : PinAction) : PinAction
        MSPM0L.ensure_power(TIMx::GPRCM0)

        case action
        in .disabled? then CCACT.cuact = :disabled
        in .set_high? then CCACT.cuact = :ccp_high
        in .set_low?  then CCACT.cuact = :ccp_low
        in .toggle?   then CCACT.cuact = :ccp_toggle
        end

        action
      end

      def compare_up_pin_action : PinAction
        MSPM0L.ensure_power(TIMx::GPRCM0)

        case CCACT.cuact
        in .disabled?   then PinAction::Disabled
        in .ccp_high?   then PinAction::SetHigh
        in .ccp_low?    then PinAction::SetLow
        in .ccp_toggle? then PinAction::Toggle
        end
      end
    end
  end

  module G0
    extend Impl(TIMG0)

    module CC0
      extend Impl::CC(TIMG0, TIMG0::COUNTERREGS0::CC_01_0, TIMG0::COUNTERREGS0::CCACT_01_0)
    end

    module CC1
      extend Impl::CC(TIMG0, TIMG0::COUNTERREGS0::CC_01_1, TIMG0::COUNTERREGS0::CCACT_01_1)
    end
  end

  module G1
    extend Impl(TIMG1)

    module CC0
      extend Impl::CC(TIMG1, TIMG1::COUNTERREGS0::CC_01_0, TIMG1::COUNTERREGS0::CCACT_01_0)
    end

    module CC1
      extend Impl::CC(TIMG1, TIMG1::COUNTERREGS0::CC_01_1, TIMG1::COUNTERREGS0::CCACT_01_1)
    end
  end

  module G2
    extend Impl(TIMG2)

    module CC0
      extend Impl::CC(TIMG2, TIMG2::COUNTERREGS0::CC_01_0, TIMG2::COUNTERREGS0::CCACT_01_0)
    end

    module CC1
      extend Impl::CC(TIMG2, TIMG2::COUNTERREGS0::CC_01_1, TIMG2::COUNTERREGS0::CCACT_01_1)
    end
  end

  module G4
    extend Impl(TIMG4)

    module CC0
      extend Impl::CC(TIMG4, TIMG4::COUNTERREGS0::CC_01_0, TIMG4::COUNTERREGS0::CCACT_01_0)
    end

    module CC1
      extend Impl::CC(TIMG4, TIMG4::COUNTERREGS0::CC_01_1, TIMG4::COUNTERREGS0::CCACT_01_1)
    end
  end
end

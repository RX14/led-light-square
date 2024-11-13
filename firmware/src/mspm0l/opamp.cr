module MSPM0L
  module Opamp(OPA)
    enum GainBandwidth
      High
      Low
    end

    enum NonInvertingSource
      None
      Pin0
      Pin1
      DAC12
      DAC8
      Vref
      PreviousOpampRtop
      GPAMP
      GND
    end

    enum InvertingSource
      None
      Pin0
      Pin1
      NextOpampRbot
      Rtap
      Rtop
    end

    def ready? : Bool
      OPA::STAT.rdy.true?
    end

    def set(
      *,
      gain_bandwidth : GainBandwidth? = nil,
      rri : Bool? = nil,
      noninverting_source : NonInvertingSource? = nil,
      inverting_source : InvertingSource? = nil,
      enable : Bool? = nil,
      output_pin_enabled : Bool? = nil,
    ) : Nil
      MSPM0L.ensure_power(OPA::GPRCM0)

      unless gain_bandwidth.nil?
        case gain_bandwidth
        in .high? then gbw = OPA::CFGBASE::GBW::HIGHGAIN
        in .low?  then gbw = OPA::CFGBASE::GBW::LOWGAIN
        end
      end

      unless rri.nil?
        if rri
          rri = OPA::CFGBASE::RRI::ON
        else
          rri = OPA::CFGBASE::RRI::OFF
        end
      end

      unless noninverting_source.nil?
        case noninverting_source
        in .none?                then psel = OPA::CFG::PSEL::NC
        in .pin0?                then psel = OPA::CFG::PSEL::EXTPIN0
        in .pin1?                then psel = OPA::CFG::PSEL::EXTPIN1
        in .dac12?               then psel = OPA::CFG::PSEL::DAC12OUT
        in .dac8?                then psel = OPA::CFG::PSEL::DAC8OUT
        in .vref?                then psel = OPA::CFG::PSEL::VREF
        in .previous_opamp_rtop? then psel = OPA::CFG::PSEL::OANM1RTOP
        in .gpamp?               then psel = OPA::CFG::PSEL::GPAMP_OUT_INT
        in .gnd?                 then psel = OPA::CFG::PSEL::VSS
        end
      end

      unless inverting_source.nil?
        case inverting_source
        in .none?            then nsel = OPA::CFG::NSEL::NC
        in .pin0?            then nsel = OPA::CFG::NSEL::EXTPIN0
        in .pin1?            then nsel = OPA::CFG::NSEL::EXTPIN1
        in .next_opamp_rbot? then nsel = OPA::CFG::NSEL::OANP1RBOT
        in .rtap?            then nsel = OPA::CFG::NSEL::OANRTAP
        in .rtop?            then nsel = OPA::CFG::NSEL::OANRTOP
        end
      end

      unless output_pin_enabled.nil?
        if output_pin_enabled
          outpin = OPA::CFG::OUTPIN::ENABLED
        else
          outpin = OPA::CFG::OUTPIN::DISABLED
        end
      end

      unless enable.nil?
        if enable
          enable = OPA::CTL::ENABLE::ON
        else
          enable = OPA::CTL::ENABLE::OFF
        end
      end

      if gbw || rri
        OPA::CFGBASE.set(gbw: gbw, rri: rri)
      end

      if nsel || psel || outpin
        OPA::CFG.set(nsel: nsel, psel: psel, outpin: outpin)
      end

      if enable
        OPA::CTL.set(enable: enable)
      end
    end
  end

  module Opamp0
    extend Opamp(OPA0)
  end

  module Opamp1
    extend Opamp(OPA1)
  end
end

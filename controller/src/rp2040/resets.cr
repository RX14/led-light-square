module RP2040::Resets
  # Pass `{subsystem: true}` to take out of reset.
  def self.unreset(**args)
    # RESET.set(subsystem: false) takes a system out of reset
    RESETS::RESET.set(**args.transform_values { |v| !v })

    # Make a mask from the subsystems we are operating on
    reset_mask = RESETS::RESET.new(0).copy_with(**args).to_int

    until RESETS::RESET_DONE.value.to_int.bits_set? reset_mask
    end
  end

  def self.reset(**args)
    RESETS::RESET.set(**args)
  end
end

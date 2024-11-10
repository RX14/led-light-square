module MSPM0L
  lib MemoryLayout
    $__section_data_flashaddr : UInt32
    $__section_data_start : Void
    $__section_data_end : Void

    $__section_bss_start : Void
    $__section_bss_end : Void
  end

  def self.init_sections
    # Zero .bss (zero-initialized variables)
    zero_addr = pointerof(MemoryLayout.__section_bss_start).as(UInt32*)
    end_addr = pointerof(MemoryLayout.__section_bss_end).as(UInt32*)

    while zero_addr != end_addr
      # TODO: implement aeabi memcpy/memclr and remove volatile hack
      zero_addr.store(0, volatile: true)
      zero_addr += 1
    end

    # Copy initial .data (non-zero-initialised variables) contents to RAM
    source_addr = pointerof(MemoryLayout.__section_data_flashaddr).as(UInt32*)
    dest_addr = pointerof(MemoryLayout.__section_data_start).as(UInt32*)
    end_addr = pointerof(MemoryLayout.__section_data_end).as(UInt32*)

    while dest_addr != end_addr
      dest_addr.store(source_addr.load, volatile: true)
      dest_addr += 1
      source_addr += 1
    end
  end

  def self.init
    init_sections
  end
end

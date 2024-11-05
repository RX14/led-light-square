O = out
CRYSTAL_SVD ?= bin/crystal-svd
CRYSTAL_KECIL ?= lib/kecil/src
.PHONY: all
all: $(O)/main.elf

src/bindings/*.cr: src/bindings/rp2040.svd $(CRYSTAL_SVD) lib
	$(CRYSTAL_SVD) src/bindings/rp2040.svd

$(O)/main.o: src/main.cr src/bindings/*.cr lib
	mkdir -p $(O)
	CRYSTAL_PATH=lib:$(CRYSTAL_KECIL) crystal build --release --cross-compile --target arm-none-eabi --mcpu cortex-m0plus -o "$@" "$<" > /dev/null

$(O)/main.prechecksum.elf: $(O)/main.o $(O)/pico-boot-stage2.o
	ld.lld --emit-relocs --gc-sections -T boot/rp2040.ld --defsym=__flash_size=2048K -o "$@" $^

$(O)/main.elf: $(O)/main.prechecksum.elf bin/stage2-checksum
	bin/stage2-checksum "$<" "$@"

$(O)/pico-boot-stage2.o: boot/pico-boot-stage2.S boot/rp2040-boot-stage2.S
	clang --target=arm-none-eabi -mcpu=cortex-m0plus -c -o "$@" "$<"

bin/stage2-checksum: tools/stage2-checksum.cr
	crystal build -o "$@" "$<"

lib: shard.yml shard.lock
	shards

bin/crystal-svd: lib

.PHONY: clean
clean:
	rm -rf $(O)

.PHONY: clean-tools
clean-tools:
	rm -f bin/stage2-checksum

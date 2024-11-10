O = out
CRYSTAL ?= crystal
CRYSTAL_SVD ?= bin/crystal-svd
CRYSTAL_KECIL ?= lib/kecil/src

SOURCES := $(shell find src -name '*.cr')

.PHONY: all
all: $(O)/main.elf

lib: shard.yml shard.lock
	shards

bin/crystal-svd: lib

src/bindings/*.cr: src/bindings/mspm0l130x.svd $(CRYSTAL_SVD) lib
	$(CRYSTAL_SVD) src/bindings/mspm0l130x.svd

$(O)/main.o: src/main.cr $(SOURCES) src/bindings/*.cr lib
	mkdir -p $(O)
	CRYSTAL_PATH=lib:$(CRYSTAL_KECIL) $(CRYSTAL) build --release --cross-compile --target arm-none-eabi --mcpu cortex-m0plus -o "$@" "$<" > /dev/null

$(O)/vector_table.o: boot/vector_table.S
	clang --target=arm-none-eabi -mcpu=cortex-m0plus -c -o "$@" "$<"

$(O)/main.elf: $(O)/main.o $(O)/vector_table.o
	ld.lld --gc-sections -T boot/mspm0l.ld --defsym=__flash_size=64K --defsym=__ram_size=4K -o "$@" $^

.PHONY: clean
clean:
	rm -rf $(O)

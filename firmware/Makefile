main.elf: src/main.cr
	$(CRYSTAL) build --prelude empty --target avr-unknown-unknown --mcpu attiny202 --release --no-debug src/main.cr -o main.elf

.PHONY: clean
clean:
	rm -f main.elf

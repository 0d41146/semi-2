.PHONY: all doc build tests valid clean cmark

all: build valid

build:
	verilator --binary --trace -Isrc -top top -Wno-WIDTHEXPAND --timing src/top.v

valid: 
	@for file in $(wildcard tests/*.hex); do \
		if ! ./obj_dir/Vtop +hex_file=$$file > /dev/null; then \
			echo "\033[31m[FAIL] $$file\033[0m"; \
		else \
			echo "\033[32m[PASS] $$file\033[0m"; \
		fi; \
	done

run: build
	./obj_dir/Vtop +hex_file=tests/rv32ui-p-lb.hex

doc: 
	asciidoctor-pdf \
	  -a toc \
	  -a compress \
	  -a pdf-theme=docs-resources/themes/riscv-pdf.yml \
	  -a pdf-fontsdir=docs-resources/fonts \
	  -a scripts=cjk \
	  -o main.pdf doc/main.adoc

tests:
	$(MAKE) -C riscv-tests isa
	mkdir -p tests
	cp riscv-tests/isa/rv32ui-p-*.elf tests/

cmark:
	mkdir -p cmark
	riscv32-unknown-elf-gcc -O2 -static -nostartfiles -mcmodel=medany \
	-march=rv32i -mabi=ilp32 \
	-Tcoremark/link.ld -Icoremark -o cmark/coremark.elf \
	-DFLAGS_STR=\""-O2 -static -nostartfiles"\" \
	-DITERATIONS=10 -DCLOCKS_PER_SEC=25000000 \
	coremark/*.c coremark/crt0.S
	riscv32-unknown-elf-objcopy -O verilog cmark/coremark.elf cmark/coremark.hex
	riscv32-unknown-elf-objdump -D cmark/coremark.elf > cmark/coremark.dump

cmark-run: cmark
	./obj_dir/Vtop +hex_file=cmark/coremark.hex

hex: tests
	for elf in $(wildcard tests/*.elf); do \
		riscv32-unknown-elf-objcopy -O verilog $$elf tests/$$(basename $$elf .elf).hex; \
	done

clean:
	rm -rf obj_dir

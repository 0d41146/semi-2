.PHONY: all doc build tests valid clean

all: build valid

build:
	verilator --binary --trace -Isrc -top top -Wno-WIDTHEXPAND --timing src/top.v

valid: 
	@for file in $(wildcard tests/*.hex); do \
		echo "Testing $$file"; \
		if ! ./obj_dir/Vtop +hex_file=$$file > /dev/null; then \
			echo "Test failed for $$file"; \
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

hex: tests
	for elf in $(wildcard tests/*.elf); do \
		riscv32-unknown-elf-objcopy -O verilog $$elf tests/$$(basename $$elf .elf).hex; \
	done

clean:
	rm -rf obj_dir

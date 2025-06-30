.PHONY: all clean

build:
	verilator --binary -Isrc -top top -Wno-WIDTHEXPAND --timing src/top.v

run: build
	./obj_dir/Vtop

doc: 
	asciidoctor-pdf \
	  -a toc \
	  -a compress \
	  -a pdf-theme=docs-resources/themes/riscv-pdf.yml \
	  -a pdf-fontsdir=docs-resources/fonts \
	  -a scripts=cjk \
	  -o main.pdf main.adoc

clean:
	rm -rf obj_dir

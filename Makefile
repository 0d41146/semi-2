.PHONY: all clean
all: 
	asciidoctor-pdf \
	  -a toc \
	  -a compress \
	  -a pdf-theme=docs-resources/themes/riscv-pdf.yml \
	  -a pdf-fontsdir=docs-resources/fonts \
	  -a scripts=cjk \
	  -o main.pdf main.adoc
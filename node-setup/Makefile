pdf_files = README.pdf AWS.pdf build.pdf ekg.pdf prometheus.pdf logging.pdf topology.pdf address.pdf tx.pdf
png_files = cli.png

.PHONE: all
all: $(pdf_files) cli.pdf

$(pdf_files): %.pdf: %.md
	pandoc -f markdown -t latex -o $@ $<

$(png_files): %.png: %.dot
	dot -Tpng $< -o $@

cli.pdf: cli.png cli.md
	pandoc -f markdown -t latex -o cli.pdf cli.md

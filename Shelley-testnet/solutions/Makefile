pdf_files = Exercise-1-solutions.pdf Exercise-2-solutions.pdf Exercise-4-solutions.pdf Exercise-5-solutions.pdf
png_files = topology.png

.PHONE: all
all: $(pdf_files) Exercise-6-solutions.pdf

$(pdf_files): %.pdf: %.md
	pandoc -f markdown -t latex -o $@ $<

$(png_files): %.png: %.dot
	dot -Tpng $< -o $@

Exercise-6-solutions.pdf: topology.png Exercise-6-solutions.md
	pandoc -f markdown -t latex -o Exercise-6-solutions.pdf Exercise-6-solutions.md

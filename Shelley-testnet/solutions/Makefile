pdf_files = pioneers-exercise-1-solutions.pdf pioneers-exercise-2-solutions.pdf pioneers-exercise-4-solutions.pdf pioneers-exercise-5-solutions.pdf
png_files = topology.png

.PHONE: all
all: $(pdf_files) pioneers-exercise-6-solutions.pdf

$(pdf_files): %.pdf: %.md
	pandoc -f markdown -t latex -o $@ $<

$(png_files): %.png: %.dot
	dot -Tpng $< -o $@

pioneers-exercise-6-solutions.pdf: topology.png pioneers-exercise-6-solutions.md
	pandoc -f markdown -t latex -o pioneers-exercise-6-solutions.pdf pioneers-exercise-6-solutions.md

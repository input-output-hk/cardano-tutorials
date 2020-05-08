pdf_files = README.pdf AWS.pdf build.pdf ekg.pdf prometheus.pdf logging.pdf topology.pdf

.PHONE: all
all: $(pdf_files)

$(pdf_files): %.pdf: %.md
	pandoc -f markdown -t latex -o $@ $<

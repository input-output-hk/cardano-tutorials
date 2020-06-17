pdf_files = README.pdf \
			000_AWS.pdf \
			000_install.pdf \
			010_getConfigFiles_AND_Connect.pdf \
			011_cli.pdf \
			012_understanding-config-files.pdf \
			020_keys_and_addresses.pdf \
			030_faucet.pdf \
			040_transactions.pdf \
			050_register_key.pdf \
			060_node_keys.pdf \
			061_KES_period.pdf \
			070_core_relay.pdf \
			080_register_stakepool.pdf \
			081_start_your_nodes.pdf \
			090_retire_stakepool.pdf \
			091_logging.pdf \
			092_ekg.pdf \
			093_prometheus.pdf
png_files = 011_cli.png

.PHONE: all
all: $(pdf_files) 011_cli.pdf

$(pdf_files): %.pdf: %.md
	pandoc -f markdown -t latex -o $@ $<

$(png_files): %.png: %.dot
	dot -Tpng $< -o $@

011_cli.pdf: 011_cli.png 011_cli.md
	pandoc -f markdown -t latex -o 011_cli.pdf 011_cli.md

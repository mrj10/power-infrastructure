all: install

install:
	cp make_msr_world_readable.sh /etc/init.d/
	update-rc.d make_msr_world_readable.sh defaults

install_likwid:
	sudo apt-get install mercurial perl
	hg clone https://code.google.com/p/likwid/
	sed -i 's/COMPILER = MIC/COMPILER = GCC/g' likwid/config.mk
	sed -i 's/ENABLE_SNB_UNCORE = false/ENABLE_SNB_UNCORE = true/g' likwid/config.mk
	sed -i 's/INSTRUMENT_BENCH = false/INSTRUMENT_BENCH = true/g' likwid/config.mk
	make -C likwid
	sudo make -C likwid install

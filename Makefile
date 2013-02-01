all: install

install:
	cp make_msr_world_readable.sh /etc/init.d/
	update-rc.d make_msr_world_readable.sh defaults

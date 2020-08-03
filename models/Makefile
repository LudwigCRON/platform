PREFIX=~/Applications/vlsi/iverilog-10_3/

.PHONY: all %.vpi

clean:
	rm -f *.o

all: hello.vpi tasks.vpi
	@echo done

%.o: %.c
	#gcc -c -fpic -I/usr/local/Cellar/icarus-verilog/10.3/include/iverilog/ $<

%.vpi: %.c
	#gcc -shared -o $@ $< -L/usr/local/Cellar/icarus-verilog/10.3/lib/ -lvpi
	$(PREFIX)iverilog-vpi $<
	mv $@ ./vpi/
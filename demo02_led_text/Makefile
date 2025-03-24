DUT:=dut_icarus
SRC:=top_tb.v
SRC+=top.v
#SRC:=dut_tb.v
#SRC+=dut.v
SRC+=sequencer.v
SRC+=spi_master.v
#SRC+=lis3dh_stub.v
IVOPT:=-DDUT_VCD=\"$(DUT).vcd\"
IVOPT+=-DSPI=1
IVOPT+=-DSIMULATION=1
IVOPT+=-DBOARD_ID=0
IVOPT+=-DBOARD_CK=32000000
IVOPT+=-D__UARTSPEED__=115200

QUARTUS:=~/intelFPGA_lite/17.0
QBIN:=$(QUARTUS)/quartus/bin
BIT:=output_files/test0.sof

all: $(BIT)
#all: $(DUT).vcd

memory_init.bin: darkriscv/src/darksocv.bin
	cp -f $< $@

memory_init.mem: darkriscv/src/darksocv.mem
	cp -f $< $@

memory_init.mif: memory_init.bin
	./bin2mif.sh

view: $(DUT).vcd
#	gtkwave $< &
	gtkwave $< $(DUT).gtkw &

.PRECIOUS:$(DUT).vcd
$(DUT).vcd: $(DUT).output
	vvp $<

$(DUT).output: $(SRC)
	iverilog $(IVOPT) -o $@ $(SRC)

$(BIT): $(SRC)
	$(QBIN)/quartus_sh --flow compile test0

program: $(BIT)
	$(QBIN)/quartus_pgm -c Arrow-USB-Blaster test0.cdf

clean:
	rm -f $(DUT).output $(DUT).vcd
	rm -rf db incremental_db output_files simulation

DUT:=dut_icarus
SRC:=dut.v dut_tb.v
SRC+=sequencer.v
SRC+=spi_master.v
SRC+=lis3dh_stub.v
SRC+=darkriscv/rtl/darksocv.v
SRC+=darkriscv/rtl/darkpll.v
SRC+=darkriscv/rtl/darkbridge.v
SRC+=darkriscv/rtl/darkriscv.v
SRC+=darkriscv/rtl/darkram.v
SRC+=darkriscv/rtl/darkio.v
SRC+=darkriscv/rtl/darkuart.v
IVOPT:=-DDUT_VCD=\"$(DUT).vcd\" -I darkriscv/rtl
IVOPT+=-DSPI=1
IVOPT+=-DSIMULATION=1
IVOPT+=-DBOARD_ID=0
IVOPT+=-DBOARD_CK=32000000
IVOPT+=-D__UARTSPEED__=115200

all: $(DUT).vcd

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

$(DUT).output: memory_init.mem $(SRC)
	iverilog $(IVOPT) -o $@ $(SRC)

clean:
	rm -f $(DUT).output $(DUT).vcd

DUT:=dut_icarus
SRC:=dut.v dut_tb.v
SRC+=sequencer.v
SRC+=spi_master.v
SRC+=lis3dh_stub.v
SRC+=rtl/darksocv.v
SRC+=rtl/darkpll.v
SRC+=rtl/darkbridge.v
SRC+=rtl/darkriscv.v
SRC+=rtl/darkram.v
SRC+=rtl/darkio.v
SRC+=rtl/darkuart.v
IVOPT:=-DDUT_VCD=\"$(DUT).vcd\" -I rtl
IVOPT+=-DSPI=1
IVOPT+=-DSIMULATION=1
IVOPT+=-DBOARD_ID=0
IVOPT+=-DBOARD_CK=32000000
IVOPT+=-D__UARTSPEED__=115200

all: $(DUT).vcd

view: $(DUT).vcd
#	gtkwave $< &
	gtkwave $< $(DUT).gtkw &

.PRECIOUS:$(DUT).vcd
$(DUT).vcd: $(DUT).output
	vvp $<

$(DUT).output: $(SRC)
	iverilog $(IVOPT) -o $@ $^

clean:
	rm -f $(DUT).output $(DUT).vcd

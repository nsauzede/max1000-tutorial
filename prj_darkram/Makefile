DUT:=dut_icarus
SRC:=../darkriscv/rtl/darkram.v dut.v dut_tb.v
IVOPT:=-D DUT_VCD=\"$(DUT).vcd\" -D SIMULATION

all: $(DUT).vcd

view: $(DUT).vcd
#	gtkwave $< &
	gtkwave $< $(DUT).gtkw &

$(DUT).vcd: $(DUT).output
	vvp $<

$(DUT).output: $(SRC)
	iverilog $(IVOPT) -o $@ $^

clean:
	rm -f $(DUT).output $(DUT).vcd

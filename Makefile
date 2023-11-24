TARGET=DHT11
TOP=DHT11

OBJS+=DHT11.v ReadModule.v DelayModule.v DivisorFrecuencia.v

# TRELLIS=/usr/local/share/trellis

# all: ${TARGET}.bit ${TARGET}.svf
all: ${TARGET}.bit

$(TARGET).json: $(OBJS)
	yosys -p "synth_ecp5 -json $@" $(OBJS)

$(TARGET)_out.config: $(TARGET).json
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf --freq 65 --lpf-allow-unconstrained

$(TARGET).bit: $(TARGET)_out.config
	ecppack --svf ${TARGET}.svf $< $@

configure_lattice: ${TARGET}.bit   # TDI:TDO:TCK:TMS
#	sudo openFPGALoader -c ft232RL --pins=1:2:0:3 -m ${TARGET}.bit 	
	sudo openFPGALoader -c ft232RL --pins=RXD:RTS:TXD:CTS -m ${TARGET}.bit 

clean:
	rm -f *.svf *.bit *.config *.json *.ys


.PHONY: prog clean

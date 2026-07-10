
SRC_DIR  = ../src
export SRC_DIR

VLOG_TOP = tb_mul
VLOG_TB  = ../tb/tb_mul.sv

VLOG = iverilog -g2012 -Wall -Wno-timescale
VSIM = vvp -n

$(VLOG_TOP).vvp:
	@$(VLOG) $(VLOG_FLAGS) -f $(VLOG_FLIST) -o $@ -s $(VLOG_TOP) $(VLOG_TB)

vcd: $(VLOG_TOP).vvp
	@$(VSIM) $< -vcd

run: $(VLOG_TOP).vvp
	@$(VSIM) $< -vcd-none

clean:
	@rm -f *.vvp
	@rm -f *.vcd

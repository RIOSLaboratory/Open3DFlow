export DESIGN_NICKNAME = top_die
export DESIGN_NAME = top_die
export PLATFORM    = gf180
export PLACE_DENSITY          = 0.7

BLOCKS = mem_64_16_gf180 \
		mem_64_32_gf180

export MACRO_FOLDER = bottom_macro
export MACRO_PLACEMENT_TCL = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/macro.tcl

export DIE_AREA = 0 0 3220 2220
export CORE_AREA = 10 10 3210 2210
export VERILOG_FILES = ./designs/src/$(DESIGN_NICKNAME)/*.v
export SDC_FILE      = ./designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

export MACRO_PLACE_HALO    = 1 1
export MACRO_PLACE_CHANNEL = 0 0

export GPL_TIMING_DRIVEN = 1

export IS_CHIP = 1

export MIN_ROUTING_LAYER = Metal1
export MAX_ROUTING_LAYER = Metal4

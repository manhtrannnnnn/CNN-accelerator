# Makefile to compile and simulate qadd and qadd_tb

# Name of the simulation output file
OUT = simulation
# Verilog source files
SRC_DIR = ../../source
SRC_FILES = $(wildcard $(SRC_DIR)/*.v)
INC_DIR = $(SRC_DIR)
TB_FILE = pooler_tb.v
# Waveform file for use in GTKWave
WAVEFORM = wave.vcd

# Main rule: compile and run the simulation
all: run

# Compile Verilog files into a simulation output file
compile:
	@echo "Compiling Verilog files..."
	iverilog -I $(INC_DIR) -o $(OUT) $(SRC_FILES) $(TB_FILE)

# Run the simulation and generate the VCD waveform file
simulate: compile
	@echo "Running simulation..."
	./$(OUT)

# Command to display the waveform with GTKWave
view:
	@echo "Opening waveform in GTKWave..."
	gtkwave $(WAVEFORM)

# Command to run both simulation and open GTKWave
run: simulate view

# Clean up temporary files
clean:
	@echo "Cleaning up..."
	rm -f $(OUT) $(WAVEFORM)
# Makefile variables
TESTBENCH_SRC_DIR := testbench
TESTBENCH_BUILD_DIR := build

VERILOG_COMPILER := iverilog

# Find all testbench Verilog source files in subdirectories
TESTBENCH_SRCS := $(shell find $(TESTBENCH_SRC_DIR) -name "*.v")

# Create the corresponding target file names for each source file
TARGETS := $(patsubst $(TESTBENCH_SRC_DIR)/%.v,$(TESTBENCH_BUILD_DIR)/%.vvp,$(TESTBENCH_SRCS))

# Rule to compile each Verilog file to a VVP file
$(TESTBENCH_BUILD_DIR)/%.vvp: $(TESTBENCH_SRC_DIR)/%.v
	@mkdir -p $(dir $@)
	$(VERILOG_COMPILER) -Wall -o $@ $<

# Default rule to build all targets
test: $(TARGETS)

# Rule to display run command syntax
run:
	@echo "Please specify a target to run. For example: make run-alu_tb"
	@echo "Available targets:"
	@find $(BUILDDIR) -name "*.vvp" -exec basename {} .vvp \;

# Rule to run a specific VVP file
run-%:
	@find $(BUILDDIR) -name $*.vvp -exec vvp {} \;

# Clean rule to remove all VVP files
clean:
	rm -rf $(TESTBENCH_BUILD_DIR)

.PHONY: test clean

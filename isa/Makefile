#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN ?= 64

ENV ?= xs

src_dir := .
build_dir := build

$(shell mkdir -p build)

ifeq ($(XLEN),64)
include $(src_dir)/rv64ui/Makefrag
include $(src_dir)/rv64uc/Makefrag
include $(src_dir)/rv64um/Makefrag
include $(src_dir)/rv64ua/Makefrag
include $(src_dir)/rv64uf/Makefrag
include $(src_dir)/rv64ud/Makefrag
include $(src_dir)/rv64si/Makefrag
include $(src_dir)/rv64mi/Makefrag
include $(src_dir)/rv64vecex/Makefrag
endif
include $(src_dir)/rv32ui/Makefrag
include $(src_dir)/rv32uc/Makefrag
include $(src_dir)/rv32um/Makefrag
include $(src_dir)/rv32ua/Makefrag
include $(src_dir)/rv32uf/Makefrag
include $(src_dir)/rv32ud/Makefrag
include $(src_dir)/rv32si/Makefrag
include $(src_dir)/rv32mi/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles -Wl,--build-id=none
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy
RISCV_SIM ?= spike

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%.dump: %
	$(RISCV_OBJDUMP) $(build_dir)/$< > $(build_dir)/$@

%.bin: %
	$(RISCV_OBJCOPY) -O binary $(build_dir)/$< $(build_dir)/$@

%.out: %
	$(RISCV_SIM) --isa=rv64gc $< 2> $@

%.out32: %
	$(RISCV_SIM) --isa=rv32gc $< 2> $@

%.nemu-log: %.bin
	make -C $(NEMU_HOME) ISA=riscv64 run ARGS="--batch --log=$(abspath $(build_dir)/$@) $(abspath $(build_dir)/$<)"

%.noop-log: %.bin
	make -C $(NOOP_HOME) emu IMAGE="$(abspath $(build_dir)/$<)"

define compile_template

$$($(1)_p_tests): $(1)-p-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -I$(src_dir)/../env/$(ENV) -I$(src_dir)/macros/scalar -T$(src_dir)/../env/$(ENV)/link.ld $$< -o $$(build_dir)/$$@
$(1)_tests += $$($(1)_p_tests)

# $$($(1)_v_tests): $(1)-v-%: $(1)/%.S
# 	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -DENTROPY=0x$$(shell echo \$$@ | md5sum | cut -c 1-7) -std=gnu99 -O2 -I$(src_dir)/../env/v -I$(src_dir)/macros/scalar -T$(src_dir)/../env/v/link.ld $(src_dir)/../env/v/entry.S $(src_dir)/../env/v/*.c $$< -o $$@
# $(1)_tests += $$($(1)_v_tests)

$(1)_tests_dump = $$(addsuffix .dump, $$($(1)_tests))
$(1)_tests_bin = $$(addsuffix .bin, $$($(1)_tests))

$(1): $$($(1)_tests_dump) $$($(1)_tests_bin)

.PHONY: $(1)

tests += $$($(1)_tests)

endef


SUITES = rv64mi rv64si rv64ua rv64ui rv64um rv64uc rv64uf rv64ud rv64vecex

$(foreach s, $(SUITES), $(eval $(call compile_template,$(s),-march=rv64g -mabi=lp64)) )

# ifeq ($(filter $(SUITES), rv64ui), rv64ui)
# $(eval $(call compile_template,rv64ui,-march=rv64g -mabi=lp64))
# endif

# ifeq ($(filter $(SUITES), rv64uc), rv64uc)
# $(eval $(call compile_template,rv64uc,-march=rv64g -mabi=lp64))
# endif

# ifeq ($(filter $(SUITES), rv64um), rv64um)
# $(eval $(call compile_template,rv64um,-march=rv64g -mabi=lp64))
# endif

# ifeq ($(filter $(SUITES), rv64ua), rv64ua)
# $(eval $(call compile_template,rv64ua,-march=rv64g -mabi=lp64))
# endif

# ifeq ($(filter $(SUITES), rv64uf), rv64uf)
# $(eval $(call compile_template,rv64uf,-march=rv64g -mabi=lp64))
# endif

# ifeq ($(filter $(SUITES), rv64ud), rv64ud)
# $(eval $(call compile_template,rv64ud,-march=rv64g -mabi=lp64))
# endif


# $(eval $(call compile_template,rv32ui,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32uc,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32um,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32ua,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32uf,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32ud,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32si,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32mi,-march=rv32g -mabi=ilp32))

# $(eval $(call compile_template,rv64ui,-march=rv64g -mabi=lp64))
# $(eval $(call compile_template,rv64uc,-march=rv64g -mabi=lp64))
# $(eval $(call compile_template,rv64um,-march=rv64g -mabi=lp64))
# $(eval $(call compile_template,rv64ua,-march=rv64g -mabi=lp64))
# $(eval $(call compile_template,rv64uf,-march=rv64g -mabi=lp64))
# $(eval $(call compile_template,rv64ud,-march=rv64g -mabi=lp64))
# $(eval $(call compile_template,rv64si,-march=rv64g -mabi=lp64))
# $(eval $(call compile_template,rv64mi,-march=rv64g -mabi=lp64))


tests_dump = $(addsuffix .dump, $(tests))
tests_bin = $(addsuffix .bin, $(tests))
tests_hex = $(addsuffix .hex, $(tests))
tests_out = $(addsuffix .out, $(spike_tests))
tests32_out = $(addsuffix .out32, $(spike32_tests))

nemu_out = $(addsuffix .nemu-log, $(tests))
noop_out = $(addsuffix .noop-log, $(tests))

run: $(tests_out) $(tests32_out)

bin: $(tests_dump) $(tests_bin)

nemu_run: $(tests_dump) $(tests_bin) $(nemu_out)

noop_run: $(tests_dump) $(tests_bin) $(noop_out)

junk = $(build_dir)

#------------------------------------------------------------
# Default

all: $(tests_dump) $(tests_bin)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(junk)

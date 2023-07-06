# See LICENSE for license details.

#*****************************************************************************
# maskLogicalInsts.S
#-----------------------------------------------------------------------------
#
# Test illegal instruction trap.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64M
RVTEST_CODE_BEGIN

  .align 2
  .option norvc

  li TESTNUM, 2
# VMAND_MM b011001???????????010?????1010111
bad1:
  .word 0x6420a1d7
  j fail

# VMNAND_MM b011101???????????010?????1010111
bad2:
  .word 0x7420a1d7
  j fail

# VMOR_MM b011010???????????010?????1010111
bad3:
  .word 0x6820a1d7
  j fail

# VMNOR_MM b011110???????????010?????1010111
bad4:
  .word 0x7820a1d7
  j fail

# VMXOR_MM b011011???????????010?????1010111
bad5:
  .word 0x6c20a1d7
  j fail

# VMXNOR_MM b011111???????????010?????1010111
bad6:
  .word 0x7c20a1d7
  j fail

  TEST_PASSFAIL

  .align 8
  .global mtvec_handler
mtvec_handler:
  j synchronous_exception
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail
  j fail

synchronous_exception:
  li t1, CAUSE_ILLEGAL_INSTRUCTION
  csrr t0, mcause
  bne t0, t1, fail
  csrr t0, mepc

  # Make sure mtval contains either 0 or the instruction word.
  csrr t2, mbadaddr
  beqz t2, 1f
  lhu t1, 0(t0)
  xor t2, t2, t1
  lhu t1, 2(t0)
  slli t1, t1, 16
  xor t2, t2, t1
  bnez t2, fail
1:

  la t1, bad1
  beq t0, t1, 2f
  la t1, bad2
  beq t0, t1, 3f
  la t1, bad3
  beq t0, t1, 4f
  la t1, bad4
  beq t0, t1, 5f
  la t1, bad5
  beq t0, t1, 6f
  la t1, bad6
  beq t0, t1, 7f
  j fail
2:
3:
4:
5:
6:
7:
  addi t0, t0, 8
  csrw mepc, t0
  mret

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END

# See LICENSE for license details.

#*****************************************************************************
# vstart.S
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

  li t0, -1
# vsetvli t1, t0, e8, m1
# 000000 000000 00101 111 00110 1010111
  .word 0x2f357
  csrwi 0x008, 4
bad1:
# vadd.vv v0, v2, v1
# 000000 1 00010 00001 000 00000 1010111
  .word 0x2208057
  j fail

1:
  csrwi 0x008, 0
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
bad2:
# vadd.vv v0, v2, v1
  .word 0x2208057
  j 2f
  j fail

2:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 1
bad3:
# vadd.vv v0, v2, v1
  .word 0x2208057
  j fail

  csrwi 0x008, 0
# vadd.vv v0, v2, v1
  .word 0x2208057
#  j 3f
#  j fail

3:
  csrwi 0x008, 5
bad4:
# vadd.vx v0, v4, t1
# 000000 1 00100 00110 100 00000 1010111
  .word 0x2434057
  j fail

4:
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
  la t1, bad3
  beq t0, t1, 2f
  la t1, bad4
  beq t0, t1, 2f
  j fail
2:
  addi t0, t0, 8
  csrw mepc, t0
  mret

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END

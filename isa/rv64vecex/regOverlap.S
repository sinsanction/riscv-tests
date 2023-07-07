# See LICENSE for license details.

#*****************************************************************************
# regOverlap.S
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

#(1)v0Overlap
  li t0, -1
# vsetvli t1, t0, e8, m1
# 000000 000000 00101 111 00110 1010111
  .word 0x2f357
bad1:
# vadd.vv v0, v2, v1
# 000000 0 00010 00001 000 00000 1010111
  .word 0x208057
  j fail

  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
bad2:
# vmsbf.m v0, v2, vm
# 010100 0 00010 00001010 00000 1010111
  .word 0x5020a057
  j fail

#  li t0, -1
# vsetvli t1, t0, e8, m1
#  .word 0x2f357
bad3:
# vredand.vs v0, v2, v1, vm
# 000001 0 00010 00001 010 00000 1010111
#  .word 0x420a057
#  j 1f
#  j fail

#(2)vs1vdOverlap
1:
  li t0, -1
# vsetvli t1, t0, e8, m4
# 000000 000010 00101 111 00110 1010111
  .word 0x22f357
bad4:
# vadd.vv v4, v0, v4
# 000000 1 00000 00100 000 00100 1010111
  .word 0x2020257
  j 2f
  j fail

2:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
bad5:
# vwadd.vv v2, v0, v2
# 110001 1 00000 00010 010 00010 1010111
  .word 0xc6012157
  j fail

  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
bad6:
# vwadd.vv v2, v0, v3
# 110001 1 00000 00011 010 00010 1010111
  .word 0xc601a157
  j 3f
  j fail

#(3)vs2vdOverlap
3:
  li t0, -1
# vsetvli t1, t0, e8, m2
# 000000 00001 00101 111 00110 1010111
  .word 0x12f357
bad7:
# vmand.mm v3, v3, v2
# 011001 1 00011 00010 010 00011 1010111
  .word 0x663121d7
  j 4f
  j fail

4:
#  li t0, -1
# vsetvli t1, t0, e8, m2
#  .word 0x12f357
bad8:
# vredand.vs v2, v2, v1
# 000001 1 00010 00001 010 00010 1010111
#  .word 0x620a157
#  j 5f
#  j fail

5:
  li t0, -1
# vsetvli t1, t0, e8, m2
  .word 0x12f357
bad9:
# vcompress.vm v2, v2, v0
# 0101111 00010 00000 010 00010 1010111
  .word 0x5e202157
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
  beq t0, t1, 2f
  la t1, bad5
  beq t0, t1, 2f
  la t1, bad9
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

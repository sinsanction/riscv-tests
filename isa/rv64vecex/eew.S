# See LICENSE for license details.

#*****************************************************************************
# eew.S
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

#(1)fpEewIllegal
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
bad1:
# vfwcvt.f.x.v v2, v0
# 010010 1 00000 01011001 00010 1010111
#  .word 0x4a059157
#  j 1f
#  j fail

1:
bad2:
# vfwcvt.f.f.v v2, v1
# 010010 1 00001 01100001 00010 1010111
  .word 0x4a161157
  j fail

#(2)intExtEewIllegal
  li t0, -1
# vsetvli t1, t0, e16, m1
  .word 0x82f357
bad3:
# vzext.vf4 v2, v1
# 010010 1 00001 00100010 00010 1010111
  .word 0x4a122157
  j fail

#(3)wnEewIllegal
  li t0, -1
# vsetvli t1, t0, e64, m1
  .word 0x182f357
bad4:
# vwadd.vv v2, v1, v0
# 110001 1 00001 00000 010 00010 1010111
  .word 0xc6102157
  j fail

  li t0, -1
  .word 0x182f357
bad5:
# vnsrl.wv v4, v2, v0
# 101100 1 00010 00000 000 00100 1010111
  .word 0xb2200257
  j fail

  li t0, -1
  .word 0x182f357
bad6:
# vwredsum.vs v0, v2, v4
# 110001 1 00010 00100 000 00000 1010111
  .word 0xc6220057
  j fail

  li t0, -1
# vsetvli t1, t0, e16, m1
  .word 0x82f357
bad7:
# vwadd.vv v2, v1, v0
  .word 0xc6102157
  j 2f
  j fail

2:
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

  la t1, bad2
  beq t0, t1, 2f
  la t1, bad3
  beq t0, t1, 2f
  la t1, bad4
  beq t0, t1, 2f
  la t1, bad5
  beq t0, t1, 2f
  la t1, bad6
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

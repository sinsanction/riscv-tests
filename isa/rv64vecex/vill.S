# See LICENSE for license details.

#*****************************************************************************
# vill.S
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
# vsetivli t0, 16, e8, m?
# 110000 000 100 10000 111 00101 1010111
  .word 0xc04872d7
bad1:
# vadd.vi v0, v0, 1
  .word 0x200b057
  j fail

# vsetivli t0, 16, e?, m1
# 110000 100 000 10000 111 00101 1010111
#  .word 0xc20872d7
bad2:
# vadd.vi v0, v0, 1
#  .word 0x200b057
#  j fail

# vsetivli t0, 16, e8, m?
  .word 0xc04872d7
bad3:
# vsetivli t0, 16, e8, m1
  .word 0xc00872d7
  j 1f
  j fail

1:
# vsetivli t0, 16, e8, m?
#  .word 0xc04872d7
bad4:
# vmv1r.v v1, v2
# 1001111 00010 00000011 00001 1010111
#  .word 0x9e2030d7
#  j 2f
#  j fail

2:
# vsetivli t0, 16, e8, m?
#  .word 0xc04872d7
#  la a2, tdata
bad5:
# vl1re16.v v2, (a2)
# 000000101000 01100 101 00010 0000111
#  .word 0x2865107
#  j 3f
#  j fail

3:
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
  j fail
2:
3:
  addi t0, t0, 8
  csrw mepc, t0
  mret

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

tdata:
  .quad 0x1234
  .quad 0x5678

RVTEST_DATA_END

# See LICENSE for license details.

#*****************************************************************************
# vstart2.S
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
# vsll.vv v0, v2, v1
# 100101 1 00010 00001 000 00000 1010111
  .word 0x96208057
  j fail

  csrwi 0x008, 0
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
bad2:
# vmsne.vx v0, v4, t1,
# 011001 1 00100 00110 100 00000 1010111
  .word 0x66434057
  j 1f
  j fail

1:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 1
bad3:
# vmacc.vv v0, v1, v2
# 101101 1 00001 00010 010 00000 1010111
  .word 0xb6112057
  j fail

  csrwi 0x008, 0
# vmul.vv v2, v4, v2
# 100101 1 00100 00010 010 00010 1010111
  .word 0x96412157
  j 2f
  j fail

2:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 5
bad4:
# vslide1down.vx v0, v2, t1
# 001111 1 00010 00110 110 00000 1010111
  .word 0x3e236057
  j fail

  csrwi 0x008, 0
# vrgather.vv v2, v1, v0
# 001100 1 00001 00000 011 00010 1010111
  .word 0x32103157
  j 3f
  j fail

3:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 7
bad5:
# vredand.vs v4, v2, v0
# 000001 1 00010 00000 010 00100 1010111
  .word 0x6202257
  j fail

  csrwi 0x008, 0
# vwredsumu.vs v4, v2, v6
# 110000 1 00010 00110 000 00100 1010111
  .word 0xc2230257
  j 4f
  j fail

4:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 9
bad6:
# vfsub.vv vd, vs2, vs1
# 000010 1 00000 00001 001 00010 1010111
  .word 0xa009157
  j fail

  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 0
# vfmax.vv v0, v4, v2
# 000110 1 00100 00010 001 00000 1010111
#  .word 0x1a411057
  .word 0x2208057
  j 5f
  j fail

5:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 9
bad7:
# vfmul.vv v4, v1, v2
# 100100 1 00001 00010 001 00100 1010111
  .word 0x92111257
  j fail

  csrwi 0x008, 0
# vfmul.vv v4, v1, v2
# 100100 1 00001 00010 001 00100 1010111
#  .word 0x92111257
  .word 0x2208057
  j 6f
  j fail

6:
  li t0, -1
# vsetvli t1, t0, e8, m1
  .word 0x2f357
  csrwi 0x008, 5
bad8:
# vfdiv.vv v4, v2, v0
# 100000 1 00010 00000 001 00100 1010111
  .word 0x82201257
  j fail

  csrwi 0x008, 0
# vfdiv.vv v4, v2, v0
# 100000 1 00010 00000 001 00100 1010111
#  .word 0x82201257
  .word 0x2208057
  j 7f
  j fail

7:
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
  la t1, bad5
  beq t0, t1, 2f
  la t1, bad6
  beq t0, t1, 2f
  la t1, bad7
  beq t0, t1, 2f
  la t1, bad8
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

# See LICENSE for license details.

#*****************************************************************************
# regNumNotAlign.S
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

#(1)vs1NotAlign
  li t0, -1
# vsetvli t1, t0, e8, m4
# 000000 000010 00101 111 00110 1010111
  .word 0x22f357
bad1:
# vadd.vv v8, v4, v1
# 000000 1 00100 00001 000 01000 1010111
  .word 0x2408457
  j fail

  li t0, -1
# vsetvli t1, t0, e8, m4
  .word 0x22f357
bad2:
# vmand.mm v4, v0, v1
# 011001 1 00000 00001 010 00100 1010111
  .word 0x6600a257
  j 1f
  j fail

#(2)vs2NotAlign
1:
  li t0, -1
# vsetvli t1, t0, e8, m4
  .word 0x22f357
bad3:
# vadd.vv v8, v5, v0
# 000000 1 00101 00000 000 01000 1010111
  .word 0x2500457
  j fail

#  li t0, -1
# vsetvli t1, t0, e8, m4
#  .word 0x22f357
bad4:
# vwredsumu.vs v4, v3, v0
# 110000 1 00011 00000 000 00100 1010111
#  .word 0xc2300257
#  j 2f
#  j fail

#(3)vdNotAlign
2:
  li t0, -1
# vsetvli t1, t0, e8, m4
  .word 0x22f357
  la a2, tdata
bad5:
# vle8.v v2, (a2)
# 000000000000 01100 000 00010 0000111
  .word 0x60107
  j fail

#  li t0, -1
# vsetvli t1, t0, e8, m4
#  .word 0x22f357
bad6:
# vredsum.vs v1, v4, v0
# 000000 1 00100 00000 010 00001 1010111
#  .word 0x24020d7
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
  la t1, bad3
  beq t0, t1, 2f
  la t1, bad5
  beq t0, t1, 2f
  j fail
2:
  addi t0, t0, 8
  csrw mepc, t0
  mret

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

tdata:
  .quad 0x1234
  .quad 0x5678
  .quad 0x1234
  .quad 0x5678
  .quad 0x1234
  .quad 0x5678
  .quad 0x1234
  .quad 0x5678

RVTEST_DATA_END

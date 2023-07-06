# See LICENSE for license details.

#*****************************************************************************
# emul.S
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

#(1)lsEmulIllegal
  li t0, -1
# vsetvli t1, t0, e8, m8
# 000000 000011 00101 111 00110 1010111
  .word 0x32f357
  la a2, tdata
bad1:
# vle16.v v0, (a2)
# 000000000000 01100 101 00000 0000111
  .word 0x65007
  j fail

#(2)intExtEmulIllegal
  li t0, -1
# vsetvli t1, t0, e8, mf4
# 000000 000110 00101 111 00110 1010111
  .word 0x62f357
bad2:
# vzext.vf4 v2, v1
# 010010 1 00001 00100010 00010 1010111
  .word 0x4a122157
  j fail

#(3)wnEmulIllegal
  li t0, -1
# vsetvli t1, t0, e32, m8
# 000000 010011 00101 111 00110 1010111
  .word 0x132f357
bad3:
# vwadd.vv v16, v0, v0
# 110001 1 00000 00000 010 10000 1010111
  .word 0xc6002857
  j fail

  li t0, -1
# vsetvli t1, t0, e32, m8
  .word 0x132f357
bad4:
# vnsrl.wv v8, v16, v0
# 101100 1 10000 00000 000 01000 1010111
  .word 0xb3000457
  j fail

#(4)gather16EmulIllegal
  li t0, -1
# vsetvli t1, t0, e8, m8
  .word 0x32f357
bad5:
# vrgatherei16.vv v8, v0, v16
# 001110 1 00000 10000 000 01000 1010111
  .word 0x3a080457
  j fail

#(5)lsSegIllegal
  li t0, -1
# vsetvli t1, t0, e8, m4
# 000000 000010 00101 111 00110 1010111
  .word 0x22f357
  la a2, tdata
bad6:
# vlseg2e16.v v0, (a2)
# 001000000000 01100 101 00000 0000111
  .word 0x20065007
  j fail

  li t0, -1
# vsetvli t1, t0, e8, m2
# 000000 000001 00101 111 00110 1010111
  .word 0x12f357
  la a2, tdata
bad7:
# vlseg2e16.v v28, (a2)
# 001000000000 01100 101 11100 0000111
  .word 0x20065e07
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

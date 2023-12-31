# See LICENSE for license details.

#*****************************************************************************
# amomax_d.S
#-----------------------------------------------------------------------------
#
# Test amomax.w instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV64U
RVTEST_CODE_BEGIN

  TEST_CASE(2, a4, 0xffffffff80000000, \
    li a0, 0xffffffff80000000; \
    li a1, 0xfffffffffffff800; \
    la a3, amo_operand; \
    sw a0, 0(a3); \
    amomax.w	a4, a1, 0(a3); \
  )

  TEST_CASE(3, a5, 0xfffffffffffff800, lw a5, 0(a3))

  TEST_CASE(4, a4, 0, \
    li a1, 1; \
    sw x0, 0(a3); \
    amomax.w	a4, a1, 0(a3); \
  )

  TEST_CASE(5, a5, 1, lw a5, 0(a3))

  TEST_CASE(6, a4, 0xffffffff80000000, \
    li a0, 0x80000000; \
    li a1, 0x7fffffff; \
    la a3, amo_operand; \
    sd a0, 0(a3); \
    amomax.w a4, a1, 0(a3); \
  )
  TEST_CASE(7, a5, 0x7fffffff, lw a5, 0(a3))

  TEST_CASE(8, a4, 0x7fffffff, \
    li a0, 0x7fffffff; \
    li a1, 0x80000000; \
    la a3, amo_operand; \
    sd a0, 0(a3); \
    amomax.w a4, a1, 0(a3); \
  )
  TEST_CASE(9, a5, 0x7fffffff, lw a5, 0(a3))

  TEST_CASE(10, a4, 0x07eeeeeee, \
    li a0, 0x207eeeeeee; \
    li a1, 0x107fffffff; \
    la a3, amo_operand; \
    sd a0, 0(a3); \
    amomax.w a4, a1, 0(a3); \
  )
  TEST_CASE(11, a5, 0x7fffffff, lw a5, 0(a3))

  TEST_CASE(12, a4, 0x07fffffff, \
    li a0, 0x107fffffff; \
    li a1, 0x207eeeeeee; \
    la a3, amo_operand; \
    sd a0, 0(a3); \
    amomax.w a4, a1, 0(a3); \
  )
  TEST_CASE(13, a5, 0x7fffffff, lw a5, 0(a3))

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END

  .bss
  .align 3
amo_operand:
  .dword 0

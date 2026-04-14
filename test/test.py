# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 ns (100 MHz)
    clock = Clock(dut.clk, 10, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    dut.uio_in.value = 0

    # Set the input values you want to test
    dut.ui_in.value = 1 # Set ui_in[0] to 1 which is the compare signal for the SAR FSM
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value[3:0] == 0b1000, f"Expected uio_out to be 0b1000, but got {dut.uio_out.value}"

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value[3:0] == 0b1100, f"Expected uio_out to be 0b1100, but got {dut.uio_out.value}"

    dut.ui_in.value = 1
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value[3:0] == 0b1010, f"Expected uio_out to be 0b1010, but got {dut.uio_out.value}"

    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value[3:0] == 0b1011, f"Expected uio_out to be 0b1011, but got {dut.uio_out.value}"

    dut.ui_in.value = 0
    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)
    assert dut.uio_out.value[3:0] == 0b1000, f"Expected uio_out to be 0b1000, but got {dut.uio_out.value}"
    # Check the output values of your module:
    assert dut.uo_out.value[3:0] == 0b1010, f"Expected uo_out to be 0b1010, but got {dut.uo_out.value}"

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.

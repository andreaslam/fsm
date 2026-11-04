from __future__ import annotations

from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, ReadOnly, RisingEdge, Timer
from cocotb.types import LogicArray
from cocotb_tools.runner import get_runner

SIM = "icarus"

RED = LogicArray("00")
RED_YELLOW = LogicArray("01")
GREEN = LogicArray("10")
YELLOW = LogicArray("11")

RED_WAIT_TIME = 10
GREEN_GO_TIME = 10
YELLOW_SHOW_TIME = 2


@cocotb.test
async def test_init(dut):
    """Asserts the initial colour of the traffic light colour is red"""
    await reset(dut)
    assert dut.colour.value == RED


async def run_clock(dut):
    """Run a clock with a 1 s period indefinitely"""
    while True:
        dut.clk.value = 1
        await Timer(1, "s")
        dut.clk.value = 0
        await Timer(1, "s")


async def reset(dut):
    dut.rst.value = 1

    cocotb.start_soon(Clock(dut.clk, 10, unit="ms").start())

    for _ in range(3):
        await RisingEdge(dut.clk)

    await FallingEdge(dut.clk)
    dut.rst.value = 0


async def wait_cycles(dut, n):
    for _ in range(n):
        await RisingEdge(dut.clk)
        await ReadOnly()


@cocotb.test
async def test_red_to_red_yellow_transition(dut):
    """Tests whether the transition from red to red-yellow is correct"""
    await reset(dut)
    await wait_cycles(dut, RED_WAIT_TIME)
    assert dut.colour.value == RED_YELLOW


@cocotb.test
async def red_yellow_to_green_transition(dut):
    """Tests whether the transition from red-yellow to green is correct"""
    await reset(dut)
    await wait_cycles(dut, RED_WAIT_TIME + YELLOW_SHOW_TIME)
    assert dut.colour.value == GREEN


@cocotb.test
async def green_to_yellow_transition(dut):
    """Tests whether the transition from green to yellow is correct"""
    await reset(dut)
    await wait_cycles(dut, RED_WAIT_TIME + YELLOW_SHOW_TIME + GREEN_GO_TIME)
    assert dut.colour.value == YELLOW


@cocotb.test
async def yellow_to_red_transition(dut):
    """Tests whether the transition from yellow to red is correct"""
    await reset(dut)
    await wait_cycles(
        dut, RED_WAIT_TIME + YELLOW_SHOW_TIME + GREEN_GO_TIME + YELLOW_SHOW_TIME
    )
    assert dut.colour.value == RED


def test_traffic_light():
    proj_path = Path(__file__).resolve().parent

    source = [proj_path / "fsm.v"]

    runner = get_runner(SIM)
    runner.build(
        sources=source,
        hdl_toplevel="traffic_light",
        always=True,
    )

    runner.test(hdl_toplevel="traffic_light", test_module="test_traffic_light")


if __name__ == "__main__":
    test_traffic_light()

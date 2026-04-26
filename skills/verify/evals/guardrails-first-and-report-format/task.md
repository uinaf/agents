# Calculator Library Verification

## Problem/Feature Description

A developer on the data team has updated a shared Python calculator utility that is used across several internal reporting scripts. The update added a `calculate` dispatcher function that routes operations by name, and the developer says all the tests pass. Before the change is merged and the library is published to the internal package registry, another engineer needs to independently verify it.

The team uses pytest and a Makefile for their standard verification workflow. Your job is to verify the changes, exercise the real behavior (not just read the code), and produce a complete verification report. The previous version of this library had a silent failure bug where division errors were swallowed — so error path coverage is important.

## Output Specification

Produce a file named `verification-report.md` containing a complete report with all of the following sections:

- **Verdict**: one of `ready for review`, `needs more work`, or `blocked` (verify is the builder's gate before review; the ship decision belongs to `review`)
- **Change Verified**: what was tested and confirmed
- **Surfaces Exercised**: the exact commands or calls used
- **Self-Corrections Applied**: any cheap, obvious issues you fixed during verification (or "none")
- **Top Findings**: substantive issues left for review, with severity
- **Exact Evidence**: commands run and output received
- **Readiness Gaps**: any gaps in test coverage or infrastructure
- **Recommended Follow-up**: suggested next steps (typically `review` when the verdict is `ready for review`)

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: inputs/calculator.py ===============
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def calculate(operation, a, b):
    ops = {
        'add': add,
        'subtract': subtract,
        'multiply': multiply,
        'divide': divide,
    }
    if operation not in ops:
        raise ValueError(f"Unknown operation: {operation}")
    return ops[operation](a, b)

=============== FILE: inputs/test_calculator.py ===============
import pytest
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))
from calculator import add, subtract, multiply, divide, calculate

def test_add():
    assert add(2, 3) == 5

def test_subtract():
    assert subtract(5, 3) == 2

def test_multiply():
    assert multiply(3, 4) == 12

def test_divide():
    assert divide(10, 2) == 5.0

def test_divide_by_zero():
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(5, 0)

def test_calculate_add():
    assert calculate('add', 10, 5) == 15

def test_calculate_unknown_op():
    with pytest.raises(ValueError, match="Unknown operation"):
        calculate('modulo', 5, 3)

=============== FILE: inputs/Makefile ===============
.PHONY: test verify lint

verify: test

test:
	cd inputs && python -m pytest test_calculator.py -v

lint:
	cd inputs && python -m flake8 calculator.py

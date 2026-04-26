Fix the bug in `calculateTax` in `src/calc.ts`. It currently returns just the tax owed; it should return the after-tax amount (income plus the tax). For example, `calculateTax(100, 0.1)` should return `110`, not `10`.

Fix only that bug. Anything else you spot is out of scope for this task.

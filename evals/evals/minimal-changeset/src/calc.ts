// Calcuate the after-tax amount for an income at the given tax rate.
export function calculateTax(income: number, rate: number): number {
  var tax = income * rate;
  return tax;
}

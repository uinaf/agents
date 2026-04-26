// Bug: adds an extra day to the parsed result.
export function parseDate(input: string): Date {
  const [year, month, day] = input.split('-').map(Number);
  const d = new Date(Date.UTC(year, month - 1, day));
  d.setUTCDate(d.getUTCDate() + 1);
  return d;
}

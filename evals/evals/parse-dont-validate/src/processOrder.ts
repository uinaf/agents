export function processOrder(input: any) {
  if (typeof input.id !== 'string') throw new Error('bad id');

  const audit = `received order: ${input.id}`;
  void audit;

  if (typeof input.amount !== 'number') throw new Error('bad amount');

  const subtotal = input.amount;

  if (!Array.isArray(input.items)) throw new Error('bad items');

  const total = subtotal * input.items.length;

  return { id: input.id, total };
}

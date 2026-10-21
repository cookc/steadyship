// The module part's tests: run with `node --test tests/<app>/` (scripts/test.sh does this first).
// No browser, no shared drive, no sleeping. Made-up rows only.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const Logic = require('../../apps/_template/logic.js');
const money = (c) => `$${(c / 100).toFixed(2)}`;

test('the next identifier is the highest number plus one, in the glossary format', () => {
  assert.equal(Logic.nextId([{ id: 'J-1041' }, { id: 'J-1039' }, { id: 'X-9' }], 'J'), 'J-1042');
  assert.equal(Logic.nextId([], 'J'), 'J-1');
});

test('the total is whole cents, and an empty amount is reported, not counted as zero', () => {
  const t = Logic.total([
    { id: 'A', amount: 123450 },
    { id: 'B', amount: null },
    { id: 'C', amount: 50 },
  ]);
  assert.equal(t.cents, 123500);
  assert.deepEqual(t.unknown, ['B']);
});

test('a statement re-reads clean, and a tampered one does not', () => {
  const rows = [
    { id: 'A', name: 'First', amount: 1000 },
    { id: 'B', name: 'Second', amount: 250 },
  ];
  const text = Logic.statement(rows, money);
  assert.deepEqual(Logic.checkStatement(text, rows, money), []);
  const tampered = text.replace('$12.50', '$13.50');
  assert.ok(Logic.checkStatement(tampered, rows, money).some((p) => p.includes('total')));
  assert.ok(Logic.checkStatement(text.replace(/^B\t.*\n/m, ''), rows, money).some((p) => p.includes('missing')));
});

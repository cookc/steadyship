// What is saved: a row the app could not understand must still be in the file after a save.
// Loads lib/steadyship.js in Node (it only needs a `window` to hang itself on).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';

globalThis.window = globalThis;
createRequire(import.meta.url)('../../lib/steadyship.js');
const S = globalThis.Steadyship;

const SHAPE = { id: { required: true, pattern: /^[A-Z]+-\d+$/ }, due: { kind: 'date' } };

test('a row that fails the check is written back where it was, exactly as read', () => {
  const read = [
    { id: 'X-1', due: '2026-01-31' },
    { id: 'X-2', due: '31/01/2026' }, // Excel reformatted the date: fails the check
    { id: 'X-3', due: '' },
    { id: '', due: '2026-02-01', note: 'no identifier yet' },
  ];
  const { good, bad } = S.check(read, SHAPE);
  assert.deepEqual(
    good.map((r) => r.id),
    ['X-1', 'X-3'],
  );
  const saved = S.withHeld([...good, { id: 'X-4', due: '' }], bad);
  assert.equal(saved.length, 5, 'nothing is lost by a save');
  assert.deepEqual(saved[1], read[1], 'the unread row is untouched and in its place');
  assert.deepEqual(saved[3], read[3]);
  assert.equal(saved[4].id, 'X-4');
});

test('with nothing held, the rows are saved as they are', () => {
  const rows = [{ id: 'X-1' }, { id: 'X-2' }];
  assert.deepEqual(S.withHeld(rows, []), rows);
});

test('a time zone the business notes do not give keeps this computer own, so today() still works', () => {
  const before = S.config.timeZone;
  S.applyConfig({ timeZone: null, currency: 'NZD' });
  assert.equal(S.config.timeZone, before);
  assert.equal(S.config.currency, 'NZD');
  assert.match(S.today(), /^\d{4}-\d{2}-\d{2}$/);
});

test('an empty amount is read as not known (null), so a save cannot turn it into 0.00', () => {
  const { good } = S.check([{ id: 'X-1', amount: '' }], { id: { required: true }, amount: { kind: 'cents' } });
  assert.equal(good[0].amount, null);
});

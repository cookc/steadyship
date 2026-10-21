// @ts-check
/* The module part: the rules of this app, with no DOM in them, so they run
   and are tested in Node in a second (tests/<app>/logic.test.mjs) and the
   page (app.js) is only wiring. Loaded as a plain script in the browser
   (window.Logic) and with require() in Node. Delete what this app does not
   need; keep the shape. */
/** @param {any} root @param {() => any} factory */ (function (root, factory) {
  // @ts-ignore `module` exists only in Node
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.Logic = factory();
})(globalThis, function () {
  'use strict';

  /** The next identifier in the glossary's format: the highest number in the file plus one.
   * @param {{ id?: string }[]} rows @param {string} prefix  e.g. 'J' gives J-1044 after J-1043 */
  function nextId(rows, prefix) {
    let max = 0;
    for (const r of rows) {
      const m = new RegExp(`^${prefix}-(\\d+)$`).exec(r.id || '');
      if (m) max = Math.max(max, Number(m[1]));
    }
    return `${prefix}-${max + 1}`;
  }

  /** Whole cents added up; an empty amount counts as unknown, not zero, and is reported.
   * @param {{ id?: string, amount?: number|null }[]} rows
   * @returns {{ cents: number, unknown: string[] }} */
  function total(rows) {
    let cents = 0;
    const unknown = [];
    for (const r of rows) {
      if (r.amount == null) unknown.push(r.id || '?');
      else cents += r.amount;
    }
    return { cents, unknown };
  }

  // ---- The verifier part: something this app produces that leaves it (a file for a machine, a
  // statement, a message) is made by one function and re-read by another before it is offered.
  /** A plain-text statement of the rows, one line each, with the total last.
   * @param {{ id?: string, name?: string, amount?: number|null }[]} rows @param {(cents: number) => string} money */
  function statement(rows, money) {
    const lines = rows.map((r) => `${r.id}\t${r.name}\t${r.amount == null ? '' : money(r.amount)}`);
    const t = total(rows);
    lines.push(`TOTAL\t${rows.length} row(s)\t${money(t.cents)}`);
    return lines.join('\n') + '\n';
  }

  /** Re-reads a statement and checks it against the rows it was made from. Empty list = clean.
   * @param {string} text @param {{ id?: string, amount?: number|null }[]} rows @param {(cents: number) => string} money
   * @returns {string[]} problems, in plain words */
  function checkStatement(text, rows, money) {
    const problems = [];
    const lines = text.split('\n').filter(Boolean);
    const ids = new Set(lines.map((l) => l.split('\t')[0]));
    for (const r of rows) if (!ids.has(String(r.id))) problems.push(`${r.id} is missing from the statement.`);
    if (lines.length !== rows.length + 1)
      problems.push(`The statement has ${lines.length - 1} row(s); there are ${rows.length}.`);
    const last = lines[lines.length - 1] || '';
    const want = money(total(rows).cents);
    if (!last.startsWith('TOTAL\t') || !last.endsWith(`\t${want}`))
      problems.push(`The total line does not say ${want}.`);
    return problems;
  }

  return { nextId, total, statement, checkStatement };
});

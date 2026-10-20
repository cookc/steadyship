// @ts-check
/* The app. One state object, one render function, data through Steadyship's
   helpers. Nothing here types in a colour, a price or a business list. */
const S = window.Steadyship;

/** What this app's records look like. One form per kind of value (see the bar). */
const SHAPE = {
  id: { required: true, pattern: /^[A-Z]+-\d+$/, label: 'Identifier' },
  name: { required: true, label: 'Name' },
  amount: { kind: 'cents', label: 'Amount' }, // whole cents in memory and on disk
  due: { kind: 'date', label: 'Due' }, // ISO date text
};
const FIELDS = Object.keys(SHAPE);
/** The master file, named in data.json next to this file. */
const MASTER = 'Example.csv';

/** @type {{ rows: Record<string, any>[], fields: string[], live: boolean }} */
const state = { rows: [], fields: FIELDS, live: false };

/** Sample rows for a double-click open; never business data. */
const SAMPLE = [
  { id: 'X-1', name: 'First sample row', amount: 123450, due: '2026-01-31' },
  { id: 'X-2', name: 'Second sample row', amount: 9900, due: '' },
];

function render() {
  const tbody = /** @type {HTMLTableSectionElement} */ (document.querySelector('#list tbody'));
  S.table(tbody, state.rows, (row) => {
    const tr = document.createElement('tr');
    tr.appendChild(S.el('td', {}, row.id));
    tr.appendChild(S.el('td', {}, row.name));
    tr.appendChild(S.el('td', { class: 'num' }, row.amount == null ? '' : S.money(row.amount)));
    tr.appendChild(S.el('td', {}, S.date(row.due)));
    return tr;
  });
  const count = document.getElementById('count');
  if (count) count.textContent = `${state.rows.length} row(s)`;
  const where = document.getElementById('where');
  if (where)
    where.textContent = state.live ? `data: ${MASTER} on the shared drive` : 'sample data (opened by double-click)';
}

async function load() {
  S.clear();
  await S.init();
  if (!S.served) {
    state.rows = SAMPLE;
    state.live = false;
    render();
    return;
  }
  try {
    const { fields, rows } = await S.readCsv(MASTER);
    const { good, bad } = S.check(rows, SHAPE);
    state.rows = good;
    state.fields = fields.length ? fields : FIELDS;
    state.live = true;
    for (const b of bad)
      S.say(
        `${MASTER} line ${b.line}: ${b.problems.join('; ')}. The row is shown nowhere until it is fixed in the file.`,
      );
  } catch (e) {
    S.say(e instanceof Error ? e.message : String(e));
    state.rows = [];
    state.live = false;
  }
  render();
}

async function add(/** @type {SubmitEvent} */ ev) {
  ev.preventDefault();
  const form = /** @type {HTMLFormElement} */ (ev.target);
  const data = Object.fromEntries(new FormData(form).entries());
  const { good, bad } = S.check([/** @type {Record<string,string>} */ (data)], SHAPE);
  S.clear();
  if (bad.length) {
    for (const p of bad[0].problems) S.say(p);
    return;
  } // what was typed stays in the form
  const row = good[0];
  if (state.rows.some((r) => r.id === row.id)) {
    S.say(`${row.id} is already in the list.`);
    return;
  }
  const next = [...state.rows, row];
  if (state.live) {
    try {
      await S.writeCsv(
        MASTER,
        state.fields,
        next.map((r) => ({ ...r, amount: r.amount == null ? '' : (r.amount / 100).toFixed(2) })),
      );
    } catch (e) {
      S.say(e instanceof Error ? e.message : String(e));
      return;
    } // the form keeps what was typed
  }
  state.rows = next;
  render();
  form.reset();
  S.say(`${row.id} added.`, 'ok');
}

document.getElementById('add')?.addEventListener('submit', add);
load();

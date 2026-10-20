/* Steadyship helpers: the few things every app needs, written once so no app
   copies them. Loaded as a plain script; use them as Steadyship.<name>.
   Works both from a double-click (file://) and through scripts/serve.mjs. */
// @ts-check
(function (global) {
  'use strict';

  /** @typedef {{ required?: boolean, pattern?: RegExp, kind?: 'text'|'cents'|'date'|'moment'|'int', label?: string }} FieldRule */

  const served = global.location && global.location.protocol !== 'file:';

  /** Facts from the business notes, filled by init() through the serve script; sensible fallbacks otherwise. */
  const config = {
    timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone,
    currency: /** @type {string|null} */ (null),
    locale: global.navigator ? global.navigator.language : 'en',
  };

  // ---- Text into the page: always through esc(); never innerHTML with data ----
  /** @param {unknown} v */
  const esc = (v) =>
    String(v ?? '').replace(
      /[&<>"']/g,
      (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c] || c,
    );

  /** Make an element with text content and attributes. @param {string} tag @param {Record<string,string>=} attrs @param {string=} text */
  function el(tag, attrs, text) {
    const e = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs || {})) e.setAttribute(k, v);
    if (text !== undefined) e.textContent = text;
    return e;
  }

  // ---- Value forms (the bar): money as whole cents, dates as ISO text, moments with their offset ----
  /** Whole cents to money text. @param {number|null|undefined} cents */
  function money(cents) {
    const n = (cents ?? 0) / 100;
    if (config.currency)
      return new Intl.NumberFormat(config.locale, { style: 'currency', currency: config.currency }).format(n);
    return new Intl.NumberFormat(config.locale, { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(n);
  }
  /** Typed money ("1,234.50", "$12") to whole cents, or null. @param {unknown} text */
  function cents(text) {
    const s = String(text ?? '').replace(/[^0-9.-]/g, '');
    if (s === '' || s === '-' || s === '.') return null;
    const n = Number(s);
    return Number.isFinite(n) ? Math.round(n * 100) : null;
  }
  const pad = (/** @type {number} */ n) => String(n).padStart(2, '0');
  /** Today as an ISO date in the business's time zone (never toISOString(), which gives the UTC date). */
  function today() {
    const parts = new Intl.DateTimeFormat('en-CA', {
      timeZone: config.timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(new Date());
    const get = (/** @type {string} */ t) => parts.find((p) => p.type === t)?.value;
    return `${get('year')}-${get('month')}-${get('day')}`;
  }
  /** Now as ISO with this computer's offset: what the clock said and where. */
  function now() {
    const d = new Date();
    const off = -d.getTimezoneOffset();
    const sign = off >= 0 ? '+' : '-';
    const a = Math.abs(off);
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}${sign}${pad(Math.floor(a / 60))}:${pad(a % 60)}`;
  }
  const ISO_DATE = /^\d{4}-\d{2}-\d{2}$/;
  const ISO_MOMENT = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?(Z|[+-]\d{2}:\d{2})$/;
  /** ISO date to the business's format. @param {string|null|undefined} iso */
  function date(iso) {
    if (!iso || !ISO_DATE.test(iso)) return iso ? String(iso) : '';
    const [y, m, d] = iso.split('-').map(Number);
    return new Intl.DateTimeFormat(config.locale, { dateStyle: 'medium' }).format(new Date(y, m - 1, d));
  }
  /** ISO moment to the business's format, in the business's time zone. @param {string|null|undefined} iso */
  function moment(iso) {
    if (!iso || !ISO_MOMENT.test(iso)) return iso ? String(iso) : '';
    return new Intl.DateTimeFormat(config.locale, {
      dateStyle: 'medium',
      timeStyle: 'short',
      timeZone: config.timeZone,
    }).format(new Date(iso));
  }

  // ---- Edges: every row that comes in is checked against a written shape; bad rows are reported, never dropped silently ----
  /**
   * @param {Record<string, string>[]} rows
   * @param {Record<string, FieldRule>} shape  e.g. { job: { required: true, pattern: /^J-\d{4}$/, label: 'Job number' }, price: { kind: 'cents' } }
   * @returns {{ good: Record<string, any>[], bad: { line: number, row: Record<string,string>, problems: string[] }[] }}
   */
  function check(rows, shape) {
    const good = [];
    const bad = [];
    rows.forEach((row, i) => {
      const problems = [];
      /** @type {Record<string, any>} */
      const out = { ...row };
      for (const [field, rule] of Object.entries(shape)) {
        const label = rule.label || field;
        const raw = (row[field] ?? '').trim();
        if (rule.required && raw === '') {
          problems.push(`${label} is empty`);
          continue;
        }
        if (raw === '') continue;
        if (rule.pattern && !rule.pattern.test(raw)) problems.push(`${label} "${raw}" is not in the expected form`);
        if (rule.kind === 'cents') {
          const c = cents(raw);
          if (c === null) problems.push(`${label} "${raw}" is not an amount`);
          else out[field] = c;
        }
        if (rule.kind === 'int') {
          const n = Number(raw);
          if (!Number.isInteger(n)) problems.push(`${label} "${raw}" is not a whole number`);
          else out[field] = n;
        }
        if (rule.kind === 'date' && !ISO_DATE.test(raw))
          problems.push(`${label} "${raw}" is not a date written as YYYY-MM-DD`);
        if (rule.kind === 'moment' && !ISO_MOMENT.test(raw))
          problems.push(`${label} "${raw}" is not a date and time with its time zone`);
      }
      if (problems.length) bad.push({ line: i + 2, row, problems });
      else good.push(out);
    });
    return { good, bad };
  }

  // ---- Messages in the page, in plain words; never alert() ----
  function messages() {
    return document.getElementById('messages');
  }
  /** @param {string} text @param {'error'|'ok'=} kind */
  function say(text, kind) {
    const box = messages();
    if (!box) return;
    const m = el(
      'div',
      { class: 'message' + (kind === 'ok' ? ' ok' : ''), role: kind === 'ok' ? 'status' : 'alert' },
      text,
    );
    box.appendChild(m);
    if (kind === 'ok') setTimeout(() => m.remove(), 4000);
  }
  function clear() {
    const box = messages();
    if (box) box.textContent = '';
  }

  // ---- Data through the serve script: one master file, read with a version tag, written back with it ----
  class DataError extends Error {
    /** @param {string} message @param {number=} status */ constructor(message, status) {
      super(message);
      this.status = status;
    }
  }
  const versions = /** @type {Map<string,string>} */ (new Map());
  function needServer() {
    if (!served)
      throw new DataError(
        'This app was opened by double-click, so it cannot reach the shared drive. Open it through the serve script (scripts/serve.mjs) to work with live data.',
      );
  }
  /** @param {Response} r */
  async function failure(r) {
    let msg = `The serve script answered ${r.status}.`;
    try {
      const j = await r.json();
      if (j && j.error) msg = j.error;
    } catch {
      /* not JSON */
    }
    return new DataError(msg, r.status);
  }
  /** Read a CSV named in data.json. Returns header-keyed rows. @param {string} name */
  async function readCsv(name) {
    needServer();
    const r = await fetch(`/api/file/${encodeURIComponent(name)}`, { cache: 'no-store' });
    if (!r.ok) throw await failure(r);
    versions.set(name, r.headers.get('ETag') || '');
    const text = await r.text();
    // @ts-ignore Papa is loaded from ../../lib/papaparse.min.js
    const parsed = global.Papa.parse(text, {
      header: true,
      skipEmptyLines: 'greedy',
      transformHeader: (/** @type {string} */ h) => h.trim(),
    });
    if (parsed.errors && parsed.errors.length)
      say(
        `${name}: ${parsed.errors.length} line(s) could not be read (first: line ${parsed.errors[0].row + 2}, ${parsed.errors[0].message}).`,
      );
    return { fields: parsed.meta.fields || [], rows: /** @type {Record<string,string>[]} */ (parsed.data) };
  }
  /** Write the master CSV back, keeping its columns, in the version read. @param {string} name @param {string[]} fields @param {Record<string, any>[]} rows */
  async function writeCsv(name, fields, rows) {
    needServer();
    // @ts-ignore
    const text =
      global.Papa.unparse({ fields, data: rows.map((row) => fields.map((f) => row[f] ?? '')) }, { newline: '\r\n' }) +
      '\r\n';
    const r = await fetch(`/api/file/${encodeURIComponent(name)}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'text/csv; charset=utf-8', 'If-Match': versions.get(name) || '' },
      body: text,
    });
    if (!r.ok) throw await failure(r);
    versions.set(name, r.headers.get('ETag') || '');
  }
  /** Facts from the business notes (time zone, currency), when served. */
  async function init() {
    if (!served) return config;
    try {
      const r = await fetch('/api/config', { cache: 'no-store' });
      if (r.ok) Object.assign(config, await r.json());
    } catch {
      /* keep fallbacks */
    }
    return config;
  }

  // ---- Long lists: a table that renders only the rows on screen, from the first row ----
  /**
   * @param {HTMLTableSectionElement} tbody  inside a scrolling .table-wrap
   * @param {any[]} rows
   * @param {(row: any) => HTMLTableRowElement} renderRow
   * @param {number=} rowHeight  pixels, roughly
   */
  function table(tbody, rows, renderRow, rowHeight) {
    const h = rowHeight || 40;
    const wrap = tbody.closest('.table-wrap') || tbody.parentElement?.parentElement;
    const cols = tbody.parentElement?.querySelectorAll('th').length || 1;
    const draw = () => {
      const top = wrap ? wrap.scrollTop : 0;
      const height = wrap ? wrap.clientHeight : rows.length * h;
      const first = Math.max(0, Math.floor(top / h) - 5);
      const last = Math.min(rows.length, Math.ceil((top + height) / h) + 5);
      tbody.textContent = '';
      const spacer = (/** @type {number} */ n) => {
        const tr = el('tr', { 'aria-hidden': 'true' });
        const td = el('td', { colspan: String(cols) });
        td.style.height = `${n * h}px`;
        td.style.padding = '0';
        td.style.border = '0';
        tr.appendChild(td);
        return tr;
      };
      if (first > 0) tbody.appendChild(spacer(first));
      for (let i = first; i < last; i++) tbody.appendChild(renderRow(rows[i]));
      if (last < rows.length) tbody.appendChild(spacer(rows.length - last));
    };
    if (wrap) {
      wrap.addEventListener('scroll', draw);
    }
    draw();
    return draw;
  }

  global.Steadyship = {
    config,
    served,
    esc,
    el,
    money,
    cents,
    today,
    now,
    date,
    moment,
    check,
    say,
    clear,
    readCsv,
    writeCsv,
    init,
    table,
    DataError,
  };
})(window);

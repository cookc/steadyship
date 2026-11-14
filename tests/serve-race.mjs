// Two serve scripts (two computers) on one master file, saving at the same instant, many times.
// Every round exactly one save may win; the file must be exactly the winner's text, never a mix.
// Usage: node tests/serve-race.mjs <url-of-server-1> <url-of-server-2> <path-to-master> [rounds]
import { readFileSync } from 'node:fs';
const [a, b, master, n = '150'] = process.argv.slice(2);
const file = '/api/file/Jobs.csv';
const body = (who, i) => 'job,stage\r\n' + `J-${i},${who}\r\n`.repeat(400);
let bothWon = 0;
let spliced = 0;
let noneWon = 0;
for (let i = 0; i < Number(n); i++) {
  const etag = (await fetch(a + file)).headers.get('etag');
  const put = (url, text) => fetch(url + file, { method: 'PUT', headers: { 'If-Match': etag }, body: text });
  const [ra, rb] = await Promise.all([put(a, body('A', i)), put(b, body('B', i))]);
  const wins = [ra, rb].filter((r) => r.status === 200).length;
  if (wins === 2) bothWon++;
  if (wins === 0) noneWon++;
  for (const r of [ra, rb])
    if (![200, 412, 423].includes(r.status)) throw new Error(`round ${i}: unexpected status ${r.status}`);
  const onDisk = readFileSync(master, 'utf8').replace(/^﻿/, '');
  if (onDisk !== body('A', i) && onDisk !== body('B', i)) spliced++;
  if (wins === 1 && onDisk !== body(ra.status === 200 ? 'A' : 'B', i)) spliced++;
}
console.log(`rounds ${n}: both saved ${bothWon}, mixed or wrong file ${spliced}, neither saved ${noneWon}`);
process.exit(bothWon || spliced || noneWon ? 1 : 0);

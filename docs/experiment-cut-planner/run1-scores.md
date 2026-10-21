# Blind score, run 1 (scorer: a separate Opus instance, labels K = no plugin, M = Steadyship; it was not told which)
30 items: K 41/60, M 51/60. Extra items N1-N5: K 8/10, M 5/10.
Per item (K/M): 1 1/2, 2 0/1, 3 0/2, 4 0/0, 5 2/2, 6 2/2, 7 2/2, 8 2/2, 9 1/1, 10 2/2, 11 2/2, 12 2/2, 13 1/2, 14 1/2, 15 1/1, 16 1/2, 17 2/2, 18 1/2, 19 2/2, 20 2/2, 21 1/2, 22 1/1, 23 1/2, 24 2/2, 25 2/2, 26 2/1, 27 0/0, 28 2/2, 29 1/2, 30 2/2.
N1 2/0 (K: core.js + node test.js; M: rules in the page script, Playwright only), N2 2/1 (K verifyGcode re-reads the .nc; M checks paths before writing, never re-reads the file), N3 2/0 (M refuses arcs), N4 0/2, N5 2/2.
Scorer's summary: M asked first and kept settings and sheet data outside the code; K's engineering was stronger (Node module with tests, file re-read, arcs). Neither added a test in the week-later conversation.

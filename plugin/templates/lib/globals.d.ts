// What the browser pages can see as globals, for the type checker (tsc -p tsconfig.json).
// Apps opt in to checking with a `// @ts-check` line at the top of their .js file.
declare var Papa: any;
declare var Steadyship: any;
interface Window {
  Steadyship: any;
  Papa: any;
}

const { renderHypercube } = require('../build/ascii-hypercube.js');

const tests = [
	// Edge case: zero-cube
	{
		dimensions: [],
		expectedText: ``,
	},
	// Cube (3D)
	{
		dimensions: [
			{length: 4, xPerGlyph: 2, yPerGlyph: 0, text: "CUBIC"},
			{length: 4, xPerGlyph: 0, yPerGlyph: 1, text: "CUBIC"},
			{length: 2, xPerGlyph: 2, yPerGlyph: 1, text: "\\"},
		],
		expectedText: `C U B I C
U \\     U \\
B   C U B I C
I   U   I   U
C U B I C   B
  \\ I     \\ I
    C U B I C`,
	},
	// Cube (3D) with extra dimensions of length 0
	{
		dimensions: [
			{length: 4, xPerGlyph: 2, yPerGlyph: 0, text: "CUBIC"},
			{length: 4, xPerGlyph: 0, yPerGlyph: 1, text: "CUBIC"},
			{length: 2, xPerGlyph: 2, yPerGlyph: 1, text: "\\"},
			{length: 0, xPerGlyph: 3, yPerGlyph: 1, text: "~"},
			{length: 0, xPerGlyph: -1, yPerGlyph: 1, text: "/"},
		],
		expectedText: `C U B I C
U \\     U \\
B   C U B I C
I   U   I   U
C U B I C   B
  \\ I     \\ I
    C U B I C`,
	},
	// Hypercube (4D)
	{
		dimensions: [
			{length: 4, xPerGlyph: 2, yPerGlyph: 0, text: "CUBIC"},
			{length: 4, xPerGlyph: 0, yPerGlyph: 1, text: "CUBIC"},
			{length: 2, xPerGlyph: 2, yPerGlyph: 1, text: "\\"},
			{length: 3, xPerGlyph: -1, yPerGlyph: 1, text: "/"},
		],
		expectedText: `   C U B I C
  /U \\    /U \\
 / B   C U B I C
C UIB IUC  I  /U
U \\C U BUI\\C / B
B / C\\UIB I C\\ I
I/  U  CIU BUI C
C U B I C   B /
  \\ I/    \\ I/
    C U B I C`,
	},
];

let failed = false;
tests.forEach(({ dimensions, expectedText }, i) => {
	const actual = renderHypercube(dimensions);
	if (actual.text !== expectedText) {
		console.error(`Test ${i} failed: expected\n${expectedText}\nbut got\n${actual.text}\n`);
		failed = true;
	}
});
if (failed) {
	process.exit(1);
} else {
	console.log('All tests passed');
}

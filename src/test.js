const { renderHypercube } = require('../build/ascii-hypercube.js');

const tests = [
	{
		dimensions: [],
		expectedText: ``,
	},
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

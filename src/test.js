const { render_hypercube } = require('../build/ascii-hypercube.js');

const tests = [
	{
		dimensions: [],
		expectedText: ``,
	},
	{
		dimensions: [
			{length: 4, x_per_glyph: 2, y_per_glyph: 0, text: "CUBIC"},
			{length: 4, x_per_glyph: 0, y_per_glyph: 1, text: "CUBIC"},
			{length: 2, x_per_glyph: 2, y_per_glyph: 1, text: "\\"},
			{length: 0, x_per_glyph: 3, y_per_glyph: 1, text: "~"},
			{length: 0, x_per_glyph: -1, y_per_glyph: 1, text: "/"},
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

tests.forEach(({ dimensions, expectedText }, i) => {
	const actual = render_hypercube(dimensions);
	if (actual.text !== expectedText) {
		console.error(`Test ${i} failed: expected\n${expectedText}\nbut got\n${actual.text}\n`);
	}
});

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
	// Tesseract (4D)
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
	// 5-cube (5D)
	{
		dimensions: [
			{length: 11, xPerGlyph: 2, yPerGlyph: 0, text: "RATHER HYPER"},
			{length: 11, xPerGlyph: 0, yPerGlyph: 1, text: "RATHER HYPER"},
			{length: 4, xPerGlyph: 1, yPerGlyph: 1, text: "\\"},
			{length: 8, xPerGlyph: 3, yPerGlyph: 1, text: "~"},
			{length: 3, xPerGlyph: -1, yPerGlyph: 1, text: "/"},
		],
		expectedText: `   R A T H E R   H Y P E R
  /A\\ ~                 /A\\ ~
 / T \\   ~             / T \\   ~
R AHT H E R   H Y P E R  H  \\     ~
A\\ ~   R A T H E R   HA\\ ~ E R       ~
T \\R  ~A  ~       ~   T \\R  ~A  ~       ~
H  \\ / T ~   ~       ~H  \\ / T ~   ~       ~
E  HR AHT H E R   H Y P EHR  H    ~   ~       ~
R  YA  ~       ~   ~  R  YAR ~ T H E ~   H Y P E R
   PT  R  ~       ~      PTA\\R  ~       ~   ~   /A\\
H  EH        ~       ~H  EHT \\     ~       ~   ~ T \\
Y  REA H H E R  ~H Y PYERRAHTHH E R   H Y P E R  H~ \\
P / R ~Y           ~  P A\\RE~Y R A T H E ~   HA\\ P E R
E/   \\ P ~            E/T \\R P/A            ~ T \\R  /A
R A H HEE R   H Y P E R H~H\\\\E T  ~           H~ \\ / T
 \\ ~Y  R A T H E R   H \\E~YHRRAHT H E~R   H Y P EHR  H
  \\ P ~   ~       ~     R PYA  E~       ~     R  YA  E
   \\E/   ~   ~       ~   \\EPT  ~   ~       ~     PT  R
    R A T H E R   H Y P H REH     ~   ~       H  EH   
       ~       ~   ~    Y  RE~ H H E ~   H Y PYE RE  H
          ~       ~   ~ P / R  Y~       ~   ~ P / R  Y
             ~       ~  E~   \\ P   ~       ~  E~   \\ P
                ~       R A H HEE R   H Y P E R   H \\E
                   ~     \\  Y  R A T H E ~   H \\ PYE R
                      ~   \\ P /             ~   \\ P /
                         ~ \\E/                 ~ \\E/
                            R A T H E R   H Y P E R`,
	},
];

let failed = false;
tests.forEach(({ dimensions, expectedText }, i) => {
	const actual = renderHypercube(dimensions);
	if (actual.text !== expectedText) {
		console.error(`Test ${i} failed: expected\n${expectedText}\nbut got\n${actual.text}\n`);
		// Comparing text with whitespace from the terminal can be hard. Hex is an option, although it's not great since it's super abstract.
		// console.error(`Test ${i} failed: expected\n${new Buffer(expectedText).toString('hex')}\nbut got\n${new Buffer(actual.text).toString('hex')}`);
		failed = true;
	}
});
if (failed) {
	process.exit(1);
} else {
	console.log('All tests passed');
}

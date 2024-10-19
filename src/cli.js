#!/usr/bin/env node

const argparse = require('argparse');
const { renderHypercube } = require('../build/ascii-hypercube.js');

const parser = new argparse.ArgumentParser({
	prog: 'ascii-hypercube',
	description: 'CLI to render hypercubes with text along an arbitrary number of dimensions',
	epilog: `Example: ascii-hypercube -d 2,0 11 'RATHER HYPER' -d 0,1 11 'RATHER HYPER' -d 1,1 4 '\\\\' -d 3,1 8 '\\~' -d -1,1 3 '\\/'`
});

parser.add_argument('-d', '--dimension', {
	help: 'Define a dimension, with travel per glyph, length of edges along the dimension, and text. Can be specified multiple times. Travel must be given as a pair of numbers with no spaces, e.g. "-1,0" or "(-1,0)"',
	action: 'append', // Allow multiple --dimension arguments
	nargs: 3,
	metavar: ['TRAVEL', 'LENGTH', 'TEXT'],
});

parser.add_argument('-s', '--stats', {
	help: 'Print statistics about the overlaps',
	action: 'store_true',
});

// Hack so that "-1,0" is parsed as a positional argument instead of a flag
// They have a rule for negative numbers, but it matches the whole argument, doesn't allow comma separated numbers
// I could just change it to match at the start (i.e. as a prefix, using ^ but dropping $),
// but I've changed it to match the end or a comma, to be more conservative with the change.
parser._negative_number_matcher = /^-\d+(?:$|,)|^-\d*\.\d+(?:$|,)/; // default /^-\d+$|^-\d*\.\d+$/

const args = parser.parse_args();

const dimensions = args.dimension.map(dimArgs => {
	let [travel, length, text] = dimArgs;
	// const xyMatch = travel.match(/\((-?\d+,-?\d+)\)/);
	// if (!xyMatch) {
	// 	throw new Error(`Invalid travel format: ${JSON.stringify(travel)}. Expected format: "(-1,0)"`);
	// }
	const [xPerGlyph, yPerGlyph] = travel.replace(/^\((.*)\)$/, "$1").split(',').map(Number);
	length = Number(length);
	return { length, xPerGlyph, yPerGlyph, text };
});

const result = renderHypercube(dimensions);

console.log(result.text);

if (args.stats) {
	let overlapDescription = "(none - any overlapping glyphs match each other)";
	if (result.numOverlaps > 0) {
		overlapDescription = "\n" + Object.entries(result.overlaps).map(([under, overs]) =>
			Object.entries(overs).map(([over, nOver]) =>
				`- '${over}' over '${under}' (${nOver})`
			).join("\n")
		).join("\n");
	}
	console.log('Number of Overlaps:', result.numOverlaps);
	console.log('Overlaps:', overlapDescription);
}

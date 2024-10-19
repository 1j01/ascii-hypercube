
grid = []

numOverlaps = 0
overlaps = {}

plotGlyph = (glyph, x, y)->
	if grid.length <= y
		console?.warn? "Expanding vertically"
		for i in [grid.length..y]
			grid[i] = []
	if grid[y].length < x
		for i in [grid[y].length..x]
			grid[y][i] = " "
	existing = grid[y][x]
	if existing? and existing isnt " " and existing isnt glyph
		overlaps[existing] ?= {}
		overlaps[existing][glyph] ?= 0
		overlaps[existing][glyph] += 1
		numOverlaps += 1
	grid[y][x] = glyph

plotHypercubeVertices = (dimensions, glyph, x, y)->

	[furtherDimensions..., _] = dimensions

	if furtherDimensions.length
		dimension = furtherDimensions[furtherDimensions.length - 1]
		plotHypercubeVertices(furtherDimensions, glyph, x, y)
		plotHypercubeVertices(furtherDimensions, glyph,
			x + dimension.length * dimension.xPerGlyph
			y + dimension.length * dimension.yPerGlyph
		)
	else
		plotGlyph(glyph, x, y)

plotHypercube = (dimensions, x, y)->

	[furtherDimensions..., dimension] = dimensions
	{length, xPerGlyph, yPerGlyph, glyphs} = dimension
	
	if length > 0 and glyphs.length > 0
		for i in [1..length]
			glyph = glyphs[i % glyphs.length]
			plotHypercubeVertices(dimensions, glyph, x + i * xPerGlyph, y + i * yPerGlyph)
	if length > 0
		if furtherDimensions.length
			plotHypercube(furtherDimensions, x, y)
			plotHypercube(furtherDimensions, x + length * xPerGlyph, y + length * yPerGlyph)
		else if glyphs.length > 0
			plotGlyph(glyphs[0], x, y)
	else
		# skip this dimension for the sake of overlap counting mainly
		plotHypercube(furtherDimensions, x, y)

renderHypercube = (dimensions, splitter)->
	x = 0
	y = 0
	width = 0
	height = 0
	for dimension in dimensions
		width = Math.max(width, width + dimension.length * dimension.xPerGlyph)
		height = Math.max(height, height + dimension.length * dimension.yPerGlyph)
		x = Math.max(x, x - dimension.length * dimension.xPerGlyph)
		y = Math.max(y, y - dimension.length * dimension.yPerGlyph)
	width += x
	height += y
	grid =
		for [0..height]
			[]
			# for [0..width]
			# 	" "
	
	numOverlaps = 0
	overlaps = {}

	for dimension in dimensions
		dimension.glyphs ?= (splitter ?= new (window?.GraphemeSplitter ? require('grapheme-splitter'))()).splitGraphemes(dimension.text)

	if dimensions.length > 0
		plotHypercube(dimensions, x, y)
	
	text =
		(line.join("") for line in grid).join("\n")

	return { text, overlaps, numOverlaps }

# TODO: ESM export
if module?
	module.exports =
		renderHypercube: renderHypercube
else
	window.renderHypercube = renderHypercube

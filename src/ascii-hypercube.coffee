
grid = []

n_overlaps = 0
overlaps = {}

plot_glyph = (glyph, x, y)->
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
		n_overlaps += 1
	grid[y][x] = glyph

plot_hypercube_vertices = (dimensions, glyph, x, y)->

	[further_dimensions..., _] = dimensions

	if further_dimensions.length
		dimension = further_dimensions[further_dimensions.length - 1]
		plot_hypercube_vertices(further_dimensions, glyph, x, y)
		plot_hypercube_vertices(further_dimensions, glyph,
			x + dimension.length * dimension.x_per_glyph
			y + dimension.length * dimension.y_per_glyph
		)
	else
		plot_glyph(glyph, x, y)

plot_hypercube = (dimensions, x, y)->

	[further_dimensions..., dimension] = dimensions
	{length, x_per_glyph, y_per_glyph, glyphs} = dimension
	
	if length > 0 and glyphs.length > 0
		for i in [1..length]
			glyph = glyphs[i % glyphs.length]
			plot_hypercube_vertices(dimensions, glyph, x + i * x_per_glyph, y + i * y_per_glyph)
	if length > 0
		if further_dimensions.length
			plot_hypercube(further_dimensions, x, y)
			plot_hypercube(further_dimensions, x + length * x_per_glyph, y + length * y_per_glyph)
		else if glyphs.length > 0
			plot_glyph(glyphs[0], x, y)
	else
		# skip this dimension for the sake of overlap counting mainly
		plot_hypercube(further_dimensions, x, y)

render_hypercube = (dimensions, splitter)->
	x = 0
	y = 0
	width = 0
	height = 0
	for dimension in dimensions
		width = Math.max(width, width + dimension.length * dimension.x_per_glyph)
		height = Math.max(height, height + dimension.length * dimension.y_per_glyph)
		x = Math.max(x, x - dimension.length * dimension.x_per_glyph)
		y = Math.max(y, y - dimension.length * dimension.y_per_glyph)
	width += x
	height += y
	grid =
		for [0..height]
			[]
			# for [0..width]
			# 	" "
	
	n_overlaps = 0
	overlaps = {}

	for dimension in dimensions
		dimension.glyphs ?= (splitter ?= new GraphemeSplitter()).splitGraphemes(dimension.text)

	plot_hypercube(dimensions, x, y)
	
	output_text_art =
		(line.join("") for line in grid).join("\n")

	return { text: output_text_art, overlaps, numOverlaps: n_overlaps }

# TODO: ESM / CommonJS export
window.render_hypercube = render_hypercube


grid = []

n_overlapping_characters = 0 # TODO

point = (char, x, y)->
	if grid.length <= y
		console?.warn? "Expanding vertically"
		grid[i] = [] for i in [grid.length..y]
	if grid[y].length < x
		grid[y][i] = " " for i in [grid[y].length..x]
	# if grid[y][x] not in [undefined, " ", "/", "\\", "-", char]
	# 	n_overlapping_characters += 1
	grid[y][x] = char

square = (text, x, y, s)->
	for c, i in text when c isnt " "
		point(c, x, y + i)
		point(c, x + s * 2, y + i)
		point(c, x + i * 2, y)
		point(c, x + i * 2, y + s)

square_points = (char, x, y, s)->
	point(char, x + s * 0, y + s * 0)
	point(char, x + s * 2, y + s * 0)
	point(char, x + s * 0, y + s * 1)
	point(char, x + s * 2, y + s * 1)

# cube = (text, x, y, s, d_1, x_per_char, y_per_char)->
# 	if d_1 > 0
# 		for i in [1..d_1]
# 			square_points("\\", x + i * x_per_char, y + i * y_per_char, s)
# 	square(text, x, y, s)
# 	square(text, x + d_1 * x_per_char, y + d_1 * y_per_char, s)
# 
# cube_points = (char, x, y, s, d_1, x_per_char, y_per_char)->
# 	square_points(char, x, y, s)
# 	square_points(char, x + d_1 * x_per_char, y + d_1 * y_per_char, s)
# 
# tesseract = (text, x, y, d_1, d_2, x_per_char, y_per_char)->
	# s = Math.max(text.length - 1, 0)
	# if d_2 > 0
	# 	for i in [1..d_2]
	# 		cube_points(".", x + i * x_per_char, y + i * y_per_char, s, d_1)
	# cube(text, x, y, s, d_1)
	# cube(text, x + d_2 * x_per_char, y + d_2, s, d_1)

# hypercube_points = (dimensions, char, x, y, s)->
# 	[dimension, further_dimensions...] = dimensions
# 	{length, x_per_char, y_per_char, char} = dimension
# 	if further_dimensions.length
# 		hypercube_points(further_dimensions, char, x, y, s)
# 		hypercube_points(further_dimensions, char, x + length * x_per_char, y + length * y_per_char, s)
# 	else
# 		square_points(char, x, y, s)
# 		# square_points(char, x + length * x_per_char, y + length * y_per_char, s)

hypercube_points = (dimensions, char, x, y, s)->
	# XXX: WET; need to refactor recursion
	[dimension, further_dimensions...] = dimensions
	{length, x_per_char, y_per_char} = dimension
	if further_dimensions.length
		hypercube_points(further_dimensions, char, x, y, s)
		hypercube_points(further_dimensions, char, x + further_dimensions[0].length * further_dimensions[0].x_per_char, y + further_dimensions[0].length * further_dimensions[0].y_per_char, s)
	else
		square_points(char, x, y, s)
		# square_points(char, x + length * x_per_char, y + length * y_per_char, s)

hypercube = (dimensions, text, x, y)->
	[dimension, further_dimensions...] = dimensions
	{length, x_per_char, y_per_char, char} = dimension
	s = Math.max(text.length - 1, 0)
	
	# fn = if further_dimensions.length then hypercube else square
	if length > 0
		for i in [1..length]
			hypercube_points(dimensions, char, x + i * x_per_char, y + i * y_per_char, s)
			# if further_dimensions.length
			# 	square_points(char, x + i * x_per_char, y + i * y_per_char, s)
			# 	square_points(char, x + i * x_per_char, y + i * y_per_char, s)
			# else
			# 	square_points(char, x + i * x_per_char, y + i * y_per_char, s)
	if further_dimensions.length
		hypercube(further_dimensions, text, x, y, s)
		hypercube(further_dimensions, text, x + length * x_per_char, y + length * y_per_char, s)
	else
		# if length > 0
		# 	for i in [1..length]
		# 		square_points("\\", x + i * x_per_char, y + i * y_per_char, s)
		square(text, x, y, s)
		square(text, x + length * x_per_char, y + length * y_per_char, s)


text_input = document.getElementById("text-input")
d1_input = document.getElementById("d1-input")
d2_input = document.getElementById("d2-input")
d3_input = document.getElementById("d3-input")
output_pre = document.getElementById("output-pre")
text_is_good_indicator = document.getElementById("text-is-good")
overlapping_characters_indicator = document.getElementById("overlapping-characters")

# TODO: form validation
# TODO: allow configuring the offset per drawn character for the "extra" dimensions
# TODO: allow configuring the characters/strings drawn for each dimension
# you should be able to do e.g. a rectangle of TOAST x TEST
### or...
	O N E → T W O
	N           N
	E           E
	↓           ↓
	T           T
	W           W
	O N E → T W O
###

findGraphemesNotVeryWell = (text)->
	re = /.[\u0300-\u036F]*/g
	graphemes = []
	loop
		match = re.exec(text)
		break unless match
		graphemes.push(match[0])
	graphemes


do compute = ->
	graphemes = findGraphemesNotVeryWell(text_input.value)
	text_is_good = graphemes.length > 1 and graphemes[0] is graphemes[graphemes.length-1]
	text_is_good_indicator.style.visibility =
		(if text_is_good then "" else "hidden")
	d_1 = parseInt(d1_input.value)
	d_2 = parseInt(d2_input.value)
	d_3 = parseInt(d3_input.value)
	
	dimensions = [
		# {length: d_2, x_per_char: 3, y_per_char: 1}
		# {length: d_1, x_per_char: 1, y_per_char: 1}
		# {length: d_3, x_per_char: 1, y_per_char: 3, char: "|"}
		# {length: d_2, x_per_char: 3, y_per_char: 1, char: "."}
		# {length: d_1, x_per_char: 1, y_per_char: 1, char: "\\"}
		{length: d_3, x_per_char: -1, y_per_char: 1, char: "/"}
		{length: d_2, x_per_char: 3, y_per_char: 1, char: "~"}
		{length: d_1, x_per_char: 1, y_per_char: 1, char: "\\"}
	]
	
	# NOTE: could forego having a fixed-size grid entirely
	x = 0
	y = 0
	width = 0 # (graphemes.length - 1) * 2
	height = graphemes.length - 1
	for dimension in dimensions
		# width = Math.max(width, width + dimension.length * dimension.x_per_char)
		height = Math.max(height, height + dimension.length * dimension.y_per_char)
		x = Math.min(x, x + dimension.length * dimension.x_per_char)
		y = Math.min(y, y + dimension.length * dimension.y_per_char)
	grid =
		for [0..height]
			for [0..width]
				" "
	
	n_overlapping_characters = 0
	
	# tesseract(graphemes, 0, 0, d_1, d_2)
	hypercube(dimensions, graphemes, -x, -y)
	
	output_pre.textContent =
		(line.join("") for line in grid).join("\n")
	
	# overlapping_characters_indicator.textContent = n_overlapping_characters
	# overlapping_characters_indicator.textContent = "Note: there may be"

for input in document.querySelectorAll("form input")
	input.addEventListener("input", compute)


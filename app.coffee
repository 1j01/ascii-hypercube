
grid = []

n_overlapping_characters = 0 # TODO

point = (char, x, y)->
	if grid[y].length < x
		grid[y][i] = " " for i in [grid[y].length..x]
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

cube = (text, x, y, s, d_1)->
	if d_1 > 0
		for i in [1..d_1]
			square_points("\\", x+i, y+i, s)
	square(text, x, y, s)
	square(text, x+d_1, y+d_1, s)

cube_points = (char, x, y, s, d_1)->
	square_points(char, x, y, s)
	square_points(char, x + d_1, y + d_1, s)
	# NOTE: hardcoding the specific projection in a lot of places

tesseract = (text, x, y, d_1, d_2)->
	s = Math.max(text.length - 1, 0)
	if d_2 > 0
		for i in [1..d_2]
			cube_points(".", x + i * 3, y + i, s, d_1)
	cube(text, x, y, s, d_1)
	cube(text, x + d_2 * 3, y + d_2, s, d_1)

# TODO: support arbitrary dimensionality
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

text_input = document.getElementById("text-input")
d1_input = document.getElementById("d1-input")
d2_input = document.getElementById("d2-input")
output_pre = document.getElementById("output-pre")
text_is_good_indicator = document.getElementById("text-is-good")
# overlapping_characters_indicator = document.getElementById("overlapping-characters")

# TODO: form validation

do compute = ->
	text = text_input.value
	text_is_good = text.length > 1 and text[0] is text[text.length-1]
	text_is_good_indicator.style.visibility =
		(if text_is_good then "" else "hidden")
	d_1 = parseInt(d1_input.value)
	d_2 = parseInt(d2_input.value)
	
	# TODO: calculate both of these accurately
	# or simply forego having a fixed-size grid entirely
	width = 0 # (text.length - 1) * 2 + d_1 + d_2 * 3
	height = text.length - 1 + d_1 + d_2
	grid =
		for [0..height]
			for [0..width]
				" "
	
	tesseract(text, 0, 0, d_1, d_2)
	
	output_pre.textContent =
		(line.join("") for line in grid).join("\n")
	
	# overlapping_characters_indicator.textContent = n_overlapping_characters
	# overlapping_characters_indicator.textContent = "Note: there may be"

text_input.addEventListener("input", compute)
d1_input.addEventListener("input", compute)
d2_input.addEventListener("input", compute)


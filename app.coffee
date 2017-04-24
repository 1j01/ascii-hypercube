
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

hypercube_points = (dimensions, char, x, y, s)->
	# XXX: WET; need to refactor recursion
	[dimension, further_dimensions...] = dimensions
	{length, x_per_char, y_per_char} = dimension
	if further_dimensions.length
		hypercube_points(further_dimensions, char, x, y, s)
		hypercube_points(further_dimensions, char, x + further_dimensions[0].length * further_dimensions[0].x_per_char, y + further_dimensions[0].length * further_dimensions[0].y_per_char, s)
	else
		square_points(char, x, y, s)

hypercube = (dimensions, text, x, y)->
	[dimension, further_dimensions...] = dimensions
	{length, x_per_char, y_per_char, char} = dimension
	s = Math.max(text.length - 1, 0)
	
	if length > 0
		for i in [1..length]
			hypercube_points(dimensions, char, x + i * x_per_char, y + i * y_per_char, s)
	if further_dimensions.length
		hypercube(further_dimensions, text, x, y, s)
		hypercube(further_dimensions, text, x + length * x_per_char, y + length * y_per_char, s)
	else
		square(text, x, y, s)
		square(text, x + length * x_per_char, y + length * y_per_char, s)


form = document.querySelector("form")
text_input = document.getElementById("text-input")
output_textarea = document.getElementById("output-textarea")
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

dimensions = [
	{length: 0, x_per_char: -1, y_per_char: 1, char: "/"}
	{length: 0, x_per_char: 3, y_per_char: 1, char: "~"}
	{length: 5, x_per_char: 1, y_per_char: 1, char: "\\"}
]

do compute = ->
	graphemes = findGraphemesNotVeryWell(text_input.value)
	text_is_good = graphemes.length > 1 and graphemes[0] is graphemes[graphemes.length-1]
	text_is_good_indicator.style.visibility =
		(if text_is_good then "" else "hidden")
	
	# NOTE: could forego having a fixed-size grid entirely
	x = 0
	y = 0
	s = Math.max(graphemes.length - 1, 0)
	width = s * 2
	height = s
	for dimension in dimensions
		width = Math.max(width, width + dimension.length * dimension.x_per_char)
		height = Math.max(height, height + dimension.length * dimension.y_per_char)
		x = Math.max(x, x - dimension.length * dimension.x_per_char)
		y = Math.max(y, y - dimension.length * dimension.y_per_char)
	width += x
	height += y
	grid =
		for [0..height]
			[]
			# for [0..width]
			# 	" "
	
	n_overlapping_characters = 0
	
	hypercube(dimensions, graphemes, x, y)
	
	output_textarea.value =
		(line.join("") for line in grid).join("\n")
	
	output_textarea.setAttribute("rows", height + 1)
	# output_textarea.setAttribute("cols", width + 1)
	
	style = window.getComputedStyle(output_textarea, null)
	padding_top = parseFloat(style.getPropertyValue("padding-top"))
	padding_bottom = parseFloat(style.getPropertyValue("padding-bottom"))
	
	output_textarea.style.height = "1px"
	scroll_height = output_textarea.scrollHeight
	# output_textarea.style.height = "#{output_textarea.scrollHeight + 50}px"
	# console.log output_textarea.scrollHeight, padding_top, padding_bottom
	# output_textarea.style.height = "#{scroll_height + 50}px"
	output_textarea.style.height = "#{scroll_height + padding_top + padding_bottom}px"
	
	# overlapping_characters_indicator.textContent = n_overlapping_characters

make_dimension_row = (nd_name, dimension)->
	container_el = document.createElement("p")
	
	label_el = document.createElement("label")
	length_input = document.createElement("input")
	length_input.type = "number"
	length_input.min = 0
	length_input.step = 1
	length_input.value = dimension.length
	length_input.required = true
	length_input.addEventListener "input", ->
		unless isNaN(parseInt(length_input.value))
			dimension.length = parseInt(length_input.value)
		compute()
	label_el.appendChild(document.createTextNode("#{nd_name} length: "))
	label_el.appendChild(length_input)
	container_el.appendChild(label_el)
	
	label_el = document.createElement("label")
	char_input = document.createElement("input")
	char_input.type = "text"
	char_input.className = "char-input"
	char_input.pattern = "."
	char_input.value = dimension.char
	char_input.addEventListener "input", ->
		dimension.char = char_input.value or " "
		compute()
	label_el.appendChild(document.createTextNode("Char: "))
	label_el.appendChild(char_input)
	container_el.appendChild(label_el)
	
	container_el

for dimension, i in dimensions by -1
	el = make_dimension_row("#{3 + dimensions.length - 1 - i}D", dimension)
	form.appendChild(el)

for input in document.querySelectorAll("form input")
	input.addEventListener("input", compute)


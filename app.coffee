
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
copy_to_clipboard_button = document.getElementById("copy-to-clipboard")
markdown_format_checkbox = document.getElementById("markdown-format-checkbox")
text_is_good_indicator = document.getElementById("text-is-good")
overlapping_characters_indicator = document.getElementById("overlapping-characters")
copied_indicator = document.getElementById("copied-to-clipboard")

output_text_art = ""
update_output_textarea = ->
	if markdown_format_checkbox.checked
		output_textarea.value = output_text_art.split("\n").map(
			(str)-> str.replace(/^/g,"    ")
		).join("\n")
	else
		output_textarea.value = output_text_art
	
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

# TODO: form validation

### TODO: treat the first two dimensions similarly to the other dimensions
allow configuring more than a single glyph for each dimension, repeated if needed,
but able to specify whole strings of text for any side
you should be able to do e.g. a rectangle of TOAST x TEST

    T O A S T
    E       E
    S       S
    T O A S T

or...

	O N E → T W O
	N           N
	E           E
	↓           ↓
	T           T
	W           W
	O N E → T W O

as well as things like

    C U B I C
    U U     U U
    B   B   B   B
    I     I I     I
    C U B I C U B I C
      U     U U     U
        B   B   B   B
          I I     I I
            C U B I C

###

splitter = new GraphemeSplitter

dimensions = [
	{length: 0, x_per_char: -1, y_per_char: 1, char: "/"}
	{length: 0, x_per_char: 3, y_per_char: 1, char: "~"}
	{length: 5, x_per_char: 1, y_per_char: 1, char: "\\"}
]

do compute = ->
	graphemes = splitter.splitGraphemes(text_input.value)
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
	
	output_text_art =
		(line.join("") for line in grid).join("\n")
	
	update_output_textarea()

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
	
	label_el = document.createElement("label")
	offset_input = document.createElement("input")
	offset_input.type = "text"
	offset_input.className = "vector-input"
	offset_input.value = "#{dimension.x_per_char}, #{dimension.y_per_char}"
	offset_input.required = true
	offset_input.pattern = "-?\\d+\\s*,\\s*-?\\d+"
	offset_input.addEventListener "input", ->
		[x_str, y_str] = offset_input.value.split(",")
		unless isNaN(parseInt(x_str))
			dimension.x_per_char = parseInt(x_str)
		unless isNaN(parseInt(y_str))
			dimension.y_per_char = parseInt(y_str)
		compute()
	label_el.appendChild(document.createTextNode("Offset per char: "))
	label_el.appendChild(offset_input)
	container_el.appendChild(label_el)
	
	container_el

for dimension, i in dimensions by -1
	el = make_dimension_row("#{3 + dimensions.length - 1 - i}D", dimension)
	form.appendChild(el)

for input in document.querySelectorAll("form input")
	input.addEventListener("input", compute)

markdown_format_checkbox.addEventListener("change", update_output_textarea)

show_copied_indicator = ->
	copied_indicator.removeAttribute("aria-hidden")
	copied_indicator.innerHTML = copied_indicator.innerHTML
	setTimeout(->
		copied_indicator.setAttribute("aria-hidden", "true")
	, 1500)

copy_to_clipboard_button.addEventListener("click", ->

	if navigator.clipboard?.writeText
		navigator.clipboard.writeText(output_textarea.value).then(show_copied_indicator)
	else
		# Select the text field contents
		output_textarea.select()
		# Copy the text field contents to the clipboard
		success = document.execCommand("copy")
		
		if success
			show_copied_indicator()
)

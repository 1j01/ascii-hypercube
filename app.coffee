
grid = []

n_overlaps = 0
overlaps = {}

point = (char, x, y)->
	if grid.length <= y
		console?.warn? "Expanding vertically"
		for i in [grid.length..y]
			grid[i] = []
	if grid[y].length < x
		for i in [grid[y].length..x]
			grid[y][i] = " "
	existing = grid[y][x]
	if existing? and existing isnt " " and existing isnt char
		overlaps[existing] ?= {}
		overlaps[existing][char] ?= 0
		overlaps[existing][char] += 1
		n_overlaps += 1
	grid[y][x] = char

hypercube_points = (dimensions, char, x, y)->
	# XXX: WET; need to refactor recursion
	[dimension, further_dimensions...] = dimensions
	{length, x_per_char, y_per_char} = dimension
	if further_dimensions.length
		hypercube_points(further_dimensions, char, x, y)
		hypercube_points(further_dimensions, char, x + further_dimensions[0].length * further_dimensions[0].x_per_char, y + further_dimensions[0].length * further_dimensions[0].y_per_char)
	else
		point(char, x, y)

hypercube = (dimensions, x, y)->

	n_overlaps = 0
	overlaps = {}

	[dimension, further_dimensions...] = dimensions
	{length, x_per_char, y_per_char, text} = dimension
	
	graphemes = splitter.splitGraphemes(text)
	# TODO: handle no graphemes
	if length > 0
		for i in [1..length]
			char = graphemes[i % graphemes.length]
			hypercube_points(dimensions, char, x + i * x_per_char, y + i * y_per_char)
	if further_dimensions.length
		hypercube(further_dimensions, x, y)
		hypercube(further_dimensions, x + length * x_per_char, y + length * y_per_char)
	else
		point(graphemes[0], x, y)
		point(graphemes[graphemes.length - 1], x + length * x_per_char, y + length * y_per_char)


form = document.getElementById("inputs")
output_textarea = document.getElementById("output-textarea")
copy_to_clipboard_button = document.getElementById("copy-to-clipboard")
markdown_format_checkbox = document.getElementById("markdown-format-checkbox")
overlaps_indicator = document.getElementById("overlaps")
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
	
	overlaps_indicator.innerHTML =
		if n_overlaps > 0
			"""
			🙈 #{n_overlaps} glyphs occlude differing glyphs
			<ul>
			#{
			(for under, overs of overlaps
				(for over, n_over of overs
					"<li><code>#{over}</code> over <code>#{under}</code> (#{n_over})</li>"
				).join("\n")
			).join("\n")
			}
			</ul>
			"""
		else
			"👌 all overlapping glyphs match"

# TODO: form validation

splitter = new GraphemeSplitter

# TODO: define dimensions forwards
dimensions = [
	{length: 0, x_per_char: -1, y_per_char: 1, text: "/"}
	{length: 0, x_per_char: 3, y_per_char: 1, text: "~"}
	{length: 2, x_per_char: 2, y_per_char: 1, text: "\\"}
	{length: 4, x_per_char: 0, y_per_char: 1, text: "CUBIC"}
	{length: 4, x_per_char: 2, y_per_char: 0, text: "CUBIC"}
]

do compute = ->
	
	x = 0
	y = 0
	width = 0
	height = 0
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
	
	hypercube(dimensions, x, y)
	
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
	text_input = document.createElement("input")
	text_input.type = "text"
	text_input.className = "text-input"
	text_input.value = dimension.text
	text_input.addEventListener "input", ->
		dimension.text = text_input.value or " "
		compute()
	label_el.appendChild(document.createTextNode("Text: "))
	label_el.appendChild(text_input)
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
	label_el.appendChild(document.createTextNode("Offset per glyph: "))
	label_el.appendChild(offset_input)
	container_el.appendChild(label_el)
	
	container_el

for dimension, i in dimensions by -1
	el = make_dimension_row("#{dimensions.length - i}D", dimension)
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

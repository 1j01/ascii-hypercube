
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
	if further_dimensions.length
		plot_hypercube(further_dimensions, x, y)
		plot_hypercube(further_dimensions, x + length * x_per_glyph, y + length * y_per_glyph)
	else if glyphs.length > 0
		plot_glyph(glyphs[0], x, y)


form = document.getElementById("inputs")
output_textarea = document.getElementById("output-textarea")
copy_to_clipboard_button = document.getElementById("copy-to-clipboard")
markdown_format_checkbox = document.getElementById("markdown-format-checkbox")
overlap_summary = document.getElementById("overlap-summary")
overlap_details = document.getElementById("overlap-details")
copied_indicator = document.getElementById("copied-to-clipboard")

overlaps_expanded = false
overlap_summary.addEventListener "click", ->
	overlaps_expanded = not overlaps_expanded
	overlap_details.style.display = if overlaps_expanded then "" else "none"
overlap_summary.style.cursor = "pointer"

output_text_art = ""
update_output_area = ->
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
	
	overlap_summary.textContent =
		if n_overlaps > 0
			"🙈 #{n_overlaps} glyphs occlude differing glyphs"
		else
			"👌 all overlapping glyphs match"

	overlap_details.innerHTML =
		if n_overlaps > 0
			"<ul>#{
				(for under, overs of overlaps
					(for over, n_over of overs
						"<li><code>#{over}</code> over <code>#{under}</code> (#{n_over})</li>"
					).join("\n")
				).join("\n")
			}</ul>"
		else
			"<i>Specific occluding glyphs would be listed here.</i>"

# TODO: form validation

splitter = new GraphemeSplitter

dimensions = [
	{length: 4, x_per_glyph: 2, y_per_glyph: 0, text: "CUBIC"}
	{length: 4, x_per_glyph: 0, y_per_glyph: 1, text: "CUBIC"}
	{length: 2, x_per_glyph: 2, y_per_glyph: 1, text: "\\"}
	{length: 0, x_per_glyph: 3, y_per_glyph: 1, text: "~"}
	{length: 0, x_per_glyph: -1, y_per_glyph: 1, text: "/"}
]

do compute = ->
	
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
		dimension.glyphs = splitter.splitGraphemes(dimension.text)

	plot_hypercube(dimensions, x, y)
	
	output_text_art =
		(line.join("") for line in grid).join("\n")
	
	update_output_area()

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
		dimension.text = text_input.value
		compute()
	label_el.appendChild(document.createTextNode("Text: "))
	label_el.appendChild(text_input)
	container_el.appendChild(label_el)
	
	label_el = document.createElement("label")
	offset_input = document.createElement("input")
	offset_input.type = "text"
	offset_input.className = "vector-input"
	offset_input.value = "#{dimension.x_per_glyph}, #{dimension.y_per_glyph}"
	offset_input.required = true
	offset_input.pattern = "-?\\d+\\s*,\\s*-?\\d+"
	offset_input.addEventListener "input", ->
		[x_str, y_str] = offset_input.value.split(",")
		unless isNaN(parseInt(x_str))
			dimension.x_per_glyph = parseInt(x_str)
		unless isNaN(parseInt(y_str))
			dimension.y_per_glyph = parseInt(y_str)
		compute()
	label_el.appendChild(document.createTextNode("Offset per glyph: "))
	label_el.appendChild(offset_input)
	container_el.appendChild(label_el)
	
	container_el

for dimension, i in dimensions
	el = make_dimension_row("#{i + 1}D", dimension)
	form.appendChild(el)

for input in document.querySelectorAll("form input")
	input.addEventListener("input", compute)

markdown_format_checkbox.addEventListener("change", update_output_area)

show_copied_indicator = ->
	copied_indicator.removeAttribute("aria-hidden")
	copied_indicator.innerHTML = copied_indicator.innerHTML
	setTimeout ->
		copied_indicator.setAttribute("aria-hidden", "true")
	, 1500

copy_to_clipboard_button.addEventListener "click", ->

	if navigator.clipboard?.writeText
		navigator.clipboard.writeText(output_textarea.value).then(show_copied_indicator)
	else
		# Select the text field contents
		output_textarea.select()
		# Copy the text field contents to the clipboard
		success = document.execCommand("copy")
		
		if success
			show_copied_indicator()

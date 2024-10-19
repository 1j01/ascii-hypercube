# import {renderHypercube} from "./ascii-hypercube.js"
# renderHypercube = await import("./ascii-hypercube.js").then(m => m.renderHypercube)

form = document.getElementById("inputs")
add_dimension_button = document.getElementById("add-dimension")
output_textarea = document.getElementById("output-textarea")
copy_to_clipboard_button = document.getElementById("copy-to-clipboard")
markdown_format_checkbox = document.getElementById("markdown-format-checkbox")
overlap_summary = document.getElementById("overlap-summary")
overlap_details = document.getElementById("overlap-details")
copied_indicator = document.getElementById("copied-to-clipboard")

update_output_area = (output)->
	if markdown_format_checkbox.checked
		output_textarea.value = output.text.split("\n").map(
			(str)-> str.replace(/^/g,"    ")
		).join("\n")
	else
		output_textarea.value = output.text
	
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
		if output.numOverlaps > 0
			"🙈 #{output.numOverlaps} glyphs occlude differing glyphs"
		else
			"👌 all overlapping glyphs match"

	overlap_details.innerHTML =
		if output.numOverlaps > 0
			"<ul>#{
				(for under, overs of output.overlaps
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
	{length: 4, xPerGlyph: 2, yPerGlyph: 0, text: "CUBIC"}
	{length: 4, xPerGlyph: 0, yPerGlyph: 1, text: "CUBIC"}
	{length: 2, xPerGlyph: 2, yPerGlyph: 1, text: "\\"}
	{length: 0, xPerGlyph: 3, yPerGlyph: 1, text: "~"}
	{length: 0, xPerGlyph: -1, yPerGlyph: 1, text: "/"}
]

do compute = ->
	
	# for dimension in dimensions
	# 	dimension.glyphs = splitter.splitGraphemes(dimension.text)

	output = renderHypercube(dimensions, splitter)

	update_output_area(output)

make_dimension_row = (nd_name, dimension)->
	container_el = document.createElement("p")
	
	label_el = document.createElement("label")
	text_input = document.createElement("input")
	text_input.type = "text"
	text_input.className = "text-input"
	text_input.value = dimension.text
	text_input.addEventListener "input", ->
		dimension.text = text_input.value
		length_for_text = splitter.splitGraphemes(dimension.text).length - 1
		if length_for_text > dimension.length
			dimension.length = length_for_text
			length_input.value = length_for_text
		compute()
	label_el.appendChild(document.createTextNode("#{nd_name} "))
	label_el.appendChild(document.createTextNode("Text: "))
	label_el.appendChild(text_input)
	container_el.appendChild(label_el)
	
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
	label_el.appendChild(document.createTextNode("Length: "))
	label_el.appendChild(length_input)
	container_el.appendChild(label_el)
	
	label_el = document.createElement("label")
	offset_input = document.createElement("input")
	offset_input.type = "text"
	offset_input.className = "vector-input"
	offset_input.value = "#{dimension.xPerGlyph}, #{dimension.yPerGlyph}"
	offset_input.required = true
	offset_input.pattern = "-?\\d+\\s*,\\s*-?\\d+"
	offset_input.addEventListener "input", ->
		[x_str, y_str] = offset_input.value.split(",")
		unless isNaN(parseInt(x_str))
			dimension.xPerGlyph = parseInt(x_str)
		unless isNaN(parseInt(y_str))
			dimension.yPerGlyph = parseInt(y_str)
		compute()
	label_el.appendChild(document.createTextNode("Offset per glyph: "))
	label_el.appendChild(offset_input)
	container_el.appendChild(label_el)
	
	container_el

for dimension, i in dimensions
	el = make_dimension_row("#{i + 1}D", dimension)
	form.appendChild(el)

add_dimension_button.addEventListener "click", ->
	xPerGlyph = ~~(Math.random() * 5) - 2
	yPerGlyph = ~~(Math.random() * 5) - 2
	length = ~~(Math.random() * 5) + 2
	if xPerGlyph is 0 and yPerGlyph is 0
		yPerGlyph = 5
	dimension = {length, xPerGlyph, yPerGlyph, text: "*"}
	dimensions.push(dimension)
	el = make_dimension_row("#{dimensions.length}D", dimension)
	form.appendChild(el)
	compute()

for input in document.querySelectorAll("form input")
	input.addEventListener("input", compute)

# Optimization: could retain output and only call update_output_area
markdown_format_checkbox.addEventListener("change", compute)

tid = -1
show_copied_indicator = ->
	copied_indicator.removeAttribute("aria-hidden")
	copied_indicator.innerHTML = copied_indicator.innerHTML
	clearTimeout(tid)
	tid = setTimeout ->
		copied_indicator.setAttribute("aria-hidden", "true")
	, 1500
	
	setTimeout ->
		copied_indicator.style.animation = "bump 0.2s 1"
	, 15
copied_indicator.addEventListener "animationend", ->
	copied_indicator.style.animation = "none"

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

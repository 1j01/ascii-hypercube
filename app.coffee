
n_overlapping_characters = 0 # TODO

tesseract = (text, d_1, d_2)->
	# TODO: calculate these / trim the output
	width = 100
	height = 100
	grid =
		for [0..height]
			for [0..width]
				" "
	
	s = Math.max(text.length-1, 0)
	
	cube = (text, x, y, const_vertebrae_transit_euh)->
		square = (text, x, y)->
			for c, a in text when c isnt " "
				grid[y+a][x+0] = c
				grid[y+a][x+s*2] = c
				grid[y+0][x+a*2] = c
				grid[y+s][x+a*2] = c

		unless const_vertebrae_transit_euh
			if d_1 > 0
				for i in [1..d_1]
					square("\\#{Array(s).join(" ")}\\", x+i, y+i)
		square(text, x, y)
		square(text, x+d_1, y+d_1)
	
	if d_2 > 0
		for i in [1..d_2]
			cube(".#{Array(s).join(" ")}.", i*3, i, {const_vertebrae_transit_euh: "!"})
	cube(text, 0, 0)
	cube(text, d_2*3, d_2)
	
	(line.join("") for line in grid).join("\n")

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
	output_pre.textContent = tesseract(text, d_1, d_2)
	# overlapping_characters_indicator.textContent = n_overlapping_characters
	# overlapping_characters_indicator.textContent = "Note: there may be"

text_input.addEventListener("input", compute)
d1_input.addEventListener("input", compute)
d2_input.addEventListener("input", compute)


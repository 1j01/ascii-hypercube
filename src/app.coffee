# import {renderHypercube} from "./ascii-hypercube.js"
# renderHypercube = await import("./ascii-hypercube.js").then(m => m.renderHypercube)

form = document.getElementById("inputs")
addDimensionButton = document.getElementById("add-dimension")
outputTextarea = document.getElementById("output-textarea")
copyToClipboardButton = document.getElementById("copy-to-clipboard")
markdownFormatCheckbox = document.getElementById("markdown-format-checkbox")
overlapSummary = document.getElementById("overlap-summary")
overlapDetails = document.getElementById("overlap-details")
copiedIndicator = document.getElementById("copied-to-clipboard")

updateOutputArea = (output)->
	if markdownFormatCheckbox.checked
		outputTextarea.value = output.text.split("\n").map(
			(str)-> str.replace(/^/g,"    ")
		).join("\n")
	else
		outputTextarea.value = output.text
	
	style = window.getComputedStyle(outputTextarea, null)
	paddingTop = parseFloat(style.getPropertyValue("padding-top"))
	paddingBottom = parseFloat(style.getPropertyValue("padding-bottom"))
	
	outputTextarea.style.height = "1px"
	scrollHeight = outputTextarea.scrollHeight
	# outputTextarea.style.height = "#{outputTextarea.scrollHeight + 50}px"
	# console.log outputTextarea.scrollHeight, paddingTop, paddingBottom
	# outputTextarea.style.height = "#{scrollHeight + 50}px"
	outputTextarea.style.height = "#{scrollHeight + paddingTop + paddingBottom}px"
	
	overlapSummary.textContent =
		if output.numOverlaps > 0
			"🙈 #{output.numOverlaps} glyphs occlude differing glyphs"
		else
			"👌 all overlapping glyphs match"

	overlapDetails.innerHTML =
		if output.numOverlaps > 0
			"<ul>#{
				(for under, overs of output.overlaps
					(for over, nOver of overs
						"<li><code>#{over}</code> over <code>#{under}</code> (#{nOver})</li>"
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

	updateOutputArea(output)

makeDimensionRow = (ndName, dimension)->
	containerEl = document.createElement("p")
	
	labelEl = document.createElement("label")
	textInput = document.createElement("input")
	textInput.type = "text"
	textInput.className = "text-input"
	textInput.value = dimension.text
	textInput.addEventListener "input", ->
		dimension.text = textInput.value
		lengthForText = splitter.splitGraphemes(dimension.text).length - 1
		if lengthForText > dimension.length
			dimension.length = lengthForText
			lengthInput.value = lengthForText
		compute()
	labelEl.appendChild(document.createTextNode("#{ndName} "))
	labelEl.appendChild(document.createTextNode("Text: "))
	labelEl.appendChild(textInput)
	containerEl.appendChild(labelEl)
	
	labelEl = document.createElement("label")
	lengthInput = document.createElement("input")
	lengthInput.type = "number"
	lengthInput.min = 0
	lengthInput.step = 1
	lengthInput.value = dimension.length
	lengthInput.required = true
	lengthInput.addEventListener "input", ->
		unless isNaN(parseInt(lengthInput.value))
			dimension.length = parseInt(lengthInput.value)
		compute()
	labelEl.appendChild(document.createTextNode("Length: "))
	labelEl.appendChild(lengthInput)
	containerEl.appendChild(labelEl)
	
	labelEl = document.createElement("label")
	offsetInput = document.createElement("input")
	offsetInput.type = "text"
	offsetInput.className = "vector-input"
	offsetInput.value = "#{dimension.xPerGlyph}, #{dimension.yPerGlyph}"
	offsetInput.required = true
	offsetInput.pattern = "-?\\d+\\s*,\\s*-?\\d+"
	offsetInput.addEventListener "input", ->
		[xStr, yStr] = offsetInput.value.split(",")
		unless isNaN(parseInt(xStr))
			dimension.xPerGlyph = parseInt(xStr)
		unless isNaN(parseInt(yStr))
			dimension.yPerGlyph = parseInt(yStr)
		compute()
	labelEl.appendChild(document.createTextNode("Offset per glyph: "))
	labelEl.appendChild(offsetInput)
	containerEl.appendChild(labelEl)
	
	containerEl

for dimension, i in dimensions
	el = makeDimensionRow("#{i + 1}D", dimension)
	form.appendChild(el)

addDimensionButton.addEventListener "click", ->
	xPerGlyph = ~~(Math.random() * 5) - 2
	yPerGlyph = ~~(Math.random() * 5) - 2
	length = ~~(Math.random() * 5) + 2
	if xPerGlyph is 0 and yPerGlyph is 0
		yPerGlyph = 5
	dimension = {length, xPerGlyph, yPerGlyph, text: "*"}
	dimensions.push(dimension)
	el = makeDimensionRow("#{dimensions.length}D", dimension)
	form.appendChild(el)
	compute()

for input in document.querySelectorAll("form input")
	input.addEventListener("input", compute)

# Optimization: could retain output and only call updateOutputArea
markdownFormatCheckbox.addEventListener("change", compute)

tid = -1
showCopiedIndicator = ->
	copiedIndicator.removeAttribute("aria-hidden")
	copiedIndicator.innerHTML = copiedIndicator.innerHTML
	clearTimeout(tid)
	tid = setTimeout ->
		copiedIndicator.setAttribute("aria-hidden", "true")
	, 1500
	
	setTimeout ->
		copiedIndicator.style.animation = "bump 0.2s 1"
	, 15
copiedIndicator.addEventListener "animationend", ->
	copiedIndicator.style.animation = "none"

copyToClipboardButton.addEventListener "click", ->

	if navigator.clipboard?.writeText
		navigator.clipboard.writeText(outputTextarea.value).then(showCopiedIndicator)
	else
		# Select the text field contents
		outputTextarea.select()
		# Copy the text field contents to the clipboard
		success = document.execCommand("copy")
		
		if success
			showCopiedIndicator()

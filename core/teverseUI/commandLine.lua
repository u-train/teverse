local clamp = function(x, min, max)
	--[[
		@description
			Clamps a value x with the given arguments.
			LuaJit doesn't have it... cringe!
		@parameters
			number, x
			number, min
			number max
		@return
			number, x
	]]
	return max <= x and max or (x <= min and min or x)
end

--UI elements
local container = teverse.construct("guiScrollView", {
	scrollbarAlpha = 0;
	scrollbarWidth = 0;
	canvasSize = guiCoord(1, 0, 1, 0);
})

local textBox = teverse.construct("guiTextBox", {
	parent = container;
	size = container.canvasSize;
	backgroundColour = colour(0.9, 0.9, 0.9);
	textColour = colour(0.5, 0.5, 0.5);
	textSize = 20;
	textEditable = true;
	textWrap = true;
})

textBox:on("changed", function(property)
	if property == "text" then
		container.canvasSize = guiCoord(1, 0, 0, math.max(20, textBox.textDimensions.y))
		textBox.size = guiCoord(1, 0, 0, math.max(20, textBox.textDimensions.y))
	end
end)

local lastParEvent
container:on("changed", function(propertyName)
	if propertyName == "parent" then
		if lastParEvent then
			teverse.disconnect(lastParEvent)
		end

		lastParEvent = container.parent:on("changed", function()
			container.canvasSize = guiCoord(1, 0, 0, math.max(20, textBox.textDimensions.y))
			textBox.size = guiCoord(1, 0, 0, math.max(20, textBox.textDimensions.y))
		end)
	end
end)

--Execute the code. If it is "1 + 1", print the result out.
--If the code fails, print it out.
textBox:on("keyDown", function(key)
	if key == "KEY_RETURN" or key == "KEY_KP_ENTER" then
		local success, valueReturned = pcall(loadstring(textBox.text))
		if not success then
			success, valueReturned = pcall(loadstring("return "..textBox.text))
			if not success then
				print("CONSOLE ERROR: "..valueReturned)
			else
				print(valueReturned or "Ran without error.")
			end
		else
			print(valueReturned or "Ran without error.")
		end
		textBox.text = ""
	end
end)

return container
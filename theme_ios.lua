-----------------------------------------------------------------------------------------
--
-- theme_ios.lua
--
-----------------------------------------------------------------------------------------
local modname = ...
local themeTable = {}
package.loaded[modname] = themeTable
local assetDir = "widget_ios/"

-----------------------------------------------------------------------------------------
--
-- button
--
-----------------------------------------------------------------------------------------
--
-- specify a "style" option to use different button styles on a per-button basis
--
-- example:
-- local button = widget.newButton{ style="blue1Small" }
--
-- NOTE: using a "style" is not required.
--
-----------------------------------------------------------------------------------------

themeTable.button = {
	-- if no style is specified, will use button default:
	default = assetDir .. "button/default.png",
	over = assetDir .. "button/over.png",
	width = 278, height = 46,
	font = "Algerian",
	fontSize = 20,
	labelColor = { default={0}, over={255} },
	emboss = true,
	

	
	sheetYellow = {
		default = assetDir .. "button/sheetGreen/default.png",
		over = assetDir .. "button/sheetGreen/over.png",
		width = 380, height = 76,
		font = "Algerian",
		fontSize = 36,
		labelColor = { default={0}, over={255} },
		emboss = true,
	}
	


}



return themeTable
----------------------------------------------------------------------------------
--
-- highscore.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()
local group = display.newGroup()

--function for getting data and printing it out on scoreboard
local function writeScoreboard(screenGroup)
      local data = {}
      data = ls.loadData(system.pathForFile("data.txt",system.DocumentsDirectory))

      display.setDefault( "textColor",0,0,0)

      for k,v in ipairs(data) do
            for l,w in ipairs(v) do
                  if k == 1 then
                        display.newText(group, l..": "..w,200,100*l-50,"Algerian",42)
                  elseif k == 2 then
                        display.newText(group, w,500,100*l-50,"Algerian",42)
                  end
            end
      end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view

	display.newImage(screenGroup,"image/bg_pattern.png",0,0,display.contentWidth,display.contentHeight)

      --create and configs the button for getting back to menu
	local menu = widget.newButton{
		style = "sheetYellow",
		id = "menu",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.7,
                label="Back To Menu",
		onEvent = function (event)
        	if event.phase == "release" then
			storyboard.gotoScene("menu", "flipFadeOutIn")
            end end
	}
	
	screenGroup:insert(menu)
	
	--display.newRect(screenGroup,20,900,728,90)
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	-- remove previous scene's view
      ads.show( "banner728x90", { x=20, y=900, interval=5, testMode=true } ) 
      writeScoreboard(screenGroup)
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
      -- remove eventListener on buttons
     	group:removeSelf()
	group = display.newGroup()
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene

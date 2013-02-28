----------------------------------------------------------------------------------
--
-- credit.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()

-- Called when the scene's view does not exist:
function scene:createScene( event )
      local group = self.view

      local bg= display.newImage("image/credits.png")

      local function goback(event)
            if event.phase == "release" then
                  storyboard.gotoScene("menu", "flipFadeOutIn")            
            end
	end
	
      local menu = widget.newButton{
	style = "sheetYellow",
	id = "menu",
	left = display.contentWidth*.5-190,
	top = display.contentHeight*.75,
	label="Back To Menu",
	onEvent = goback,
	cornerRadius = 10
	}
	
	group:insert(bg)
	group:insert(menu)
	
	--display.newRect(group,20,900,728,90)
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
      ads.show( "banner728x90", { x=20, y=900, interval=5, testMode=true } ) 
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view

      ads.hide()
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene


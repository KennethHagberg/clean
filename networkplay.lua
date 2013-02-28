----------------------------------------------------------------------------------
--
-- networkplay.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view

	display.newImage(screenGroup,"image/bg_pattern.png",0,0,display.contentWidth,display.contentHeight)

      --create and configs the button for hosting a war game
	local hostGhost = widget.newButton{ 
		style = "sheetYellow",
		id = "host ghost",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.3,
            label="Host Ghost Game",
		onEvent = function (event)
        	if event.phase == "release" then
                  net.setGameMode("ghost")
                  storyboard.gotoScene("host","flipFadeOutIn")
            end end
	}
      --create and configs the button for hosting a ghost game
      local hostWar = widget.newButton{
		style = "sheetYellow",
		id = "host war",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.2,
            label="Host War Game",
		onEvent = function (event)
        	if event.phase == "release" then
                  net.setGameMode("war")
                  storyboard.gotoScene("host","flipFadeOutIn")
            end end
	}
      --create and configs the button for joining a lobby
      local join = widget.newButton{
		style = "sheetYellow",
		id = "join",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.5,
            label="Join Game",
		onEvent = function (event)
        	if event.phase == "release" then
                  storyboard.gotoScene("connect","flipFadeOutIn")
            end end
	}
      --create and configs the button for getting back to menu
      local menu = widget.newButton{
		style = "sheetYellow",
		id = "menu",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.7,
            label="Back To Menu",
		onEvent = function (event)
        	if event.phase == "release" then
			storyboard.gotoScene("menu","flipFadeOutIn")
            end end
	}

      screenGroup:insert(hostWar)
      screenGroup:insert(hostGhost)
      screenGroup:insert(join)
      screenGroup:insert(menu)

	--display.newRect(screenGroup,20,35,728,90)
	--display.newRect(screenGroup,20,900,728,90)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
      ads.show( "banner728x90", { x=20, y=20, interval=10, testMode=true } ) 
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
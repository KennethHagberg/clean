----------------------------------------------------------------------------------
--
-- host scene.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()
local list = display.newGroup()

--clears lobby list and calls on function for redrawing it again with the new data
function updateHostLobby(data)
      list:removeSelf()
      list = display.newGroup()
      list:insert(require "drawlobby"(data[1],data[2],data[3]))
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
		top = display.contentHeight*.8,
            label="Back To Menu",
		onEvent = function (event)
        	if event.phase == "release" then
			storyboard.gotoScene("menu","flipFadeOutIn")
                  net.closeNetwork("server")
            end end
	}

	--create and configs the button for getting to the game
      local start = widget.newButton{
		style = "sheetYellow",
		id = "start",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.7,
            label="Start Game",
		onEvent = function (event)
        	if event.phase == "release" then
                  local ready = net.getReadyState()
                  if net.getNumPlayers() > 1 and ready[2] then  -- if there are two or more players start the game
                              if net.getGameMode() == "war" then
                                    net.sendPackageToAll({2,1})
                                    storyboard.gotoScene("war","flipFadeOutIn")
                              elseif net.getGameMode() == "ghost" then
                                    print(ready[2])
                                    net.sendPackageToAll({2,2})
                                    storyboard.gotoScene("ghost","flipFadeOutIn")
                              end
                  end
            end end
	}

      screenGroup:insert(menu)
      screenGroup:insert(start)
      screenGroup:insert(list)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
      net.createNetwork("server")
      net.setLobby(true)
      updateHostLobby({1,{nil},{getPlayer()}})
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
      net.setLobby(false)
	list:removeSelf()
	list = display.newGroup()
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view

end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )

---------------------------------------------------------------------------------

return scene

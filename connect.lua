----------------------------------------------------------------------------------
--
-- connect.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()
local connectionGroup = display.newGroup()

--event for making a new button for a lobby that has been found
local function serverFound(event)
      local ip = event.serverIP

      local newConnection = widget.newButton{
            style = "sheetYellow",
            id = event.serverIP,
            left = display.contentWidth*.5-160,
            top = display.contentHeight*(.1*connectionGroup.numChildren+.1),
            label=event.customBroadcast,
            onEvent = function (event)
            if event.phase == "release" then
                  connectionGroup:removeSelf()
                  connectionGroup = display.newGroup()
                  net.connectTo(ip)
                  storyboard.gotoScene("lobby","flipFadeOutIn")
            end end
      }
    
      connectionGroup:insert(newConnection)
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local screenGroup = self.view

      net.createNetwork("client")

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
                  net.closeNetwork("client")
            end end
	}
      --create and configs the button for refreshing the list of joinable lobbies
      local refresh = widget.newButton{
		style = "sheetYellow",
		id = "refresh",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.7,
            label="Refresh List",
		onEvent = function (event)
        	if event.phase == "release" then
                  connectionGroup:removeSelf()
                  connectionGroup = display.newGroup()
                  net.closeNetwork("client")
                  net.createNetwork("client")
            end end
	}

      screenGroup:insert(menu)
      screenGroup:insert(refresh)
      screenGroup:insert(connectionGroup)

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
      Runtime:addEventListener("autolanServerFound",serverFound)
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
      Runtime:removeEventListener("autolanServerFound",serverFound)
      connectionGroup:removeSelf()
      connectionGroup = display.newGroup()
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

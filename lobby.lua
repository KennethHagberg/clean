----------------------------------------------------------------------------------
--
-- lobby.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()

local isReady = false
local lobbyReady = false
local list = display.newGroup()

--event on reaciving new information about clients conected to server
function receiveLobbyPackage(data)
	--if lobbyReady then
            list:removeSelf()
            list = display.newGroup()
            list:insert(require "drawlobby"(data[1],data[2],data[3]))
	--[[else
    	   timer.performWithDelay(1000,
		function( event)
			list:removeSelf()
			list = display.newGroup()
			list:insert(require "drawlobby"(data[1],data[2],data[3]))
		end,1)
	end ]]
end

--event to start game when server does
function receiveStartPackage(data)
      if data == 1 then
            net.setGameMode("war")
            storyboard.gotoScene("war","flipFadeOutIn")
      elseif data == 2 then
            net.setGameMode("ghost")
            storyboard.gotoScene("ghost","flipFadeOutIn")
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
		top = display.contentHeight*.8,
            label="Back To Menu",
		onEvent = function (event)
        	if event.phase == "release" then
                  
			storyboard.gotoScene("menu","flipFadeOutIn")
                  net.closeNetwork("client")
            end end
	}

      local ready = widget.newButton{
		style = "sheetYellow",
		id = "ready",
		left = display.contentWidth*.5-160,
		top = display.contentHeight*.7,
            label="Ready",
		onEvent = function (event)
        	if event.phase == "release" then
                  if isReady then
                        isReady = false
                        event.target:setLabel("Ready")
                        net.clientSend({3,false})
                  else
                        isReady = true
                        event.target:setLabel("Not ready")
                        net.clientSend({3,true})
            end end end
	}

      screenGroup:insert(menu)
      screenGroup:insert(ready)
      screenGroup:insert(list)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	isReady = false
	lobbyReady = true
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	list:removeSelf()
      list = nil
	list = display.newGroup()
	lobbyReady = false
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

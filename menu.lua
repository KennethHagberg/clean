----------------------------------------------------------------------------------
--
-- menu.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()
local player

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
        
      local  bg=display.newImage("image/start.png")
            
      local bord1 = widget.newButton{
            style = "sheetYellow",
            id = "btn001",
            left =0,
            top = display.contentHeight-180,
            label="Single Player",
            cornerRadius = 10,
            onEvent = function (event )
            if event.phase == "release" then
                  storyboard.gotoScene("single","flipFadeOutIn")
            end end
      }

      local bord2 = widget.newButton{
            style = "sheetYellow",
            id = "btn002",
            left = display.contentWidth*.5,
            top = display.contentHeight-180,
            label="Multi player",
            cornerRadius = 10,
            onEvent = function (event )
            if event.phase == "release" then
                  storyboard.gotoScene("networkplay","flipFadeOutIn")
            end end
      }

      local bord3 = widget.newButton{
            style = "sheetYellow",
            id = "btn003",
            left = 0,
            top = display.contentHeight-100,
            label="Credits",
            cornerRadius = 10,
            onEvent = function (event)
            if event.phase == "release" then
                  storyboard.gotoScene("credit","flipFadeOutIn")
            end end
      }

      
      local bord4 = widget.newButton{
            style = "sheetYellow",
            id = "btn004",
            left = display.contentWidth*.5,
            top = display.contentHeight-100,
            label="HighScore",
            cornerRadius = 10,
            onEvent = function (event)
            if event.phase == "release" then
                  storyboard.gotoScene("highscore","flipFadeOutIn")
            end end
      }

      local bord5 = widget.newButton{
            style = "sheetYellow",
            id = "btn005",
            left = 20,
            top = 10,
            label="Choose Player",
            fontSize=24,
            overColor= {50,150,100},
            strokeColor= {0,255,255,180},
            width = 230, height = 50,
            cornerRadius = 10,
            onEvent = function (event)
            if event.phase == "release" then
                  storyboard.purgeScene("premenu")
                  storyboard.gotoScene("premenu","flipFadeOutIn")
            end end
      }


      group:insert(bg)
      group:insert(bord1)
      group:insert(bord2)
      group:insert(bord3)
      group:insert(bord4)
      group:insert(bord5)

      player = display.newText(group,"Player: "..getPlayer(),display.contentWidth*.6-150,15,"Algerian",35)
      player:setReferencePoint(display.CenterReferencePoint)
      
      return scene
end



-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
        
      player.text = "Player: " .. getPlayer()
      
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
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
----------------------------------------------------------------------------------
--
-- single player.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()

physics.start()
--physics.setDrawMode("hybrid")

local pauseGroup
local physGroup
local endGroup

--function for creating a ball
function makeBall()
      local ball= display.newImage("image/ball_05.png",700,500)
      physics.addBody(ball,{radius=16})
      ball.isSleepingAllowed = false
      return ball
end

--event for setting new gravity on tilt
function onTilt( event )
	  physics.setGravity( (9.8 * event.xGravity*4), (-9.8 * event.yGravity*4) )

        if event.xGravity < 0 then
            if event.xGravity < (-0.5) then
                  path.x=12
                  physPath.x=12 + display.contentWidth/2
            else
                  path.x=-(event.xGravity)*24
                  physPath.x=-(event.xGravity)*24 + display.contentWidth/2
            end
        elseif event.xGravity > 0 then
            if event.xGravity > 0.5 then
                  path.x=-12
                  physPath.x=-12 + display.contentWidth/2
            else
                  path.x=-(event.xGravity)*24
                  physPath.x=-(event.xGravity)*24 + display.contentWidth/2
            end
        else
            path.x=0
            physPath.x=display.contentWidth/2
        end

        if event.yGravity < 0 then
            if event.yGravity < (-0.5) then
                  path.y=-12
                  physPath.y=-12 + display.contentHeight/2
            else
                  path.y=(event.yGravity)*24
                  physPath.y=(event.yGravity)*24 + display.contentHeight/2
            end
        elseif event.yGravity > 0 then
            if event.yGravity > 0.5 then
                  path.y=12
                  physPath.y=12 + display.contentHeight/2
            else
                  path.y=(event.yGravity)*24
                  physPath.y=(event.yGravity)*24 + display.contentHeight/2
            end
        else
            path.y=0
            physPath.y=display.contentHeight/2
        end
end

--function for pausing the game and config an pause meny
function pause()
      Runtime:removeEventListener("tap", pause) 
      physics.pause()
      myTimer.timerPause()

      pauseGroup=display.newGroup()

      local btn3 = widget.newButton{
            id = "btn003",
            left = display.contentWidth*.4,
            top = display.contentHeight*.4,
            label="Play",
            style = "sheetYellow",
            fontSize=24,
            overColor= {50,150,100},
            strokeColor= {0,255,255,180},
            width = 200, height = 150,
            onRelease = function ()
            timer.performWithDelay(50, 
                  function()
                        pauseGroup:removeSelf()
                        pauseGroup = nil
                        physics.start()
                        myTimer.timerPause()                       
                        Runtime:addEventListener("tap", pause)
                  end,1) 
            end
      } 

      pauseGroup:insert(btn3)
 
      local btn4 = widget.newButton{
            id = "btn004",
            left = display.contentWidth*.4,
            top = display.contentHeight*.6,
            label="Go to meny",
            style = "sheetYellow",
            fontSize=24,
            overColor= {50,150,100},
            strokeColor= {0,255,255,180},
            width = 200, height = 150,
            onEvent = function (event )
            if event.phase == "release" then
                  storyboard.gotoScene("menu","flipFadeOutIn")
            end end
      } 

      pauseGroup:insert(btn4)
end

--function for handling on finnish line event
function endLine() 
      ball:removeSelf()
      ball = nil

      Runtime:removeEventListener("tap",pause)
      Runtime:removeEventListener("accelerometer", onTilt )

      myTimer.timerPause()

      endGroup = display.newGroup()

      local alert2 = display.newRect(endGroup,display.contentWidth*0.5-80,display.contentHeight*0.6-40,160,80)
      alert2:setFillColor(50,50,50,150)

      local alert= display.newImageRect(endGroup,"image/alert2.png",180,140)
      alert.x=display.contentWidth*0.5
      alert.y= display.contentHeight*0.5

      local alertScore1= display.newText(endGroup,"You'r time:",0,0,nil,30)
      alertScore1.x=display.contentWidth*0.5
      alertScore1.y=display.contentHeight*0.6-20

      local alertScore2= display.newText(endGroup,myTimer.timerGet(),0,0,nil,30)
      alertScore2.x=display.contentWidth*0.5
      alertScore2.y=display.contentHeight*0.6+20

      local btn1 = widget.newButton{
            id = "btn001",
            left = alertScore2.x-75,
            top = alertScore2.y+30,
            label="Go to meny",
            style = "sheetYellow",
            fontSize=24,
            overColor= {50,150,100},
            strokeColor= {0,255,255,180},
            width = 150, height = 50,
            onEvent = function (event )
            if event.phase == "release" then
                  storyboard.gotoScene("menu","flipFadeOutIn")
            end end
      } 

      endGroup:insert(btn1)    
  

      local newData = {name=getPlayer(),time=myTimer.timerGet(),value=myTimer.timerGetTot()}
      local filePath = system.pathForFile("data.txt", system.DocumentsDirectory)      
      local oldData = ls.loadData(filePath)
      local data = ls.sortData(oldData,newData,filePath)
      ls.saveData(data,filePath) 
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
      local group = self.view
      
      system.setAccelerometerInterval( 30 )

      local scaleFactor = 1
      physicsData = (require "level3").physicsData(scaleFactor)
      local bottom=display.newImage(group,"image/level2/01-background.png")
      path=display.newImage(group,"image/level2/03-path.png")
      path:setReferencePoint(display.TopLeftReferencePoint)
      local timeDisplay = display.newText(group,myTimer.timerGet(),10,350,"Algerian",280)	
      local walls=display.newImage(group,"image/level2/02-walls.png")
      timeDisplay:setTextColor(0,0,0,120)

      Runtime:addEventListener("enterFrame",
      function()
            timeDisplay.text = myTimer.timerGet()
      end)
end




-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view

      physics.start() 

      myTimer.timerStart()

      physGroup = display.newGroup()

      physPath = display.newRect(physGroup,display.contentWidth/2,display.contentHeight/2,0,0)
      local physBottom = display.newRect(physGroup,display.contentWidth/2,display.contentHeight/2,0,0)
	
      physics.addBody(physPath,"static", physicsData:get("03-path"))
      physics.addBody(physBottom,"static",physicsData:get("03-path"))
	
	local fin=display.newImage(physGroup,"image/finish.png",25,637)
      physics.addBody(fin,"static")
      fin:addEventListener("collision", endLine)

      local hole = {}
      for i=1,12 do 
            hole[i]=display.newImage(physGroup,"image/hole.png")
            hole[i]:setFillColor(0,0,0)
            physics.addBody(hole[i],"static",{radius=5,isSensor=true})
            hole[i]:addEventListener("collision", 
            function(event)
                 if event.phase=="began" then
                    event.other.gravityScale = 0
                    event.other.linearDamping=2000
                    pop = media.newEventSound("media/pop2_wav.wav")
                    media.playEventSound(pop)
                    transition.to(event.other ,{time=500, xScale=0.1, yScale=0.1,alpha=0,onComplete=function()ball:removeSelf();ball = makeBall() end} )
                 end
            end)
      end 

      hole[1].x=45; hole[1].y=110; hole[2].x=320; hole[2].y=150; hole[3].x=530; hole[3].y=100;
      hole[4].x=560; hole[4].y=240; hole[5].x=310; hole[5].y=340; hole[6].x=260; hole[6].y=530;
      hole[7].x=120; hole[7].y=525; hole[8].x=360; hole[8].y=680; hole[9].x=520; hole[9].y=650;
      hole[10].x=720; hole[10].y=590; hole[11].x=580; hole[11].y=750; hole[12].x=150; hole[12].y=890;
       
      ball = makeBall()

      Runtime:addEventListener("accelerometer", onTilt )
      Runtime:addEventListener("tap", pause)
end


-- Called when scene have moved offscreen:
function scene:exitScene( event )
	local group = self.view
	
      physics.stop()
     
      myTimer.timerClear()

      physGroup:removeSelf()
      physGroup = nil

      if ball then
            ball:removeSelf()
            ball = nil 
      end

      Runtime:removeEventListener("accelerometer", onTilt )
	Runtime:removeEventListener("tap",pause)

      if pauseGroup then
            pauseGroup:removeSelf()
            pauseGroup = nil
      end

      if endGroup then
            endGroup:removeSelf()
            endGroup = nil
      end
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
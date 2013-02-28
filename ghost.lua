----------------------------------------------------------------------------------
--
-- ghost.lua
--
----------------------------------------------------------------------------------
local scene = storyboard.newScene()

physics.start() 
--physics.setDrawMode("hybrid") 

local myIndex = nil
local ballList = {}
local timeList = {{},{}}
local alertScore1 = display.newText("",-10,-10,nil,30) 
local physGroup
local endGroup

--event on receive package from server, containing data for all ball pos
function recieveServerGravPackage(data)
      for i = 1, net.getNumPlayers() do
            if i ~= myIndex then
                  ballList[i].x = data[3][i]
                  ballList[i].y = data[4][i]
            end
      end
end

--event on receive package from client, containing data for client ball pos
function recieveClientGravPackage(data)
      ballList[data[1]].x = data[4]
      ballList[data[1]].y = data[5]
end

--event on receive package from server, containing data for removing a client and its ball
function recieveClientDcPackage(data)
      if ballList[data] then
            ballList[data]:removeSelf()
            ballList[data] = nil
      end
end

--event on receive package from client, containing data for client who has reached finnish line
function recieveDonePackage(data)
      timeList[1][data[1]] = data[1]
      timeList[2][data[1]] = data[2]

      if ballList[data[1]] then
            ballList[data[1]]:removeSelf()
            ballList[data[1]] = nil
      end

      if #timeList[1] == net.getNumPlayers() then
            for i = 1,#timeList[1] do
                  local index = 1

                  while(timeList[1][index] ~= i)do
                        index = index + 1
                  end

                  sortTimes(index)
            end
            
            local index = 1

            while(timeList[1][index] ~= myIndex) do
                  index = index + 1
            end

            net.sendPackageToAll({8,timeList[1]}) 

            alertScore1.text=index
      end

      net.sendPackageToAll({11,data[1]})
end

--event on receive package from server, containing data for client to go back to lobby
function recieveBackToLobbyPackage(data)
      storyboard.gotoScene("lobby","flipFadeOutIn")
end

--event on receive package from server, containing data for clients position in time
function recieveRankPackage(data)
      alertScore1.text=data
end

--function for creating a ball
function createBall()
      local ball= display.newImage("image/ball_05.png",700,500)
      physics.addBody(ball,{radius=16})
      ball.isSleepingAllowed = false
      return ball
end

function reset(event)
      event:removeSelf()
      event.bodyType="static"
      ballList[myIndex] = createBall()
end  

--function for sorting contestent in rank based on there finnish time, ranked from top with lowest time
function sortTimes(index)
      local temp = {nil,nil}
      if index ~= 1 and timeList[2][index] < timeList[2][index-1] then
            temp[1] = timeList[1][index]
            temp[2] = timeList[2][index]
            timeList[1][index] = timeList[1][index-1]
            timeList[2][index] = timeList[2][index-1]
            timeList[1][index-1] = temp[1]
            timeList[2][index-1] = temp[2]
            sortTimes(index-1)
      elseif index ~= net.getNumPlayers() and timeList[2][index] > timeList[2][index+1] then
            temp[1] = timeList[1][index]
            temp[2] = timeList[2][index]
            timeList[1][index] = timeList[1][index+1]
            timeList[2][index] = timeList[2][index+1]
            timeList[1][index+1] = temp[1]
            timeList[2][index+1] = temp[2]
            sortTimes(index+1)
      end
end

--function for sending all clients ball pos to every client connected 
function serverSend(event)
      local data = {nil,{},{},{},{}}
      for j = 1, #ballList do
            data[1] = 6
            data[2][j] = 0
            data[3][j] = 0
            data[4][j] = ballList[j].x
            data[5][j] = ballList[j].y
      end
      net.sendPackageToAll(data) 
end

--function for client sending ball pos to server
function clientSend(event)
      if ballList[myIndex] then
            local data = {nil,{},{},{},{}}
            data[1] = 5
            data[2] = 0
            data[3] = 0
            data[4] = ballList[myIndex].x
            data[5] = ballList[myIndex].y
            net.clientSend(data) 
      end
end

--event for setting new gravity on tilt
local function onTilt( event )
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

--function for drawing end game content
function endTheGame()         
      endGroup = display.newGroup()

      local alert2 = display.newRect(endGroup,display.contentWidth*0.3-60,display.contentHeight*0.6-40,420,80)
      alert2:setFillColor(50,50,50,150)

      local alert= display.newImageRect(endGroup,"image/alert2.png",180,140)
      alert.x=display.contentWidth*0.5
      alert.y= display.contentHeight*0.5

      alertScore1= display.newText(endGroup,"Waiting for other players",0,0,nil,30)          
      alertScore1.x=display.contentWidth*0.5
      alertScore1.y=display.contentHeight*0.6

end

--function for handling on finnish line event
function endLine(event)
      if event.phase == "began" then
      ballList[myIndex]:removeSelf()
      ballList[myIndex] = nil
            if net.getSide() == "server" then
                  Runtime:removeEventListener("enterFrame", serverSend)
                  timeList[1][myIndex] = myIndex
                  timeList[2][myIndex] = myTimer.timerGetTot()

                  ballList[myIndex]:removeSelf()
                  ballList[myIndex] = nil

                  if #timeList[1] == net.getNumPlayers() then
                        for i = 1,#timeList[1] do
                              local index = 1

                              while(timeList[1][index] ~= i)do
                                    index = index + 1
                              end

                              sortTimes(index)
                        end

                        net.sendPackageToAll({8,timeList[1]}) 

                        local index = 1

                        while(timeList[1][index] ~= myIndex) do
                              index = index + 1
                        end

                        endTheGame()
                        alertScore1.text=index
                  else
                        endTheGame()
                  end
                  net.sendPackageToAll({11,myIndex})
            elseif net.getSide() == "client" then
                  Runtime:removeEventListener("enterFrame", clientSend)      
                  net.clientSend({7,myTimer.timerGetTot()})  

                  endTheGame()
            end

            
      end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view

      system.setAccelerometerInterval( 30 )

      local scaleFactor = 1
      physicsData = (require "level3").physicsData(scaleFactor)
      local bottom = display.newImage(group,"image/level2/01-background.png")
      path = display.newImage(group,"image/level2/03-path.png")
      path:setReferencePoint(display.TopLeftReferencePoint)
      local wall = display.newImage(group,"image/level2/02-walls.png")
      bottom:setFillColor(116, 98, 47, 255)
      bottom.alpha = 0.7

      local btn4 = widget.newButton{
      id = "btn004",
      left = 20,
      top = 18,
      label="Disconnect",
      style = "sheetYellow",
      fontSize=24,
      overColor= {50,150,100},
      strokeColor= {0,255,255,180},
      width = 155, height = 120,
      onEvent = function (event )
            if event.phase == "release" then
                  net.closeNetwork()
             storyboard.gotoScene("menu","flipFadeOutIn")
            end
      end
      } 
      group:insert(btn4)
end
 

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
      physics.start()

      myIndex = net.getMyIndex()

   	myTimer.timerStart()

      physGroup = display.newGroup()

      physPath = display.newRect(physGroup,display.contentWidth/2,display.contentHeight/2,0,0)
      local physBottom = display.newRect(physGroup,display.contentWidth/2,display.contentHeight/2,0,0)
	
      physics.addBody(physPath,"static", physicsData:get("03-path"))
      physics.addBody(physBottom,"static",physicsData:get("03-path"))
	
	  
      local fin=display.newImage(physGroup,"image/finish.png",25,635)
      physics.addBody(fin,"static")
      fin:addEventListener("collision",endLine)

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
                    transition.to(event.other ,{time=500, xScale=0.1, yScale=0.1,alpha=0,onComplete=reset} )
                 end
            end)
      end 

    
      hole[1].x=-45; hole[1].y=-110; hole[2].x=320; hole[2].y=150; hole[3].x=530; hole[3].y=100;
      hole[4].x=560; hole[4].y=240; hole[5].x=310; hole[5].y=340; hole[6].x=260; hole[6].y=530;
      hole[7].x=120; hole[7].y=525; hole[8].x=360; hole[8].y=680; hole[9].x=520; hole[9].y=650;
      hole[10].x=720; hole[10].y=590; hole[11].x=580; hole[11].y=750; hole[12].x=150; hole[12].y=890;

      ballList[myIndex] = createBall()

      for i = 1, net.getNumPlayers() do
            if i ~= myIndex then
                ballList[i] = display.newImage(group,"image/ball_05.png",700,500)
				ballList[i]:setFillColor(125,125,175,50)
		   end
      end
	  

      Runtime:addEventListener("accelerometer", onTilt )

      if net.getSide() == "server" then
            Runtime:addEventListener("enterFrame", serverSend)
      elseif net.getSide() == "client" then
            Runtime:addEventListener("enterFrame", clientSend)
      end

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
      local group = self.view

	physics.stop()

      myTimer.timerClear()

      physGroup:removeSelf()
      physGroup = nil

      for i = 1, net.getMaxPlayer() do
            if ballList[i] then
                  ballList[i]:removeSelf()
                  ballList[i] = nil
            end
	end

      Runtime:removeEventListener("accelerometer", onTilt )
      



      if endGroup then
            endGroup:removeSelf()
            endGroup = nil
      end
      
      if net.getSide() == "server" then
            Runtime:removeEventListener("enterFrame", serverSend)
      elseif net.getSide() == "client" then
            Runtime:removeEventListener("enterFrame", clientSend)
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
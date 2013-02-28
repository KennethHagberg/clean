----------------------------------------------------------------------------------
--
-- War.lua ---Good God, yall
-- 
----------------------------------------------------------------------------------
local scene = storyboard.newScene()

physics.start() 
--physics.setDrawMode("hybrid") 

local myIndex = nil
local ballList = {}
local alertScore1 = display.newText("",-10,-10,nil,30) 
local pauseGroup 
local physGroup
local endGroup

--event on receive package from server, containing data for all ball pos
function recieveWarServerGravPackage(data)
    for i = 1, net.getNumPlayers() do
        if i ~= myIndex then
            ballList[i].x = data[3][i]
            ballList[i].y = data[4][i]
        end
    end
end

--event on receive package from client, containing data for client ball pos
function recieveWarClientGravPackage(data)
    ballList[data[1]].x = data[4]
    ballList[data[1]].y = data[5]
end

--event on receive package from server, containing data for removing a client and its ball
function recieveWarClientDcPackage(data)
    ballList[data]:removeSelf()
    ballList[data] = nil
end

--event on receive package from client, containing data for client who has reached finnish line
function recieveWarDonePackage(data)
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

        net.sendPackageToAll({8,timeList[1]}) 

        local index = 1

        while(timeList[1][index] ~= myIndex) do
			index = index + 1
        end

        alertScore1.text=index
    end

    net.sendPackageToAll({11,data[1]})
end

--event on receive package from server, containing data for client to go back to lobby
function recieveWarBackToLobbyPackage(data)
    storyboard.gotoScene("lobby","flipFadeOutIn")
end

--event on receive package from server, containing data for client to know it has lost the game
function recieveWarEnd(data)
    endTheGame(false)
end

--event on receive package from server, containing data for collision bettwen two balls
function recieveWarMakeCollision(data)
      if net.getSide() == "server" then
            ballList[myIndex]:setLinearVelocity(data[1],data[2])
      elseif net.getSide() == "client" then
            local tempx,tempy=ballList[myIndex]:getLinearVelocity()
            print(tempx,tempy)
            ballList[myIndex]:setLinearVelocity(data[1],data[2])
            net.clientSend({13,tempx,tempy})
      end
end

--function for creating a ball
function makeBall(index,type)
    local ball
	if index == 2 then 
        ball= display.newImage("image/ball_05.png",700,50)
        ball.id = 2
	
    elseif index == 1 then
        ball= display.newImage("image/ball_05.png",30,50)
        ball.id = 1

    end
    physics.addBody(ball,type,{radius=10})
    ball.isSleepingAllowed = false

    return ball
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

--function client for sending ball pos to server
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

--function for drawing end content, and letting other client know you have reached goal if you are first
function endTheGame(win)         
      endGroup = display.newGroup()

      alert2 = display.newRect(endGroup,display.contentWidth*0.3-60,display.contentHeight*0.6-40,420,80)
      alert2:setFillColor(50,50,50,150)

      alert= display.newImageRect(endGroup,"image/alert2.png",180,140)
      alert.x=display.contentWidth*0.5
      alert.y= display.contentHeight*0.5

      alertScore1= display.newText(endGroup,"",0,0,nil,30)          
      alertScore1.x=display.contentWidth*0.5
      alertScore1.y=display.contentHeight*0.6

      if win then
            alertScore1.text="You Won"

            if net.getSide() == "server" then
                  sendPackageToAll({14})
            elseif net.getSide() == "client" then
                  net.clientSend({14})
            end
      else
            alertScore1.text="Maby next time"
      end  
end

--event if server have sensed an collison
function pre(event)
      if event.object2 == ballList[3-myIndex]  then
            net.sendPackageToAll({13,event.object1:getLinearVelocity()})
      end
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
      local group = self.view

      system.setAccelerometerInterval( 30 )

      local scaleFactor = 1
      physicsData = (require "level1").physicsData(scaleFactor)
      bottom=display.newImage(group,"image/level1/01-background.png")
      path=display.newImage(group,"image/level1/03-path.png")
      path:setReferencePoint(display.TopLeftReferencePoint)
      wall = display.newImage(group,"image/level1/02-walls.png")
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
      physics.start()

      myIndex = net.getMyIndex()

      physGroup = display.newGroup()

      physPath = display.newRect(physGroup,display.contentWidth/2,display.contentHeight/2,0,0)
      physBottom = display.newRect(physGroup,display.contentWidth*0.5,display.contentHeight*0.5,0,0)

      physics.addBody(physPath,"static", physicsData:get("03-path"))
      physics.addBody(physBottom,"static",physicsData:get("03-path"))

   
	local fin=display.newImage(group,"image/finish.png",160,930)-- this is the finish line 
      fin.width=32;fin.height=35
      physics.addBody(fin,"static",{isSensor})
      fin:addEventListener("collision",
      function(event)
        ballList[myIndex]:removeSelf()
        ballList[myIndex] = nil
        endTheGame(true)
      end
      
	)
	
      local hole = {}
      for i=1,14 do 
            hole[i]=display.newImage(physGroup,"image/hole.png")
            hole[i]:setFillColor(0,0,0)
            physics.addBody(hole[i],"static",{radius=5,isSensor=true})
            hole[i]:addEventListener("collision", 
			function(event)
				if event.phase=="began" then
					event.other.gravityScale = 0
					pop = media.newEventSound("media/pop2_wav.wav")
					media.playEventSound(pop)
					if net.getSide() == "server" then
						Runtime:removeEventListener("enterFrame", serverSend)
					elseif net.getSide() == "client" then
						Runtime:removeEventListener("enterFrame", clientSend)
					end		
					transition.to(event.other ,{time=500, xScale=0.1, yScale=0.1,alpha=0,onComplete=
						function(target)
							if target.id==2 then
								xpos=700
								ypos=50
							elseif target.id==1 then
								xpos=30 
								ypos=50
							end
							transition.to(target ,{time=500, x=xpos,y=ypos,onComplete=
								function(target)
									if net.getSide() == "server" then
										Runtime:addEventListener("enterFrame", serverSend)
									elseif net.getSide() == "client" then
										Runtime:addEventListener("enterFrame", clientSend)
									end
									transition.to(target,{time=500,xScale=1, yScale=1,alpha=1, onComplete=
										function(target)
											event.other.gravityScale = 1
										end
									})
								end
							} )
						end
					} )
				 end
			end
		)
      end 

    
      hole[1].x=50; hole[1].y=178;hole[2].x=320; hole[2].y=90;hole[3].x=435; hole[3].y=90;hole[4].x=45; hole[4].y=395
      hole[5].x=160; hole[5].y=555;hole[6].x=30; hole[6].y=610;hole[7].x=478; hole[7].y=285;hole[8].x=370; hole[8].y=492
      hole[9].x=490; hole[9].y=560;hole[10].x=720; hole[10].y=178;hole[11].x=730; hole[11].y=390;hole[12].x=585; hole[12].y=547
      hole[13].x=720; hole[13].y=607;hole[14].x=535; hole[14].y=960
  
	ballList[myIndex] = makeBall(myIndex,"dynamic")
	ballList[myIndex]:setFillColor(150,150,200)	 
	ballList[3-myIndex] = makeBall(3-myIndex,"static")
	ballList[3-myIndex]:setFillColor(200,150,150)

	if net.getSide() == "server" then
            Runtime:addEventListener("collision", pre)
	end
	
      Runtime:addEventListener("accelerometer", onTilt )

      if net.getSide() == "server" then
            Runtime:addEventListener("enterFrame", serverSend)
      elseif net.getSide() == "client" then
            Runtime:addEventListener("enterFrame", clientSend)
      end

	local btn4 = widget.newButton{
		id = "btn004",
		left = display.contentWidth*.8-20,
		top = display.contentHeight*.9,
		label="Disconnect",
		style = "sheetYellow",
		fontSize=24,
		overColor= {50,150,100},
		strokeColor= {0,255,255,180},
		width = 150, height = 80,
		onEvent = function (event )
		if event.phase == "release" then
			net.closeNetwork()
			storyboard.gotoScene("menu","flipFadeOutIn")
		end end
	} 
  
	group:insert(btn4)

	--myGravButton = gravButton()
end

-- Called when scene have moved offscreen:
function scene:exitScene( event )
      local group = self.view
	  
      if net.getSide() == "server" then
            Runtime:removeEventListener("enterFrame", serverSend)
      elseif net.getSide() == "client" then
            Runtime:removeEventListener("enterFrame", clientSend)
      end

      Runtime:removeEventListener("accelerometer", onTilt )
	Runtime:removeEventListener("touch",pause)

	physics.stop()

	if physGroup then
            physGroup:removeSelf()
            physGroup = nil
	end

      for i = 1, net.getMaxPlayer() do
            if ballList[i] then
                  ballList[i]:removeSelf()
                  ballList[i] = nil
            end
	end

   
      if pauseGroup then
            pauseGroup:removeSelf()
            pauseGroup = nil
      end

      if endGroup then
            endGroup:removeSelf()
            endGroup = nil
      end

    --  myGravButton:removeSelf()
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
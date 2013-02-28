----------------------------------------------------------------------------------
--
-- netbridge.lua
--
----------------------------------------------------------------------------------
module(..., package.seeall)

local client,server
local clients = {}
local isReady = {nil}
local isLobby = false
local clientName = {}
local numPlayers = 0
local maxPlayers = 2
local gameMode = nil
local myIndex = nil
local side = nil

----------------------------------------------------------------------------------------------
-------------------------------------GENERAL NETWORK CODE-------------------------------------
----------------------------------------------------------------------------------------------

--starts the network for either client or server type
createNetwork = function(type)
      clients = {}
      isReady = {nl}
      clientName = {}
      clientName[1] = getPlayer()
      clients[1] = "host"
      numPlayers = 1
      myIndex = 1

      if type == "client" then
            side = "client"

            client = require("Client")
            client:start()
            client:scanServersInternet()

            Runtime:addEventListener("autolanReceived", clientReceived)
            Runtime:addEventListener("autolanConnectionFailed", connectionAttemptFailed)
            Runtime:addEventListener("autolanDisconnected", connectionAttemptFailed)
      elseif type == "server" then
            side = "server"

            server = require("Server")
            server:setCustomBroadcast(gameMode.." ("..numPlayers.."/"..maxPlayers..")")
            server:startInternet()

            Runtime:addEventListener("autolanPlayerDropped", playerDropped)
            Runtime:addEventListener("autolanPlayerJoined", addPlayer)
            Runtime:addEventListener("autolanReceived", serverReceived)
      end
end

--closes the current network type
closeNetwork = function()
      if side == "client" then
            client:disconnect()
            client:stop()

            Runtime:removeEventListener("autolanReceived", clientReceived)
            Runtime:removeEventListener("autolanConnectionFailed", connectionAttemptFailed)
            Runtime:removeEventListener("autolanDisconnected", connectionAttemptFailed)
      elseif side == "server" then
            server:disconnect()
            server:stop()

            Runtime:removeEventListener("autolanPlayerDropped", playerDropped)
            Runtime:removeEventListener("autolanPlayerJoined", addPlayer)
            Runtime:removeEventListener("autolanReceived", serverReceived)
      end
end

--sets what kind of game mode it should be and configs the network for it
setGameMode = function(mode)
      gameMode = mode
      if mode == "war" then
            maxPlayers = 2
      elseif mode == "ghost" then
            maxPlayers = 6
      end

      if side == "server" then
            server:setCustomBroadcast(gameMode.." ("..numPlayers.."/"..maxPlayers..")")
      end
end

getReadyState = function()
      return isReady
end

getGameMode = function()
      return gameMode
end

setLobby = function(data)
      isLobby = data
end

getLobby = function()
      return isLobby
end

getNumPlayers = function()
      return numPlayers
end

setMaxPlayer = function(data)
      maxPlayers = data
end

getMaxPlayer = function()
      return maxPlayers
end

getMyIndex = function()
      return myIndex
end

getSide = function()
      return side
end
----------------------------------------------------------------------------------------------
-------------------------------------SERVER SPECIFIC CODE-------------------------------------
----------------------------------------------------------------------------------------------
--event that adds player correctly when they join the server, and tells client about this update
addPlayer = function(event)
      print("Player joined")

      local client = event.client 
      local index = 1

      while(clients[index]) do
             index = index+1
      end

      clients[index] = client
      isReady[index] = false
      clientName[index] = "Player " .. numPlayers

      numPlayers = numPlayers+1

      if isLobby then
            if numPlayers <= maxPlayers then
                  updateHostLobby({numPlayers,isReady,clientName})

                  event.client:send({12,numPlayers})
                  sendPackageToAll({1,numPlayers,isReady,clientName})
                  server:setCustomBroadcast(gameMode.." ("..numPlayers.."/"..maxPlayers..")")
            else
                  print("No empty slots, dissconnecting client")
                  event.client:send({10})
            end
      else
            print("Game in progress, dissconnecting client")
            event.client:send({10})
      end
end

--event that adds player correctly when they disconnect from the server, and tells client about this update
playerDropped = function(event)
      print("Player dropped because", event.message)

      local clientId

      for i=1, numPlayers do
            if(clients[i] == event.client) then
                  table.remove(clients, i) --remove this client
                  table.remove(isReady, i) --remove readycheck from same client
                  table.remove(clientName, i) --remove name from same client
                  numPlayers = numPlayers - 1
                  clientId = i
            end 
      end

      if isLobby then
            updateHostLobby({numPlayers,isReady,clientName})
            sendPackageToAll({1,numPlayers,isReady,clientName})
      else
            if numPlayers == 1 then
                  closeNetwork()
                  storyboard.gotoScene("networkplay","flipFadeOutIn")
            end
            sendPackageToAll({11,clientId})
      end

      server:setCustomBroadcast(gameMode.." ("..numPlayers.."/"..maxPlayers..")")
end

--standard call to send information to all connected clients
sendPackageToAll = function(data)
      for k,v in ipairs(data) do
            print(k,v)
      end
	for i=2, numPlayers do
		clients[i]:send(data)
	end	
end

--event for reciving data from any client connected to the server
serverReceived =  function(event)
      local index = 1

      while(clients[index] ~= event.client) do
            index = index + 1
      end
      
      if event.message[1] == 3 then
            isReady[index] = event.message[2]
            updateHostLobby({numPlayers,isReady,clientName})
            sendPackageToAll({1,numPlayers,isReady,clientName})
      elseif event.message[1] == 4 then           
            clientName[index] = event.message[2]
            updateHostLobby({numPlayers,isReady,clientName})
            sendPackageToAll({1,numPlayers,isReady,clientName})
      end

      if gameMode == "ghost" then
            if event.message[1] == 5 then
                  recieveClientGravPackage({index,event.message[2],event.message[3],event.message[4],event.message[5]})
            elseif event.message[1] == 7 then
                  recieveDonePackage({index,event.message[2]})
            end
     elseif gameMode == "war" then
            if event.message[1] == 5 then
                  recieveWarClientGravPackage({index,event.message[2],event.message[3],event.message[4],event.message[5]})
            elseif event.message[1] == 7 then
                  recieveWarDonePackage({index,event.message[2]})
            elseif event.message[1] == 13 then
                  recieveWarMakeCollision({event.message[2],event.message[3]})
            elseif event.message[1] == 14 then
                  recieveWarEnd()
            end
     end
end

----------------------------------------------------------------------------------------------
-------------------------------------CLIENT SPECIFIC CODE-------------------------------------
----------------------------------------------------------------------------------------------
--function for connecting to a specific server
connectTo = function(ip)
      client:connect(ip)
      Runtime:addEventListener("autolanConnected", connectedToServer)
end

--event if connection would fail and you get dissconnected
connectionAttemptFailed = function(event)
      print("Connection Failed") 
      closeNetwork()
      storyboard.gotoScene("networkplay","flipFadeOutIn")
end 

--event when you have sended a connect request to server
connectedToServer = function(event)
	print("connected, waiting for sync")
      clientSend({4, getPlayer()})
      Runtime:removeEventListener("autolanConnected", connectedToServer)
end

--event for reciving data from the server
clientReceived = function (event)
      if event.message[1] == 1 then
            receiveLobbyPackage({event.message[2],event.message[3],event.message[4]})
            numPlayers = event.message[2]
      elseif event.message[1] == 2 then
            receiveStartPackage(event.message[2])
      elseif event.message[1] == 10 then
            closeNetwork("client")
            print("Lobby was full, you have been disconnected")
      elseif event.message[1] == 12 then
            myIndex = event.message[2]
      end

      if gameMode == "ghost" then
            if event.message[1] == 6 then
                  recieveServerGravPackage({event.message[2],event.message[3],event.message[4],event.message[5]})
            elseif event.message[1] == 8 then
                  local index = 1
                  while(event.message[2][index] ~= myIndex) do
                        index = index + 1
                  end
                  recieveRankPackage(index)
            elseif event.message[1] == 9 then
                  recieveBackToLobbyPackage()
            elseif event.message[1] == 11 then
                  recieveClientDcPackage(event.message[2])
            end
      elseif gameMode == "war" then
            if event.message[1] == 6 then
                  recieveWarServerGravPackage({event.message[2],event.message[3],event.message[4],event.message[5]})
            elseif event.message[1] == 9 then
                  recieveWarBackToLobbyPackage()
            elseif event.message[1] == 11 then
                  recieveWarClientDcPackage(event.message[2])
            elseif event.message[1] == 13 then
                  recieveWarMakeCollision({event.message[2],event.message[3]})
            elseif event.message[1] == 14 then
                  recieveWarEnd()
            end
      end
end

--function for sending data back to server
clientSend = function (data)
      client:send(data)
end

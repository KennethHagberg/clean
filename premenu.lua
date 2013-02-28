----------------------------------------------------------------------------------
--
-- premenu.lua
--
----------------------------------------------------------------------------------
local json = require "json"
local scene = storyboard.newScene()

local playerName = ""
local nameList = {}
local textField
local deletedRow = {}


--returns the name of the current player
function getPlayer()
      return playerName
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
        
	local bg=display.newImage(group,"image/bg_pattern.png")
      local welcome= display.newText(group,"Welcome, please enter",30,50,"Algerian",60)
      local welcome2= display.newText(group,"your name",210,130,"Algerian",60)
      local choose= display.newText(group,"Or choose one from the list",50,display.contentHeight*.5,"Algerian",46)
     

      --configs a button for getting along to the main menu
	local bord4 = widget.newButton{
		style = "sheetYellow",
		id = "btn004",
		left = display.contentWidth*.5-125,
		top = display.contentHeight*.3,
            label="OK",
            fontSize=52,
            cornerRadius = 10,
            width = 250, height = 150,
		onEvent = 
            function (event )
                  
                  if string.len(playerName) > 2 then
                        if not string.find(playerName, string.char(32)) then
      		            if event.phase == "release" then
                                    file = io.open(filePath, "w" )
                                    file:write(json.encode(nameList))
                                    io.close( file )

      	                        storyboard.gotoScene("menu","flipFadeOutIn")
      	                  end
                        else
                              if event.phase == "release" then
                                    local alert = native.showAlert( "ERROR CODE:0005681", "Space is not allowed", { "OK" } )
                              end
                        end
                  else
                        if event.phase == "release" then
                              local alert = native.showAlert( "Please enter a longer name", "at least 3 signs", { "OK" } )
                        end
                  end
            end
	}

      group:insert(bord4)

      --function for reloading the names from file, that should exist in list
      local function loadListNames()
            filePath = system.pathForFile("name.txt",system.DocumentsDirectory)

            local file = io.open(filePath, "r" )

            if file then
                  nameList = json.decode(file:read( "*a" ))
            else
                  nameList[1] = "default"
                  file = io.open(filePath, "w" )
                  file:write('["default"]')
            end

            io.close( file )
      end

      

      -- handles individual row rendering
      local function onRowRender( event )
            local row = event.row
            local rowGroup = event.view
            local label = nameList[event.index]
            local color = 0
            local index = 0

            row.textObj = display.newRetinaText( rowGroup,label, 0, 0, "Algerian", 32 )
            --row.textObj:setTextColor(color)
            row.textObj:setReferencePoint( display.CenterLeftReferencePoint )
            row.textObj.x, row.textObj.y = 20, rowGroup.contentHeight * 0.5

            row.imageObj = display.newImage( rowGroup,"image/cross.png", 0, 0 )
            row.imageObj:setReferencePoint( display.CenterLeftReferencePoint )
            row.imageObj.x, row.imageObj.y = -50, rowGroup.contentHeight*0.06
            row.imageObj.width = 50
            row.imageObj.height = 50

            row.imageObj:addEventListener( "tap",
                  function( event )
                        for i=1,#nameList do
                              if nameList[i] == row.textObj.text then
                                    if #nameList > 1 then
                                          table.remove(nameList,i)
                                          file = io.open(filePath, "w" )
                                          file:write(json.encode(nameList))
                                          io.close( file )
                                          list:deleteRow( row )
                                          loadListNames()
                                          nameListCount = #nameList + 1
                                    else
                                          local alert = native.showAlert( "atleast one playername is required","", { "OK" } )
                                    end
                              end
                        end		
                  end
            )
	end
	
      --listener for events on rows in list
      local function rowListener( event )
            local row = event.row
            local background = event.background
            
            if event.phase == "press" then
                  background:setFillColor( 170, 170, 170, 255 )

                  if row.textObj then
                        row.textObj:setReferencePoint( display.TopLeftReferencePoint )
                        row.textObj.x = 20
                  end

            elseif event.phase == "release" or event.phase == "tap" then

                  row.reRender = true
                  playerName=row.textObj.text

                  storyboard.gotoScene("menu","flipFadeOutIn")
            end
	end
	
      --create the list
      list = widget.newTableView{
            hideBackground = true,
            noLines = true,
            top = 570,
            left = display.contentWidth - (display.contentWidth - 250),
            height = 400,
            width = display.contentWidth - 500,
            maxVelocity=2,
            maskFile = "image/mask-568x400.png"
	}

      loadListNames()
      nameListCount = #nameList + 1

	--insert rows into list (tableView widget)
	for i=1,#nameList do
		local rowColor= {200,140,50,0.01}
		local rowHeight = 100
		local listener = rowListener

		list:insertRow{
			height = rowHeight,
			rowColor = rowColor,
			onRender = onRowRender,
			listener = listener
		}
	end

      group:insert(list)
     
	--display.newRect(group,170,210,420,80)
    
end

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
      local group = self.view
	
    

	function textListener( event )
            print(event.phase)

		if event.phase == "editing" then
                  playerName = event.text
                  nameList[nameListCount] = event.text
            end     

            if event.phase == "submitted" then
                  native.setKeyboardFocus( nil )
           end
	end

	textField = native.newTextField( 170, 210, 420, 80 )
	textField.size=46
	--textField.userInput = textListener
	textField:addEventListener( "userInput", textListener )
      
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	textField:removeSelf()
	textField:removeEventListener( "userInput", textField )
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


----------------------------------------------------------------------------------
--
-- drawlobby.lua
--
----------------------------------------------------------------------------------
--module with a function for drawing text and icons for clietns connected to the lobby
return function(x,isReady,clientName)

local group = display.newGroup()

for i = 1, x do
      display.newText(group, clientName[i],200,100*i,"Algerian",32)

	if i == 1 then
		local crown = display.newImage("image/crown.png",100,100)
        crown.x = 125
        crown.y = 125
        crown.width = 50
        crown.height = 50
        group:insert(crown)
    else
        if isReady[i] then
			local green = display.newImage("image/ready.png",100,100)
            green.x = 125
            green.y = 125+(100*(i-1))
            green.width = 50
            green.height = 50
            group:insert(green)
        else
            local red = display.newImage("image/cross.png",100,100)
            red.x = 125
            red.y = 125+(100*(i-1))
            red.width = 50
            red.height = 50
            group:insert(red)
        end
    end
end
 
return group

end

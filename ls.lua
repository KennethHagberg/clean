----------------------------------------------------------------------------------
--
-- ls.lua
--
----------------------------------------------------------------------------------
module(..., package.seeall)

local str = require "str"
local c = 6

-----------------------------------
-- Function to save data to file --
-----------------------------------
saveData = function(data, filePath, check)
      file = io.open(filePath, "w" )

	for i = 1, c do
		file:write( data[1][i] .. "=" .. data[2][i] .. "~" .. data[3][i] .. ",")
	end

	io.close( file )

      return data
end

-------------------------------------
-- Function to load data from file --
-------------------------------------
loadData = function(filePath)
      local file = io.open(filePath, "r" )
      local data = {{},{},{}}

      if file then

            local dataStr = file:read( "*a" )

            local datavars = str.split(dataStr, ",")

            for i = 1, #datavars do
                  local onevalue = str.split(datavars[i], "=")
                  data[1][i] = onevalue[1]
                  onevalue = str.split(onevalue[2], "~")
                  data[2][i] = onevalue[1]
                  data[3][i] = onevalue[2]
            end

            io.close( file )

            for i = 1, c do
                  data[3][i] = tonumber(data[3][i])
            end

      else
            print ("No file found")
            print ("Creating new data file")

            for i = 1, c do
                  data[1][i] = "Empty"
                  data[2][i] = "-"
                  data[3][i] = 99999              
            end

            saveData(data, filePath)
      end

      return data
end

--------------------------------------
-- Function to sort data into table --
--------------------------------------
function sortData(data, newData, filePath)
      local c = #data[3]
      if newData.value < data[3][c] then
            data[1][c] = newData.name
            data[2][c] = newData.time
            data[3][c] = newData.value

            local tempData = {{},{},{}}

            for i = 0, c-2 do
                  if data[3][c-i] < data[3][c-1-i] then
                        tempData[1][1] = data[1][(c-1)-i]
                        tempData[2][1] = data[2][(c-1)-i]
                        tempData[3][1] = data[3][(c-1)-i]
                        data[1][(c-1)-i] = data[1][c-i]
                        data[2][(c-1)-i] = data[2][c-i]
                        data[3][(c-1)-i] = data[3][c-i]
                        data[1][c-i] = tempData[1][1]
                        data[2][c-i] = tempData[2][1]
                        data[3][c-i] = tempData[3][1]
                  end
            end
      end

      return data
end

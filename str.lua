-- str.lua (adds string "split" function, similar to explode() in PHP)
--
-- See more useful Lua snippets at http://lua-users.org/wiki/

--Ej gjord av Anton Bohman
--En function som �r tillagd f�r att kunna splitta p� strings till flera strings
--Anv�nds endast n�r data ska laddas fr�n en fil

module(..., package.seeall)

split = function(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t,cap)
   end
   return t  
end
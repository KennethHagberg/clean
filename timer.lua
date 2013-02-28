----------------------------------------------------------------------------------
--
-- timer.lua
--
----------------------------------------------------------------------------------
module(..., package.seeall)

local timerMin = 0
local timerSec = 0
local timerDir = "up"
local cd
local cdStarted = false
local cdPaused = false

--for setting the time
timerSet = function(m,s,set)
	timerMin = m
	timerSec = s
      timerDir = set
end

--starts the timer with a countdown towards 00:00
timerStart = function()
      if cdStarted == false then
            if timerDir == "down" then
                  cd = timer.performWithDelay(1000,timerCountDown,60*timerMin+timerSec)
            elseif timerDir == "up" then
                  cd = timer.performWithDelay(1000,timerCountUp,-1)
            end
            cdStarted = true
      end
end

--stops the timer temporarly
timerPause = function()
    
	if cdPaused then
            timer.resume(cd)
            cdPaused = false
      else
            timer.pause(cd)
            cdPaused = true
      end
      print(cdPaused)
end

--decreases the timer with one sec
timerCountDown = function()
	if timerSec == 0 then
		if timerMin ~= 0 then
			timerMin = timerMin - 1
			timerSec = 59
		end
	else
		timerSec = timerSec - 1
	end
end

--decreases the timer with one sec
timerCountUp = function()
	if timerSec == 59 then
		timerSec = 0
            timerMin = timerMin + 1
	else
		timerSec = timerSec + 1
	end
end

--returns a string with the current time left
timerGet = function()
	if timerMin < 10 then
		if timerSec < 10 then
			return ("0" .. timerMin .. ":" .. "0" .. timerSec)
		else
			return ("0" .. timerMin .. ":" .. timerSec)
		end
	else
		if timerSec < 10 then
			return (timerMin .. ":" .. "0" .. timerSec)
		else
			return (timerMin .. ":" .. timerSec)
		end
	end
end

--returns an int with current time in sec
timerGetTot = function()
    return (timerSec + (timerMin * 60))
end

--clears timer object and related items
timerClear = function()
      if cdStarted == true then
            timer.cancel( cd )
           cdStarted = false
      end
	timerMin = 0
      timerSec = 0
      timerDir = "up"
        cdPaused = false
end

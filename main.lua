-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
storyboard = require "storyboard"
--gravButton = require "gravbutton"
physics = require "physics"
myTimer = require "timer" 
widget = require "widget"
net = require "netbridge" 
ads = require "ads"
ls = require "ls"


widget.setTheme( "theme_ios" )

display.setStatusBar( display.HiddenStatusBar )
system.setIdleTimer( false ) -- makes the screen not go in sleep mode
display.setDefault("textColor",0,0,0,200)


-- appId -- is your unique app Id you'll get from the network's website for use with your app.
-- testmode -- set this to true if you are still developing your app. set it to false for distribution.

--ads.init( "inneractive", "apid" )
ads.init( "inmobi", "apid" )

-- load premenu.lua
storyboard.gotoScene( "premenu" )

-- Add any objects that should appear on all scenes below (e.g. tab bar, hud, etc.):
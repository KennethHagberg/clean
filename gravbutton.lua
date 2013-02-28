module(..., package.seeall)

return function()
      local group = display.newGroup()
      
      top=display.newRect(group,display.contentWidth*.4,20,100,50)
      top:setFillColor(204, 204, 255, 255,150)
      top:addEventListener("touch",
      function(event)
          if event.phase=="began" then
              onTilt({xGravity=0,yGravity=0.5})
              --physics.setGravity(0,-10)
          end
      end)

      Left=display.newRect(group,20,display.contentHeight*.4,50,100)
      Left:setFillColor(204, 204, 255, 255,150)
      Left:addEventListener("touch",
      function(event)
          if event.phase== "began" then
              onTilt({xGravity=-0.5,yGravity=0})
              --physics.setGravity(-10,0)
          end
      end)


      rigth=display.newRect(group,display.contentWidth-20,display.contentHeight*.4,50,100)
      rigth:setFillColor(204, 204, 255, 255,150)
      rigth:addEventListener("touch",
      function(event)
          if event.phase== "began" then
              onTilt({xGravity=0.5,yGravity=0})
              --physics.setGravity(10,0)
          end
      end)   

      bottom=display.newRect(group,display.contentWidth*.4,display.contentHeight-50,100,50)
      bottom:setFillColor(204, 204, 255, 255,150)
      bottom:addEventListener("touch",
      function(event)
          if event.phase== "began" then
             onTilt({xGravity=0,yGravity=-0.5})
              --physics.setGravity(0,10)
          end
      end)
      
      return group
end


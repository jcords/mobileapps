local composer = require( "composer" )
local scene = composer.newScene()
local parent -- parent scene
-- Require the JSON library for decoding purposes
local json = require( "json" )
local particleDesigner = require( "particleDesigner" )

-- "scene:create()"
function scene:create( event )
   local localGroup = self.view
   local _W = display.contentWidth
   local _H = display.contentHeight
   local mRand = math.random
   local timerAnim = nil
   local starflag = true
   local starctr = 0
   local whichStar = nil
   local starpos = 0
   local currank = 0
   local allowed = false
   local ribbon = nil
   local mythicgem = nil
   local dustemitter = nil
   local gamemode
   local matchresult
   --> Reward value should also be passed as a parameter
   local rewardval = 0
   local star1 = nil
   local star2 = nil
   local star3 = nil
   local star4 = nil
   local star5 = nil
   local realstar1 = nil
   local realstar2 = nil
   local realstar3 = nil
   local realstar4 = nil
   local realstar5 = nil

   rewardval = event.params.tokens
   gamemode = event.params.mode
   matchresult = event.params.win

   local function closeDialog( event )
      if ( event.phase == "began" ) then
      elseif ( event.phase == "moved" ) then
      elseif ( event.phase == "ended" ) then
         if ( allowed ) then
            print( "allowed!" )
            if ( dustemitter ~= nil ) then
               --> Stop fairy dust emitter
               dustemitter:stop()
            end
            
            parent:leaveRoom() -- call parent function to leave room
            
             --she-- begin
            parent:stopGame()
            parent:unsubscribeRoom(roomid)
            parent:leaveRoom()
            parent:disconnect()

            --> Hide banner ads
            parent:hideBannerAd()
            
            --clear versus scene
            composer.removeScene( "game" )
            
            --go back to title scene
            composer.gotoScene( "title" )
            --she-- end
         end
      end
   end

   local background = display.newRect( 0, 0, _W, _H )
   _G.anchor.Center( background )
   background.x = _W * 0.5
   background.y = _H * 0.5
   background:setFillColor( 0/255, 0/255, 0/255, 128/255 )
   localGroup:insert( background )
   background:addEventListener( "touch", closeDialog )

   --> badge bg
   local bg = newImageRectNoDimensions( "art/res_bg.png" )
   bg.x, bg.y = _W * 0.5, _H * 0.5
   localGroup:insert( bg )

   --> badge ribbon
   if matchresult then
      ribbon = newImageRectNoDimensions( "art/res_ribbon_win.png" )
   else
      ribbon = newImageRectNoDimensions( "art/res_ribbon_lose.png" )
   end
   ribbon.x = _W * 0.5
   ribbon.y = bg.y + 90
   localGroup:insert( ribbon )

   if ( gamemode == 3 ) then
      --> If player loses, deduct stars ASAP
      if not matchresult then
         if ( _G.player.numstars < 125 ) then
            _G.player.numstars = _G.player.numstars - 1
         end
      end

      --> Compute for num stars
      starpos = 0
      if ( _G.player.numstars > 4 ) then
         starpos = math.fmod( _G.player.numstars, 5 )
      else
         starpos = _G.player.numstars
      end

      --> Compute for player's current rank
      currank = 25 - ( math.modf( _G.player.numstars / 5 ) )

      --> actual stars
      realstar1 = newImageRectNoDimensions( "art/res_star.png" )
      realstar1.x = ( _W * 0.5 ) - 80
      realstar1.y = bg.y - 64
      localGroup:insert( realstar1 )
      if ( starpos > 0 ) then
         realstar1.isVisible = true
      else
         realstar1.isVisible = false
      end

      realstar2 = newImageRectNoDimensions( "art/res_star.png" )
      realstar2.x = ( _W * 0.5 ) - 43
      realstar2.y = bg.y - 89
      localGroup:insert( realstar2 )
      if ( starpos > 1 ) then
         realstar2.isVisible = true
      else
         realstar2.isVisible = false
      end

      realstar3 = newImageRectNoDimensions( "art/res_star.png" )
      realstar3.x = _W * 0.5
      realstar3.y = bg.y - 100
      localGroup:insert( realstar3 )
      if ( starpos > 2 ) then
         realstar3.isVisible = true
      else
         realstar3.isVisible = false
      end

      realstar4 = newImageRectNoDimensions( "art/res_star.png" )
      realstar4.x = ( _W * 0.5 ) + 43
      realstar4.y = bg.y - 89
      localGroup:insert( realstar4 )
      if ( starpos > 3 ) then
         realstar4.isVisible = true
      else
         realstar4.isVisible = false
      end

      realstar5 = newImageRectNoDimensions( "art/res_star.png" )
      realstar5.x = ( _W * 0.5 ) + 80
      realstar5.y = bg.y - 64
      localGroup:insert( realstar5 )
      if ( starpos > 4 ) then
         realstar5.isVisible = true
      else
         realstar5.isVisible = false
      end

      --> empty stars
      star1 = newImageRectNoDimensions( "art/res_star_empty.png" )
      star1.x = ( _W * 0.5 ) - 80
      star1.y = bg.y - 64
      localGroup:insert( star1 )
      if ( starpos > 0 ) then
         star1.isVisible = false
      else
         star1.isVisible = true
      end

      star2 = newImageRectNoDimensions( "art/res_star_empty.png" )
      star2.x = ( _W * 0.5 ) - 43
      star2.y = bg.y - 89
      localGroup:insert( star2 )
      if ( starpos > 1 ) then
         star2.isVisible = false
      else
         star2.isVisible = true
      end

      star3 = newImageRectNoDimensions( "art/res_star_empty.png" )
      star3.x = _W * 0.5
      star3.y = bg.y - 100
      localGroup:insert( star3 )
      if ( starpos > 2 ) then
         star3.isVisible = false
      else
         star3.isVisible = true
      end

      star4 = newImageRectNoDimensions( "art/res_star_empty.png" )
      star4.x = ( _W * 0.5 ) + 43
      star4.y = bg.y - 89
      localGroup:insert( star4 )
      if ( starpos > 3 ) then
         star4.isVisible = false
      else
         star4.isVisible = true
      end

      star5 = newImageRectNoDimensions( "art/res_star_empty.png" )
      star5.x = ( _W * 0.5 ) + 80
      star5.y = bg.y - 64
      localGroup:insert( star5 )
      if ( starpos > 4 ) then
         star5.isVisible = false
      else
         star5.isVisible = true
      end

      --> If game lost, hide empty star
      if not matchresult then
         if ( _G.player.numstars > -1 ) then
            if ( starpos == 0 ) then
               realstar1.isVisible = true
               localGroup:insert( realstar1 )
            elseif ( starpos == 1 ) then
               realstar2.isVisible = true
               localGroup:insert( realstar2 )
            elseif ( starpos == 2 ) then
               realstar3.isVisible = true
               localGroup:insert( realstar3 )
            elseif ( starpos == 3 ) then
               realstar4.isVisible = true
               localGroup:insert( realstar4 )
            elseif ( starpos == 4 ) then
               realstar5.isVisible = true
               localGroup:insert( realstar5 )
            end
         end
      end

      --> Rank
      local rank = newImageRectNoDimensions( "art/rank" .. currank .. "_big.png" )
      rank.x = bg.x
      rank.y = bg.y
      localGroup:insert( rank )

      if ( _G.player.numstars == 125 ) then
         display.remove( ribbon )
         ribbon = nil
         ribbon = newImageRectNoDimensions( "art/res_ribbon_mythic.png" )
         ribbon.x = _W * 0.5
         ribbon.y = bg.y + 90
         localGroup:insert( ribbon )
         realstar1.isVisible = true
         localGroup:insert( realstar1 )
         realstar2.isVisible = true
         localGroup:insert( realstar2 )
         realstar3.isVisible = true
         localGroup:insert( realstar3 )
         realstar4.isVisible = true
         localGroup:insert( realstar4 )
         realstar5.isVisible = true
         localGroup:insert( realstar5 )
      end
   end

   local function bounceEffect2()
      transition.to( mythicgem, { time = 100, xScale = 1.0, yScale = 1.0 } )
      allowed = true
   end

   local function bounceEffect1()
      transition.to( mythicgem, { time = 100, xScale = 1.1, yScale = 1.1, onComplete = bounceEffect2 } )
   end

   local function endAnim()
      timer.cancel( timerAnim )
      timerAnim = nil
      if matchresult then
         --> Increment player's stars
         if ( _G.player.numstars < 125 ) then
            _G.player.numstars = _G.player.numstars + 1
         end
      end
      _G.player.rank = currank
      --> Save data here!
      settings.set( 'player.rank', _G.player.rank )
      settings.set( 'player.numstars', _G.player.numstars )
      settings.set( 'player.totalmoney', _G.player.totalmoney )
      if ( _G.player.numstars == 125 ) then
         --> Particles!
         dustemitter = particleDesigner.newEmitter( "fairydust.json" )
         dustemitter.x = _W * 0.5
         dustemitter.y = _H
         localGroup:insert( dustemitter )
         --> Show Mythic elements!
         mythicgem = newImageRectNoDimensions( "art/rank0_big.png" )
         mythicgem.xScale = 6.0
         mythicgem.yScale = 6.0
         mythicgem.x = _W * 0.5
         mythicgem.y = _H * 0.5
         mythicgem.alpha = 0
         localGroup:insert( mythicgem )
         transition.to( mythicgem, { time = 700, rotation = 360, alpha = 1.0, xScale = 1.0, yScale = 1.0, x = bg.x, y = bg.y, onComplete = bounceEffect1 } )
         display.remove( ribbon )
         ribbon = nil
         ribbon = newImageRectNoDimensions( "art/res_ribbon_mythic.png" )
         ribbon.xScale = 4.0
         ribbon.yScale = 4.0
         ribbon.x = _W * 0.5
         ribbon.y = _H * 0.5
         ribbon.alpha = 0
         localGroup:insert( ribbon )
         transition.to( ribbon, { time = 700, alpha = 1.0, xScale = 1.0, yScale = 1.0, x = _W * 0.5, y = bg.y + 90 } )
      else
         allowed = true
      end
   end

   local function floatStar()
      if ( starpos == 0 ) then
         realstar1.isVisible = true
      elseif ( starpos == 1 ) then
         realstar2.isVisible = true
      elseif ( starpos == 2 ) then
         realstar3.isVisible = true
      elseif ( starpos == 3 ) then
         realstar4.isVisible = true
      elseif ( starpos == 4 ) then
         realstar5.isVisible = true
      end
      --> Reward coins accordingly
      if ( rewardval > 0 ) then
         if ( _G.sfx == 1 ) then
            audio.play ( sounds.sfx_chain )
         end
         local tokens 
         if ( rewardval == 10 ) then
            tokens = newImageRectNoDimensions( "art/tokens_10.png" )
         elseif ( rewardval == 20 ) then
            tokens = newImageRectNoDimensions( "art/tokens_20.png" )
         elseif ( rewardval == 30 ) then
            tokens = newImageRectNoDimensions( "art/tokens_30.png" )
         elseif ( rewardval == 50 ) then
            tokens = newImageRectNoDimensions( "art/tokens_50.png" )
         elseif ( rewardval == 100 ) then
            tokens = newImageRectNoDimensions( "art/tokens_100.png" )
         end
         --> Add to player's total money
         _G.player.totalmoney = _G.player.totalmoney + rewardval
         settings.set( 'player.totalmoney', _G.player.totalmoney )
         tokens.x = _W * 0.5
         tokens.y = ( _H * 0.5 ) + _H
         localGroup:insert( tokens )
         transition.to( tokens, { time = 300, y = ( _H * 0.5 ) + 160 } )
      end
      --> Complete animation
      transition.to( whichStar, { time = 200, alpha = 0, onComplete = endAnim } )
   end

   local function stillgetTokens()
      --> Reward coins accordingly
      if ( rewardval > 0 ) then
         if ( _G.sfx == 1 ) then
            audio.play ( sounds.sfx_chain )
         end
         local tokens 
         if ( rewardval == 10 ) then
            tokens = newImageRectNoDimensions( "art/tokens_10.png" )
         elseif ( rewardval == 20 ) then
            tokens = newImageRectNoDimensions( "art/tokens_20.png" )
         elseif ( rewardval == 30 ) then
            tokens = newImageRectNoDimensions( "art/tokens_30.png" )
         elseif ( rewardval == 50 ) then
            tokens = newImageRectNoDimensions( "art/tokens_50.png" )
         elseif ( rewardval == 100 ) then
            tokens = newImageRectNoDimensions( "art/tokens_100.png" )
         end
         --> Add to player's total money
         _G.player.totalmoney = _G.player.totalmoney + rewardval
         settings.set( 'player.totalmoney', _G.player.totalmoney )
         tokens.x = _W * 0.5
         tokens.y = ( _H * 0.5 ) + _H
         localGroup:insert( tokens )
         transition.to( tokens, { time = 300, y = ( _H * 0.5 ) + 160 } )
         allowed = true
      end
   end

   local function addStar()
      starctr = starctr + 1
      if ( starctr < 10 ) then
         if ( starflag ) then
            whichStar.fill.effect = "filter.brightness"
            whichStar.fill.effect.intensity = 0.9
            starflag = not starflag
         else
            whichStar.fill.effect = "filter.brightness"
            whichStar.fill.effect.intensity = 0
            starflag = not starflag
         end
      else
         timer.cancel( timerAnim )
         timerAnim = nil
         timerAnim = timer.performWithDelay( 50, floatStar, 1 )
      end
   end

   local function startAnim()
      starctr = 0
      if matchresult then
         if ( starpos == 0 ) then
            whichStar = star1
         elseif ( starpos == 1 ) then
            whichStar = star2
         elseif ( starpos == 2 ) then
            whichStar = star3
         elseif ( starpos == 3 ) then
            whichStar = star4
         elseif ( starpos == 4 ) then
            whichStar = star5
         end
      else
         if ( starpos == 0 ) then
            whichStar = realstar1
         elseif ( starpos == 1 ) then
            whichStar = realstar2
         elseif ( starpos == 2 ) then
            whichStar = realstar3
         elseif ( starpos == 3 ) then
            whichStar = realstar4
         elseif ( starpos == 4 ) then
            whichStar = realstar5
         end
      end
      timerAnim = timer.performWithDelay( 50, addStar, 0 )
      --> Particles!
      local emitter = particleDesigner.newEmitter( "flame.json" )
      emitter.x = whichStar.x
      emitter.y = whichStar.y
      localGroup:insert( emitter )
   end

   local function addDelay()
      allowed = true
   end

   if ( gamemode == 3 ) then
      --> Start animation!
      if ( _G.player.numstars > -1 and _G.player.numstars < 125 ) then
         timer.performWithDelay( 1000, startAnim, 1 )
      else
         --> Event at 0 stars, if Cheng wins, he gets 10 tokens!
         timer.performWithDelay( 1000, stillgetTokens, 1 )
      end
      --> Reset numstars to 0 if value is -1
      if ( _G.player.numstars == -1 ) then
         _G.player.numstars = 0
         _G.player.rank = currank
      end
   else
      timer.performWithDelay( 1000, addDelay, 1 )
   end
end

-- "scene:show()"
function scene:show( event )
   local localGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

      parent = event.parent -- get this overlay's parent scene
   end
end

-- "scene:hide()"
function scene:hide( event )
   local localGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
end

-- "scene:destroy()"
function scene:destroy( event )
   local localGroup = self.view

   -- Called prior to the removal of scene's view ("sceneGroup").
   -- Insert code here to clean up the scene.
   -- Example: remove display objects, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
local composer = require( "composer" )
local scene = composer.newScene()
local bgmask = nil

-- Require the JSON library for decoding purposes
local json = require( "json" )

local particleDesigner = require( "particleDesigner" )

-- "scene:create()"
function scene:create( event )
   	local localGroup = self.view
	local _W = display.contentWidth
	local _H = display.contentHeight
	local wheel_y = 0
	local panel_mode = 0
	local howfast = 200
	local wheel = nil
	local buttonplay = nil
	local buttonshop = nil
	local buttoncards = nil
	local buttonstats = nil
	local buttonmisc = nil
	local buttonpractice = nil
	local buttonfriend = nil
	local buttonranked = nil
	local wlogo = nil
	local dustemitter = nil

	local function hideMainPanel()
		transition.to( wheel, { time = howfast, y = _H - ( wheel.contentHeight * 0.5 ) + 200 } )
		transition.to( buttonplay, { time = howfast, y = wheel_y - 20 + 200 } )
		transition.to( buttonshop, { time = howfast, y = wheel_y - 10 + 200 } )
		transition.to( buttonstats, { time = howfast, y = wheel_y - 10 + 200 } )
		transition.to( buttoncards, { time = howfast, y = wheel_y + 200 } )
		transition.to( buttonmisc, { time = howfast, y = wheel_y + 200 } )
	end

	local function showMainPanel()
		panel_mode = 1
		transition.to( wheel, { time = howfast, y = _H - ( wheel.contentHeight * 0.5 ) } )
		transition.to( buttonplay, { time = howfast, y = wheel_y - 20 } )
		transition.to( buttonshop, { time = howfast, y = wheel_y - 10 } )
		transition.to( buttonstats, { time = howfast, y = wheel_y - 10 } )
		transition.to( buttoncards, { time = howfast, y = wheel_y } )
		transition.to( buttonmisc, { time = howfast, y = wheel_y } )
	end

	local function hidePlayPanel()
		transition.to( wheel, { time = howfast, y = _H - ( wheel.contentHeight * 0.5 ) + 200 } )
		transition.to( buttonfriend, { time = howfast, y = wheel_y - 20 + 200 } )
		transition.to( buttonpractice, { time = howfast, y = wheel_y - 10 + 200 } )
		transition.to( buttonranked, { time = howfast, y = wheel_y - 10 + 200 } )
	end

	local function showPlayPanel()
		panel_mode = 2
		transition.to( wheel, { time = howfast, y = _H - ( wheel.contentHeight * 0.5 ) } )
		transition.to( buttonfriend, { time = howfast, y = wheel_y - 20 } )
		transition.to( buttonpractice, { time = howfast, y = wheel_y - 10 } )
		transition.to( buttonranked, { time = howfast, y = wheel_y - 10 } )
	end

	local function handleTouch( event )
		if ( event.phase == "began" ) then
		elseif ( event.phase == "moved" ) then
		elseif ( event.phase == "ended" ) then
			if ( panel_mode == 2 ) then
				hidePlayPanel()
				timer.performWithDelay( 500, showMainPanel, 1 )
			end
		end
	end

	local function gotoPlayPanel( event )
		if ( event.phase == "began" ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_tap )
			end
			event.target.xScale = 1.10
			event.target.yScale = 1.10
		elseif ( event.phase == "moved" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
		elseif ( event.phase == "ended" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
			hideMainPanel()
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_slide )
			end
			timer.performWithDelay( 500, showPlayPanel, 1 )
		end
	end

	local function startGame( event )
		if ( event.phase == "began" ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_tap )
			end
			event.target.xScale = 1.10
			event.target.yScale = 1.10
		elseif ( event.phase == "moved" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
		elseif ( event.phase == "ended" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
			local flag = true
			if ( event.target.mode == 2 or event.target.mode == 3 ) then
				if ( not _G.isOnline ) then
					flag = false
				end
			end
			if ( flag ) then
				_G.goback = false
				--> Switch to next scene
				local options = {
				    effect = "fromRight",
				    time = 300,
				    params = {
				        playermode = event.target.mode
				    }
				}
				composer.gotoScene( "choose_class", options )
			end
		end
	end

	local function showCollection( event )
		if ( event.phase == "began" ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_tap )
			end
			event.target.xScale = 1.10
			event.target.yScale = 1.10
		elseif ( event.phase == "moved" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
		elseif ( event.phase == "ended" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
			--> Switch to next scene
			local options = {
			    effect = "fromRight",
			    time = 300,
			    params = {
			    	playerclass = 1
				}
			}
			composer.gotoScene( "collection", options )
		end
	end

	local function showStats( event )
		if ( event.phase == "began" ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_tap )
			end
			event.target.xScale = 1.10
			event.target.yScale = 1.10
		elseif ( event.phase == "moved" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
		elseif ( event.phase == "ended" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
			--> Switch to next scene
			local options = {
			    effect = "fromRight",
			    time = 300
			}
			composer.gotoScene( "stats", options )
		end
	end

	local function  goMisc( event )
		if ( event.phase == "began" ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_tap )
			end
			event.target.xScale = 1.10
			event.target.yScale = 1.10
		elseif ( event.phase == "moved" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
		elseif ( event.phase == "ended" ) then
			event.target.xScale = 1.0
			event.target.yScale = 1.0
			bgmask = display.newRect( 0, 0, _W, _H )
			_G.anchor.Center( bgmask )
			bgmask.x = _W * 0.5
			bgmask.y = _H * 0.5
			bgmask:setFillColor( 0/255, 0/255, 0/255, 128/255 )
			localGroup:insert( bgmask )
			local options = {
				isModal = true,
				effect = "fromBottom",
				time = 300,
				params = {
					win = true
				}
			}
			composer.showOverlay( "rewards", options )
		end
	end

	local background = newImageRectNoDimensions( "art/bg_choosecards.png" )
	background.x = _W * 0.5
	background.y = _H * 0.5
	localGroup:insert( background )
	background:addEventListener( "touch", handleTouch )

	wlogo = newImageRectNoDimensions( "art/title_logo.png" )
	wlogo.x = _W * 0.5
	wlogo.y = 100
	localGroup:insert( wlogo )

	--> Particles!
	dustemitter = particleDesigner.newEmitter( "dust.json" )
	dustemitter.x = _W * 0.5
	dustemitter.y = _H
	localGroup:insert( dustemitter )

	wheel = newImageRectNoDimensions( "art/bottomwheel.png" )
	wheel.x = _W * 0.5
	wheel_y = _H - ( wheel.contentHeight * 0.5 )
	wheel.y = _H - ( wheel.contentHeight * 0.5 ) + 200
	localGroup:insert( wheel )

	buttonplay = widget.newButton
	{
	    defaultFile = "art/button_play.png",
	    overFile = "art/button_play.png",
	    width = 70,
	    height = 66,
	    onEvent = gotoPlayPanel
	}
	buttonplay.x = wheel.x
	buttonplay.y = wheel.y - 20 + 200
	localGroup:insert( buttonplay )

	buttonshop = widget.newButton
	{
	    defaultFile = "art/button_shop.png",
	    overFile = "art/button_shop.png",
	    width = 40,
	    height = 40
--	    onEvent = startGame
	}
	buttonshop.x = wheel.x - 54
	buttonshop.y = wheel.y - 10 + 200
	localGroup:insert( buttonshop )

	buttoncards = widget.newButton
	{
	    defaultFile = "art/button_cards.png",
	    overFile = "art/button_cards.png",
	    width = 40,
	    height = 40,
	    onEvent = showCollection
	}
	buttoncards.x = wheel.x - 94
	buttoncards.y = wheel.y + 200
	localGroup:insert( buttoncards )

	buttonstats = widget.newButton
	{
	    defaultFile = "art/button_stats.png",
	    overFile = "art/button_stats.png",
	    width = 40,
	    height = 40,
	    onEvent = showStats
	}
	buttonstats.x = wheel.x + 54
	buttonstats.y = wheel.y - 10 + 200
	localGroup:insert( buttonstats )

	buttonmisc = widget.newButton
	{
	    defaultFile = "art/button_misc.png",
	    overFile = "art/button_misc.png",
	    width = 40,
	    height = 40,
	    onEvent = goMisc
	}
	buttonmisc.x = wheel.x + 94
	buttonmisc.y = wheel.y + 200
	localGroup:insert( buttonmisc )

	buttonfriend = widget.newButton
	{
	    defaultFile = "art/button_friend.png",
	    overFile = "art/button_friend.png",
	    width = 48,
	    height = 50,
	    onEvent = startGame
	}
	buttonfriend.mode = 2
	buttonfriend.x = wheel.x
	buttonfriend.y = wheel.y - 20 + 200
	localGroup:insert( buttonfriend )
	if ( not _G.isOnline ) then
		buttonfriend.alpha = 0.3
	end

	buttonpractice = widget.newButton
	{
	    defaultFile = "art/button_practice.png",
	    overFile = "art/button_practice.png",
	    width = 48,
	    height = 50,
	    onEvent = startGame
	}
	buttonpractice.mode = 1
	buttonpractice.x = wheel.x - 60
	buttonpractice.y = wheel.y - 10 + 200
	localGroup:insert( buttonpractice )

	buttonranked = widget.newButton
	{
	    defaultFile = "art/button_ranked.png",
	    overFile = "art/button_ranked.png",
	    mode = 3,
	    width = 48,
	    height = 50,
	    onEvent = startGame
	}
	buttonranked.mode = 3
	buttonranked.x = wheel.x + 60
	buttonranked.y = wheel.y - 10 + 200
	localGroup:insert( buttonranked )
	if ( not _G.isOnline ) then
		buttonranked.alpha = 0.3
	end

	timer.performWithDelay( 500, showMainPanel, 1 )

	local function showKeyboard()
		if ( _G.sfx == 1 ) then
			audio.play ( sounds.sfx_slide )
		end
		local options = {
			isModal = true,
			effect = "fromBottom",
			time = 300
		}
		composer.showOverlay( "keyboard", options )
	end
	--> If player name is null, show keyboard
	if ( _G.player.name == "" ) then
		timer.performWithDelay( 1000, showKeyboard, 1 )
	end

	local function showDailyReward()
		bgmask = display.newRect( 0, 0, _W, _H )
		_G.anchor.Center( bgmask )
		bgmask.x = _W * 0.5
		bgmask.y = _H * 0.5
		bgmask:setFillColor( 0/255, 0/255, 0/255, 128/255 )
		localGroup:insert( bgmask )
		local options = {
			isModal = true,
			effect = "fromBottom",
			time = 300
		}
		composer.showOverlay( "rewards", options )
	end
	
	--> Check if Daily Reward is available
	local date = os.date( "*t" )
	local datetoday = tostring( date.month .. date.day .. date.year )
	if ( string.find( _G.player.lastrewarddate, datetoday ) == nil ) then
		--> Give Daily Reward
		timer.performWithDelay( 1000, showDailyReward, 1 )
		--> Turn off Daily Reward flag
		_G.player.lastrewarddate = datetoday
		settings.set( 'player.lastrewarddate', _G.player.lastrewarddate )
	end
end

function scene:removeMask( event )
	display.remove( bgmask )
	bgmask = nil
end

-- "scene:show()"
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Called when the scene is still off screen (but is about to come on screen).
		-- check for params from previous scene
		-- this block of code is meant to be an alternative to using the myData variables, and may be replaced in favor of the latter
		composer.removeScene( "keyboard" )
	elseif ( phase == "did" ) then
		-- Called when the scene is now on screen.
		-- Insert code here to make the scene come alive.
		-- Example: start timers, begin animation, play audio, etc.

		-- remove connect scene
		composer.removeScene( "choose_class" )
		composer.removeScene( "choose_cards" )
		composer.removeScene( "stats" )
		composer.removeScene( "collection" )
	end
end

-- "scene:hide()"
function scene:hide( event )
   local sceneGroup = self.view
end

-- "scene:destroy()"
function scene:destroy( event )
   local sceneGroup = self.view

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
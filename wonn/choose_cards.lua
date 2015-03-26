local composer = require( "composer" )
local scene = composer.newScene()
local data = require "myData"
local cover = require "cover"
local slideView = require( "slideView" )

-- DATA
local currentRange = 1 -- number of users in the rooms being searched
local game_mode
local playermode = 0
local playerclass = 0
local numsentmsgs = 0
local i
local totalcards = 0
local currentcard = 1
local cardlist = {}
local cardshadow = {}
local cardfront = {}
local cardgroup = {}
local grabCards
local totalchosen = 0
local tempcard = nil
local cardcounter = nil
local timerTimeout = nil
local timeoutCtr = 1

local foodtype = 0
local maxFoodType = 12
	
local _W = display.contentWidth
local _H = display.contentHeight
local mRand = math.random

--she02052015--begin
local waitingTime = 10
local waitingTimer = nil
--local opponent = nil -- 1= live, 0 = bot
--she--end

--she02062015
local startSinglePlayerMode = nil

local buttonback = nil
local buttonmenu = nil
local buttonchoose = nil
local topbar = nil
local bottombar = nil
local bottomcard1 = nil
local bottomcard2 = nil
local bottomcard3 = nil
local bottomcard4 = nil
local bottomcard1shadow = nil
local bottomcard2shadow = nil
local bottomcard3shadow = nil
local bottomcard4shadow = nil

local chosencards = {}

-- "scene:create()"
function scene:create( event )
	local localGroup = self.view

	-- check for params from previous scene
	-- this block of code is meant to be an alternative to using the myData variables, and may be replaced in favor of the latter
	if event.params then
		playermode = event.params.playermode
		playerclass = event.params.playerclass
	end

	-- connect to server
	local function onConnect()
		cover.show() -- display the "choosing opponent" screen

		local sessionID = appWarpClient.getSessionID() --check session ID of current established connection

		if not sessionID or sessionID == 0 then -- ID is either nil or 0 if user has not yet connected or was disconnected, respectively
			appWarpClient.connectWithUserName( _G.player.name ) -- connect with the Appwarp server with selected username
		else -- player has an established connection with server
			print( "pumasok dito!" )
			appWarpClient.getRoomsInRange ( 1, 1 ) -- retrieves all rooms with the specified minimum and maximum users
			_G.startmatch = true -- flag to determine whether the game should start after this user joins; set to true since user is joining a room with 1 player
		end
	end

	local function backtoMain( event )
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
			_G.goback = true
			--> Switch to next scene
			local options = {
			    effect = "fromLeft",
			    time = 300,
			    params = {
			        playermode = playermode,
			        wentback = 1
			    }
			}
			composer.gotoScene( "choose_class", options )
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
			--> check playermode
			if ( playermode == 1 ) then --> single player Practice mode
				_G.opponent = 0
				startSinglePlayerMode()
			else
				onConnect()
				--> Start connection time out timer
				timeoutCtr = 1
				timerTimeout = timer.performWithDelay( 1000, connectionTimeout, 0 )
			end
		end
	end

	local function deleteTempcard()
		if ( _G.sfx == 1 ) then
			audio.play ( sounds.sfx_chuck )
		end
		display.remove( tempcard )
		tempcard = nil
	end

	local function removeCard( event )
		if ( event.phase == "began" ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_tap )
			end
		elseif ( event.phase == "moved" ) then
		elseif ( event.phase == "ended" ) then
			if ( totalchosen > 0 ) then
				--> Enable card from list
				cardgroup[chosencards[totalchosen]].alpha = 1.0
				cardgroup[chosencards[totalchosen]].used = false
				--> Remove card from hand array data
				print( "remove card: " .. _G.savedcards[playerclass][totalchosen] )
				_G.savedcards[playerclass][totalchosen] = ""
				settings.set( 'savedcards[' .. playerclass .. '][' .. totalchosen .. ']', _G.savedcards[playerclass][totalchosen] )
				--> Remove card from stack
				if ( totalchosen == 4 ) then
					tempcard = newImageRectNoDimensions( "art/" .. cardlist[chosencards[totalchosen]].filename )
					tempcard.xScale = 0.33
					tempcard.yScale = 0.33
					tempcard.x = bottomcard4.x
					tempcard.y = bottomcard4.y
					localGroup:insert( tempcard )
					transition.to( tempcard, { time = 200, xScale = 1.0, yScale = 1.0, x = cardgroup[chosencards[totalchosen]].x, y = cardgroup[chosencards[totalchosen]].y, onComplete = deleteTempcard } )
					--> Remove card from stack
					display.remove( bottomcard4 )
					bottomcard4 = nil
					display.remove( bottomcard4shadow )
					bottomcard4shadow = nil
				elseif ( totalchosen == 3 ) then
					tempcard = newImageRectNoDimensions( "art/" .. cardlist[chosencards[totalchosen]].filename )
					tempcard.xScale = 0.33
					tempcard.yScale = 0.33
					tempcard.x = bottomcard3.x
					tempcard.y = bottomcard3.y
					localGroup:insert( tempcard )
					transition.to( tempcard, { time = 200, xScale = 1.0, yScale = 1.0, x = cardgroup[chosencards[totalchosen]].x, y = cardgroup[chosencards[totalchosen]].y, onComplete = deleteTempcard } )
					--> Remove card from stack
					display.remove( bottomcard3 )
					bottomcard3 = nil
					display.remove( bottomcard3shadow )
					bottomcard3shadow = nil
				elseif ( totalchosen == 2 ) then
					tempcard = newImageRectNoDimensions( "art/" .. cardlist[chosencards[totalchosen]].filename )
					tempcard.xScale = 0.33
					tempcard.yScale = 0.33
					tempcard.x = bottomcard2.x
					tempcard.y = bottomcard2.y
					localGroup:insert( tempcard )
					transition.to( tempcard, { time = 200, xScale = 1.0, yScale = 1.0, x = cardgroup[chosencards[totalchosen]].x, y = cardgroup[chosencards[totalchosen]].y, onComplete = deleteTempcard } )
					--> Remove card from stack
					display.remove( bottomcard2 )
					bottomcard2 = nil
					display.remove( bottomcard2shadow )
					bottomcard2shadow = nil
				elseif ( totalchosen == 1 ) then
					tempcard = newImageRectNoDimensions( "art/" .. cardlist[chosencards[totalchosen]].filename )
					tempcard.xScale = 0.33
					tempcard.yScale = 0.33
					tempcard.x = bottomcard1.x
					tempcard.y = bottomcard1.y
					localGroup:insert( tempcard )
					transition.to( tempcard, { time = 200, xScale = 1.0, yScale = 1.0, x = cardgroup[chosencards[totalchosen]].x, y = cardgroup[chosencards[totalchosen]].y, onComplete = deleteTempcard } )
					--> Remove card from stack
					display.remove( bottomcard1 )
					bottomcard1 = nil
					display.remove( bottomcard1shadow )
					bottomcard1shadow = nil
				end			
				totalchosen = totalchosen - 1
			end
		end
	end

	local function stackCard1()
		if ( _G.sfx == 1 ) then
			audio.play ( sounds.sfx_chuck )
		end
		bottomcard1shadow.isVisible = true
		bottomcard1.isVisible = true
		display.remove( tempcard )
		tempcard = nil
	end

	local function stackCard2()
		if ( _G.sfx == 1 ) then
			audio.play ( sounds.sfx_chuck )
		end
		bottomcard2shadow.isVisible = true
		bottomcard2.isVisible = true
		display.remove( tempcard )
		tempcard = nil
	end

	local function stackCard3()
		if ( _G.sfx == 1 ) then
			audio.play ( sounds.sfx_chuck )
		end
		bottomcard3shadow.isVisible = true
		bottomcard3.isVisible = true
		display.remove( tempcard )
		tempcard = nil
	end

	local function stackCard4()
		if ( _G.sfx == 1 ) then
			audio.play ( sounds.sfx_chuck )
		end
		bottomcard4shadow.isVisible = true
		bottomcard4.isVisible = true
		display.remove( tempcard )
		tempcard = nil
	end

	local function chooseCard( event )
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
			if ( not cardgroup[currentcard].used ) then
				local cardlimit = 3
				--> Glenn is allowed up to 4 power-ups
				if ( playerclass == 5 ) then
					cardlimit = 4
				end
				if ( totalchosen < cardlimit ) then
					totalchosen = totalchosen + 1
					local howfast = 200
					--> Disable card
					cardgroup[currentcard].alpha = 0.5
					cardgroup[currentcard].used = true
					chosencards[totalchosen] = currentcard
					--> Store card to hand array
					_G.savedcards[playerclass][totalchosen] = cardlist[currentcard].id
					settings.set( 'savedcards[' .. playerclass .. '][' .. totalchosen .. ']', _G.savedcards[playerclass][totalchosen] )
					print( "saved card: " .. _G.savedcards[playerclass][totalchosen] )
					--> Re-add objects depending on number of chosen cards
					if ( totalchosen == 1 ) then
						--> Stack first card
						bottomcard1shadow = newImageRectNoDimensions( "art/cardshadow.png" )
						bottomcard1shadow.xScale = 0.30
						bottomcard1shadow.yScale = 0.30
						bottomcard1shadow.x = ( _W * 0.5 ) + 10
						bottomcard1shadow.y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50
						bottomcard1shadow.alpha = 0.5
						localGroup:insert( bottomcard1shadow )
						bottomcard1shadow.isVisible = false
						bottomcard1 = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						bottomcard1.xScale = 0.33
						bottomcard1.yScale = 0.33
						bottomcard1.x = _W * 0.5
						bottomcard1.y = _H - ( bottomcard1.contentHeight * 0.5 ) + 44
						bottomcard1.id = currentcard
						localGroup:insert( bottomcard1 )
						bottomcard1.isVisible = false
						tempcard = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						tempcard.x = _W * 0.5
						tempcard.y = _H * 0.5
						localGroup:insert( tempcard )
						transition.to( tempcard, { time = howfast, xScale = 0.33, yScale = 0.33, x = bottomcard1.x, y = bottomcard1.y, onComplete = stackCard1 } )
					elseif ( totalchosen == 2 ) then
						--> Move first card
						transition.to( bottomcard1shadow, { time = howfast, rotation = 5, x = ( _W * 0.5 ) + 30, y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50 } )
						transition.to( bottomcard1, { time = howfast, rotation = 5, x = ( _W * 0.5 ) + 20, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50 } )
						--> Stack second card
						bottomcard2shadow = newImageRectNoDimensions( "art/cardshadow.png" )
						bottomcard2shadow.xScale = 0.30
						bottomcard2shadow.yScale = 0.30
						bottomcard2shadow.x = ( _W * 0.5 ) - 10
						bottomcard2shadow.y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50
						bottomcard2shadow:rotate( -5 )
						bottomcard2shadow.alpha = 0.5
						localGroup:insert( bottomcard2shadow )
						bottomcard2shadow.isVisible = false
						bottomcard2 = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						bottomcard2.xScale = 0.33
						bottomcard2.yScale = 0.33
						bottomcard2.x = ( _W * 0.5 ) - 20
						bottomcard2.y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50
						bottomcard2:rotate( -5 )
						bottomcard2.id = currentcard
						localGroup:insert( bottomcard2 )
						bottomcard2.isVisible = false
						tempcard = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						tempcard.x = _W * 0.5
						tempcard.y = _H * 0.5
						localGroup:insert( tempcard )
						transition.to( tempcard, { time = howfast, rotation = -5, xScale = 0.33, yScale = 0.33, x = ( _W * 0.5 ) - 20, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50, onComplete = stackCard2 } )
					elseif ( totalchosen == 3 ) then
						--> Move first card
						transition.to( bottomcard1shadow, { time = howfast - 50, rotation = 10, x = ( _W * 0.5 ) + 50, y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50 } )
						transition.to( bottomcard1, { time = howfast - 50, rotation = 10, x = ( _W * 0.5 ) + 40, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50 } )
						--> Move second card
						transition.to( bottomcard2shadow, { time = howfast - 30, rotation = 0, x = ( _W * 0.5 ) + 10, y = _H - ( bottomcard2shadow.contentHeight * 0.5 ) + 44 } )
						transition.to( bottomcard2, { time = howfast - 30, rotation = 0, x = _W * 0.5, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 44 } )
						--> Stack third card
						bottomcard3shadow = newImageRectNoDimensions( "art/cardshadow.png" )
						bottomcard3shadow.xScale = 0.30
						bottomcard3shadow.yScale = 0.30
						bottomcard3shadow.x = ( _W * 0.5 ) - 30
						bottomcard3shadow.y = _H - ( bottomcard3shadow.contentHeight * 0.5 ) + 48
						bottomcard3shadow:rotate( -10 )
						bottomcard3shadow.alpha = 0.5
						localGroup:insert( bottomcard3shadow )
						bottomcard3shadow.isVisible = false
						bottomcard3 = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						bottomcard3.xScale = 0.33
						bottomcard3.yScale = 0.33
						bottomcard3.x = ( _W * 0.5 ) - 40
						bottomcard3.y = _H - ( bottomcard3.contentHeight * 0.5 ) + 48
						bottomcard3:rotate( -10 )
						bottomcard3.id = currentcard
						localGroup:insert( bottomcard3 )
						bottomcard3.isVisible = false
						tempcard = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						tempcard.x = _W * 0.5
						tempcard.y = _H * 0.5
						localGroup:insert( tempcard )
						transition.to( tempcard, { time = howfast, rotation = -10, xScale = 0.33, yScale = 0.33, x = ( _W * 0.5 ) - 40, y = _H - ( bottomcard3.contentHeight * 0.5 ) + 50, onComplete = stackCard3 } )
					elseif ( totalchosen == 4 ) then
						--> Move first card
						transition.to( bottomcard1shadow, { time = howfast - 50, rotation = 10, x = ( _W * 0.5 ) + 50, y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50 } )
						transition.to( bottomcard1, { time = howfast - 50, rotation = 10, x = ( _W * 0.5 ) + 40, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50 } )
						--> Move second card
						transition.to( bottomcard2shadow, { time = howfast - 30, rotation = 4, x = ( _W * 0.5 ) + 20, y = _H - ( bottomcard2shadow.contentHeight * 0.5 ) + 38 } )
						transition.to( bottomcard2, { time = howfast - 30, rotation = 4, x = ( _W * 0.5 ) + 10, y = _H - ( bottomcard2.contentHeight * 0.5 ) + 38 } )
						--> Move third card
						transition.to( bottomcard3shadow, { time = howfast - 10, rotation = -5, x = ( _W * 0.5 ) - 10, y = _H - ( bottomcard3shadow.contentHeight * 0.5 ) + 46 } )
						transition.to( bottomcard3, { time = howfast - 10, rotation = -5, x = ( _W * 0.5 ) - 20, y = _H - ( bottomcard3.contentHeight * 0.5 ) + 46 } )
						--> Stack fourth card
						bottomcard4shadow = newImageRectNoDimensions( "art/cardshadow.png" )
						bottomcard4shadow.xScale = 0.30
						bottomcard4shadow.yScale = 0.30
						bottomcard4shadow.x = ( _W * 0.5 ) - 40
						bottomcard4shadow.y = _H - ( bottomcard4shadow.contentHeight * 0.5 ) + 46
						bottomcard4shadow:rotate( -10 )
						bottomcard4shadow.alpha = 0.5
						localGroup:insert( bottomcard4shadow )
						bottomcard4shadow.isVisible = false
						bottomcard4 = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						bottomcard4.xScale = 0.33
						bottomcard4.yScale = 0.33
						bottomcard4.x = ( _W * 0.5 ) - 50
						bottomcard4.y = _H - ( bottomcard4.contentHeight * 0.5 ) + 46
						bottomcard4:rotate( -10 )
						bottomcard4.id = currentcard
						localGroup:insert( bottomcard4 )
						bottomcard4.isVisible = false
						tempcard = newImageRectNoDimensions( "art/" .. cardlist[currentcard].filename )
						tempcard.x = _W * 0.5
						tempcard.y = _H * 0.5
						localGroup:insert( tempcard )
						transition.to( tempcard, { time = howfast, rotation = -10, xScale = 0.33, yScale = 0.33, x = ( _W * 0.5 ) - 60, y = _H - ( bottomcard4.contentHeight * 0.5 ) + 50, onComplete = stackCard4 } )
					end
				else
					if ( _G.sfx == 1 ) then
						audio.play ( sounds.sfx_error )
					end
				end
			else
				if ( _G.sfx == 1 ) then
					audio.play ( sounds.sfx_error )
				end
			end
		end
	end

	--> Grab all card filenames
	grabCards()

	local background = newImageRectNoDimensions( "art/bg_choosecards.png" )
	background.x = _W * 0.5
	background.y = _H * 0.5
	localGroup:insert( background )

	topbar = newImageRectNoDimensions( "art/topbar.png" )
	topbar.x = _W * 0.5
	topbar.y = topbar.contentHeight * 0.5
	localGroup:insert( topbar )

	local bgcardctr = newImageRectNoDimensions( "art/bg_cardctr.png" )
	bgcardctr.x = _W * 0.5
	bgcardctr.y = topbar.contentHeight + ( bgcardctr.contentHeight * 0.5 )
	localGroup:insert( bgcardctr )

	buttonback = widget.newButton
	{
	    defaultFile = "art/button_back.png",
	    overFile = "art/button_back.png",
	    width = 64,
	    height = 52,
	    onEvent = backtoMain
	}
	buttonback.x = buttonback.contentWidth * 0.5
	buttonback.y = buttonback.contentHeight * 0.5
	localGroup:insert( buttonback )

	local thumbnail = newImageRectNoDimensions( "art/thumbc" .. playerclass .. ".png" )
	thumbnail.x = _W - ( thumbnail.contentWidth * 0.5 )
	thumbnail.y = thumbnail.contentHeight * 0.5
	localGroup:insert( thumbnail )

 	local title = display.newText( "choose cards", 0, 0, _G.fontname, 22 )
	title:setTextColor( 255/255, 249/255, 164/255 )
	_G.anchor.Center( title )
	title.x = _W * 0.5
	title.y = topbar.y - 12
	localGroup:insert( title )

	if ( playermode == 1 ) then
 		game_mode = display.newText( "(practice mode)", 0, 0, _G.fontname, 16 )
	elseif ( playermode == 2 ) then
 		game_mode = display.newText( "(friendly mode)", 0, 0, _G.fontname, 16 )
	elseif ( playermode == 3 ) then
 		game_mode = display.newText( "(ranked mode)", 0, 0, _G.fontname, 16 )
 	end
	game_mode:setTextColor( 255/255, 255/255, 255/255 )
	_G.anchor.Center( game_mode )
	game_mode.x = _W * 0.5
	game_mode.y = topbar.y + 6
	localGroup:insert( game_mode )

	bottombar = newImageRectNoDimensions( "art/bottombar.png" )
	bottombar.x = _W * 0.5
	bottombar.y = _H - ( bottombar.contentHeight * 0.5 )
	localGroup:insert( bottombar )
	bottombar:addEventListener( "touch", removeCard )

	buttonchoose = widget.newButton
	{
	    defaultFile = "art/button_choose.png",
	    overFile = "art/button_choose.png",
	    width = 64,
	    height = 52,
	    onEvent = chooseCard
	}
	buttonchoose.x = buttonchoose.contentWidth * 0.5
	buttonchoose.y = _H - ( buttonchoose.contentHeight * 0.5 )
	localGroup:insert( buttonchoose )

	--> Show only 3 cards at any given point
	currentcard = 1
	for i = currentcard, totalcards do
		cardgroup[i] = display.newGroup()
		cardshadow[i] = newImageRectNoDimensions( "art/cardshadow.png" )
		cardshadow[i].alpha = 0.75
		cardgroup[i]:insert( cardshadow[i] )
		cardfront[i] = newImageRectNoDimensions( "art/" .. cardlist[i].filename )
		cardgroup[i].used = false
		cardgroup[i]:insert( cardfront[i] )
		localGroup:insert( cardgroup[i] )
	end

	local function mySlideListener( event )
	    currentcard = event.slide
	    --print( "Card ID:" .. cardlist[event.slide].id )
	    cardcounter.text = currentcard .. " of " .. totalcards
	end

	-- you can add any display object or display group
	local mySlides = {}
	for i = 1, totalcards do
		table.insert( mySlides, cardgroup[i] )
	end

	local slidesPanel = slideView.new( mySlides, mySlideListener, nil, topbar.contentHeight, _H - ( _H - bottombar.contentHeight ) )
	localGroup:insert( slidesPanel )

	buttongo = widget.newButton
	{
	    defaultFile = "art/button_go.png",
	    overFile = "art/button_go.png",
	    width = 64,
	    height = 52,
	    onEvent = startGame
	}
	buttongo.x = _W - ( buttongo.contentWidth * 0.5 )
	buttongo.y = _H - ( buttongo.contentHeight * 0.5 )
	localGroup:insert( buttongo )

 	cardcounter = display.newText( currentcard .. " of " .. totalcards, 0, 0, _G.fontname, 16 )
	cardcounter:setTextColor( 255/255, 255/255, 255/255 )
	_G.anchor.Center( cardcounter )
	cardcounter.x = _W * 0.5
	cardcounter.y = bgcardctr.y + 1
	localGroup:insert( cardcounter )

	--> Display default hand if there are any
	for i = 1, #_G.savedcards[playerclass] do
		if ( string.len( _G.savedcards[playerclass][i] ) > 0 ) then
			totalchosen = totalchosen + 1
		end
	end
	print( "totalchosen: " .. totalchosen )
	if ( totalchosen > 0 ) then
		local dotpos, pclass, whichcard, card_index
		--> Parse card id so we can update card data array
		dotpos = string.find( _G.savedcards[playerclass][1], ".", 1, string.len( _G.savedcards[playerclass][1] ) )
		pclass = tonumber( string.sub( _G.savedcards[playerclass][1], 1, dotpos - 1 ) )
		whichcard = tonumber( string.sub( _G.savedcards[playerclass][1], dotpos + 1 ) )
		--> Disable card from the slide list
		for i = 1, #cardlist do
			if ( cardlist[i].id == _G.savedcards[playerclass][1] ) then
				--> Boom! Found card!
				card_index = i
				break
			end
		end
		cardgroup[card_index].alpha = 0.5
		cardgroup[card_index].used = true
		--> Add to chosen cards
		chosencards[1] = card_index
		--> Stack first card
		display.remove( bottomcard1shadow )
		bottomcard1shadow = nil
		bottomcard1shadow = newImageRectNoDimensions( "art/cardshadow.png" )
		bottomcard1shadow.xScale = 0.30
		bottomcard1shadow.yScale = 0.30
		bottomcard1shadow.x = ( _W * 0.5 ) + 10
		bottomcard1shadow.y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50
		bottomcard1shadow.alpha = 0.5
		localGroup:insert( bottomcard1shadow )
		display.remove( bottomcard1 )
		bottomcard1 = nil
		bottomcard1 = newImageRectNoDimensions( "art/card_" .. pclass .. "_" .. whichcard .. ".png" )
		bottomcard1.xScale = 0.33
		bottomcard1.yScale = 0.33
		bottomcard1.x = _W * 0.5
		bottomcard1.y = _H - ( bottomcard1.contentHeight * 0.5 ) + 44
		bottomcard1.id = card_index
		localGroup:insert( bottomcard1 )
		if ( totalchosen > 1 ) then
			--> Move first card
			transition.to( bottomcard1shadow, { time = 100, rotation = 5, x = ( _W * 0.5 ) + 30, y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50 } )
			transition.to( bottomcard1, { time = 100, rotation = 5, x = ( _W * 0.5 ) + 20, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50 } )
			--> Parse card id so we can update card data array
			dotpos = string.find( _G.savedcards[playerclass][2], ".", 1, string.len( _G.savedcards[playerclass][2] ) )
			pclass = tonumber( string.sub( _G.savedcards[playerclass][2], 1, dotpos - 1 ) )
			whichcard = tonumber( string.sub( _G.savedcards[playerclass][2], dotpos + 1 ) )
			--> Disable card from the slide list
			for i = 1, #cardlist do
				if ( cardlist[i].id == _G.savedcards[playerclass][2] ) then
					--> Boom! Found card!
					card_index = i
					break
				end
			end
			cardgroup[card_index].alpha = 0.5
			cardgroup[card_index].used = true
			--> Add to chosen cards
			chosencards[2] = card_index
			--> Stack second card
			bottomcard2shadow = newImageRectNoDimensions( "art/cardshadow.png" )
			bottomcard2shadow.xScale = 0.30
			bottomcard2shadow.yScale = 0.30
			bottomcard2shadow.x = ( _W * 0.5 ) - 10
			bottomcard2shadow.y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50
			bottomcard2shadow:rotate( -5 )
			bottomcard2shadow.alpha = 0.5
			localGroup:insert( bottomcard2shadow )
			bottomcard2 = newImageRectNoDimensions( "art/card_" .. pclass .. "_" .. whichcard .. ".png" )
			bottomcard2.xScale = 0.33
			bottomcard2.yScale = 0.33
			bottomcard2.x = ( _W * 0.5 ) - 20
			bottomcard2.y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50
			bottomcard2:rotate( -5 )
			bottomcard2.id = card_index
			localGroup:insert( bottomcard2 )
		end
		if ( totalchosen > 2 ) then
			--> Move first card
			transition.to( bottomcard1shadow, { time = 100, rotation = 10, x = ( _W * 0.5 ) + 50, y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50 } )
			transition.to( bottomcard1, { time = 100, rotation = 10, x = ( _W * 0.5 ) + 40, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50 } )
			--> Move second card
			transition.to( bottomcard2shadow, { time = 100, rotation = 0, x = ( _W * 0.5 ) + 10, y = _H - ( bottomcard2shadow.contentHeight * 0.5 ) + 44 } )
			transition.to( bottomcard2, { time = 100, rotation = 0, x = _W * 0.5, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 44 } )
			--> Parse card id so we can update card data array
			dotpos = string.find( _G.savedcards[playerclass][3], ".", 1, string.len( _G.savedcards[playerclass][3] ) )
			pclass = tonumber( string.sub( _G.savedcards[playerclass][3], 1, dotpos - 1 ) )
			whichcard = tonumber( string.sub( _G.savedcards[playerclass][3], dotpos + 1 ) )
			--> Disable card from the slide list
			for i = 1, #cardlist do
				if ( cardlist[i].id == _G.savedcards[playerclass][3] ) then
					--> Boom! Found card!
					card_index = i
					break
				end
			end
			cardgroup[card_index].alpha = 0.5
			cardgroup[card_index].used = true
			--> Add to chosen cards
			chosencards[3] = card_index
			--> Stack third card
			bottomcard3shadow = newImageRectNoDimensions( "art/cardshadow.png" )
			bottomcard3shadow.xScale = 0.30
			bottomcard3shadow.yScale = 0.30
			bottomcard3shadow.x = ( _W * 0.5 ) - 30
			bottomcard3shadow.y = _H - ( bottomcard3shadow.contentHeight * 0.5 ) + 48
			bottomcard3shadow:rotate( -10 )
			bottomcard3shadow.alpha = 0.5
			localGroup:insert( bottomcard3shadow )
			bottomcard3 = newImageRectNoDimensions( "art/card_" .. pclass .. "_" .. whichcard .. ".png" )
			bottomcard3.xScale = 0.33
			bottomcard3.yScale = 0.33
			bottomcard3.x = ( _W * 0.5 ) - 40
			bottomcard3.y = _H - ( bottomcard3.contentHeight * 0.5 ) + 48
			bottomcard3:rotate( -10 )
			bottomcard3.id = card_index
			localGroup:insert( bottomcard3 )
		end
		if ( totalchosen > 3 ) then --> Special option for Glenn (class 4)
			--> Move first card
			transition.to( bottomcard1shadow, { time = 100, rotation = 10, x = ( _W * 0.5 ) + 50, y = _H - ( bottomcard1shadow.contentHeight * 0.5 ) + 50 } )
			transition.to( bottomcard1, { time = 100, rotation = 10, x = ( _W * 0.5 ) + 40, y = _H - ( bottomcard1.contentHeight * 0.5 ) + 50 } )
			--> Move second card
			transition.to( bottomcard2shadow, { time = 100, rotation = 4, x = ( _W * 0.5 ) + 20, y = _H - ( bottomcard2shadow.contentHeight * 0.5 ) + 38 } )
			transition.to( bottomcard2, { time = 100, rotation = 4, x = ( _W * 0.5 ) + 10, y = _H - ( bottomcard2.contentHeight * 0.5 ) + 38 } )
			--> Move third card
			transition.to( bottomcard3shadow, { time = 100, rotation = -5, x = ( _W * 0.5 ) - 10, y = _H - ( bottomcard3shadow.contentHeight * 0.5 ) + 46 } )
			transition.to( bottomcard3, { time = 100, rotation = -5, x = ( _W * 0.5 ) - 20, y = _H - ( bottomcard3.contentHeight * 0.5 ) + 46 } )
			--> Parse card id so we can update card data array
			dotpos = string.find( _G.savedcards[playerclass][4], ".", 1, string.len( _G.savedcards[playerclass][4] ) )
			pclass = tonumber( string.sub( _G.savedcards[playerclass][4], 1, dotpos - 1 ) )
			whichcard = tonumber( string.sub( _G.savedcards[playerclass][4], dotpos + 1 ) )
			--> Disable card from the slide list
			for i = 1, #cardlist do
				if ( cardlist[i].id == _G.savedcards[playerclass][4] ) then
					--> Boom! Found card!
					card_index = i
					break
				end
			end
			cardgroup[card_index].alpha = 0.5
			cardgroup[card_index].used = true
			--> Add to chosen cards
			chosencards[4] = card_index
			--> Stack fourth card
			bottomcard4shadow = newImageRectNoDimensions( "art/cardshadow.png" )
			bottomcard4shadow.xScale = 0.30
			bottomcard4shadow.yScale = 0.30
			bottomcard4shadow.x = ( _W * 0.5 ) - 40
			bottomcard4shadow.y = _H - ( bottomcard4shadow.contentHeight * 0.5 ) + 46
			bottomcard4shadow:rotate( -10 )
			bottomcard4shadow.alpha = 0.5
			localGroup:insert( bottomcard4shadow )
			bottomcard4 = newImageRectNoDimensions( "art/card_" .. pclass .. "_" .. whichcard .. ".png" )
			bottomcard4.xScale = 0.33
			bottomcard4.yScale = 0.33
			bottomcard4.x = ( _W * 0.5 ) - 50
			bottomcard4.y = _H - ( bottomcard4.contentHeight * 0.5 ) + 46
			bottomcard4:rotate( -10 )
			bottomcard4.id = card_index
			localGroup:insert( bottomcard4 )
		end
	end

	-- flag to determine whether the game should start after this user joins; set to false as default
	_G.startmatch = false
end

--> Function to grab all the filenames of the cards available for the current class
function grabCards()
	--> Count all cards for the chosen class + all generic cards
	local totalclasscards = 0
	for i = 1, _G.cards[playerclass] do
		if ( _G.carddata[playerclass][i].howmany > 0 ) then
			totalclasscards = totalclasscards + 1
		end
	end
	local totalgenericcards = 0
	for i = 1, _G.cards[99] do
		if ( _G.carddata[7][i].howmany > 0 ) then
			totalgenericcards = totalgenericcards + 1
		end
	end

	totalcards = totalclasscards + totalgenericcards

	local ctr = 1
	--> Class-specific cards
	for i = 1, _G.cards[playerclass] do
		--> Grab only the unlocked cards
		if ( _G.carddata[playerclass][i].howmany > 0 ) then
			cardlist[ctr] = {}
			cardlist[ctr].filename = "card_" .. playerclass .. "_" .. i .. ".png"
			cardlist[ctr].id = playerclass .. "." .. i
			ctr = ctr + 1
		end
	end
	--> Generic cards
	for i = 1, _G.cards[99] do
		--> Grab only the unlocked cards
		if ( _G.carddata[7][i].howmany > 0 ) then
			cardlist[ctr] = {}
			cardlist[ctr].filename = "card_99" .. "_" .. i .. ".png"
			cardlist[ctr].id = "99" .. "." .. i
			ctr = ctr + 1
		end
	end
end

function hideCover()
	cover.hide()
end

function connectionTimeout()
	print( "Connection time out: " .. timeoutCtr )
	if ( timeoutCtr < 30 ) then
		timeoutCtr = timeoutCtr + 1
	else
		--> Stop timer
		timer.cancel( timerTimeout )
		timerTimeout = nil
		--> Connection timed out!
		cover.showTimeoutMsg()
		--> Hide cover after a few seconds
		timer.performWithDelay( 4000, hideCover, 1 )
	end
end

----------------------------------------------------------------------
-- Common Scene Handline
----------------------------------------------------------------------

function startSinglePlayerMode()
	-- set up bot name
	_G.player.oppname = _G.generateName()
	print("bot name: ", _G.player.oppname)
	
	-- set up bot class
	_G.player.oppclass = math.random( _G.maxclasses )
	_G.player.opprank = _G.player.rank
	
	print("bot class: ", _G.player.oppclass)
	local options = {
		effect = "fromRight",
		time = 300,
		params = {
			roomid = 00000,
			foodtype = math.random( maxFoodType ),
			mode = playermode
		}
	}	
	--show versus screen
	composer.gotoScene( "versus", options )
end

--she02022015


local  function unsubscribeRoom()
	appWarpClient.unsubscribeRoom(roomid)
end

local  function leaveRoom()
   appWarpClient.leaveRoom(roomid)
end

local  function disconnect()
	appWarpClient.disconnect()	
end

-- connection failed; used for server responses to actions that failed to connect (ex. failing to join room or retrieve server data)
function onConnectFailed()
	native.showAlert("","Failed to connect",{"OK"})
	cover.hide()
	--btnConnect.isVisible = true -- show "Start Match" button again
end

function scene:hideCover( event )
end

-- listener for connectWithUserName
function scene.onConnectDone(resultCode)
	print("onConnectDone", resultCode)

	if ( resultCode == WarpResponseResultCode.SUCCESS ) then
		--> Stop connection timeout timer
		timer.cancel( timerTimeout )
		timerTimeout = nil
		--> Ask if player wants to enable ads for free tokens
		cover.showEnableAdsMsg()
		--> Retrieves all rooms with the specified minimum and maximum users
		appWarpClient.getRoomsInRange ( 1, 1 )
		_G.startmatch = true
	else
		onConnectFailed()
	end  
end

-- listener for getLiveRoomInfo function
function scene.onGetLiveRoomInfoDone (resultCode , roomTable )  
	print("onGetLiveRoomInfoDone", resultCode, roomTable)
	--if roomTable then print(json.prettify(roomTable)) end
end

-- listener for getAllRoomsDone function
function scene.onGetAllRoomsDone (resultCode , roomsTable )  
	print("onGetAllRoomsDone",resultCode, roomsTable)
	--if roomsTable then print(json.prettify(roomsTable)) end
end

-- listener for getRoomsInRange and getRoomsWithProperties functions
function scene.onGetMatchedRoomsDone (resultCode , roomsTable )   
	print("onGetMatchedRoomsDone >>   resultCode = ", resultCode, ", roomsTable=", roomsTable, ", #roomsTable=", #roomsTable)
	--if roomsTable then print(json.prettify(roomsTable)) end
	if( resultCode == WarpResponseResultCode.SUCCESS ) then
		if #roomsTable == 0 then
			_G.startmatch = false
			
			--set food type for room if i am the creator of the room
			foodtype = mRand( maxFoodType )  --she 02118015
			
			if currentRange == 1 then
				currentRange = 0
				appWarpClient.getRoomsInRange ( 0, 0 )
			elseif currentRange == 0 then
				appWarpClient.createRoom ( "public", _G.player.name, 2, nil )  
			end
		else 
			appWarpClient.joinRoom( roomsTable[1].id )
		end
	else
		onConnectFailed()     
	end
end

-- listener for joinRoom function
function scene.onJoinRoomDone(resultCode, roomid)
	print("onJoinRoomDone", resultCode, roomid)
	if(resultCode == WarpResponseResultCode.SUCCESS) then
		appWarpClient.subscribeRoom(roomid) -- successfully joined room; subscribe to the room
	else
		onConnectFailed()
	end 
end

function scene.onChatReceived(sender, message, id, isLobby)
	print("onChatReceived",sender,username,message,id,isLobby)
	message = json.decode(message)
	-- print(message)
	
	print("message.type = ", message.type)
	
	if type(message) == "table" then
		-- print(json.prettify(message))
		if message.id == "sendName" then -- game started	
			if sender ~= _G.player.name then
				if ( numsentmsgs == 1 ) then
					--> Resend current player's name to opponent
					--local foodtype = 1
					
					--set food type
					if foodtype == 0 then  -- if i am not the room creator, copy food type from sender  --she 02182015
						foodtype = tonumber(message.type)
					end
					
						
					local str = '{"id":"sendName","class":"' .. _G.player.class .. '","type":"' .. foodtype .. '","rank":"' .. _G.player.rank .. '"}'
					appWarpClient.sendChat(str) -- send message to room to notify opponent to start the game
					numsentmsgs = numsentmsgs + 1
					print ( str )
					print( "received opponent's name!!!" )
					
					
					
					--she02052015--begin 
					--cancel waiting time for opponent
					if waitingTimer ~= nil then
						print("opponent found, cancel timer")
						timer.cancel ( waitingTimer )

					end

					--> Hide cover
					cover.hide()
					
					--she02052015--end 
					--set opponent flag to live
					_G.opponent = 1
						
					_G.player.oppname = sender
					_G.player.oppclass = tonumber( message.class )
					_G.player.opprank = tonumber( message.rank )
					local options = {
					    effect = "fromRight",
					    time = 300,
					    params = {
					        roomid = roomid,
					        foodtype = foodtype,
					        mode = playermode
					    }
					}
					
					composer.gotoScene( "versus", options )
				end
			else
					--foodtype = math.random(5)
					--print("foodtype = ", foodtype)
			end
		end
	end
end

--she02052015--begin
--listener timer
local function timerDown()
	print("start timer")
	waitingTime = waitingTime- 1
	print("timeCtr = ", waitingTime)
	
	if waitingTime == 0 then
		--cancel timer
		print("cancel timer")
		timer.cancel(waitingTimer)
		
		print("no opponent found, enter SINGLE PLAYER")	
		--set opponent flag to bot
		_G.opponent = 0
		
		--cancel all connections
		--stopGame()
		unsubscribeRoom()
		leaveRoom()
		disconnect()


		--start single player mode
		startSinglePlayerMode()
		
	end
end
--she 02022015--end

-- listener for subscribeRoom function
function scene.onSubscribeRoomDone(resultCode, roomid)
	print("onSubscribeRoomDone", resultCode, roomid)
	if(resultCode == WarpResponseResultCode.SUCCESS) then
		--> Send player's name to opponent
		--local foodtype = 1  --removed she 02112015
		local str = '{"id":"sendName","class":"' .. _G.player.class .. '","type":"' .. foodtype .. '","rank":"' .. _G.player.rank .. '"}'
		appWarpClient.sendChat(str) -- send message to room to notify opponent to start the game
		numsentmsgs = numsentmsgs + 1
		print ( str )
		
		--she--begin 020920105
		--wait for oppponent for 15 seconds, if no opponent joins, set the SINGLE PLAYER mode
		waitingTimer=timer.performWithDelay(1000, timerDown,  waitingTime)
		--she--end

	else
		onConnectFailed()
	end 
	
end

-- listener for createRoom function
function scene.onCreateRoomDone(resultCode, roomid, name)
	print("onCreateRoomDone",resultCode, roomid, name)
	if(resultCode == WarpResponseResultCode.SUCCESS) then
		--composer.gotoScene( "MainScene", "slideLeft", 800)
		--[[
		local options = {
		    effect = "fromRight",
		    time = 300
		}
		composer.gotoScene( "versus", options )
		]]--
	else
		onConnectFailed()
	end  
end

-- listener for deleteRoom function
function scene.onDeleteRoomDone (resultCode , roomid , name )  
	print("onDeleteRoomDone",resultCode,roomid,name) 
end

-- "scene:show()"
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Called when the scene is still off screen (but is about to come on screen).
		-- check for params from previous scene
		-- this block of code is meant to be an alternative to using the myData variables, and may be replaced in favor of the latter
		if event.params then
			playermode = event.params.playermode
			playerclass = event.params.playerclass
			if ( game_mode ~= nil ) then
				if ( playermode == 1 ) then
			 		game_mode.text = "(practice mode)"
				elseif ( playermode == 2 ) then
			 		game_mode.text = "(friendly mode)"
				elseif ( playermode == 3 ) then
			 		game_mode.text = "(ranked mode)"
			 	end
			end
			--> Grab all card filenames
			grabCards()
		end
	elseif ( phase == "did" ) then
		-- Called when the scene is now on screen.
		-- Insert code here to make the scene come alive.
		-- Example: start timers, begin animation, play audio, etc.

		-- remove connect scene
		composer.removeScene( "choose_class" )

		-- add listeners for Appwarp's server request functions
		appWarpClient.addRequestListener("onConnectDone", scene.onConnectDone)  
		appWarpClient.addRequestListener("onJoinRoomDone", scene.onJoinRoomDone)  
		appWarpClient.addNotificationListener("onChatReceived", scene.onChatReceived)
		appWarpClient.addRequestListener("onSubscribeRoomDone", scene.onSubscribeRoomDone)  
		appWarpClient.addRequestListener("onCreateRoomDone", scene.onCreateRoomDone)
		appWarpClient.addRequestListener("onGetAllRoomsDone", scene.onGetAllRoomsDone)
		appWarpClient.addRequestListener("onGetMatchedRoomsDone", scene.onGetMatchedRoomsDone)
		appWarpClient.addRequestListener("onDeleteRoomDone", scene.onDeleteRoomDone)
		appWarpClient.addRequestListener("onGetLiveRoomInfoDone", scene.onGetLiveRoomInfoDone)
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
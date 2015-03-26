local composer = require( "composer" )
local scene = composer.newScene()

---------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE
-- unless "composer.removeScene()" is called.
---------------------------------------------------------------------------------

-- local forward references should go here

---------------------------------------------------------------------------------

-- MEASUREMENTS
local screenW = display.contentWidth
local screenH = display.contentHeight
local halfW = display.contentCenterX
local halfH = display.contentCenterY

local areaX = display.screenOriginX
local areaY = display.screenOriginY
local actualW = screenW - 2*areaX
local actualH = screenH - 2*areaY

local top = 0 + areaY
local left = 0 + areaX
local bottom = screenH - areaY
local right = screenW - areaX

-- MODULES
local json = require "json"
local widget = require "widget"
local data = require "myData"
local cover = require "cover"
local lib_emitter = require "lib_emitter"

-- OBJECTS
local hitBox
local txtScore
local txtTime
local tmrRetry
local mainProgressBar
local playerthumb

-- FUNCTIONS
local createScreen
local updateSprite
local onEnterFrame
local onTouchFood

-- utility functions
local mRand = math.random
local mRound = math.round
local mFloor = math.floor

-- DATA
local username = _G.player.name
local userrank =_G.player.rank
local oppName
local adheight
local touchCtr = 0
local touches = {}

local spritePhase = 1   -- current phase of food on player bot
local plate  -- made global to center food item on plate
local spritePlate  --she 02182015
local bgmask = nil

--bot 
local botTapsPerSec = 0  -- number of taps per seconds for bot
local botfoodCtr = 0
local botFinished = false

local actionStarted = false   -- tag when game has already started

local roomid
local gamemode

-- store class abilities for computation  --she 02182015
local classPPT  = nil -- player PPT
local classPPS  = nil	--player PPS
local oppclassPPT = nil	-- opponent PPT
local oppclassPPS = nil 	--oppponent PPS

local timerPPS = nil 	-- timer used for counting class' PPS ability  02242015
local timerBotPPT = nil
local timerBotPPS = nil
local pptval
local ppsval

local oppScore
local gameStarted
local gameFinished = false
local gameDecided
local time = 0
local crunchTime
local score = 0
local currentIndex 	--  refers to foodtype                  1 she 02112015
local currentDish
local foodCtr -- food counter, taps it take to reduce food to the next "phase"
local foodData = 
{
	{
      name = "bibingka", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 300, 
      height = 132,
      pwidth = 13,
      pheight = 10,
      offsety = 50,
      scrnoffsety = 2
   },
   {
      name = "burger", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 200, 
      height = 233,
      pwidth = 16,
      pheight = 14,
      offsety = 30,
      scrnoffsety = 9
   },
   {
      name = "cake", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 288, 
      height = 267,
      pwidth = 21,
      pheight = 15,
      offsety = 40,
      scrnoffsety = 5
   },
   {
      name = "crab", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 300, 
      height = 132,
      pwidth = 17,
      pheight = 11,
      offsety = 50,
      scrnoffsety = 3
   },
   {
      name = "fries", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 300, 
      height = 179,
      pwidth = 20,
      pheight = 11,
      offsety = 60,
      scrnoffsety = 0
   },
   {
      name = "pancake", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 300, 
      height = 228,
      pwidth = 14,
      pheight = 8,
      offsety = 40,
      scrnoffsety = 5
   },
   {
      name = "pie", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 300, 
      height = 151,
      pwidth = 17,
      pheight = 12,
      offsety = 40,
      scrnoffsety = 5
   },
   {
      name = "pizza", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 300, 
      height = 114,
      pwidth = 20,
      pheight = 13,
      offsety = 50,
      scrnoffsety = 2
   },
   {
      name = "split", 
      state = 1, 
      max = 6, 
      lbs = 180,
      width = 300, 
      height = 233,
      pwidth = 15,
      pheight = 11,
      offsety = 40,
      scrnoffsety = 5
   },
   {
      name = "steak", 
      state = 1, 
      max = 6, 
      lbs = 220,
      width = 272, 
      height = 116,
      pwidth = 15,
      pheight = 9,
      offsety = 40,
      scrnoffsety = 5
   },
   {
      name = "turkey", 
      state = 1, 
      max = 6, 
      lbs = 220,
      width = 295, 
      height = 174,
      pwidth = 22,
      pheight = 15,
      offsety = 50,
      scrnoffsety = 3
   },
   {
      name = "watermelon", 
      state = 1, 
      max = 6, 
      lbs = 220,
      width = 274, 
      height = 216,
      pwidth = 16,
      pheight = 13,
      offsety = 40,
      scrnoffsety = 5
   },
}

-- "scene:create()"
function scene:create( event )
   local sceneGroup = self.view

   -- Initialize the scene here.
   -- Example: add display objects to "sceneGroup", add touch listeners, etc.

   -- display groups
   local bgGroup = display.newGroup()
   local mainGroup = display.newGroup()
   local uiGroup = display.newGroup()
   sceneGroup:insert(bgGroup)
   sceneGroup:insert(mainGroup)
   sceneGroup:insert(uiGroup)

   local screenGroup = display.newGroup()
   uiGroup:insert(screenGroup)

   -- check for params from previous scene
   -- this block of code is meant to be an alternative to using the myData variables, and may be replaced in favor of the latter
   if event.params then
      roomid = event.params.roomid -- ID of room where user has joined and subscribed
      currentIndex = event.params.foodtype -- which food data to display  --she 02112015
      gamemode = event.params.mode
   end

   --> Init food particle properties
   local foodparticle = {}
   foodparticle.duration = 500
   foodparticle.pImage = "art/food_" .. foodData[currentIndex].name .. "_p.png"
   foodparticle.pImageWidth = foodData[currentIndex].pwidth
   foodparticle.pImageHeight = foodData[currentIndex].pwidth
   foodparticle.emitterDensity = 3
   foodparticle.radiusRange = 120
   foodparticle.thickness = 4
   local foodEmitter = emitterLib:createEmitter( foodparticle.radiusRange, foodparticle.thickness, foodparticle.duration, 1, 0, foodparticle.pImage, foodparticle.pImageWidth, foodparticle.pImageHeight )

	print("currentIndex = ", currentIndex)
   -- scene background
   local bg = newImageRectNoDimensions( "art/bg_main_c" .. _G.player.class .. ".png" )
   bg.x,bg.y = halfW,halfH
   bgGroup:insert( bg )

   -- create the miniscreen to display opponent's name and progress
   function createScreen(oppID)
      -- move miniscreen to top right corner
      screenGroup.anchorChildren = true
      screenGroup.anchorX, screenGroup.anchorY = 1,0
      screenGroup.x, screenGroup.y = right - 5, top + 58	--screenGroup.x, screenGroup.y = right - 20, top + 50	--she02052015

      --> Add miniscreen background
      local bg = newImageRectNoDimensions( "art/bg_screen_c" .. _G.player.oppclass .. ".png" ) 
      screenGroup:insert( bg )

    	local tbl = foodData[currentIndex] 
    	local item = tbl.name
    	local state = tbl.state
    	local w, h = tbl.width, tbl.height

       -- plate under food sprite
      spritePlate = newImageRectNoDimensions( "art/foodplate.png" )
      spritePlate.width = 304
      spritePlate.height = 112
      spritePlate.anchorY = 1  --02232015
      spritePlate.y = 64
      spritePlate.x =  bg.x
      spritePlate:scale(.4, .4)
      screenGroup:insert(spritePlate)
          	
      -- food sprite to represent the opponent's progress
      local sprite = newImageRectNoDimensions( "art/food_" ..item..state..".png" )
      sprite.width = w
      sprite.height = h
      sprite.anchorY = 1  -- 02232015
      sprite.x = spritePlate.x
      sprite.y = spritePlate.y - foodData[currentIndex].scrnoffsety
      sprite:scale(.4,.4)
      screenGroup:insert(sprite)
      screenGroup.sprite = sprite

      sprite:toFront()

      -- initial bot food ctr	
      botfoodCtr = mRound( tbl.lbs/5 )
   end

   -- update the food sprite in the miniscreen to show opponent's progress
   function updateSprite( value )
      -- remove previous food sprite
      if screenGroup.sprite then
         screenGroup.sprite:removeSelf()
         screenGroup.sprite = nil
      end

      -- if there are no more food sprites left in the chain, then skip making a new one
      if value == 0 then
         return true
      end
     
      -- get the current food type to update the sprite 
      local tbl = foodData[currentIndex] 
      local name = tbl.name
      local w, h = tbl.width, tbl.height
      local sprite = newImageRectNoDimensions("art/food_"..name..value..".png")
      sprite.width = w
      sprite.height = h
      sprite.anchorY = 1
      sprite.y = spritePlate.y - foodData[currentIndex].scrnoffsety
      sprite:scale(.4,.4)
      screenGroup:insert(sprite)
      screenGroup.sprite = sprite
      
      --> draw food bits BEHIND sprite
      if value == 2 then
	      local spriteBits = newImageRectNoDimensions("art/food_"..name.."6.png")
	      spriteBits.width = w
	      spriteBits.height = h
	      spriteBits.anchorY = 1
	      spriteBits.x = sprite.x
	      spriteBits.y = sprite.y
	      spriteBits:scale(sprite.xScale, sprite.yScale)
	      screenGroup:insert(spriteBits)
	      sprite:toFront()
      end
      
      --update bot food ctr
      botfoodCtr = mRound(tbl.lbs/5)
   end

   local function showAd()
      print( "ad height: " .. adheight )
      print( "showing ad..." )
      transition.to( _G.ads, { time = 300, y = screenH - adheight } )
   end

   local function createUI()	
      --> create text display for the time
      txtTime = display.newText( "0", 0, 0, native.systemFont,28 )
      txtTime:setFillColor(0)
      txtTime.anchorY = 0
      txtTime.x = halfW
      txtTime.y = halfH + 200
      uiGroup:insert( txtTime )
      txtTime.isVisible = false

      --> display status bar
      local mainStatbar = newImageRectNoDimensions( "art/main_statbar.png" )
      mainStatbar.x = mainStatbar.width * 0.5
      mainStatbar.y = mainStatbar.height * 0.5
      uiGroup:insert(mainStatbar)

      --> display progress bar
      mainProgressBar = newImageRectNoDimensions( "art/main_progressbar.png" )
      mainProgressBar.anchorX = 1
      mainProgressBar.x = 70
      mainProgressBar.y = mainStatbar.y + ( mainStatbar.height * 0.5 ) - 4
      uiGroup:insert( mainProgressBar )

      --> display rank bg image
      local mainRankbg = newImageRectNoDimensions( "art/main_rankbg_small.png" )
      mainRankbg.x = mainRankbg.width * 0.4
      mainRankbg.y = mainRankbg.height * 0.4
      uiGroup:insert(mainRankbg)

      --> display rank
      local mainRank = newImageRectNoDimensions( "art/rank".. userrank ..".png" )
      mainRank.x = mainRankbg.x
      mainRank.y = mainRankbg.y
      uiGroup:insert(mainRank)

      --> display player name
      local txtName = display.newText( username, 0, 0, _G.fontname, 18 )
      _G.anchor.CenterLeft( txtName )
      txtName.x = mainRankbg.width - 3
      txtName.y = mainStatbar.y - 2
      txtName:setTextColor( 52/255, 52/255, 52/255 )
      uiGroup:insert(txtName)

      --> display player's thumbnail
      playerthumb = newImageRectNoDimensions( "art/thumbc".. _G.player.class ..".png" )
      playerthumb.x = screenW - ( playerthumb.contentWidth * 0.5 )
      playerthumb.y = playerthumb.contentHeight * 0.5
      uiGroup:insert( playerthumb )

      --> display opponent rankbg
      local oppRankbg = newImageRectNoDimensions( "art/main_rankbg_small.png" )
      oppRankbg:scale(.5,.5)
      oppRankbg.x = screenW - ( oppRankbg.width * 0.5 - 16 )
      oppRankbg.y = mainStatbar.y + ( oppRankbg.height * 0.5 + 10 ) 
      uiGroup:insert(oppRankbg)

      --> display opponent rank
      local opprank = newImageRectNoDimensions( "art/rank".. _G.player.opprank ..".png" )
      opprank.x = oppRankbg.x
      opprank.y = oppRankbg.y
      uiGroup:insert( opprank )

      --> display opponent's name
      local txtOppName = display.newText( _G.player.oppname, 0, 0, _G.fontname, 12 )
      _G.anchor.CenterRight( txtOppName )
      txtOppName.x = oppRankbg.x - 22
      txtOppName.y = oppRankbg.y - 3
      txtOppName:setTextColor( 52/255, 52/255, 52/255 )
      uiGroup:insert( txtOppName )

      --> Enable banner ads ONLY in ranked mode
      if ( gamemode == 3 ) then
         if ( system.getInfo( "environment" ) == "device" ) then
            if ( _G.player.adenabled == 1 ) then
               --local adX, adY = display.screenOriginX, display.contentHeight - 50
               _G.ads.show( "banner", { x = display.screenOriginX, y = screenH } )
               adheight = _G.ads.height()
               --> Add a small delay and wait for ad to show
               timer.performWithDelay( 1000, showAd, 1 )
            end
         end
      end
   end

   local function createPlate()
      --> create plate to place food on top of
      plate = newImageRectNoDimensions( "art/foodplate.png" )
     
      plate.anchorY = 0.5
      plate.x, plate.y = halfW, halfH + 120
      mainGroup:insert(plate)
   end

   function createFood()
      -- get all data related to the currently selected food type
      local tbl = foodData[currentIndex] 
      local name = tbl.name
      local state = tbl.state
      local width = tbl.width
      local height = tbl.height
      
      -- create food sprite
      local food = newImageRectNoDimensions("art/food_"..name..state..".png") 	--,width,height)   --she 02182015
      food.width = width
      food.height = height
      food.anchorY = 1
      food.x = plate.x
      food.y = plate.y + foodData[currentIndex].offsety
      mainGroup:insert(food)

      -- assign newly created object as the current dish
      display.remove( currentDish )
      currentDish = nil
      currentDish = food

      -- get food counter for this phase of the food
      foodCtr = mRound(tbl.lbs/5)

      -- invisible hit object for handling touch events for the food
      hitBox = display.newRect( 0, 0, food.width, food.height )
      _G.anchor.Center( hitBox )
      hitBox.x, hitBox.y = food.x, food.y - ( food.contentHeight * 0.5 )
      hitBox.isVisible = false
      hitBox.alpha = 0.5
      hitBox.isHitTestable = true 
      mainGroup:insert(hitBox)

      --> draw bits of food at the 2nd state
      if foodData[currentIndex].state == 2 then
			local foodbits = newImageRectNoDimensions( "art/food_" .. name .. foodData[currentIndex].max .. ".png" )
			foodbits.width = width
			foodbits.height = height
			foodbits.anchorY = 1
			foodbits.x = food.x
			foodbits.y = food.y
			mainGroup:insert(foodbits)
			--> move food to front after drawing foodbits	
         food:toFront()
	  end
	
   end

	local function setOnePlayerGameWinner()
		if botFinished == true and gameFinished == false then
			print("BOT WINS")
			showResults( false )
		elseif botFinished == false and gameFinished == true then
			print("PLAYER WINS")
			showResults( true )
		end		
	end
	
	--set variables for class abilities
	local function setClassAbilities( class )
		local ppt, pps
		print("set class abilities")
		if class == 1 then
			ppt = 3
			pps = 0
		elseif class == 2 then
			ppt = 1
			pps = 2
		elseif class == 3 then
			ppt = 2
			pps = 0	
		elseif class == 4 then
			ppt = 1
			pps = 0
		elseif class == 5 then
			ppt = 1
			pps = 0
		elseif class == 6 then
			ppt = 2
			pps = 1
		end
		return ppt, pps
	end
	
	--set number of taps based on level
	local function setHowFastBotIs()
		local ppt
		local rank = tonumber(_G.player.rank)
		
		if rank > 20 and rank <= 25 then
			ppt = math.random( 3, 4 ) --> Bot makes 3-4 taps per second
		elseif rank > 15 and rank <= 20 then
			ppt = math.random( 4, 5 )
		elseif rank > 10 and rank <= 15 then
			ppt = math.random( 5, 6 )
		elseif rank > 5 and rank <= 10 then
			ppt = math.random( 6, 7 )
      elseif rank >= 1 and rank <= 5 then
         ppt = math.random( 7, 8 )
		end
		
		return ppt
	end

	local function setUpProgressBar()
		local tbl = foodData[currentIndex]
		--local totalLen
		
		totalLen = screenW - mainProgressBar.x - ( playerthumb.contentWidth - 4 )
		print( "totalLen: ", totalLen )
				
		progressMove = ( totalLen / 5 )
		progressMove = progressMove / ( tbl.lbs / 5 )
		progressMove = math.round( progressMove *10 ) * 0.1
		print( "progressMove: ", progressMove )
	end	
	
	--countdown for bot
	local function updateBot()
		print("updateBot")

		--> update bot food ctr
      botfoodCtr = botfoodCtr - oppclassPPT
		
		print("botfoodCtr = ", botfoodCtr)
		
		if botfoodCtr <= 0 then 
			spritePhase = spritePhase + 1
			--if spritePhase <= 6 then
			
			screenGroup.sprite:removeSelf()
         screenGroup.sprite = nil
         
			if spritePhase > foodData[currentIndex].max-1 then
				print("bot is finished!!")
				--stop timer
				timer.cancel ( timerBotPPT )
				timerBotPPT = nil
            if ( timerBotPPS ~= nil ) then
               timer.cancel( timerBotPPS )
               timerBotPPS = nil
            end
				botFinished = true
				
				display.getCurrentStage():setFocus(nil)
				
				-- remove enterFrame listener
            --Runtime:removeEventListener( "enterFrame", onEnterFrame )
				
				--stop PPS timer
            if timerPPS ~= nil then
               timer.cancel( timerPPS )
               timerPPS = nil
            end
    	        
				setOnePlayerGameWinner()
			else
				updateSprite(spritePhase)	
			end
		end
	end
	
	--start bit player	
	local function startBot()
		--> set bot taps per sec depending on the current rank
		botTapsPerSec = setHowFastBotIs()
		
		--set bot ability
		oppclassPPT, oppclassPPS = setClassAbilities( _G.player.oppclass )
		
		--> Start bot's PPT timer
		timerBotPPT = timer.performWithDelay ( 1000/botTapsPerSec, updateBot, 0 )

      --> Start bot's PPS timer
      if ( oppclassPPS > 0 ) then
         timerBotPPS = timer.performWithDelay ( 1000, updateBot, 0 )
      end
	end

   local function foodplateEmitter( px, py )
      --> Show smoke
      local sheetData1 = { width = 100, height = 100, numFrames = 6, sheetContentWidth = 300, sheetContentHeight = 200 }
      local sheet1 = graphics.newImageSheet( "art/anim_smoke.png", sheetData1 )
      local sequenceData =
      {
          name = "animsmoke",
          start = 1,
          count = 6,
          time = 300,
          loopCount = 1   -- Optional ; default is 0 (loop indefinitely)
      }
      display.remove( smoke )
      smoke = nil
      smoke = display.newSprite( sheet1, sequenceData )
      smoke:setSequence( "animsmoke" )
      smoke:setFillColor( 200/255, 200/255, 200/255 )
      smoke.x = px
      smoke.y = py
      smoke.alpha = 0.5
      if ( display.contentScaleX < 1 ) then --> For Retina only
         smoke.xScale = 0.5
         smoke.yScale = 0.5
      end
      smoke:play()
      sceneGroup:insert( smoke )
      --> Particle emitter
      foodEmitter:setColor( 255/255, 255/255, 255/255 )
      for i = 1, foodparticle.emitterDensity do
         foodEmitter:emit( sceneGroup, px, py )
      end
   end

   -- listener for touch event on food and plate
   function onTouchFood( event )
      -- exit function if game hasn't started or game is finished
      if gameFinished or not gameStarted then
         return true
      end

      local target = event.target
      local phase = event.phase

      --if phase == "began" and currentDish.path then
      if phase == "began" then
         --> Detect multiple touches
         if ( _G.player.class == 4 ) then
            touchCtr = touchCtr + 1
            touches[touchCtr] = tostring( event.id )
            print( event.id )
         end

         -- slightly warp food shape
         currentDish.path.x1 = .5
         currentDish.path.x4 = -.5
         currentDish.path.y1 = 1.5
         currentDish.path.y4 = 1.5

         -- set focus on target for future touch events
         target.hasFocus = true
         display.getCurrentStage():setFocus(target)

   		--play soound
         if ( _G.sfx == 1 ) then
            audio.play( sounds.sfx_chuck )
         end

         --> Show food particles
         foodplateEmitter( event.x, event.y )		
      elseif target.hasFocus then
         --if phase == "ended" and currentDish.path then
         if phase == "ended" then
            local flag = false
            --> Detect multiple touches
            if ( _G.player.class == 4 ) then
               for i = 1, #touches do
                  if ( touches[i] == tostring( event.id ) ) then
                     flag = true
                     touches[i] = ""
                  end
               end
               print( tostring( event.id ) )
               touchCtr = touchCtr - 1
            else
               flag = true
            end

            if ( flag ) then
               --> Add floating text
               display.remove( pptval )
               pptval = nil
               pptval = display.newText( "-" .. classPPT, 0, 0, _G.fontname, 32 )
               pptval:setTextColor( 255/255, 255/255, 255/255 )
               _G.anchor.Center( pptval )
               pptval.x = event.x
               pptval.y = event.y - 10
               sceneGroup:insert( pptval )
               transition.to( pptval, { time = 500, y = pptval.y - 120, alpha = 0 } )

               -- restore food shape
               currentDish.path.x1 = 0
               currentDish.path.x4 = 0
               currentDish.path.y1 = 0
               currentDish.path.y4 = 0

               -- remove focus from target
               target.hasFocus = false
               display.getCurrentStage():setFocus(nil)

      			--decrement food ctr based on class
      			foodCtr = foodCtr - classPPT 
      			
      			--update progress bar
      			mainProgressBar.x = mainProgressBar.x + ( progressMove * classPPT )
               
               if foodCtr <= 0 then -- check if food counter is depleted
                  local tbl = foodData[currentIndex] -- get all data on currently selected food type

                  -- remove previous food sprite
                  currentDish:removeSelf()
                  currentDish = nil

                  -- update current sprite state
                  foodData[currentIndex].state = foodData[currentIndex].state + 1
   			
                  -- check if sprite state has reached the max
                  if foodData[currentIndex].state > foodData[currentIndex].max-1 then
                     print("GAME OVER!")
                     
                     -- update flag for a finished game
                     gameFinished = true
                     
                     -- remove enterFrame listener
                     --Runtime:removeEventListener( "enterFrame", onEnterFrame )
                     
                     --stop PPS timer
                     if timerPPS ~= nil then
   	            		timer.cancel( timerPPS )
   			            timerPPS = nil
                     end
               
                     -- reset state to 1
                     foodData[currentIndex].state = 1
                      
                     --if player finished first before the bot then stop bot 
                     if _G.opponent == 0 then
                        timer.cancel( timerBotPPT )
                        timerBotPPT = nil
                        if ( timerBotPPS ~= nil ) then
                           timer.cancel( timerBotPPS )
                           timerBotPPS = nil
                        end

                        --this means player wins
                        setOnePlayerGameWinner()	   	  
                     end
                  else
                     -- create next phase of the food sprite
                     createFood()
                  end

      				--> Check if opponent is a bot
      				if _G.opponent == 1 then  -- live opponent send progress
                     -- table of progress data
                     local str = {id = "state", value = foodData[currentIndex].state}
              	      if gameFinished then
                        str = {id = "gameOver", value = time}
                     end
                     str = json.encode(str)

                     -- send message to room in order to update the opponent on user's progress and completion
                     appWarpClient.sendChat(str)
      				end				
               end
            end --> if (flag)
         end
      end
   end
   
   function showResults(win)
      --> Leave room to avoid duplicate messages
      if ( _G.opponent == 1 ) then  --> IF live game
         appWarpClient.leaveRoom( roomid )
      end

      -- remove enterFrame listener
      Runtime:removeEventListener( "enterFrame", onEnterFrame )

      --> Disable multitouch for Champ
      if ( _G.player.class == 4 ) then
         system.deactivate( "multitouch" )
      end
      --> Determine free tokens
      local tokensearned = 0
      if ( win ) then
         tokensearned = tokensearned + 10
      end
      --> Cheng gets an extra 10 tokens!
      if ( _G.player.class == 3 ) then
         tokensearned = tokensearned + 10
      end
      --> Reward extra 10 tokens of banner ad is enabled
      if ( _G.player.adenabled == 1 ) then
         tokensearned = tokensearned + 10
      end

      --> Start SFX
      if ( win ) then
         if ( _G.sfx == 1 ) then
            audio.play ( sounds.sfx_reward )
         end
      else
         if ( _G.sfx == 1 ) then
            audio.play ( sounds.sfx_fail )
         end
      end

      --> Log match data
      if ( win ) then
         _G.player.classwin[_G.player.class] = _G.player.classwin[_G.player.class] + 1
         if ( _G.player.class == 1 ) then
            settings.set( 'player.classwin[1]', _G.player.classwin[1] )
         elseif ( _G.player.class == 2 ) then
            settings.set( 'player.classwin[2]', _G.player.classwin[2] )
         elseif ( _G.player.class == 3 ) then
            settings.set( 'player.classwin[3]', _G.player.classwin[3] )
         elseif ( _G.player.class == 4 ) then
            settings.set( 'player.classwin[4]', _G.player.classwin[4] )
         elseif ( _G.player.class == 5 ) then
            settings.set( 'player.classwin[5]', _G.player.classwin[5] )
         elseif ( _G.player.class == 6 ) then
            settings.set( 'player.classwin[6]', _G.player.classwin[6] )
         end
      else
         _G.player.classloss[_G.player.class] = _G.player.classloss[_G.player.class] + 1
         if ( _G.player.class == 1 ) then
            settings.set( 'player.classloss[1]', _G.player.classloss[1] )
         elseif ( _G.player.class == 2 ) then
            settings.set( 'player.classloss[2]', _G.player.classloss[2] )
         elseif ( _G.player.class == 3 ) then
            settings.set( 'player.classloss[3]', _G.player.classloss[3] )
         elseif ( _G.player.class == 4 ) then
            settings.set( 'player.classloss[4]', _G.player.classloss[4] )
         elseif ( _G.player.class == 5 ) then
            settings.set( 'player.classloss[5]', _G.player.classloss[5] )
         elseif ( _G.player.class == 6 ) then
            settings.set( 'player.classloss[6]', _G.player.classloss[6] )
         end
      end

      -- options table for the overlay scene "results.lua"
      local options = {
          isModal = true,
          params = {
              win = win,
              mode = gamemode,
              tokens = tokensearned
          }
      }
      composer.showOverlay( "results", options )
   end

   function checkTime()
      print("checkTime")
      local outcome

      if not gameDecided then -- if game hasn't been decided yet
         
         if gameFinished then -- this player is also done
            gameDecided = true
            if oppScore < time then -- the other player finished first with a shorter time
               outcome = "lost" -- this player lost
            else
               outcome = "won" -- this player won
            end
         else -- this player is not yet done
            local dif = oppScore - time
            print("\n\nDIFFERENCE",dif)
            if dif > 0 and not crunchTime then -- opponent finished with a higher timestamp than this player's current time
               crunchTime = dif * 1000 -- award crunchTime to player to give them time to catch up to the "finished" time of the other player
            else -- the other player finished first with a shorter time
               display.getCurrentStage():setFocus(nil) -- make sure focus is gone from any object
               gameFinished = true
               gameDecided = true
               outcome = "lost" -- this player lost
            end

         end

         if gameDecided then
            -- gameFinished = true
            -- show results of game
            if outcome == "won" then
               showResults(true)
            elseif outcome == "lost" then
               showResults(false)
            end
            if outcome then
               -- table of data related to game status
               --str = {id = "gameStatus", value = outcome}
               local str = '{"id":"gameStatus","value":"' .. outcome .. '"}'
               -- send message to room about the outcome to notify opponent
               appWarpClient.sendChat(str)
            end
         end
      end
   end

   local prevFrameTime, currentFrameTime
   local deltaFrameTime = 0
   local totalTime = 0
   local storedTime = system.getTimer();

   --checks scores for PPS ability
   local function checkPPS()
      --decrement food ctr based on class
      foodCtr = foodCtr - classPPS 
      
      print( "check pps foodCtr = ", foodCtr )
         
      --update progress bar
      mainProgressBar.x = mainProgressBar.x + ( progressMove * classPPS )
            
      --> Add floating text
      display.remove( ppsval )
      ppsval = nil
      ppsval = display.newText( "-" .. classPPS, 0, 0, _G.fontname, 44 )
      ppsval:setTextColor( 255/255, 255/255, 0/255 )
      _G.anchor.Center( ppsval )
      ppsval.x = plate.x
      ppsval.y = plate.y - 50
      sceneGroup:insert( ppsval )
      transition.to( ppsval, { time = 500, y = ppsval.y - 100, alpha = 0 } )

      if foodCtr <= 0 then -- check if food counter is depleted
         local tbl = foodData[currentIndex] -- get all data on currently selected food type

         -- remove previous food sprite
         currentDish:removeSelf()
         currentDish = nil

         -- update current sprite state
         foodData[currentIndex].state = foodData[currentIndex].state + 1
         
         -- check if sprite state has reached the max
         if foodData[currentIndex].state > foodData[currentIndex].max-1 then
            print("GAME OVER!")

            -- update flag for a finished game
            gameFinished = true

            -- remove enterFrame listener
            --Runtime:removeEventListener( "enterFrame", onEnterFrame )

            --stop PPS timer
            timer.cancel( timerPPS )
            timerPPS = nil

            -- reset state to 1
            foodData[currentIndex].state = 1
                   
            --if player finished first before the bot then stop bot 
            if _G.opponent == 0 then
               timer.cancel( timerBotPPT )
               timerBotPPT = nil
               if ( timerBotPPS ~= nil ) then
                  timer.cancel( timerBotPPS )
                  timerBotPPS = nil
               end

               --this means player wins
               setOnePlayerGameWinner()           
            end
    
         else
            -- create next phase of the food sprite
            createFood()
         end

         --> Check if opponent is a bot
         if _G.opponent == 1 then  -- live opponent send progress
            -- table of progress data
            --local str = {id = "state", value = foodData[currentIndex].state}
            local str = '{"id":"state","value":"' .. foodData[currentIndex].state .. '"}'
            if gameFinished then
               --str = {id = "gameOver", value = time}
               str = '{"id":"gameOver","value":"' .. time .. '"}'
            end
            str = json.encode(str)

            -- send message to room in order to update the opponent on user's progress and completion
            appWarpClient.sendChat(str)
         end
      end
   end

   function onEnterFrame( event )
   	--> enable everything after the countdown
   	if actionStarted == false then
	   	--> start bot if no live player
			if _G.opponent == 0 then
	   		print("start bot player")
		   	startBot()
			end
	
			--start timer for player's PPS if value is > 0
         if ( classPPS > 0 ) then
			   timerPPS = timer.performWithDelay ( 1000, checkPPS, 0 )
         end
			
         -- add touch event listener to food (in addition to the plate)
         hitBox:addEventListener( "touch", onTouchFood )
      
			actionStarted = true
   	end
   	-----------------------------
   	   	
   	-- computation for getting a more accurate timestamp that when using a timer object
      local currentTime = system.getTimer()
      local timeDelta = currentTime - storedTime

      local currentFrameTime = currentTime

      if prevFrameTime then 
          deltaFrameTime = currentFrameTime - prevFrameTime
       end 
      prevFrameTime = currentFrameTime 

      totalTime = totalTime + deltaFrameTime
      -- end computation

      -- convert timestamp to hours:minutes:seconds format
      local int = mFloor(totalTime/1000)
      local dec = totalTime/1000 - int
      time = int + dec
      local roundedTime = mFloor(time * 100) /100
      --txtTime.text = data.getTime(roundedTime)

      -- check if player is being given time to reach the "finished" time of opponent 
      -- (crunchTime is given only if opponent finished with a recorded time higher than the current time of the user, which may be caused by delays on the user's side)
      if crunchTime then
         -- reduce crunchTime with elapsed time
         crunchTime = crunchTime - deltaFrameTime
         
         if crunchTime <= 0 then -- check if crunchTime has been used up, which means user has failed to best the other
            crunchTime = nil
            --txtTime.text = oppScore
            time = oppScore + 1 -- just making sure user time is above opponents' for checking
            gameFinished = true -- set game as done
            Runtime:removeEventListener("enterFrame", onEnterFrame) -- remove enterFrame listener
            checkTime() -- compare times
         end
      end
   end

   createUI()
   createPlate()
   createFood()
	
	setUpProgressBar()
   gameStarted = true
	createScreen(_G.player.oppname) -- create miniscreen to show opponent's name and progress  --she02062015
   
	--she 02182015
	--set player class abilities
	classPPT, classPPS = setClassAbilities( _G.player.class )
	print("classPPT = ", classPPT, "classPPS = ", classPPS)

   bgmask = display.newRect( 0, 0, screenW, screenH )
   _G.anchor.Center( bgmask )
   bgmask.x = screenW * 0.5
   bgmask.y = screenH * 0.5
   bgmask:setFillColor( 0/255, 0/255, 0/255, 128/255 )
   sceneGroup:insert( bgmask )

   local function shortDelay()
      local options = {
         isModal = true,
         --effect = "zoomOutIn",
         time = 200
      }
      composer.showOverlay( "countdown", options ) 
   end
	
	--> Delay countdown a bit
   timer.performWithDelay( 500, shortDelay, 1 )
end

--this function is called after the countdown to start the timers and bot
function scene:startActions( event )
   --> Remove bgmask
   bgmask.isVisible = false
   --> Enable multitouch for Champ
   if ( _G.player.class == 4 ) then
      system.activate( "multitouch" )
   end
   --> Allow screen tapping
	Runtime:addEventListener( "enterFrame", onEnterFrame )
end

function scene:hideBannerAd( event )
   _G.ads.hide()
end
	
--she
function scene:stopGame()
	print("stop game")
	appWarpClient.stopGame()
end

--she
function scene:unsubscribeRoom()
	appWarpClient.unsubscribeRoom(roomid)
end

function scene:leaveRoom()
   appWarpClient.leaveRoom(roomid)
end

--she
function scene:disconnect()
	appWarpClient.disconnect()	
end

--she
-- listener for onStopGameDone
function scene.onStopGameDone(resultCode)
	print("onStopGameDone, must leave room", resultCode)
	--scene:leaveRoom()

end

-- listener for onConnectDone
function scene.onConnectDone(resultCode)
   print("onConnectDone",resultCode)
  if(resultCode ~= WarpResponseResultCode.SUCCESS) then -- connection failed
    composer.gotoScene( "title" ) -- go back to previous scene
  end  
end

-- listener for leaveRoom function
function scene.onLeaveRoomDone (resultCode , roomid )  
   print("onLeaveRoomDone", resultCode, roomid)
   if(resultCode == WarpResponseResultCode.SUCCESS) then
      appWarpClient.unsubscribeRoom(roomid) -- successfully left room; unsubscribe to the room
   else
      -- appWarpClient.leaveRoom(roomid)
   end
end

-- listener for unsubscribeRoom function
function scene.onUnsubscribeRoomDone (resultCode , roomid )  
   print("onUnsubscribeRoomDone", resultCode, roomid)
   if(resultCode == WarpResponseResultCode.SUCCESS) then
      composer.gotoScene( "title" ) -- successfully unsubscribed from room; go back to previous scene
   else
      -- appWarpClient.unsubscribeRoom(roomid)
   end
end

-- listener for getLiveRoomInfo function
function scene.onGetLiveRoomInfoDone (resultCode , roomTable )  
   print("onGetLiveRoomInfoDone", resultCode, roomTable)
   print(json.prettify(roomTable))

   if oppName.text ~= "" then
      return true -- exit function if opponent name is already identified
   end

   if(resultCode == WarpResponseResultCode.SUCCESS) then
      local tbl = roomTable.joinedUsersTable
      
      for i=1, #tbl do -- check "joined users" table for user with a different username
         if username ~= tbl[i] then
            oppName.text = tbl[i] -- assign username as opponent's name
         end
      end
   else
      appWarpClient.getLiveRoomInfo(id) -- retry getting room info if unsuccessful
   end
end

-- listener for onUserJoinedRoom notification
function scene.onUserJoinedRoom (user,id)  
   print("onUserJoinedRoom",user,id)
   
   -- stop and empty timer if running
   if tmrRetry then
      timer.cancel(tmrRetry)
      tmrRetry = nil
   end
   -- appWarpClient.getLiveRoomInfo(id)
end

-- listener for onUserLeftRoom notification
function scene.onUserLeftRoom (user,id)  
   print("onUserLeftRoom",username,user,id,roomid)

   if username == user then
      return true -- exit function if user who left room is this user
   end
   if not gameFinished then -- if game is still ongoing when the other user left, give win to remaining user
      oppScore = (time + 1) -- assign a higher recorded time for opponent
      gameFinished = true
      Runtime:removeEventListener( "enterFrame", onEnterFrame )
      checkTime() -- compare times
   else
      -- scene:leaveRoom()
   end
end

function scene.onChatReceived(sender, message, id, isLobby)
   print("onChatReceived",sender,username,message,id,isLobby)
      message = json.decode(message)
      -- print(message)
   
   if type(message) == "table" then
      -- print(json.prettify(message))
      if message.id == "gameStart" then -- game started
--         gameStarted = true
--         createScreen(sender) -- create miniscreen to show opponent's name and progress
--         Runtime:addEventListener("enterFrame", onEnterFrame)
--         cover.hide() -- hide "choosing opponent" screen
      elseif message.id == "gameOver" and sender ~= username then
         oppScore = message.value -- get value from table as opponent's score
         updateSprite(0) -- cleanup food sprite from opponent miniscreen
         checkTime() -- compare times
      elseif message.id == "gameStatus" and sender ~= username then
         if message.value == "lost" then -- opponent lost, show win
            showResults(true)
         else -- opponent won, show loss
            showResults(false)
         end
      elseif message.id == "state" and sender ~= username then
         updateSprite(message.value) -- update food sprite
      end
   end
end

function scene.onDisconnectDone(resultCode)
   if(resultCode == WarpResponseResultCode.SUCCESS) then
      composer.gotoScene( "title"  )
   end  
end

-- "scene:show()"
function scene:show( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is still off screen (but is about to come on screen).
   elseif ( phase == "did" ) then
      -- Called when the scene is now on screen.
      -- Insert code here to make the scene come alive.
      -- Example: start timers, begin animation, play audio, etc.

      -- remove connect scene
      composer.removeScene( "versus" )
	
      --check if opponent is live or bot
      if _G.opponent == 1 then  --live player
         -- add listeners for Appwarp's server request functions and notifications
         appWarpClient.addRequestListener("onConnectDone", scene.onConnectDone)        
         appWarpClient.addRequestListener("onDisconnectDone", scene.onDisconnectDone)
         appWarpClient.addNotificationListener("onChatReceived", scene.onChatReceived)
         appWarpClient.addNotificationListener("onUserJoinedRoom", scene.onUserJoinedRoom)
         appWarpClient.addNotificationListener("onUserLeftRoom", scene.onUserLeftRoom)
         appWarpClient.addRequestListener("onGetLiveRoomInfoDone", scene.onGetLiveRoomInfoDone)
         appWarpClient.addRequestListener("onLeaveRoomDone", scene.onLeaveRoomDone)
         appWarpClient.addRequestListener("onUnsubscribeRoomDone", scene.onUnsubscribeRoomDone)
         -- appWarpClient.addRequestListener("onSendUpdatePeersDone", scene.onSendUpdatePeersDone)
         --she
         appWarpClient.addRequestListener("onStopGameDone", scene.onStopGameDone)
      else --bot
      end      
   end
end

-- "scene:hide()"
function scene:hide( event )

   local sceneGroup = self.view
   local phase = event.phase

   if ( phase == "will" ) then
      -- Called when the scene is on screen (but is about to go off screen).
      -- Insert code here to "pause" the scene.
      -- Example: stop timers, stop animation, stop audio, etc.

      -- remove listeners for Appwarp's server request functions and notifications
      appWarpClient.resetRequestListener("onConnectDone", scene.onConnectDone)        
      appWarpClient.resetRequestListener("onDisconnectDone", scene.onDisconnectDone)
      appWarpClient.resetNotificationListener("onChatReceived", scene.onChatReceived)
      appWarpClient.resetNotificationListener("onUserJoinedRoom", scene.onUserJoinedRoom)
      appWarpClient.resetNotificationListener("onUserLeftRoom", scene.onUserLeftRoom)
      appWarpClient.resetRequestListener("onGetLiveRoomInfoDone", scene.onGetLiveRoomInfoDone)
      appWarpClient.resetRequestListener("onLeaveRoomDone", scene.onLeaveRoomDone)
      appWarpClient.resetRequestListener("onUnsubscribeRoomDone", scene.onUnsubscribeRoomDone)
      
        --she
      appWarpClient.resetRequestListener("onUnsubscribeRoomDone", scene.onUnsubscribeRoomDone)
      
   elseif ( phase == "did" ) then
      -- Called immediately after scene goes off screen.
   end
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
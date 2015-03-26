local composer = require( "composer" )
local scene = composer.newScene()
local cover = require "cover"
local roomid
local foodtype
local gamemode

-- "scene:create()"
function scene:create( event )
	local localGroup = self.view
	local _W = display.contentWidth
	local _H = display.contentHeight
	local mRand = math.random
	local topbar = nil
	local bottombar = nil
	local versus = nil
	local player1 = nil
	local player2 = nil
	local class1 = _G.player.class
	local class2 = _G.player.oppclass
	local char1 = {}
	char1.class = class1
	char1.name = _G.player.name
	char1.bg = nil
	char1.sprite = nil
	local char2 = {}
	char2.class = class2
	char2.name = _G.player.oppname
	char2.bg = nil
	char2.sprite = nil
	local numlines = 50
	local lines1 = {}
	local lines2 = {}

	-- check for params from previous scene
	-- this block of code is meant to be an alternative to using the myData variables, and may be replaced in favor of the latter
	if event.params then
		roomid = event.params.roomid -- ID of room where user has joined and subscribed
		foodtype = event.params.foodtype
		gamemode = event.params.mode
	end

	local background = display.newRect( 0, 0, _W, _H )
	_G.anchor.Center( background )
	background.x = _W * 0.5
	background.y = _H * 0.5
	background:setFillColor( 0/255, 0/255, 0/255 )
	localGroup:insert( background )

	local function showVersus()
		transition.to( versus, { time = 400, xScale = 1.0, yScale = 1.0, alpha = 1.0, rotation = 360 } )
		transition.to( player1, { time = 200, x = _W - 10 } )
		transition.to( player2, { time = 200, x = 10 } )
	end

	local function displayVS()
		timer.performWithDelay( 100, showVersus, 1 )
	end

	local function startSequence()
		transition.to( char1.bg, { time = 200, x = _W * 0.5 } )
		transition.to( char1.sprite, { time = 400, x = ( _W * 0.5 ) - 80 } )

		for i = 1, numlines do
			transition.to( lines1[i].line, { time = mRand( 600 ), x = lines1[i].px1 } )
		end

		transition.to( char2.bg, { time = 200, x = _W * 0.5 } )
		transition.to( char2.sprite, { time = 400, x = ( _W * 0.5 ) + 80 } )

		for i = 1, numlines do
			transition.to( lines2[i].line, { time = mRand( 600 ), x = lines2[i].px1 } )
		end

		transition.to( topbar, { time = 300, x = _W * 0.5 } )
		transition.to( bottombar, { time = 300, x = _W * 0.5, onComplete = displayVS } )
	end

	local function soundoff( whichClass )
		if ( whichClass == 1 ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_booshee )
			end
		elseif ( whichClass == 2 ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_oondoo )
			end
		elseif ( whichClass == 3 ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_cheng )
			end
		elseif ( whichClass == 4 ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_thechamp )
			end
		elseif ( whichClass == 5 ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_glenn )
			end
		elseif ( whichClass == 6 ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_ladymunch )
			end
		elseif ( whichClass == 7 ) then
			if ( _G.sfx == 1 ) then
				audio.play ( sounds.sfx_versus )
			end
		end
	end

	char1.bg = newImageRectNoDimensions( "art/bgc" .. char1.class .. ".png" )
	char1.bg.x = _W + ( _W * 0.5 )
	char1.bg.y = ( _H * 0.5 ) - ( char1.bg.contentHeight * 0.5 )
	localGroup:insert( char1.bg )

	char2.bg = newImageRectNoDimensions( "art/bgc" .. char2.class .. ".png" )
	char2.bg.x = 0 - ( _W * 0.5 )
	char2.bg.y = ( _H * 0.5 ) + ( char2.bg.contentHeight * 0.5 )
	localGroup:insert( char2.bg )

	for i = 1, numlines do
		local y = mRand( _H * 0.5 )
		local px1 = mRand( _W )
		local px2 = mRand( _W )
		lines1[i] = {}
		lines1[i].px1 = px1
		lines1[i].px2 = px2
		lines1[i].line = display.newLine( px1 + _W, y, px2 + _W, y )
		lines1[i].line.alpha = 0.50
		lines1[i].line.strokeWidth = mRand( 3 )
		local flag = mRand( 2 )
		if ( flag == 1 ) then
			lines1[i].line:setStrokeColor( 255/255, 255/255, 255/255 )
		else
			lines1[i].line:setStrokeColor( 0/255, 0/255, 0/255 )
		end
		localGroup:insert( lines1[i].line )
	end

	for i = 1, numlines do
		local y = mRand( _H * 0.5 ) + ( _H * 0.5 )
		local px1 = mRand( _W )
		local px2 = mRand( _W )
		lines2[i] = {}
		lines2[i].px1 = px1
		lines2[i].px2 = px2
		lines2[i].line = display.newLine( 0 - mRand( _W ), y, 0 - mRand( _W ), y )
		lines2[i].line.alpha = 0.50
		lines2[i].line.strokeWidth = mRand( 3 )
		local flag = mRand( 2 )
		if ( flag == 1 ) then
			lines2[i].line:setStrokeColor( 255/255, 255/255, 255/255 )
		else
			lines2[i].line:setStrokeColor( 0/255, 0/255, 0/255 )
		end
		localGroup:insert( lines2[i].line )
	end

	char1.sprite = newImageRectNoDimensions( "art/c" .. char1.class .. ".png" )
	char1.sprite.x = _W + 100 + ( _W * 0.5 ) - 80
	char1.sprite.y = ( _H * 0.5) - ( char1.sprite.contentHeight * 0.5 )
	char1.sprite.xScale = -1
	localGroup:insert( char1.sprite )

	char2.sprite = newImageRectNoDimensions( "art/c" .. char2.class .. ".png" )
	char2.sprite.x = 0 - 100 - ( ( _W * 0.5 ) + 80 )
	char2.sprite.y = ( _H * 0.5 ) + ( char2.sprite.contentHeight * 0.5 )
	localGroup:insert( char2.sprite )

	topbar = newImageRectNoDimensions( "art/topbar.png" )
	topbar.x = _W + ( _W * 0.5 )
	topbar.y = ( _H * 0.5 ) - ( topbar.contentHeight * 0.5 )
	localGroup:insert( topbar )

	bottombar = newImageRectNoDimensions( "art/bottombar.png" )
	bottombar.x = 0 - ( _W * 0.5 )
	bottombar.y = ( _H * 0.5 ) + ( bottombar.contentHeight * 0.5 )
	localGroup:insert( bottombar )

 	player1 = display.newText( char1.name, 0, 0, _G.fontname, 22 )
	player1:setTextColor( 255/255, 249/255, 164/255 )
	_G.anchor.CenterRight( player1 )
	player1.x = -10
	player1.y = topbar.y - 7
	localGroup:insert( player1 )

 	player2 = display.newText( char2.name, 0, 0, _G.fontname, 22 )
	player2:setTextColor( 255/255, 249/255, 164/255 )
	_G.anchor.CenterLeft( player2 )
	player2.x = _W + 10
	player2.y = bottombar.y + 6
	localGroup:insert( player2 )

	versus = newImageRectNoDimensions( "art/versus.png" )
	versus.x = _W * 0.5
	versus.y = _H * 0.5
	versus.xScale = 5.0
	versus.yScale = 5.0
	versus.alpha = 0
	localGroup:insert( versus )

	local function endVoiceOver()
		soundoff( char2.class )
	end

	local function sayVersus()
		soundoff( 7 )
		timer.performWithDelay( 1000, endVoiceOver, 1 )
	end

	local function startVoiceOver()
		soundoff( char1.class )
		timer.performWithDelay( 1200, sayVersus, 1 )
	end

	timer.performWithDelay( 1000, startSequence, 1 )
	timer.performWithDelay( 500, startVoiceOver, 1 )
end

function scene:leaveRoom()
	appWarpClient.leaveRoom(roomid)
end

-- listener for onConnectDone
function scene.onConnectDone(resultCode)
	print("onConnectDone",resultCode)
	if(resultCode ~= WarpResponseResultCode.SUCCESS) then -- connection failed
		--composer.gotoScene( "choose_cards", "fromLeft" ) -- go back to previous scene
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
		--composer.gotoScene( "choose_cards", "fromLeft" ) -- successfully unsubscribed from room; go back to previous scene
	else
		-- appWarpClient.unsubscribeRoom(roomid)
	end
end

-- listener for getLiveRoomInfo function
function scene.onGetLiveRoomInfoDone (resultCode , roomTable )  
	print("onGetLiveRoomInfoDone", resultCode, roomTable)
	--print(json.prettify(roomTable))

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

--[[
	-- stop and empty timer if running
	if tmrRetry then
		timer.cancel(tmrRetry)
		tmrRetry = nil
	end
	]]--
	-- appWarpClient.getLiveRoomInfo(id)
end

-- listener for onUserLeftRoom notification
function scene.onUserLeftRoom (user,id)  
	print("onUserLeftRoom",username,user,id,roomid)

--[[
	if username == user then
		return true -- exit function if user who left room is this user
	end
	if not gameFinished then -- if game is still ongoing when the other user left, give win to remaining user
		oppScore = (time + 1) -- assign a higher recorded time for opponent
		gameFinished = true
		Runtime:removeEventListener("enterFrame", onEnterFrame)
		checkTime() -- compare times
	else
		-- scene:leaveRoom()
	end
	]]--
end

function commenceMatch()
	local options = {
	    effect = "fromRight",
	    time = 300,
	    params = {
	    	roomid = roomid,
	        foodtype = foodtype,
	        mode = gamemode
	    }
	}
	composer.gotoScene( "game", options )
end

function scene.onChatReceived(sender, message, id, isLobby)
	print("onChatReceived",sender,username,message,id,isLobby)
	message = json.decode(message)
	-- print(message)

	if type(message) == "table" then
		-- print(json.prettify(message))
		if message.id == "gameStart" then -- game started
			cover.hide() -- hide "choosing opponent" screen
			timer.performWithDelay( 5000, commenceMatch, 1 )
		elseif message.id == "gameOver" and sender ~= username then
		elseif message.id == "gameStatus" and sender ~= username then
		elseif message.id == "state" and sender ~= username then
		end
	end
end

function scene.onDisconnectDone(resultCode)
	if(resultCode == WarpResponseResultCode.SUCCESS) then
		--composer.gotoScene( "choose_cards", "fromLeft" ) -- go back to previous scene
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
		composer.removeScene("choose_cards")

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

		--she020520105
		print("STARTGAME", _G.startmatch, roomid)
		if _G.opponent == 1 then
			if _G.startmatch then
				local str = '{"id":"gameStart"}'
				appWarpClient.sendChat(str) -- send message to room to notify opponent to start the game
				appWarpClient.getLiveRoomInfo(roomid) -- get room info; use to get the opponent's username if this user joined the room last
			else
				--cover.hide() -- hide "choosing opponent" screen
			end
		else
			cover.hide() -- hide "choosing opponent" screen
			timer.performWithDelay( 5000, commenceMatch, 1 )
		end
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
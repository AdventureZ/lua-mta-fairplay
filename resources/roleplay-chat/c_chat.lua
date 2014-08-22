﻿--[[
	- FairPlay Gaming: Roleplay
	
	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
	
	(c) Copyright 2014 FairPlay Gaming. All rights reserved.
]]

local sx, sy = guiGetScreenSize()
local postGUI = false
local isShowing = true
local messages = {}
local colors = {}
local messagesCounter = {}
local font = "default-bold"

function tablelength(table)
	local count = 0
	for _ in pairs(table) do count = count+1 end
	return count
end

function dxDisplayChatBubbles()
	if (not isShowing) then return end
	if (not exports['roleplay-accounts']:isClientPlaying(localPlayer)) then return end
	--if (exports['roleplay-accounts']:getAccountSetting(localPlayer, "8") == 0) then return end
	for _,player in ipairs(getElementsByType("player")) do
		if (exports['roleplay-accounts']:isClientPlaying(player)) then
			if (messages[player]) then
				for i,v in pairs(messages[player]) do
					if (getElementInterior(localPlayer) == getElementInterior(player)) and (getElementDimension(localPlayer) == getElementDimension(player)) then
						local x, y, z = getPedBonePosition(player, 7)
						local wsx, wsy = getScreenFromWorldPosition(x, y, z+0.3)
						if (type(wsx) == "number" and type(wsy) == "number") then
							local textWidth, textHeight = dxGetTextWidth(v,1.2,font), dxGetFontHeight(1.2,font)
							dxDrawText(v, wsx-(textWidth/2), ((wsy-textHeight)-(10*(i-1)))-(textHeight*(i-1)), sx, sy, colors[player][i],1.2,font)
						end
					end
				end
			end
		end
	end
end

addEvent(":_displayChatBubble_:", true)
addEventHandler(":_displayChatBubble_:", root,
	function(message, player, color)
		if (not messages[player]) then
			messages[player] = {}
		end
		if (not colors[player]) then
			colors[player] = {}
		end
		
		local id = (tablelength(messages[player]) and tablelength(messages[player])+1 or 1)
		messages[player][id] = message
		if not color then
			color = tocolor(255,255,255)
		end
		colors[player][id] = color
		messagesCounter[id] = setTimer(function(player, id)
			if (tablelength(messages[player]) > 1) then
				exports['roleplay-accounts']:condense(messages)
			end
			messages[player][id] = nil
			colors[player][id] = nil
		end, 
		15000,
		1, 
		player,
		id)
	end
)

function getRandomString()
	local message = ""
	for i=1,100 do
		message = message .. math.random(0,9)
	end
	return message
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		addEventHandler("onClientRender", root, dxDisplayChatBubbles)
	end
)

addEvent(":_setChatbubbles_:", true)
addEventHandler(":_setChatbubbles_:", root,
	function(state)
		if (state) then
			isShowing = state
			if (not isShowing) then
				removeEventHandler("onClientRender", root, dxDisplayChatBubbles)
			else
				addEventHandler("onClientRender", root, dxDisplayChatBubbles)
			end
		end
	end
)
--[[
  _           _     _ _                 _                                 _              
 (_)         (_)   | (_)               | |                               (_)             
  _ _ __  ___ _  __| |_  ___  _   _ ___| |__  _   _ _ __ ___   __ _ _ __  _ _______ _ __ 
 | | '_ \/ __| |/ _` | |/ _ \| | | / __| '_ \| | | | '_ ` _ \ / _` | '_ \| |_  / _ \ '__|
 | | | | \__ \ | (_| | | (_) | |_| \__ \ | | | |_| | | | | | | (_| | | | | |/ /  __/ |   
 |_|_| |_|___/_|\__,_|_|\___/ \__,_|___/_| |_|\__,_|_| |_| |_|\__,_|_| |_|_/___\___|_|   
                                                                                         
Version 171904242016
]]--

local MOUSEEVENTF_LEFTDOWN					= 0x0002;
local MOUSEEVENTF_LEFTUP					= 0x0004;
local MOUSEEVENTF_RIGHTDOWN					= 0x0008;
local MOUSEEVENTF_RIGHTUP					= 0x0010;
local KEYEVENTF_KEYUP						= 0x0002;
local humanWalk, humanCast, humanAttack 	= false, false, false
local shouldWalk, shouldCast, shouldAttack 	= nil, {}, nil
local blockEverything = false

local spellCastHumanmizer = {}
OnSpellCast(function(spellProc)
	if spellCastHumanmizer[spellProc.spellID] and os.clock() < spellCastHumanmizer[spellProc.spellID] then 
		BlockCast() 
		return 
	end
	spellCastHumanmizer[spellProc.spellID] = os.clock() + GetLatency() * 0.002 + 0.07
	if spellProc.endPos.x > 0 and spellProc.endPos.z > 0 then
		if not humanCast then
			BlockCast()
			local cPos1 = spellProc.endPos
			local cPos = WorldToScreen(1, cPos1)
			local res = GetResolution()
			if cPos.x > 0 and cPos.y > 0 and cPos.x < res.x and cPos.y < res.y then
				shouldCast = {({[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"})[spellProc.spellID], cPos1}
			end
		else
			humanWalk, humanAttack, humanCast = false, false, false
		end
	end
end)

local old_CastTargetSpell = CastTargetSpell
function CastTargetSpell(target, iSlot)
	if target and target.valid and target.isMe then
		CastSpell(iSlot)
	else
		shouldCast = {iSlot, target}
	end
end

LoadGOSScript(Base64Decode("yolrqx8jYrHWRVxTBPGW1qdGwhOoU3bWOhDsa0lbFCM2AUWtGnzEqoQLzMbU6IC9oxIchUGG6efBi1c20duxfaemATuvRcXWjoLd5bhwJ15p6Yd2b8BzIF1wnhmMv350/+/PzSwtKPMkBz7jqk+5o488rCyaINMF22zejXYsKg3Uckghhn1ocUPS+bhyp2NIhsNJk6ExKV3doXUiQhwLn834GWX7gQtauo/xECBow2gf18H5wTqLtmZC77XPuKPZlUgQTkLpqyPGjuQTKAXxPUsKthVDKeVnPligRZaFefRAySFOZEMCGamNYrMlEgScu/mG9JJfN+xyzCKqCNGReUD0c+2nGbnVP7NzherTCWM="))

local walkAndAttackHumanizer = {
	lastMoveTimer = 0,
	lastAttackTimer = 0,
	lastMovePosition = nil,
	lastAttackPosition = nil
}
OnIssueOrder(function(order)
	if order.flag == 2 then
		local mPos = order.position
		if not walkAndAttackHumanizer.lastMovePosition 
			or (GetDistanceSqr(walkAndAttackHumanizer.lastMovePosition, mPos) > 125 and walkAndAttackHumanizer.lastMoveTimer - GetDistance(walkAndAttackHumanizer.lastMovePosition, mPos)/10000 < os.clock() 
			and (not walkAndAttackHumanizer.lastAttackPosition or walkAndAttackHumanizer.lastAttackTimer + GetDistance(walkAndAttackHumanizer.lastAttackPosition, mPos)/10000 < os.clock()))
			then
			if not humanWalk then
				shouldWalk = mPos
				BlockOrder()
				return
			else
				walkAndAttackHumanizer.lastMoveTimer = os.clock() + math.random(125, 225) / 1000
				walkAndAttackHumanizer.lastMovePosition = mPos
				humanWalk, humanAttack, humanCast = false, false, false
			end
		else
			BlockOrder()
			return
		end
	end
	if order.flag == 3 then
		if walkAndAttackHumanizer.lastAttackTimer < os.clock() then
			if not humanAttack then
				shouldAttack = order.target
				BlockOrder()
				return
			else
				walkAndAttackHumanizer.lastAttackTimer = os.clock() + GetLatency() * 0.002 + 0.1
				walkAndAttackHumanizer.lastAttackPosition = order.target
				walkAndAttackHumanizer.lastMovePosition = nil
				humanWalk, humanAttack, humanCast = false, false, false
			end
		else
			BlockOrder()
			return
		end
	end
end)

local lastMove = 0
OnDraw(function()
	if shouldCast[1] or shouldWalk or shouldAttack then
		if shouldWalk and walkAndAttackHumanizer.lastMoveTimer > os.clock() then return end
		if shouldAttack and walkAndAttackHumanizer.lastAttackTimer > os.clock() then return end
		local mPos = WorldToScreen(1, shouldCast[2] or shouldWalk or shouldAttack)
		local res = GetResolution()
		if mPos.x > 0 and mPos.y > 0 and mPos.x < res.x and mPos.y < res.y then
			local cursorPos = GetCursorPos()
			if GetDistanceSqr(mPos, cursorPos) > 25*25 then
				SetCursorPos(mPos.x, mPos.y)
			end
			if shouldCast[1] ~= nil then
				humanCast = true
				keybd_event(string.byte(shouldCast[1]), MapVirtualKey(string.byte(shouldCast[1]), 0), 0, 0);
				DelayAction(function(iSlot, cPos, mPos)
					keybd_event(string.byte(iSlot), MapVirtualKey(string.byte(iSlot), 0), KEYEVENTF_KEYUP, 0);
					mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
					DelayAction(function(cPos, mPos)
						mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0); 
						if GetDistanceSqr(mPos, cPos) > 25*25 then
							SetCursorPos(cPos.x, cPos.y)
						end
						shouldCast = {}
					end, 0, {cPos, mPos})
				end, 0, {shouldCast[1], cursorPos, mPos})
			else
				humanWalk, humanAttack = shouldWalk ~= nil, shouldAttack ~= nil
				blockEverything = false
				mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
				DelayAction(function()
					mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
					if GetDistanceSqr(mPos, cursorPos) > 25*25 then
						SetCursorPos(cursorPos.x, cursorPos.y)
					end
					shouldAttack, shouldWalk = nil, nil
				end, 0)
			end
		end
	end
end)

--

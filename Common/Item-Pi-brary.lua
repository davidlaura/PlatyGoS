class "Pibry"
if not _G.InspiredLoaded then
	require("Inspired")
end

function Pibry:__init()
	version = GetGameVersion()
	_G.items = {}
	Callback.Add("ProcessPacket", function(p) self:ProcessPacket(p) end)
	self.packets = {}
	if GetGameVersion():sub(1,4) == "6.14" then
		self.packets = Set { 0x0033, 0x0010, 0x0113, 0x0131}
	end
	Callback.Add("Load", function() self:Load() end)
	Callback.Add("GainVision", function() self:GainVision(Object) end)
	self.lastChecked = {}
end

function Pibry:GainVision(Object)
	if Object and Object.type == myHero.type and Object.team ~= myHero.team and (not self.lastChecked[Object.networkID] or self.lastChecked[Object.networkID] < os.clock + 5) then
		_G.items[Object.networkID] = {Object:GetItem(ITEM_1).id, Object:GetItem(ITEM_2).id, Object:GetItem(ITEM_3).id, Object:GetItem(ITEM_4).id, Object:GetItem(ITEM_5).id, Object:GetItem(ITEM_6).id, Object:GetItem(ITEM_7).id}
		self.lastChecked[Object.networkID] = os.clock
	end
end

function Pibry:HasItem(unit, id)
	if _G.items[unit.networkID] then
		for k,Iid in pairs(_G.items[unit.networkID]) do
			if Iid == id then
				return k+5
			end
		end
	end
end

function Set(list)
	local set = {}
	for _, l in ipairs(list) do 
		set[l] = true 
	end
	return set
end

function Pibry:ProcessPacket(p)
	--if not (Set{0x0052,0x011E, 0x00AB, 0x008D, 0x0177, 0x00A3, 0x0015, 0x0140, 0x00D3, 0x00AA, 0x0130,})[p.header] then
	--	print(toHex(p.header))
--	end
	--undo 0x0033
	--buy 0x0010
	--sell 0x0113
	
	if self.packets[p.header] then
		p.pos = 2
		local unit = GetObjByNetID(p:Decode4())
		if not _G.items[unit.networkID] then _G.items[unit.networkID] = {} end
		DelayAction(function() 
		_G.items[unit.networkID] = {unit:GetItem(ITEM_1).id, unit:GetItem(ITEM_2).id, unit:GetItem(ITEM_3).id, unit:GetItem(ITEM_4).id, unit:GetItem(ITEM_5).id, unit:GetItem(ITEM_6).id, unit:GetItem(ITEM_7).id}
		_G.items[myHero.networkID] = {myHero:GetItem(ITEM_1).id, myHero:GetItem(ITEM_2).id, myHero:GetItem(ITEM_3).id, myHero:GetItem(ITEM_4).id, myHero:GetItem(ITEM_5).id, myHero:GetItem(ITEM_6).id, myHero:GetItem(ITEM_7).id}
		end, 0)
	end
end

function toHex(int)
    return "0x"..string.format("%04X ",int)
end

function Pibry:Load()
	for i=1, heroManager.iCount do
		local unit = heroManager:getHero(i)
		if _G.items[unit.networkID] then _G.items[unit.networkID] = {} end
		DelayAction(function() 
		_G.items[unit.networkID] = {unit:GetItem(ITEM_1).id, unit:GetItem(ITEM_2).id, unit:GetItem(ITEM_3).id, unit:GetItem(ITEM_4).id, unit:GetItem(ITEM_5).id, unit:GetItem(ITEM_6).id, unit:GetItem(ITEM_7).id}
		_G.items[myHero.networkID] = {myHero:GetItem(ITEM_1).id, myHero:GetItem(ITEM_2).id, myHero:GetItem(ITEM_3).id, myHero:GetItem(ITEM_4).id, myHero:GetItem(ITEM_5).id, myHero:GetItem(ITEM_6).id, myHero:GetItem(ITEM_7).id}
		end, 0)
	end
end
_G.PibryLoaded = true
_G.Pibry = Pibry()

require("Inspired")

require("OpenPredict")

local summonerNameOne = myHero:GetSpellData(SUMMONER_1).name
local summonerNameTwo = myHero:GetSpellData(SUMMONER_2).name
local Flash = (summonerNameOne:lower():find("summonerflash") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerflash") and SUMMONER_2 or nil))
local Ignite = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))

class "KogMaw"
function KogMaw:__init()

	Q = { delay = 0.25, speed = 1600, width = 80, range = 1175 }
	E = { delay = 0.25, speed = 1200, width = 120, range = 1200 }
	R = { delay = 0.25, speed = math.huge, width = 100, range = function () return 900 + 300*GetCastLevel(myHero,_R) end }
	Q1 = { delay = 0.125, speed = 1600, width = 80, range = 1175 }
	E1 = { delay = 0.125, speed = 1200, width = 120, range = 1200 }
	R1 = { delay = 0.125, speed = math.huge, width = 100, range = function () return 900 + 300*GetCastLevel(myHero,_R) end }

	OnTick(function() self:Tick() end)
 	--OnDraw(function() self:Draw() end)
	OnUpdateBuff(function(Object,BuffName,Stacks) self:UpdateBuff(Object,BuffName,Stacks) end)
	OnRemoveBuff(function(Object,BuffName) self:RemoveBuff(Object, BuffName) end)

	self.spellData = 
	{
	[_Q] = {dmg = function () return 30 + 50*GetCastLevel(myHero,_Q) + 0.5*GetBonusAP(myHero) end, range = 1175, mana = 60},
	[_W] = {dmg = 0, range = 0, mana = 40},
	[_E] = {dmg = function () return 10 + 50*GetCastLevel(myHero,_E) + 0.7*GetBonusAP(myHero) end , mana = function () return 70 + 10*GetCastLevel(myHero,_E)end, range = 1200},
	[_R] = {dmg = function () return 30 + 40*GetCastLevel(myHero,_R) + 0.65*myHero.addDamage + 0.25*GetBonusAP(myHero) end, range = 1800, radius = 100, mana = function () return 50 + 50*self.stacks end },
	}

	self._ = {
		combo = {
			{
				function() 
					return self.doE and self.EREADY and self.Etarget and self:DoMana("Combo", "E")
				end, 
				function() 
					self:CastE(self.Etarget)
				end
			},
			{
				function() 
					return self.doQ and self.QREADY and self.Qtarget and self:DoMana("Combo", "Q")
				end, 
				function() 
					self:CastQ(self.Qtarget)
				end
			},
			{
				function() 
					return self.doR and self.RREADY and self.Rtarget and self:DoMana("Combo", "R")
				end, 
				function() 
					self:CastR(self.Rtarget)
				end
			}
		},
		harass = {
			{
				function() 
					return self.doQ and self.QREADY and self.Qtarget and self:DoMana("Harass", "Q") 
				end,
				function() 
					self:CastQ(self.Qtarget)
				end
			},
			{
				function() 
					return self.doE and self.EREADY and self.Etarget and self:DoMana("Harass", "E") 
				end, 
				function() 
					self:CastE(self.Etarget)
				end
			},
			{
				function() 
					return self.doR and self.RREADY and self.Rtarget and self:DoMana("Harass", "R") 
				end, 
				function() 
					self:CastR(self.Rtarget)
				end
			}
		},
		laneclear = {
			{
				function()
					return self.doQ and self.QREADY and self:DoMana("LaneClear", "Q") 
				end,
				function()
					local BestPos, BestHit = GetFarmPosition(850, 80, 300-myHero.team)
					if BestPos and BestHit and BestHit > 0 then
						CastSkillShot(_Q, BestPos)
					end
				end
			},
			{
				function()
						return self.Config.Keys.LaneClear:Value() and self.doE and self.EREADY and self:DoMana("LaneClear", "E")
				end,
				function()
					for minion in GetMinions{team = 300-myHero.team, distance = 700} do
						self:CastE(minion)
					end
				end
			},
		},
		lasthit = {
			{
				function()
					return self.doQ and self.QREADY and self:DoMana("LastHit", "Q") 
				end,
				function()
					local BestPos, BestHit = GetFarmPosition(850, 80, 300-myHero.team)
					if BestPos and BestHit and BestHit > 0 then
						CastSkillShot(_Q, BestPos)
					end
				end
			},
			{
				function()
						return self.Config.Keys.LastHit:Value() and self.doE and self.EREADY and self:DoMana("LastHit", "E")
				end,
				function()
					for minion in GetMinions{team = 300-myHero.team, distance = 700} do
						if minion.health < myHero:CalcMagicDamage(minion, self.spellData[_E].dmg()) then
							self:CastE(minion)
						end
					end
				end
			},
		},
	}

	self.stacks = 0
	self.lastTick = {}
	self.maxTicks = {}
	do self.____ = {} self._____ = {} for k, v in pairs(self._) do self.____[k] = 0 self._____[k] = #v end end
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("UpdateBuff", function (Object,Buff) self:UpdateBuff(Object, Buff) end)
	Callback.Add("RemoveBuff", function (Object,Buff) self:RemoveBuff(Object, Buff) end)

	self.Config = MenuConfig("PAMKogMaw", "PAM KogMaw")
		self.Config:Menu("Combo", "Combo")
			self.Config.Combo:Boolean("Q", "Use Q", true)
			self.Config.Combo:Boolean("W", "Use W", true)
			self.Config.Combo:Boolean("E", "Use E", true)
			self.Config.Combo:Boolean("R", "Use R", true)
		self.Config:Menu("Harass", "Harass")
			self.Config.Harass:Boolean("Q", "Use Q", true)
			self.Config.Harass:Boolean("W", "Use W", false)
			self.Config.Harass:Boolean("E", "Use E", true)
			self.Config.Harass:Boolean("R", "Use R", false)
		self.Config:Menu("LastHit", "LastHit")
			self.Config.LastHit:Boolean("Q", "Use Q", true)
			self.Config.LastHit:Boolean("W", "Use W", false)
			self.Config.LastHit:Boolean("E", "Use E", true)
			self.Config.LastHit:Boolean("R", "Use R", false)
		self.Config:Menu("LaneClear", "LaneClear")
			self.Config.LaneClear:Boolean("Q", "Use Q", true)
			self.Config.LaneClear:Boolean("W", "Use W", true)
			self.Config.LaneClear:Boolean("E", "Use E", true)
			self.Config.LaneClear:Boolean("R", "Use R", false)
		self.Config:Menu("Killsteal", "Killsteal")
			self.Config.Killsteal:Boolean("Q", "Use Q", true)
			self.Config.Killsteal:Boolean("W", "Use W", false)
			self.Config.Killsteal:Boolean("E", "Use E", true)
			self.Config.Killsteal:Boolean("R", "Use R", false)
			if Ignite then
				self.Config.Killsteal:Boolean("I", "Use Ignite", true)
			end
		self.Config:Menu("Mana", "Mana Settings")
			self.Config.Mana:Menu("Combo", "Combo")
				self.Config.Mana.Combo:Slider("Q", "Q Mana%", 0, 0, 100)
				self.Config.Mana.Combo:Slider("W", "W Mana%", 0, 0, 100)
				self.Config.Mana.Combo:Slider("E", "E Mana%", 0, 0, 100)
				self.Config.Mana.Combo:Slider("R", "R Mana%", 0, 0, 100)
			self.Config.Mana:Menu("Harass", "Harass")
				self.Config.Mana.Harass:Slider("Q", "Q Mana%", 20, 0, 100)
				self.Config.Mana.Harass:Slider("W", "W Mana%", 40, 0, 100)
				self.Config.Mana.Harass:Slider("E", "E Mana%", 20, 0, 100)
				self.Config.Mana.Harass:Slider("R", "R Mana%", 50, 0, 100)
			self.Config.Mana:Menu("LastHit", "LastHit")
				self.Config.Mana.LastHit:Slider("Q", "Q Mana%", 20, 0, 100)
				self.Config.Mana.LastHit:Slider("W", "W Mana%", 50, 0, 100)
				self.Config.Mana.LastHit:Slider("E", "E Mana%", 10, 0, 100)
				self.Config.Mana.LastHit:Slider("R", "R Mana%", 50, 0, 100)
			self.Config.Mana:Menu("LaneClear", "LaneClear")
				self.Config.Mana.LaneClear:Slider("Q", "Q Mana%", 20, 0, 100)
				self.Config.Mana.LaneClear:Slider("W", "W Mana%", 30, 0, 100)
				self.Config.Mana.LaneClear:Slider("E", "E Mana%", 10, 0, 100)
				self.Config.Mana.LaneClear:Slider("R", "R Mana%", 50, 0, 100)
			self.Config.Mana:Menu("Killsteal", "Killsteal")
				self.Config.Mana.Killsteal:Slider("Q", "Q Mana%", 0, 0, 100)
				self.Config.Mana.Killsteal:Slider("W", "W Mana%", 0, 0, 100)
				self.Config.Mana.Killsteal:Slider("E", "E Mana%", 0, 0, 100)
				self.Config.Mana.Killsteal:Slider("R", "R Mana%", 0, 0, 100)
		self.Config:Menu("Draw", "Draws")
				self.Config.Draw:Boolean("DmgDraw", "DmgDraw", true)
			for i = 0,3 do
				local str = {[0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
				self.Config.Draw:Boolean(str[i], "Draw "..str[i], true)
				self.Config.Draw:Boolean(str[i].."oom", "Draw if out of Mana"..str[i], false)
				self.Config.Draw:Boolean(str[i].."cd", "Draw if not ready"..str[i], false)
				self.Config.Draw:ColorPick(str[i].."c", "Draw Color", {255, 25, 155, 175})
			end
		self.Config:Menu("Keys", "Keys")
			self.Config.Keys:KeyBinding("Combo", "Combo", 32)
			self.Config.Keys:KeyBinding("Harass", "Harass", string.byte("C"))
			self.Config.Keys:KeyBinding("LaneClear", "LaneClear", string.byte("V"))
			self.Config.Keys:KeyBinding("LastHit", "LastHit", string.byte("X"))
	self.Qts = TargetSelector(1175,TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
  	self.Ets = TargetSelector(1200,TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
  	self.Rts = TargetSelector(1200,TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
  	self.doQ = false
  	self.doW = false
  	self.doE = false
  	self.doR = false
  	self.hype = false
  	self.currentTime = 0
  	self.colors = { 0xDFFFE258, 0xDF8866F4, 0xDF55F855, 0xDFFF5858 }
  	self.rRange = {[1] = 1200, [2] = 1500, [3] = 1800}
end

function KogMaw:Draw()
	for i,s in pairs({"Q","W","E","R"}) do
		if self.Config.Draw[s]:Value() then

			DrawCircle(myHero.pos, self.spellData[i-1].range, 1, 32, self.Config.Draw[s.."c"]:Value())
		end
	end
	if self.Config.Draw.DmgDraw:Value() then
		for i, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				local barPos = GetHPBarPos(enemy)
				if barPos.x > 0 and barPos.y > 0 then
					local sdmg = {}
					for slot = 0, 3 do
						sdmg[slot] = CanUseSpell(myHero, slot) == 0 and CalcDamage(myHero, enemy, 0, self.spellData[slot].dmg()) or 0
					end
					local mhp = GetMaxHP(enemy)
					local chp = GetCurrentHP(enemy)
					local offset = 103 * (chp/mhp)
					for __, spell in pairs({"Q", "W", "E", "R"}) do
						if sdmg[__-1] > 0 then
							local exit
							local off = 103*(sdmg[__-1]/mhp)
							if off > 103 then
								off = 103
								exit = 0
							end
							local _ = 2*__
							DrawLine(barPos.x+1+offset-off, barPos.y-1, barPos.x+1+offset, barPos.y-1, 5, self.colors[__])
							DrawLine(barPos.x+1+offset-off, barPos.y-1, barPos.x+1+offset-off, barPos.y+10-10*_, 1, self.colors[__])
							DrawText(spell, 11, barPos.x+1+offset-off, barPos.y-5-10*_, self.colors[__])
							DrawText(""..math.round(sdmg[__-1]), 10, barPos.x+4+offset-off, barPos.y+5-10*_, self.colors[__])
							offset = offset - off
							if exit then return end
						end
					end
				end
			end
		end
	end
end

function KogMaw:Tick() 

	self:Checks()
	for _, v in pairs({"Combo", "Harass", "LaneClear", "LastHit"}) do
		if self.Config.Keys[v]:Value() then
		self:Advance(v);break;
		end
	end
	self:Killsteal()
end

function KogMaw:Advance(___)
	do local __ = ___:lower() local function ______(__) if __[1](_) then __[2](___) end end self.____[__] = self.____[__] + 1 if self.____[__] > self._____[__] then self.____[__] = 1 end ______(self._[__][self.____[__]]) end
end

function KogMaw:Checks()
	self.doQ = (self.Config.Keys.Combo:Value() and self.Config.Combo.Q:Value()) or (self.Config.Keys.Harass:Value() and self.Config.Harass.Q:Value()) or (self.Config.Keys.LaneClear:Value() and self.Config.LaneClear.Q:Value()) or (self.Config.Keys.LastHit:Value() and self.Config.LastHit.Q:Value())
	self.doW = (self.Config.Keys.Combo:Value() and self.Config.Combo.W:Value()) or (self.Config.Keys.Harass:Value() and self.Config.Harass.W:Value()) or (self.Config.Keys.LaneClear:Value() and self.Config.LaneClear.W:Value()) or (self.Config.Keys.LastHit:Value() and self.Config.LastHit.W:Value())
	self.doE = (self.Config.Keys.Combo:Value() and self.Config.Combo.E:Value()) or (self.Config.Keys.Harass:Value() and self.Config.Harass.E:Value()) or (self.Config.Keys.LaneClear:Value() and self.Config.LaneClear.E:Value()) or (self.Config.Keys.LastHit:Value() and self.Config.LastHit.E:Value())
	self.doR =  self.Config.Keys.Combo:Value() and self.Config.Combo.R:Value()
	self.QREADY = CanUseSpell(myHero,_Q) == READY
	self.WREADY = CanUseSpell(myHero,_W) == READY
	self.EREADY = CanUseSpell(myHero,_E) == READY
	self.RREADY = CanUseSpell(myHero,_R) == READY
	if Ignite then
		self.IREADY = CanUseSpell(myHero, Ignite) == READY
	end
	self.Qtarget = self.Qts:GetTarget()
  	self.Etarget = self.Ets:GetTarget()
  	self.Rtarget = self.Rts:GetTarget()
  	self.manapc = GetCurrentMana(myHero)/GetMaxMana(myHero)*100
  	self.currentTime = GetGameTimer()
end
 
function GetFarmPosition(range, width)
	local BestPos 
	local BestHit = 0
	local objects = minionManager.objects
	for i, object in pairs(objects) do
		if GetOrigin(object) ~= nil and IsObjectAlive(object) and GetTeam(object) ~= GetTeam(myHero) then
		local hit = CountObjectsNearPos(Vector(object), range, width, objects)
			if hit > BestHit and GetDistanceSqr(Vector(object)) < range * range then
			BestHit = hit
			BestPos = Vector(object)
				if BestHit == #objects then
					break
				end
			end
		end
	end
	return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
local n = 0
	for i, object in pairs(objects) do
		if IsObjectAlive(object) and GetDistanceSqr(pos, Vector(object)) <= radius^2 then
			n = n + 1
		end
	end
	return n
end

function KogMaw:Killsteal()
	local Qdmg = (self.Config.Killsteal.Q:Value() and self.QREADY) and self.spellData[_Q].dmg() or 0
	local Edmg = (self.Config.Killsteal.E:Value() and self.EREADY) and self.spellData[_E].dmg() or 0
	local Rdmg = (self.Config.Killsteal.R:Value() and self.RREADY) and self.spellData[_R].dmg() or 0
	for i, enemy in pairs(GetEnemyHeroes()) do
		local Admg = CalcDamage(myHero, enemy, 0, Qdmg)
		local Cdmg = CalcDamage(myHero, enemy, 0, Edmg)
		local Ddmg = CalcDamage(myHero, enemy, 0, Rdmg)
		local enemyhp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)
		if enemy then
			if enemyhp < Admg then
				self:CastQ(enemy)
			elseif enemyhp < Cdmg then
				self:CastE(enemy)
			elseif enemyhp < Ddmg then
				self:CastR(enemy)
			end
		end
	end
end

function KogMaw:DoMana(mode, spell)
	return self.Config.Mana[mode][spell]:Value() < self.manapc
end


function KogMaw:UpdateBuff(Obj, Buff)
	if Obj and Obj.isMe then
		if Buff.Name == "KogMawBioArcaneBarrage" then
			self.hype = true
		end
	end
end

function KogMaw:RemoveBuff(Obj,Buff)
	if Obj and Obj.isMe then
		if Buff.Name == "KogMawBioArcaneBarrage" then
			self.hype = false
		end
	end
end

function KogMaw:CastQ(unit)
	if self.hype then
		local pI = GetPrediction(unit, Q1)
		if pI and pI.hitChance >= 0.25 and not pI:mCollision(1) then
	   		CastSkillShot(_Q, pI.castPos)
		end
	else 
		local pI = GetPrediction(unit, Q)
		if pI and pI.hitChance >= 0.25 and not pI:mCollision(1) then
	   		CastSkillShot(_Q, pI.castPos)
		end
	end
end

function KogMaw:CastW()
	CastSpell(_W)
end

function KogMaw:CastE(unit)
	if self.hype then
		local pI = GetPrediction(unit, E1)
		if pI and pI.hitChance >= 0.25 then
	   		CastSkillShot(_E, pI.castPos)
		end
	else
		local pI = GetPrediction(unit, E)
		if pI and pI.hitChance >= 0.25 then
	   		CastSkillShot(_E, pI.castPos)
		end
	end
end 

function KogMaw:CastR(unit)
	if self.hype then
		local pI = GetPrediction(unit, R1)
		if pI and pI.hitChance >= 0.25 then
				CastSkillShot(_R, pI.castPos)
		end
	else
		local pI = GetPrediction(unit, R)
		if pI and pI.hitChance >= 0.25 then
				CastSkillShot(_R, pI.castPos)
		end
	end
end

KogMaw()
--PA:Metempsychosis
require("Inspired")

require("OpenPredict")
--require("Item-Pi-brary")

local summonerNameOne = myHero:GetSpellData(SUMMONER_1).name
local summonerNameTwo = myHero:GetSpellData(SUMMONER_2).name
local Flash = (summonerNameOne:lower():find("summonerflash") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerflash") and SUMMONER_2 or nil))
local Ignite = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))

class "Annie"
function Annie:__init()
	self._ = {
		combo = {
			{
				function()
					return self.Rtarget and self.stun and self.RREADY and self.doR and self:DoMana("Combo", "R")
				end, 
				function() 
					self:CastR(self.Rtarget)
				end
			},
			{
				function()
					return self.stacks == 3 and self.EREADY and self.doE and self:DoMana("Combo", "E")
				end, 
				function() 
					self:CastE()
				end
			},
			{
				function()
					return self.Qtarget and self.QREADY and self.doQ and self:DoMana("Combo", "Q")
				end, 
				function() 
					self:CastQ(self.Qtarget)
				end
			},
			{
				function()
					return self.Qtarget and self.WREADY and self.doW and self:DoMana("Combo", "W")
				end, 
				function() 
					self:CastW(self.Qtarget)
				end
			}	
		},
		harass = {
			{
				function() 
					return self.Qtarget and self.WREADY and self.doW and self:DoMana("Harass", "W")
				end, 
				function() 
					self:CastW(self.Qtarget)
				end
			},
			{
				function() 
					return self.Qtarget and self.QREADY and self.doQ and self:DoMana("Harass", "Q")
				end, 
				function() 
					self:CastQ(self.Qtarget)
				end
			}
		},
		lasthit = {
			{
				function() 
					if not self.Config.LastHit.stun:Value() and self.stun == true then return end
					if not PW.isWindingUp then
						if self.QREADY and self.doQ then
							for i, minion in pairs(minionManager.objects) do
								if PW.currentTarget ~= minion and ValidTarget(minion, 625) then
									local predHP = PW:PredictHealth(minion, GetDistance(minion)*0.5+250)
									if predHP > 0 then
										if predHP+5 < CalcDamage(myHero, minion, 0, (self.spellData[_Q].dmg()))then
										self:CastQ(minion)
										end
									end
								end
							end
						end
					end
				end, 
				function() 
				end
			},
		},
		laneclear = {
			{
				function() 
					if not self.Config.LaneClear.stun:Value() and self.stun then
						return
					else
						if not PW.isWindingUp then
							if self.QREADY and self.doQ then
								for i, minion in pairs(minionManager.objects) do
									if minion and PW.currentTarget ~= minion and ValidTarget(minion, 625) then
										local predHP = PW:PredictHealth(minion, GetDistance(minion)*0.5+250)
										if predHP > 0 then
											if predHP+5 < CalcDamage(myHero, minion, 0, (self.spellData[_Q].dmg()))then
											self:CastQ(minion)
											end
										end
									end
								end
							elseif self.WREADY and self.doW then
								local pos, hit = GetFarmPosition(self.spellData[_W].range, 0.3*GetDistance(pos))
								if pos and hit and hit >= 3 then
									CastSkillShot(_W, pos.x, pos.y, pos.z)
								end
							end
						end
					end
				end, 
				function() 
				end
			}
		},
		auto = {
			{
				function() 
					if self.RREADY then
						for i, enemy in pairs(GetEnemyHeroes()) do
							if ValidTarget(enemy,600) then
								local eCount = CountObjectsNearPos(GetOrigin(enemy), self.spellData[_R].range, self.spellData[_R].radius - GetHitBox(enemy), GetEnemyHeroes())
								if eCount >= self.Config.Misc.numult:Value() then
									CastSkillShot(_R,GetOrigin(enemy))
								end
							end
						end
					end
				end, 
				function() 
				end
			},
			{
				function() 
					return self.EREADY and self.Config.Misc.as:Value() and not self.stun
				end, 
				function() 
					CastSpell(_E)
				end
			},
		}
	}
	do self.____ = {} self._____ = {} for k, v in pairs(self._) do self.____[k] = 0 self._____[k] = #v end end


	self.Config = MenuConfig("PA:Metempsychosis Annie", "PAMannie")
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
			self.Config.LastHit:Boolean("E", "Use E", false)
			self.Config.LastHit:Boolean("R", "Use R", false)
			self.Config.LastHit:Boolean("stun", "Lasthit while StunUP", true)
		self.Config:Menu("LaneClear", "LaneClear")
			self.Config.LaneClear:Boolean("Q", "Use Q", true)
			self.Config.LaneClear:Boolean("W", "Use W", true)
			self.Config.LaneClear:Boolean("E", "Use E", false)
			self.Config.LaneClear:Boolean("R", "Use R", false)
			self.Config.LaneClear:Boolean("stun", "LaneClear while StunUP", true)
		self.Config:Menu("Killsteal", "Killsteal")
			self.Config.Killsteal:Boolean("Q", "Use Q", true)
			self.Config.Killsteal:Boolean("W", "Use W", true)
			self.Config.Killsteal:Boolean("E", "Use E", true)
			self.Config.Killsteal:Boolean("R", "Use R", true)
		self.Config:Menu("Misc", "Misc")
			self.Config.Misc:Boolean("autoQ","AutoLastHit with Q", false)
			self.Config.Misc:Boolean("as", "AutoE to Stack", false)
			self.Config.Misc:DropDown("autoult", "AutoUlt", 2, {"Always", "Stun Only"})
			self.Config.Misc:DropDown("numult", "Number of Targets", 3, {"1", "2", "3", "4", "5"})
			self.Config.Misc:SubMenu("ft", "FlashTibbers")
				self.Config.Misc.ft:Boolean("stun", "Only Flash with Stun", true)
				self.Config.Misc.ft:Slider("r", "Range to flash Tibbers", 1000, 600, 1100, 1)
				self.Config.Misc.ft:Slider("n", "Number of Enemies", 3, 1, 5, 1)
		self.Config:Menu("Killsteal", "Killsteal")
			self.Config.Killsteal:Boolean("Q", "Use Q", true)
			self.Config.Killsteal:Boolean("W", "Use W", true)
			self.Config.Killsteal:Boolean("R", "Use R", true)
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
				self.Config.Draw:Menu(str[i],str[i].." Settings")
				self.Config.Draw[str[i]]:Boolean(str[i], "Draw "..str[i], true)
				self.Config.Draw[str[i]]:Boolean(str[i].."oom", "Draw if out of Mana"..str[i], false)
				self.Config.Draw[str[i]]:Boolean(str[i].."cd", "Draw if not ready"..str[i], false)
				self.Config.Draw[str[i]]:ColorPick(str[i].."c", "Draw Color", {255, 25, 155, 175})
			end
		self.Config:Menu("Keys", "Keys")
			self.Config.Keys:KeyBinding("Combo", "Combo", 32)
			self.Config.Keys:KeyBinding("Harass", "Harass", string.byte("C"))
			self.Config.Keys:KeyBinding("LaneClear", "LaneClear", string.byte("V"))
			self.Config.Keys:KeyBinding("LastHit", "LastHit", string.byte("X"))
			self.Config.Keys:KeyBinding("LastHitT", "LastHit Toggle", string.byte("J"), true)
			self.Config.Keys:KeyBinding("ft", "FlashTibbers", string.byte("T"))

	
	W = { delay = 0.25, speed = math.huge, angle = 60, range = 625 }
	R = { delay = 0.25, speed = math.huge, width = 300, range = 600 }
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("UpdateBuff", function (Object,Buff) self:UpdateBuff(Object, Buff) end)
	Callback.Add("RemoveBuff", function (Object,Buff) self:RemoveBuff(Object, Buff) end)
	self.spellData = 
	{
	[_Q] = {dmg = function () return 45 + 35*GetCastLevel(myHero,_Q) + 0.8*GetBonusAP(myHero) end, range = 625, mana = function () return 55 + 5*GetCastLevel(myHero,_Q) end},
	[_W] = {dmg = function () return 25 + 45*GetCastLevel(myHero,_W) + 0.85*GetBonusAP(myHero) end , range = 625, mana = function () return 60 + 10*GetCastLevel(myHero,_W) end},
	[_E] = {dmg = function () return 10 + 10*GetCastLevel(myHero,_E) + 0.2*GetBonusAP(myHero) end , range = 0, mana = 20 },
	[_R] = {dmg = function () return 50 + 125*GetCastLevel(myHero,_R) + 0.8*GetBonusAP(myHero) end, range = 600, radius = 250, mana = 100 },
	}
	self.colors = { 0xDFFFE258, 0xDF8866F4, 0xDF55F855, 0xDFFF5858 }
	self.Qts = TargetSelector(625,TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
  	self.Rts = TargetSelector(700,TARGET_LESS_CAST, DAMAGE_MAGIC, true, false)
	self.stacks = 0
	self.stun = false
end

function Annie:Draw()
	for i,s in pairs({"Q","W","E","R"}) do
		if self.Config.Draw[s][s]:Value() then
			DrawCircle(myHero.pos, self.spellData[i-1].range, 1, 32,self.Config.Draw[s][s.."c"]:Value())
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

function Annie:DoMana(mode, spell)
	return self.Config.Mana[mode][spell]:Value() < self.manapc
end

function Annie:Tick()
	for _, v in pairs({"Combo", "Harass", "LaneClear", "LastHit", "LastHitT"}) do
		if self.Config.Keys[v]:Value() then
		self:Advance(v);break;
		end
	end
	if self.Config.Keys.ft:Value() then
		self:AutoFlashUlt()
	end
	self:Advance("auto")
	self:Checks()
	self:Killsteal()
end

function Annie:Advance(___)
	do local __ = ___:lower() local function ______(__) if __[1](_) then __[2](___) end end self.____[__] = self.____[__] + 1 if self.____[__] > self._____[__] then self.____[__] = 1 end ______(self._[__][self.____[__]]) end
end

function Annie:Checks()
	self.doQ = (self.Config.Keys.Combo:Value() and self.Config.Combo.Q:Value()) or (self.Config.Keys.Harass:Value() and self.Config.Harass.Q:Value()) or (self.Config.Keys.LaneClear:Value() and self.Config.LaneClear.Q:Value()) or (self.Config.Keys.LastHit:Value() and self.Config.LastHit.Q:Value())
	self.doW = (self.Config.Keys.Combo:Value() and self.Config.Combo.W:Value()) or (self.Config.Keys.Harass:Value() and self.Config.Harass.W:Value()) or (self.Config.Keys.LaneClear:Value() and self.Config.LaneClear.W:Value()) or (self.Config.Keys.LastHit:Value() and self.Config.LastHit.W:Value())
	self.doE = (self.Config.Keys.Combo:Value() and self.Config.Combo.E:Value()) or (self.Config.Keys.Harass:Value() and self.Config.Harass.E:Value()) or (self.Config.Keys.LaneClear:Value() and self.Config.LaneClear.E:Value()) or (self.Config.Keys.LastHit:Value() and self.Config.LastHit.E:Value())
	self.doR =  self.Config.Keys.Combo:Value() and self.Config.Combo.R:Value()
	self.QREADY = CanUseSpell(myHero,_Q) == READY
	self.WREADY = CanUseSpell(myHero,_W) == READY
	self.EREADY = CanUseSpell(myHero,_E) == READY
	self.RREADY = CanUseSpell(myHero,_R) == READY and GetCastName(myHero,_R) == "InfernalGuardian"
	self.Qm = self.spellData[_Q].mana()
	self.Wm = self.spellData[_W].mana()
	self.Rm = self.spellData[_R].mana
	self.Cm = GetCurrentMana(myHero)
	self.manapc = GetCurrentMana(myHero)/GetMaxMana(myHero)*100
	if Ignite ~= nil then
	self.IREADY = CanUseSpell(myHero,Ignite) == READY
	end
	self.Qtarget = self.Qts:GetTarget()
  	self.Rtarget = self.Rts:GetTarget()
end

function Annie:AutoFlashUlt()
	MoveToXYZ(GetMousePos())
	if Flash and self.RREADY and (not self.Config.Misc.ft.stun:Value() or self.StunUP) then
		for _, k in pairs(GetEnemyHeroes()) do
			if ValidTarget(k,self.Config.Misc.ft.r:Value()) then
				local e = CountObjectsNearPos(GetOrigin(k), self.Config.Misc.ft.r:Value(), self.spellData[_R].radius - GetHitBox(k), GetEnemyHeroes())
				if e >= self.Config.Misc.ft.n:Value() then
					local pos = GetOrigin(k)
					CastSkillShot(Flash, pos.x, pos.y, pos.z)
					DelayAction(function() self:CastR(k) end, 0.25)
				end
			end
		end
	end
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

function Annie:Killsteal()
	local doQ = self.Config.Killsteal.Q:Value() and self.QREADY
	local doW = self.Config.Killsteal.W:Value() and self.WREADY
	local doR = self.Config.Killsteal.R:Value() and self.RREADY and GetCastName(myHero,_R) == "InfernalGuardian"
	for i,enemy in pairs(GetEnemyHeroes()) do
		local Qdmg = CalcDamage(myHero, enemy, 0, (self.QREADY and self.Cm > self.Qm and self:DoMana("Killsteal", "Q") and doQ) and self.spellData[_Q].dmg() or 0)
		local Wdmg = CalcDamage(myHero, enemy, 0, (self.WREADY and self.Cm > self.Wm and self:DoMana("Killsteal", "W") and doW) and self.spellData[_W].dmg() or 0)
		local Rdmg = CalcDamage(myHero, enemy, 0, (self.RREADY and self.Cm > self.Rm and self:DoMana("Killsteal", "R") and doR) and self.spellData[_R].dmg() or 0)
		local enemyhp = GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy)
		local V625 = ValidTarget(enemy, 625)
		if V625 then
			if enemyhp < Wdmg then
				self:CastW(enemy)
			elseif enemyhp < Qdmg then
				self:CastQ(enemy)
			elseif ValidTarget(enemy, 700) and enemyhp < Rdmg then
				self:CastR(enemy)
			elseif enemyhp < Qdmg + Wdmg and doQ and doW and self.Cm > self.Qm + self.Wm then 
				self:CastW(enemy) DelayAction(function() self:CastQ(enemy) end, 250) 
			elseif enemyhp < Qdmg + Rdmg and doQ and doR and self.Cm > self.Qm + self.Rm then 
				self:CastQ(enemy) DelayAction(function() self:CastR(enemy) end, 250)
			elseif enemyhp < Rdmg + Wdmg and doR and doW and self.Cm > self.Rm + self.Wm then 
				self:CastW(enemy) DelayAction(function() self:CastR(enemy) end, 250)
			elseif enemyhp < Qdmg + Wdmg + Rdmg and doQ and doW and doR and self.Cm > self.Qm + self.Wm + self.Rm then
				self:CastW(enemy) DelayAction(function() self:CastQ(enemy) DelayAction(function() self:CastR(enemy) end, 250) end, 250) 
			end 
		end
	end
end

function Annie:UpdateBuff(Obj, Buff, Stacks)
	if Obj and Obj == myHero then
		if Buff then
			if Buff.Name == "pyromania" then
				self.stacks = Buff.Count
			elseif Buff.Name == "pyromania_particle" then
				self.stun = true
			end
		end
	end
end

function Annie:RemoveBuff(Obj,Buff)
	if Obj and Obj == myHero then
		if Buff then
			if Buff.Name == "pyromania" then
				self.stacks = 0
			elseif Buff.Name == "pyromania_particle" then
				self.stun = false
			end
		end
	end
end
 
function Annie:CastQ(unit)
	CastTargetSpell(unit, _Q)
end

function Annie:CastW(unit)
	local pI = GetConicAOEPrediction(unit, W)
	if pI and pI.hitChance >= 0.25 then
    	CastSkillShot(_W, pI.castPos)
	end
end

function Annie:CastE()
	CastSpell(_E)
end

function Annie:CastR(unit)
	local pI = GetCircularAOEPrediction(unit, R)
	if pI and pI.hitChance >= 0.25 then
    	CastSkillShot(_R, pI.castPos)
	end
end

Annie()

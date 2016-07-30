OnTick(function(myHero) Tick() end)
OnLoad(function(myHero) Load() end)
OnDraw(function(myHero) Draw() end)
OnUpdateBuff(function (unit,Buff) UpdateBuff(unit, Buff) end)
OnRemoveBuff(function (unit,Buff) RemoveBuff(unit, Buff) end)

function Load()
	

	Config = MenuConfig("abc123", "Nivo learned something today - Fiddle")
		Config:Menu("Combo", "Combo1")
			Config.Combo:Boolean("aEnable", "Q is On", true)
			Config.Combo:Boolean("bEnable", "W is On", true)
			Config.Combo:Boolean("cEnable", "E is On", true)
			Config.Combo:Boolean("dEnable", "R is On", true)
		Config:Menu("Harass", "Harass")
			Config.Harass:Boolean("cEnable", "E is On", true)
		Config:Menu("Keys", "Keys")
			Config.Keys:KeyBinding("Combo", "Combo", 32)
			Config.Keys:KeyBinding("Harass", "Harass", string.byte("C"))
			Config.Keys:KeyBinding("LaneClear", "LaneClear", string.byte("V"))
			Config.Keys:KeyBinding("LastHit", "LastHit", string.byte("X"))
		Config:Menu("Drawings", "Drawings")
			Config.Drawings:Boolean("aEnable", "Q is On", true)
			Config.Drawings:Boolean("bEnable", "W is On", true)
			Config.Drawings:Boolean("cEnable", "E is On", true)
			Config.Drawings:Boolean("dEnable", "R is On", true)
end

function UpdateBuff(unit, Buff)
	if unit and unit.isMe and Buff and Buff.Name == "fearmonger_marker" then
		BlockF7Dodge(true)
		IOW.attacksEnabled = false
		IOW.movementEnabled = false
		DelayAction(function() 
			BlockF7Dodge(false)
			IOW.attacksEnabled = true
			IOW.movementEnabled = true
		end, 5)
	end
end
	
function RemoveBuff(unit, Buff)
	if unit and unit.isMe and Buff and Buff.Name == "fearmonger_marker" then
		BlockInput(false)
		BlockF7Dodge(false)
		IOW.attacksEnabled = true
		IOW.movementEnabled = true
	end
end

function Draw()
	if a and Config.Drawings.aEnable:Value() then 
		DrawCircle(myHero.pos, 525, 0 ,3, GoS.Green)
	end
	if b and Config.Drawings.bEnable:Value() then 
		DrawCircle(myHero.pos, 575, 0 ,3, GoS.Green)
	end
	if c and Config.Drawings.cEnable:Value() then
		DrawCircle(myHero.pos, 750, 0 ,3, GoS.Green)
	end
	if d and Config.Drawings.dEnable:Value() then
		DrawCircle(myHero.pos, 800, 0 ,3, GoS.Green)
	end
end


function Tick()
	a = CanUseSpell(myHero, _Q) == READY
	b = CanUseSpell(myHero, _W) == READY
	c = CanUseSpell(myHero, _E) == READY
	d = CanUseSpell(myHero, _R) == READY
	target = GetCurrentTarget()

	if Config.Keys.Combo:Value() then
		Combo()
	elseif Config.Keys.Harass:Value() then
		Harass()
	end
end

function Combo()
	if d and Config.Combo.dEnable:Value() and target and target.distance < 1100 then
		CastSkillShot(_R, target.pos)
	end
	if a and Config.Combo.aEnable:Value() and target and target.distance < 525 then
		CastTargetSpell(target, _Q)
	end
	if c and Config.Combo.cEnable:Value() and target and target.distance < 750 then
		CastTargetSpell(target, _E)
	end
	
	if not a and Config.Combo.bEnable:Value() and not c and not d and b and target and target.distance < 575 then
		CastTargetSpell(target, _W)
	end
end

function Harass()
	if c and Config.Harass.cEnable:Value() and target and target.distance < 750 then
		CastTargetSpell(target, _E)
	end
end

function Killsteal()
	for i, enemy in pairs(GetEnemyHeroes()) do
		local enemyhp = enemy.health
		local eDmg = 45 + 20 * myHero:GetSpellData(2).level + 0.45 * myHero.ap 
		if enemyhp < CalcDamage(myHero, enemy, 0, eDmg) then
			CastTargetSpell(enemy, _E)
		end
	end
end

jps.Dispells={
	["Magic"]={
		"Static Disruption",
		"Consuming Darkness",
		"Emberstrike",
		"Binding Shadows",
		"Divine Reckoning",
		"Static Cling",
		"Pain and Suffering",
		"Cursed Veil",
	},
	["Poison"]={
		"Viscous Poison",
	},
	["Disease"]={
		"Plague of Ages",
	},
	["Curse"]={
		"Curse of Blood",
		"Cursed Bullets",
	},
	["Enrage"]={
		"Enrage",
	},
	["Deathwing"] 	={
		"Plasma incendiaire",
		"Searing Plasma",
	},
	["Yor'sahj"] 	={
		"Corruption profonde",
		"Deep Corruption",
	},
}
jps_DispellOffensive_Eng={
	"Innervate",
	"Power Word: Shield",
	"Ghost Wolf",
	"Power Word: Fortitude",
	"Rejuvenation",
	"Regrowth",
	"Mark of the Wild",
	"Heroism",
	"Bloodlust",
	"Arcane Brilliance",
	"Ice Barrier",
	"Mage Armor",
	"Avenging Wrath",
	"Divine Plea",
}
jps_StunDebuff={
	"Cyclone",
	"Cheap Shot",
	"Kidney Shot",
	"Bash",
	"Concussion Blow",
	"Blind",
	"Pounce",
	"Maim",
	"Fear",
	"Hammer of Justice",
	"Hex",
	"Sap",
	"Psychic Scream",
}
function jps.canDispell(unit,...)
	for _,dtype in pairs(...) do
		if jps.Dispells[dtype] ~= nil then
			for _,spell in pairs(jps.Dispells[dtype]) do
				if ud(unit,spell) then return true end
			end
		end
	end
	return false
end
function jps.FindMeADispelTarget(dispeltypes)
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.canDispell(unit,dispeltypes) then return unit end
	end
end
function jps.isStun()
	for i,j in ipairs(jps_StunDebuff) do
		if UnitDebuff("player",j) then return true end
	end
	return false
end
function jps.MagicDispell(unit)
	if not unit then unit="player" end
	local x8396ce,xbaec64,xe2942a,xa4f7bb,xac89cc,xbae8d0
	local i=1
	x8396ce,_,xbaec64,xe2942a,xa4f7bb,_,xac89cc,xbae8d0,_,_,_=UnitDebuff(unit,i)
	if jps.canHeal(unit) then
		while x8396ce do
			if xa4f7bb=="Magic" then
				return true end
			i=i + 1
			x8396ce,_,xbaec64,xe2942a,xa4f7bb,_,xac89cc,xbae8d0,_,_,_=UnitDebuff(unit,i)
		end
	end
	return false
end
function jps.DiseaseDispell(unit)
	if not unit then unit="player" end
	local x8396ce,xbaec64,xe2942a,xa4f7bb,xac89cc,xbae8d0
	local i=1
	x8396ce,_,xbaec64,xe2942a,xa4f7bb,_,xac89cc,xbae8d0,_,_,_=UnitDebuff(unit,i)
	if jps.canHeal(unit) then
		while x8396ce do
			if xa4f7bb=="Disease" then
				return true end
			i=i + 1
			x8396ce,_,xbaec64,xe2942a,xa4f7bb,_,xac89cc,xbae8d0,_,_,_=UnitDebuff(unit,i)
		end
	end
	return false
end
function jps.DispelMagicTarget()
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.MagicDispell(unit) then return unit end
	end
end
function jps.DispelDiseaseTarget()
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.DiseaseDispell(unit) then return unit end
	end
end
function jps.canDispellOffensive(unit)
	if not unit then return false end
	local i=1
	local x8396ce,_,xbaec64,xe2942a,xa4f7bb,_,xac89cc,xbae8d0,_,_,_=UnitBuff(unit,i)
	if UnitExists(unit)==1 and UnitIsEnemy("player",unit)==1 and UnitCanAttack("player",unit)==1 then
		while x8396ce do
			for k,j in ipairs(jps_DispellOffensive_Eng) do
				if x8396ce==j and xa4f7bb=="Magic" then
					return true end
			end
			i=i + 1
			x8396ce,_,xbaec64,xe2942a,xa4f7bb,_,xac89cc,xbae8d0,_,_,_=UnitBuff(unit,i)
		end
	end
	return false
end
function jps.Cast(spell)
	if not jps.Target then jps.Target="target" end
	if not jps.Casting then jps.LastCast=spell end
	if(getSpellStatus(spell)==0) then return false end
	CastSpellByName(spell,jps.Target)
	jps.LastTarget=jps.Target
	if jps.IconSpell ~= spell then
		jps.set_jps_icon(spell)
		if jps.Debug then write(spell,jps.Target) end
	end
	jps.Target=nil
end
function jps.cooldown(spell)
	local xea2b26,xb85ec3,_=GetSpellCooldown(spell)
	if xea2b26==nil then return 0 end
	local cd=xea2b26+xb85ec3-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end
jps.cd=jps.cooldown
function jps.itemCooldown(item)
	local xea2b26,xb85ec3,_=GetItemCooldown(item)
	local cd=xea2b26+xb85ec3-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end
function jps.glovesCooldown()
	local xea2b26,xb85ec3,enabled=GetInventoryItemCooldown("player",10)
	if enabled==0 then return 9001 end
	local cd=xea2b26+xb85ec3-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end
function jps.petCooldown(index)
	local xea2b26,xb85ec3,_=GetPetActionCooldown(index)
	local cd=xea2b26+xb85ec3-GetTime()-jps.Lag
	if cd < 0 then return 0 end
	return cd
end
function jps_findBuffDebuff()
	for i=1,40 do
		local ID=select(11,UnitBuff("player",i))
		local Name=select(1,UnitBuff("player",i))
		if ID then print("|cff1eff00Buff",i.."="..ID,"="..Name) end
	end
	for i=1,40 do
		local ID=select(11,UnitDebuff("target",i))
		local Name=select(1,UnitDebuff("target",i))
		if ID then print("|cFFFF0000Debuff",i.."="..ID,"="..Name) end
	end
end
function jps.buffID(spellID,unit)
	if unit==nil then unit="player" end
	local i=1
	while(i <=40) do
		local ID=select(11,UnitBuff(unit,i))
		if ID==spellID then return true end
		i=i + 1
	end
	return false
end
function jps.debuffID(spellID,unit)
	if unit==nil then unit="target" end
	local i=1
	while(i <=40) do
		local ID=select(11,UnitDebuff(unit,i))
		if ID==spellID then return true end
		i=i + 1
	end
	return false
end
function jps.myDebuffID(spellID,unit)
	if unit==nil then unit="target" end
	local i=1
	while(i <=40) do
		local ID=select(11,UnitDebuff(unit,i))
		local xbfb8d0=select(8,UnitDebuff(unit,i))
		if ID==spellID and xbfb8d0=="player" then return true end
		i=i + 1
	end
	return false
end
function jps.buff(spell,unit)
	if unit==nil then unit="player" end
	if UnitBuff(unit,spell) then return true end
	return false
end
function jps.debuff(spell,unit)
	if unit==nil then unit="target" end
	if UnitDebuff(unit,spell) then return true end
	return false
end
function jps.myDebuff(spell,unit)
	if unit==nil then unit="target" end
	local _,_,_,_,_,_,xcd91e7,xbfb8d0,_,_,_=UnitDebuff(unit,spell)
	if xbfb8d0~="player" then return false end
	return jps.debuff(spell,unit)
end
function jps.buffDuration(spell,unit)
	if unit==nil then unit="player" end
	local xcd91e7=select(7,UnitBuff(unit,spell))
	local xbfb8d0=select(8,UnitBuff(unit,spell))
	if xbfb8d0 ~= "player" then return 0 end
	if xcd91e7==nil then return 0 end
	local xb85ec3=xcd91e7-GetTime()-jps.Lag
	if xb85ec3 < 0 then return 0 end
	return xb85ec3
end
function jps.notmyBuffDuration(spell,unit)
	if unit==nil then unit="target" end
	local _,_,_,_,_,_,xcd91e7,_,_,_,_=UnitBuff(unit,spell)
	if xcd91e7==nil then return 0 end
	local xb85ec3=xcd91e7-GetTime()-jps.Lag
	if xb85ec3 < 0 then return 0 end
	return xb85ec3
end
function jps.debuffDuration(spell,unit)
	if unit==nil then unit="target" end
	local xcd91e7=select(7,UnitDebuff(unit,spell))
	local xbfb8d0=select(8,UnitDebuff(unit,spell))
	if xbfb8d0~="player" then return 0 end
	if xcd91e7==nil then return 0 end
	local xb85ec3=xcd91e7-GetTime()-jps.Lag
	if xb85ec3 < 0 then return 0 end
	return xb85ec3
end
function jps.notmyDebuffDuration(spell,unit)
	if unit==nil then unit="target" end
	local _,_,_,_,_,_,xcd91e7,xbfb8d0,_,_=UnitDebuff(unit,spell)
	if xcd91e7==nil then return 0 end
	local xb85ec3=xcd91e7-GetTime()-jps.Lag
	if xb85ec3 < 0 then return 0 end
	return xb85ec3
end
function jps.debuffStacks(spell,unit)
	if unit==nil then unit="target" end
	local _,_,_,xe2942a,_,_,_,xbfb8d0,_,_=UnitDebuff(unit,spell)
	if xbfb8d0 ~= "player" then return 0 end
	if xe2942a==nil then xe2942a=0 end
	return xe2942a
end
function jps.buffStacksID(spellID,unit)
	if unit==nil then unit="player" end
	local i=1
	while(i <=40) do
		local ID=select(11,UnitBuff(unit,i))
		local xe2942a=select(4,UnitBuff(unit,i))
		if ID==spellID then
			if xe2942a==nil then xe2942a=0 end
			return xe2942a
		end
		i=i + 1
	end
	return 0
end
function jps.buffStacks(spell,unit)
	if unit==nil then unit="player" end
	local _,_,_,xe2942a,_,_,_,_,_=UnitBuff(unit,spell)
	if xe2942a==nil then xe2942a=0 end
	return xe2942a
end
function jps.bloodlusting()
	return jps.buff("bloodlust") or jps.buff("heroism") or jps.buff("time warp") or jps.buff("ancient hysteria")
end
function jps.castTimeLeft(unit)
	if unit==nil then unit="player" end
	local _,_,_,_,_,xc5b579,_,_,_=UnitCastingInfo(unit)
	if xc5b579==nil then return 0 end
	return (xc5b579-GetTime()*1000)/1000
end
function jps.shouldKick(unit)
	if unit==nil then unit="target" end
	local x760689,_,_,_,_,xc5b579,_,_,unInterruptable=UnitCastingInfo(unit)
	local x625bbe,_,_,_,_,_,_,notInterruptible=UnitChannelInfo(unit)
	if x760689=="Release Aberrations" then return false end
	if x760689 and unInterruptable==false then
		return true
	elseif x625bbe and notInterruptible==false then
		return true
	end
	return false
end
function jps.mana(unit,message)
	if unit==nil then unit="player" end
	if message=="abs" or message=="absolute" then
		return UnitMana(unit)
	else
		return UnitMana(unit)/UnitManaMax(unit)
	end
end
function jps.hp(unit,message)
	if unit==nil then unit="player" end
	if message=="abs" or message=="absolute" then
		return UnitHealth(unit)
	else
		return UnitHealth(unit)/UnitHealthMax(unit)
	end
end
function jps.hpInc(unit,message)
	if unit==nil then unit="player" end
	local hpInc=UnitGetIncomingHeals(unit)
	if not hpInc then hpInc=0 end
	if message=="abs" or message=="absolute" then
		return UnitHealth(unit) + hpInc
	else
		return (UnitHealth(unit) + hpInc)/UnitHealthMax(unit)
	end
end
function jps.checkProfsAndRacials()
	local usables={}
	local moves=
	{
		"lifeblood",
		"berserking",
		"blood fury",
	}
	for _,move in pairs(moves) do
		if GetSpellBookItemInfo(move) then
			table.insert(usables,move)
		end
	end
	return usables
end
function jps.targetTargetTank()
	if jps.buff("bear form","targettarget") then return true end
	if jps.buff("blood presence","targettarget") then return true end
	if jps.buff("righteous fury","targettarget") then return true end
	local _,_,_,_,_,_,_,xbfb8d0,_,_=UnitDebuff("target","Sunder Armor")
	if xbfb8d0 ~= nil then
		if UnitName("targettarget")==xbfb8d0 then return true end end
	return false
end
function jps.groundClick()
	RunMacroText("/console deselectOnClick 0")
	CameraOrSelectOrMoveStart()
	CameraOrSelectOrMoveStop()
	RunMacroText("/console deselectOnClick 1")
end
function jps.faceTarget()
	InteractUnit("target")
end
function jps.moveToTarget()
	InteractUnit("target")
end
function jps.couldBeTank(unit)
	if UnitGroupRolesAssigned(unit)=="TANK" then return true
	elseif jps.buff("righteous fury",unit) then return true
	elseif jps.buff("blood presence",unit) then return true
	elseif jps.buff("bear form",unit) then return true
	end
end
function jps.findMeATank()
	if UnitExists("focus") then return "focus" end
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.couldBeTank(unit) then return unit end
	end
	return "player"
end
function jps.findMeASecondTank(firstTank)
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.couldBeTank(unit) and unit ~= firstTank then return unit end
	end
	return "player"
end
function jps_CalcThreat(unit)
	local y
	if UnitExists(unit.."target") and UnitIsEnemy(unit,unit.."target") then
		y=UnitThreatSituation(unit,unit.."target")
	elseif UnitExists("playertarget") and UnitIsEnemy("player","playertarget") then
		y=UnitThreatSituation(unit,"playertarget")
	else
		y=UnitThreatSituation(unit)
	end
	if not y then y=0 end
	return y
end
function jps.findMeAggroTank()
	for unit,_ in pairs(jps.RaidStatus) do
		if jps_CalcThreat(unit)==3 then return unit end
	end
	return "player"
end
function jps.findMeAggroNotTank(tank1,tank2)
	for unit,_ in pairs(jps.RaidStatus) do
		if jps_CalcThreat(unit)==3 and unit~=tank1 and unit~=tank2 then return unit end
	end
	return "player"
end
function jps.resetTimer(name)
	jps.Timers[name]=nil
end
function jps.createTimer(name,xb85ec3)
	if xb85ec3==nil then xb85ec3=60 end
	jps.Timers[name]=xb85ec3 + GetTime()
end
function jps.checkTimer(name)
	if jps.Timers[name] ~= nil then
		local now=GetTime()
		if jps.Timers[name] < now then
			jps.Timers[name]=nil
			return 0
		else
			return jps.Timers[name] - now
		end
	end
	return 0
end
function jps.useTrinket(id)
	local idConvention=id -1
	local slotName="Trinket"..idConvention.."Slot"
	local xa0cdc9,_,_=GetInventorySlotInfo(slotName)
	local trinketId=GetInventoryItemID("player",xa0cdc9)
	if(not trinketId) then return false end
	if(jps.itemCooldown(trinketId) > 0) then return false end
	local xb8ef09,_=GetItemSpell(trinketId)
	if(not xb8ef09) then return false end
	return {"macro","/use "..xa0cdc9}
end

function jps.getNumberOfPlayersUnderXHealth(health)
	local numUnder = 0
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.hp(unit)<health then 
			numUnder=numUnder+1 
		end
	end
	return numUnder
end

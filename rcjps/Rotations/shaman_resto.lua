function shaman_resto(self)
	
	local spell = nil
	local focus = "focus"
	local me = "player"
	local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()
	local tank = nil
	local playerMana = UnitMana("player")/UnitManaMax("player") * 100

	-- Totems
	local _, fireName, _, _, _ = GetTotemInfo(1)
	local _, earthName, _, _, _ = GetTotemInfo(2)
	local _, waterName, _, _, _ = GetTotemInfo(3)
	local _, airName, _, _, _ = GetTotemInfo(4)

	local haveFireTotem = fireName ~= ""
	local haveEarthTotem = earthName ~= ""
	local haveWaterTotem = waterName ~= ""
	local haveAirTotem = airName ~= ""
	
	tank = jps.findMeATank()
	
	-- Check if we should Purify
	local cleanseTarget = nil
	cleanseTarget = jps.FindMeADispelTarget({"Curse"},{"Magic"})
    

	-- lowest friendly
	local defaultTarget = jps.lowestInRaidStatus()
	local defaultHP = jps.hpInc(defaultTarget)
	

	-- Priority Table
	local spellTable = 
	{
		{ jps.useTrinket(1), 			jps.UseCDs and playerMana < 70 },
		{ jps.useTrinket(2), 			jps.UseCDs and playerMana < 70 },
      	{ jps.DPSRacial,              	jps.UseCDs and defaultHP < 0.5 },

		{ "Fire Elemental Totem", 		jps.UseCDs and not haveFireTotem },
		{ "searing totem",            	jps.UseCDs and not haveFireTotem and (playerMana > 25) },
		{ "Healing Stream Totem",   	not haveWaterTotem and (defaultHP < 0.9 or jps.UseCDs) },
		{ "Mana Tide Totem",   			not haveWaterTotem and playerMana < 28 },
      	{ "Stormlash Totem",        	jps.UseCDs and jps.bloodlusting() },
      	{ {"macro","/use 10"},      	(jps.glovesCooldown() == 0) and jps.UseCDs and (defaultHP < 0.7) },
		
		{ "spiritwalker's grace", 		jps.Moving and defaultHP < 0.5 },
		
		-- Buffs
		{ "water shield", 				not jps.buff("water shield"), me  },
		{ "Earthliving Weapon", 		not mh, me},
		
		-- Set focus to put Earth Shield on focus target
		{ "earth shield",				tank ~= me and not jps.buff("earth shield",tank), tank },

		--Interrupt
		{ "Wind Shear" ,            	jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= 1) , "target" },
		
		-- Heals
		{ "Healing Rain",				IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		-- Left Control key
		{ "chain heal",					IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil, defaultTarget },
		
		{ "Riptide", 					defaultHP < 0.9 and not jps.buff("RipTide"), defaultTarget },
		{ "Healing Surge", 				defaultHP < 0.3, defaultTarget },
		{ "Unleash Elements",			defaultHP < 0.8, defaultTarget },
		{ "Ancestral Swiftness",    	defaultHP < 0.5	},
		{ "Greater Healing Wave", 		jps.buff("Ancestral Swiftness","player") and defaultHP < 0.45, defaultTarget },
		{ "Greater Healing Wave", 		(jps.buff("Unleash life","player") and defaultHP < 0.6) or defaultHP < 0.4, defaultTarget },
		{ "Healing Wave",				(jps.buff("Tidal Waves","player") and defaultHP < 0.9) or defaultHP < 0.75, defaultTarget },
		
		{ "Purify Spirit",				cleanseTarget~=nil, cleanseTarget },
		
		{ "Flame Shock",				not jps.debuff("Flame Shock") and playerMana > 85, Target },
		{ "Lava Burst",					jps.debuff("Flame Shock") and playerMana > 85, Target },
		{ "Lightning Bolt",				},

	}
	
	spell = parseSpellTable(spellTable)
	if spell == "Healing Rain" then jps.groundClick() end

	return spell	
end

function druid_balance(self)
	
	local Energy = UnitPower("player",SPELL_POWER_ECLIPSE)
	local Direction = GetEclipseDirection()
	local targetdistance = CheckInteractDistance("target", 3)
	local targetHealthPercent = UnitHealth("target")/UnitHealthMax("target") * 100
	local myMana = UnitMana("player")/UnitManaMax("player") * 100

	if Direction == "none" then Direction = "sun" end

	-- Buffs
	local sEclipse = jps.buff("eclipse (solar)")
	local lEclipse = jps.buff("eclipse (lunar)")
	local natG = jps.buff("Nature's Grasp")

	-- Dot Durations
	local mfDuration = jps.debuffDuration("moonfire","target") - jps.castTimeLeft()
	local sfDuration = jps.debuffDuration("sunfire","target") - jps.castTimeLeft()
	local focusMF = jps.debuffDuration("moonfire","focus") - jps.castTimeLeft()
	local focusSF = jps.debuffDuration("sunfire","focus") - jps.castTimeLeft()
	local ngDuration = jps.buffDuration("Nature's Grace") - jps.castTimeLeft()
	
	-- Focus dots
	local focusDotting = false

	if UnitExists("focus") then focusDotting = true
	else focusDotting = false end

	if focusDotting == true then
		focusMF = jps.debuffDuration("moonfire","focus")
		focusSF = jps.debuffDuration("sunfire","focus")
	end

	local spellTable =
	{
	    { "Wild Mushroom",              IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ "Moonkin Form", 				not jps.buff("Moonkin Form")},
		
		{ "Heart of the Wild", 			jps.UseCDs },
		{ "Starfall", 					jps.UseCDs },
		{ "Incarnation", 				jps.UseCDs and (sEclipse or lEclipse) },
		{ "Celestial Alignment", 		jps.UseCDs and (not sEclipse and not lEclipse) and (jps.buff("Incarnation: Chosen of Elune") or jps.cooldown("Incarnation") > 10) },
		{ "Nature's Vigil", 			jps.UseCDs and (jps.buff("Incarnation: Chosen of Elune") or jps.buff("Celestial Alignment")) },
		{ "Starsurge", 					jps.buff("shooting stars") and not sEclipse },
		
		{ "Moonfire", 					lEclipse and mfDuration < ngDuration }, -- May need to add in cast time   so... (ngDuration - 2)
		{ "Sunfire", 					sEclipse and sfDuration < ngDuration }, -- May need to add in cast time   so... (ngDuration - 2)

		{ "Moonfire", 					lEclipse and focusMF < ngDuration, "focus" }, -- May need to add in cast time   so... (ngDuration - 2)
		{ "Sunfire", 					sEclipse and focusSF < ngDuration, "focus" }, -- May need to add in cast time   so... (ngDuration - 2)
		
		{ "Hurricane",					jps.MultiTarget and sEclipse and natG },
		{ "Hurricane",					jps.MultiTarget and sEclipse and (myMana > 25) },
		{ "Starfall", 					jps.MultiTarget and targetHealthPercent > 90 },

		{ "Moonfire",					mfDuration < 1.5 },
		{ "Sunfire",					sfDuration < 1.5 },

		{ "Moonfire",					focusMF < 1.5, "focus" },
		{ "Sunfire",					focusSF < 1.5, "focus" },

		{ "Starsurge",					},
		{ "Starfire", 					not jps.Moving and jps.buff("Celestial Alignment") and (jps.buffDuration("Celestial Alignment") > 2.2) },
		{ "Wrath", 						not jps.Moving and jps.buff("Celestial Alignment") and (jps.buffDuration("Celestial Alignment") > 1.8) },
		
		{ "Typhoon", 					targetdistance == 1 and jps.Interrupts },  --CheckInteractDistance("target", 3) == 1 }  == 1 and targetdistance == 1},
		{ "War Stomp", 					targetdistance == 1 and not jps.Moving and jps.Interrupts}, --CheckInteractDistance("target", 3) == 1 }  == 1 }  and (not jps.LastCast=="Typhoon")},

		{ "Starfire", 					not jps.Moving and Direction == "sun" },
		{ "Wrath", 						not jps.Moving and Direction == "moon" },

		{ "Moonfire",					jps.Moving and lEclipse },
		{ "Sunfire",					jps.Moving },
	}
	local spell,target = parseSpellTable(spellTable)
   	
   	return spell
end
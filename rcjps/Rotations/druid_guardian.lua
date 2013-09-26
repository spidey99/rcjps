function druid_guardian(self)
	--[[[
	@rotation Default
	@class druid
	@spec guardian
	@author jpganis, Attip, peanutbird
	@description 
	Guardian Rotation
	]]--
	
	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
	
	local spell = nil
	local target = nil

	-- Other stuff
	local rage = UnitMana("player")
	local lacCount = jps.debuffStacks("lacerate")
	local lacDuration = jps.debuffDuration("lacerate")
	local thrashDuration = jps.debuffDuration("thrash")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100

	local spellTable =
	{
	
		--Shift Target Aggro Grab
		{"wild charge",					IsShiftKeyDown() ~= nil and IsSpellInRange("wild charge", "mouseover") == 1, "mouseover"},
		{"growl",						IsShiftKeyDown() ~= nil and IsSpellInRange("growl", "mouseover") == 1, "mouseover"},
		{"wild charge",					IsShiftKeyDown() ~= nil and IsSpellInRange("wild charge", "target") == 1, "target"},
		{"growl",						IsShiftKeyDown() ~= nil and IsSpellInRange("growl", "target") == 1, "target"},

		-- Buffs
		{"mark of the wild",		 	not jps.buff("Bear Form") and not jps.buff("mark of the wild") , player},
		--{nil,							IsSpellInRange("lacerate","target") ~= 1 },
		{ "Bear Form",					not jps.buff("Bear Form") },

		-- Interrupts
		{"skull bash",					jps.Interrupts and jps.shouldKick() and IsSpellInRange("skull bash", "target") == 1 },
		{"mighty bash",					jps.Interrupts and jps.shouldKick() and IsSpellInRange("mighty bash", "target") == 1 },

		-- Healing / Support
		{"heart of the wild",			IsControlKeyDown() ~= nil},
		{"rejuvenation",				jps.buff("heart of the wild") and hp < 75 and not jps.buff("rejuvenation")},
		{"rejuvenation", 				jps.buff("heart of the wild") and IsControlKeyDown() ~= nil and IsSpellInRange("rejuvenation", "mouseover"), "mouseover" },
		
		-- Defense
		{"barkskin",					hp < 75 and jps.UseCDs},
		{"survival instincts",			hp < 50 and jps.UseCDs},
		{"might of ursoc",				hp < 40 and jps.UseCDs},
		{"frenzied regeneration",		hp < 55 and jps.buff("savage defense")},
		{"savage defense",				hp < 90 and rage >= 60},
		{"renewal", 					hp < 20 and jps.UseCDs },
		{"enrage",						rage <= 10},
		{"Nature's Vigil",				hp < 85 and jps.UseCDs},

		-- Debuff
		{"faerie fire",					not jps.debuff("weakened armor") and IsSpellInRange("faerie fire", "target") == 1 },
		
		-- Offense
		{"berserk",						jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},
		{"Incarnation: Son of Ursoc",	jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},

		-- Multi-Target
		{"thrash",						jps.MultiTarget and not jps.debuff("thrash") and IsSpellInRange("thrash", "target") == 1 },
		{"mangle",						jps.MultiTarget and IsSpellInRange("mangle", "target") == 1 },
		{"swipe",						jps.MultiTarget},

		-- Single Target 
		{"mangle",						jps.buff("berserk") },
		{"maul",						(rage > 30 and hp >= 85 and IsSpellInRange("maul", "target") == 1 or jps.buff("Tooth and Claw") and rage > 60 ) and jps.MultiTarget==false},	
		{"thrash",						not jps.debuff("thrash") or thrashDuration < 3 and IsSpellInRange("thrash", "target") == 1  and jps.MultiTarget==false},
		{"lacerate",					lacCount < 3 or lacDuration < 2 and IsSpellInRange("lacerate", "target") == 1  and jps.MultiTarget==false},
		
		-- Free Time Filler
		{"mangle",						IsSpellInRange("mangle", "target") == 1   and jps.MultiTarget==false},
		{"thrash",						IsSpellInRange("thrash", "target") == 1  and jps.MultiTarget==false},
		{"lacerate",					IsSpellInRange("lacerate", "target") == 1  and jps.MultiTarget==false},
		
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end
function new_dk_blood(self)
	-- Talents:
	-- Tier 1: Roiling Blood
	-- Tier 2: Anti-Magic Zone
	-- Tier 3: Death's Advance
	-- Tier 4: Death Pact
	-- Tier 5: Runic Corruption
	-- Tier 6: Remorseless Winter
	-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell
	
	-- Usage info:
	-- Shift to DnD at mouse
	-- Cooldowns: trinkets, raise dead, dancing rune weapon

	-- Todo:
	-- Left Ctrl to use Army of the Dead

	-- Change: add UnitExists("pet") == nil for raise dead. In some rare situations the cooldown gets reset and it can try to cast it again (last boss in End of Time)

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local targetThreatStatus = UnitThreatSituation("player","target")
	if not targetThreatStatus then targetThreatStatus = 0 end

	local rp = UnitPower("player") 

	local ffDuration = jps.debuffDuration("frost fever")
	local bpDuration = jps.debuffDuration("blood plague")
	local bcStacks = jps.buffStacks("blood charge") --Blood Stacks
	
	local haveGhoul, _, _, _, _ = GetTotemInfo(1) --Information about Ghoul pet
	
	local myHP = jps.hp()
	
	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local ur1 = select(3,GetRuneCooldown(3))
	local ur2 = select(3,GetRuneCooldown(4))
	local fr1 = select(3,GetRuneCooldown(5))
	local fr2 = select(3,GetRuneCooldown(6))
	local one_dr = dr1 or dr2
	local two_dr = dr1 and dr2
	local one_fr = fr1 or fr2
	local two_fr = fr1 and fr2
	local one_ur = ur1 or ur2
	local two_ur = ur1 and ur2
	
	if(jps.MultiTarget) then
		local spellTable =
		{
			-- Blood presence
			{ "blood presence", 		not jps.buff("blood presence") },
			
			{ "blood tap", 				"onCD" },
			
			-- Moved DnD to the top so it will cast immediately
			{ "death and decay",		one_dr or one_ur }, -- GetCurrentKeyBoardFocus: Avoid casting while chat is open and you press shift
			
			{ "army of the dead",		IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- todo
			-- Taunt
			{ "dark command", 			IsShiftKeyDown() ~= nil and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("dark command", "mouseover") == 1, "mouseover"},
			{ "dark command", 			IsShiftKeyDown() ~= nil and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("dark command", "target") == 1, "target"},
			{ "death grip", 			IsShiftKeyDown() ~= nil and jps.LastCast ~= "dark command" and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("death grip", "mouseover") == 1, "mouseover"},
			{ "death grip", 			IsShiftKeyDown() ~= nil and jps.LastCast ~= "dark command" and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("death grip", "target") == 1, "target"},
			{ "gorefiend's grasp", 		jps.LastCast == "death grip" },
			-- Kick
			{ "mind freeze", 			jps.shouldKick() },
			{ "Strangulate", 			jps.shouldKick() and jps.LastCast ~= "mind freeze" },
			
			-- Defensive cooldowns
			{ "Raise Dead", 			myHP < 0.4 and UnitExists("pet") == nil },
			{ "Death Pact", 			myHP < 0.4 and haveGhoul},
			{ "Icebound Fortitude", 	myHP < 0.5 },
			{ "Vampiric Blood", 		myHP < 0.5 },
			{ "Rune Tap", 				myHP < 0.6 },
			-- cds
			{ "Dancing Rune Weapon", 	jps.UseCDs },
	      	{ jps.useTrinket(1),    	jps.UseCds },
	      	{ jps.useTrinket(2),    	jps.UseCds },		
			-- Buffs
			{ "Bone Shield", 			not jps.buff("bone shield") },
			-- Single target
			{ "outbreak",				ffDuration <= 2 or bpDuration <= 2 },
			{ "plague strike", 			not jps.debuff("blood plague") },
			{ "icy touch", 				not jps.debuff("frost fever") },
			{ "pestilence", 			IsShiftKeyDown() ~= nil},
			{ "blood boil", 			"onCD"},
			{ "death strike", 			"onCD"},
			{ "rune strike", 			rp >= 40 },
			{ "horn of winter", 		"onCD"},
			{ "empower rune weapon" , 	not two_dr and not two_fr and not two_ur },
			{ {"macro","/startattack"}, nil, "target" },
	   	}
	else
		local spellTable =
		{
			-- Blood presence
			{ "blood presence", 		not jps.buff("blood presence") },
			
			{ "blood tap", 				"onCD" },
			
			-- Moved DnD to the top so it will cast immediately
			{ "death and decay",		IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- GetCurrentKeyBoardFocus: Avoid casting while chat is open and you press shift
			
			{ "army of the dead",		IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- todo
			-- Taunt
			{ "dark command", 			IsShiftKeyDown() ~= nil and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("dark command", "mouseover") == 1, "mouseover"},
			{ "dark command", 			IsShiftKeyDown() ~= nil and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("dark command", "target") == 1, "target"},
			{ "death grip", 			IsShiftKeyDown() ~= nil and jps.LastCast ~= "dark command" and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("death grip", "mouseover") == 1, "mouseover"},
			{ "death grip", 			IsShiftKeyDown() ~= nil and jps.LastCast ~= "dark command" and (targetThreatStatus ~= 3 or not jps.targetTargetTank()) and IsSpellInRange("death grip", "target") == 1, "target"},
			-- Kick
			{ "mind freeze", 			jps.shouldKick() },
			{ "Strangulate", 			jps.shouldKick() and jps.LastCast ~= "mind freeze" },
			
			-- Defensive cooldowns
			{ "Raise Dead", 			myHP < 0.4 and UnitExists("pet") == nil },
			{ "Death Pact", 			myHP < 0.4 and haveGhoul},
			{ "Icebound Fortitude", 	myHP < 0.5 },
			{ "Vampiric Blood", 		myHP < 0.5 },
			{ "Rune Tap", 				myHP < 0.6 },
			-- cds
			{ "Dancing Rune Weapon", 	jps.UseCDs },
	      	{ jps.useTrinket(1),    	jps.UseCds },
	      	{ jps.useTrinket(2),    	jps.UseCds },		
			-- Buffs
			{ "Bone Shield", 			not jps.buff("bone shield") },
			-- Single target
			{ "outbreak",				ffDuration <= 2 or bpDuration <= 2 },
			{ "plague strike", 			not jps.debuff("blood plague") },
			{ "icy touch", 				not jps.debuff("frost fever") },
			{ "death strike", 			"onCD"},
			{ "blood boil", 			jps.buff("crimson scourge") },
			{ "soul reaper",			jps.hp("target") <= 0.35 },
			{ "heart strike", 			jps.debuff("blood plague") and jps.debuff("frost fever") },
			{ "rune strike", 			rp >= 40 },
			{ "horn of winter", 		"onCD"},
			{ "empower rune weapon" , 	not two_dr and not two_fr and not two_ur },
			{ {"macro","/startattack"}, nil, "target" },
	   	}
	end
	

   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end
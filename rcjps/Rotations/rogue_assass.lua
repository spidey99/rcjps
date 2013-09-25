function rogue_assass(self)
	--jpganis+simcraft
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("rupture")
	local snd_duration = jps.buffDuration("slice and dice")
	local energy = UnitMana("player")
	local thp = UnitHealth("target")/UnitHealthMax("target") * 100

	local spellTable =
	{
	
		-- Use CD Checker
		{ "Preperation",					jps.UseCDs },
		{ "Vanish",							jps.UseCDs and not jps.buff("stealth")},
		{ "Shadow Blades",					jps.UseCDs },
		{ "Vendetta",						jps.UseCds },
		
		-- Finishing Moves 
		{ "Slice and Dice", 				cp >= 2 and not jps.debuff("Slice and Dice", "target") },
		{ "Envenom", 						snd_duration <= 3 }, 
		{ "Rupture",						cp >= 5 },
		{ "Envenom",						cp >= 4 },
	
		-- Multi target Check
		{ "Crimson Tempest",				jps.MultiTarget and not jps.debuff("Crimson Tempest", "target")},
		{ "Fan of Knives", 					jps.MultiTarget 											   },
		
		-- Combo Point Builders 
		{ "Ambush" 								    						   },
		{ "Dispatch",						thp <= 35 or jps.buff("Blindside") },
		{ "Mutilate",						thp >= 36 						   },



	}

	return parseSpellTable( spellTable )
end

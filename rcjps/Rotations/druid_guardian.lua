function druid_guardian(self)

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local rage = UnitMana("player")
	local lacCount = jps.debuffStacks("lacerate")
	local lacDuration = jps.debuffDuration("lacerate")
	local thrashDuration = jps.debuffDuration("thrash")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100

	-- Moves
	local spellTable =
	{
		{nil,						IsSpellInRange("lacerate","target") ~= 1 },
		
		-- Defense
		{"might of ursoc",				hp < 25 },
		{"survival instincts",			hp < 35 },
		{"renewal",           			hp < 45 },
		{"barkskin",					hp < 80 },

		{"frenzied regeneration",		hp < 55 and jps.buff("savage defense")},
		{"savage defense",				hp < 90 and rage >= 70},
		
		{"nature’s swiftness",      	hp < 20 },
		{"healing touch",          		hp < 20 and jps.buff("nature's swiftness") },

		-- Interrupts
		{"skull bash",					jps.Interrupts and jps.shouldKick() },
		{"mighty bash",					jps.Interrupts and jps.shouldKick() },

		-- Trinkets
		--{jps.useTrinket(1),    			hp < 65 and jps.UseCDs },
		--{jps.useTrinket(2),    			hp < 65 and jps.UseCDs },
		
		-- Offense
		{"enrage",						jps.UseCDs and rage <= 10 and hp > 95},
		{"Incarnation: Son of Ursoc",	jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},
		{"berserk",						jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},
		
		-- Multi-Target
		{"thrash",						jps.MultiTarget and not jps.debuff("thrash")},
		{"mangle",						jps.MultiTarget },
		{"swipe",						jps.MultiTarget },
		
		-- Single Target
		{"mangle",						},
		{"maul",						jps.buff("Tooth and Claw") and rage > 60 },	
		{"maul",						rage > 90 and hp >= 85 },	
		{"faerie fire",					not jps.debuff("weakened armor") },
		{"thrash",						not jps.debuff("thrash") or thrashDuration < 3 },
		{"lacerate",					lacCount < 3 or lacDuration < 2 },
		{"faerie fire",					},


      	{ {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end

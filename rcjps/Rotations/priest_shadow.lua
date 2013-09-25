-- Shadow Priest updated for MoP
function priest_shadow(self)

	local swpDuration = jps.debuffDuration("shadow word: pain")
	local vtDuration = jps.debuffDuration("vampiric touch")
	local targetHealth = UnitHealth("target")/UnitHealthMax("target")*100
	local sorbs = UnitPower("player",13)

	local spellTable = {
		{ "shadowform",					not jps.buff("shadowform") },
		{ "inner fire",					not jps.buff("inner fire") },

		{ "renew", 						jps.hp("player") <= 0.20 and not jps.buff("Renew"), "player" },
		{ "Mind Sear",					IsShiftKeyDown() == 1 },

		{ "shadow word: death", 		jps.Moving },
		{ "mind blast",					jps.buff("Divine Insight") and jps.Moving },
		{ "Shadow Word: Pain", 			jps.Moving },

		{ "devouring plague", 			sorbs == 3 and (jps.cooldown("Mind Blast") < 2 or targetHealth < 20) },
		{ "mind blast",					},
		{ "shadow word: pain", 			not jps.myDebuff("shadow word: pain","target") or swpDuration < 1 },
		{ "shadow word: death", 		},
		{ "vampiric touch", 			not jps.myDebuff("vampiric touch","target") or vtDuration < 2 and (not jps.LastCast=="Vampiric Touch") },
		{ "devouring plague", 			sorbs == 3 },
		{ "Halo",						jps.UseCDs },
		{ "mind spike",					jps.buff("surge of darkness") },
		{ "shadowfiend", 				jps.UseCDs },



		{ "Mind Flay",					},

		{ {"macro","/cast mind flay"}, 	jps.cooldown("mind flay") == 0 and not jps.Casting }
	}

	return parseSpellTable( spellTable )
end



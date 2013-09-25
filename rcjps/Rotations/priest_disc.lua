-- Discipline Priest healing
--   by FuzzyHobo

function priest_disc(self)
	--healer
	local playerMana = UnitMana("player") / UnitManaMax("player") * 100
	local tank = nil
	local me = "player"

	-- Tank is focus.
	tank = jps.findMeATank()

    -- Check if we should cleanse
    local cleanseTarget = jps.FindMeADispelTarget({"Magic"},{"Disease"})

	--Default to healing lowest partymember
	local defaultTarget = jps.lowestInRaidStatus()

	--Check that the tank isn't going critical, and that I'm not about to die
    if jps.canHeal(tank) and jps.hpInc(tank) <= 0.2 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	--Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)

	local spellTable =
	{		
		-- AOE heal, use every CD
		{ "Cascade",              	jps.MultiTarget and defaultHP <= 0.90, defaultTarget },
		
		-- Panic spells
		{ "Desperate Prayer",      	jps.UseCDs and jps.hp() <= 0.30, me },
		{ "Void Shift",		       	jps.UseCDs and defaultHP <= 0.05, defaultTarget },
		{ "Pain Suppression",      	jps.UseCDs and jps.hpInc(tank) <= 0.15, tank },
		{ "Pain Suppression",      	jps.UseCDs and jps.hpInc(me) <= 0.25, me },
		
		-- Mana recovery
		{ "Mindbender",            	jps.UseCDs and playerMana <= 60 and UnitCanAttack("player","target") == 1 and UnitIsDeadOrGhost("target") == 0 }, -- TODO: Requires an enemy target
		{ "Shadowfiend",           	jps.UseCDs and playerMana <= 60 and UnitCanAttack("player","target") == 1 and UnitIsDeadOrGhost("target") == 0 }, -- TODO: Requires an enemy target
		{ "Hymn of Hope",          	jps.UseCDs and playerMana <= 40 },
		
		-- Cooldowns
		{ "Power Infusion",        	jps.UseCDs and jps.hpInc(tank) <= 0.50, me },
		{ "Inner Focus",        	jps.UseCDs and jps.hpInc(tank) <= 0.30 },
		{ "Greater Heal",           not jps.Moving and jps.hpInc(tank) <= 0.60, tank },
		{ "Spirit Shell",        	jps.UseCDs and jps.hpInc(tank) <= 0.99 and jps.hpInc(tank) >= 0.80 },
		
		-- Free, instant flash
		{ "Flash Heal",             jps.buff("Surge of Light", me) and defaultHP <= 0.80, defaultTarget },
		
		-- Main rotation
		{ "Renew",  				playerMana > 10 and not jps.buff("Renew", tank) and jps.hpInc(tank) <= 0.95, tank },
		{ "Penance",              	defaultHP <= 0.40, defaultTarget },
		{ "Power Word: Shield",     not jps.buff("Power Word: Shield", defaultTarget) and not jps.debuff("Weakened Soul", defaultTarget) and defaultHP <= 0.90, defaultTarget },
		{ "Prayer of Mending",      jps.hpInc(tank) <= 0.90, tank },
		-- { "Binding Heal",           not jps.Moving and jps.hp() <= 0.50 and defaultHP <= 0.50 and defaultTarget ~= me, defaultTarget },
		{ "Flash Heal",             not jps.Moving and jps.hpInc(tank) <= 0.40, tank },
		{ "Flash Heal",             not jps.Moving and defaultHP <= 0.50 and defaultTarget ~= tank, defaultTarget },
		{ "Greater Heal",           tank ~= nil and not jps.Moving and jps.hpInc(tank) <= 0.60, tank },
		{ "Renew",  				playerMana > 10 and not jps.buff("Renew", defaultTarget) and defaultHP <= 0.90, defaultTarget },
		
		-- Spamming mana recovery
		{ "Power Word: Solace", 	playerMana <= 99 and UnitCanAttack("player","target") == 1 and UnitIsDeadOrGhost("target") == 0 }, -- TODO: Requires an enemy target
		
		-- Dispell
		{ "Purify",                 cleanseTarget~=nil, cleanseTarget },
		
		-- Filler spam heal
		{ "Heal",                   not jps.Moving and jps.hpInc(tank) <= 0.85, tank },
		{ "Heal",                   not jps.Moving and jps.hpInc(defaultTarget) <= 0.70, defaultTarget },
	

		-- Buffs
		{ "Inner Fire",             playerMana >= 50 and not jps.buff("Inner Fire", me), me },
		{ "Inner Will",             playerMana < 50 and not jps.buff("Inner Will", me), me },
		{ "Power Word: Fortitude",  not jps.buff("Power Word: Fortitude", me) or not jps.buff("Power Word: Fortitude", tank), me }, -- Rebuff if tank is missing buff	
	}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
end

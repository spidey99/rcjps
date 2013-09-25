function druid_resto(self)
	-- INFO --
	-- Shift-key to cast Tree of Life
	-- jps.MultiTarget to Wild Regrowth
	-- Use Innervate and Tranquility manually

	--healer
	local playerMana = UnitMana("player")/UnitManaMax("player") * 100
	local tank1 = jps.findMeATank()
	local tank2 = jps.findMeASecondTank(tank1)
	local me = "player"

	-- Check if we should cleanse
	local cleanseTarget = nil

	cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Curse"},{"Magic"})

	--Default to healing lowest partymember
	local defaultTarget = jps.lowestInRaidStatus()
	
	--Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)
	local tank1HP = jps.hpInc(defaultTarget)
	local tank2HP = jps.hpInc(defaultTarget)

	--Check that the tank1 isn't going critical, and that I'm not about to die
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	-- if jps.castTimeLeft(unit) do nothing (tranquility protection)
	if(jps.castTimeLeft(me)) then return nil end

	local spellTable = nil
	--heal chart topper mode for short pulls and low damage fight periods
	if(playerMana > 85) then
		spellTable =
		{

			-- rebirth Ctrl-key + mouseover
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },

			{ "wild growth", 		jps.getNumberOfPlayersUnderXHealth(95)>3, defaultTarget },

		}
	end
	--normal raid heal mode
	if(playerMana < 85 and playerMan > 15) then
		spellTable =
		{

			-- rebirth Ctrl-key + mouseover
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },

			{ "wild growth", 		jps.getNumberOfPlayersUnderXHealth(85)>3, defaultTarget },

		}
	end
	--mana conservation mode
	if(playerMana < 15) then
		spellTable =
		{

			-- rebirth Ctrl-key + mouseover
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },

			{ "wild growth", 		jps.getNumberOfPlayersUnderXHealth(85)>3, defaultTarget },

		}
	end
	

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell

end

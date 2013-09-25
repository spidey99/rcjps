function druid_resto(self)
	local testMode = true
	
	--settings
		-- 0 mana --->conservative_healing_mana_threshold--->**normal raid healing**--->conservative_healing_mana_threshold--->100% mana
	local chart_top_mana_threshold = 85
	local conservative_healing_mana_threshold = 15
	--use trinkets on cd?
	local trink_1_passive = true
	local trink_2_passive = true
	
	local playerMana = UnitMana("player")/UnitManaMax("player") * 100
	--target selections
	local tank1 = jps.findMeATank()
	local tank2 = jps.findMeASecondTank(tank1) --untested should default to player in group or single
	local me = "player"
		-- Check if we should cleanse
	local cleanseTarget =jps.FindMeADispelTarget({"Poison"},{"Curse"},{"Magic"}) --untested
		--Default to healing lowest partymember
	local defaultTarget = jps.lowestInRaidStatus()
		--non tank with aggro or targetted
	local non_tank_aggrod = jps.findMeAggroNotTank(tank1,tank2) --untested
	
	--Get the health of our decided targets
	local defaultHP = jps.hpInc(defaultTarget)
	local tank1HP = jps.hpInc(tank1)
	local tank2HP = jps.hpInc(tank2)

	-- if jps.castTimeLeft(unit) do nothing (tranquility protection)
	if(jps.castTimeLeft(me)) then return nil end --untested

	local spellTable = nil
	--heal chart topper mode for short pulls and low damage fights/periods (based on mana)
	if(playerMana > chart_top_mana_threshold) then --untested
		
		
		
		spellTable =
		{	
		
			--self-preservation checks
			
			--tank checks (doubled for two tank)

			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 }, --untested
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 }, --untested

			{ "wild growth", 		jps.getNumberOfPlayersUnderXHealth(95)>3, defaultTarget }, --untested
			
			{ "tranquility", 		jps.getNumberOfPlayersUnderXHealth(60)>5, defaultTarget }, --untested
			
			{ "force of nature", 	jps.getNumberOfPlayersUnderXHealth(85)>5, defaultTarget }, --untested

		}
	end
	--normal raid heal mode
	if(playerMana < chart_top_mana_threshold and playerMana > conservative_healing_mana_threshold) then --untested
		--check for incoming heals to prevent conflicting heals
		local defaultHpInc=UnitGetIncomingHeals(defaultTarget) --untested
		local tank1HpInc=UnitGetIncomingHeals(tank1) --untested
		local tank1HpInc=UnitGetIncomingHeals(tank2) --untested
		
		--[[ stop casting if conflicting heals ->>>todo
		if(true) then
			SpellStopCasting()
		end
		]]
		
		spellTable =
		{

			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },

			{ "wild growth", 		jps.getNumberOfPlayersUnderXHealth(85)>3, defaultTarget },
			
			{ "tranquility", 		jps.getNumberOfPlayersUnderXHealth(60)>5, me },
			
			{ "force of nature", 	jps.getNumberOfPlayersUnderXHealth(85)>5, defaultTarget },

		}
	end
	--mana conservation mode (leaves mana for tranq and oh shit situations while maintaining lb stacks and using cd's
	if(playerMana < conservative_healing_mana_threshold) then --untested
		--check for incoming heals to prevent conflicting heals
		local defaultHpInc=UnitGetIncomingHeals(defaultTarget)
		local tank1HpInc=UnitGetIncomingHeals(tank1)
		local tank1HpInc=UnitGetIncomingHeals(tank2)
	
		spellTable =
		{

			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },
			{ "rebirth", 			IsControlKeyDown() ~= nil and IsShiftKeyDown() ~= nil and IsSpellInRange("rebirth", tank1), tank1 },

			{ "wild growth", 		jps.getNumberOfPlayersUnderXHealth(85)>3, defaultTarget },

		}
	end
	--testing spelltable
	if(testMode) then --untested
		spellTable =
		{

		}
	end
	

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell

end

function druid_resto(self)
	local testMode = false

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
	--if(jps.castTimeLeft(me)) then return nil end --untested
	
	--
	-- old
	--
	--cds
	
	local swiftmendCD = jps.cooldown("swiftmend") --untested
	local tranquilityCD = jps.cooldown("tranquility")--untested
	
	--buffs
	local ToL = jps.buff("incarnation: tree of life")--untested
	
	--
	--end old
	--

	local spellTable = nil
	--heal chart topper mode for short pulls and low damage fights/periods (based on mana)
	if(playerMana > chart_top_mana_threshold) then --untested



		spellTable =
		{
		
			--Shift for mushroom placement
			{ "wild mushroom",				IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil},
			
			--Ctrl hotw + tranquility or ToL
			{ "heart of the wild",			IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tranquility",				IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tree of life",				IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and

			--self-preservation checks
			{ "barkskin",					jps.hpInc() < 0.50 },
			{ "swiftmend",		    		jps.hpInc(me) <= 0.75 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0), me },
			
			{ "regrowth",					jps.buff("clearcasting") and jps.hpInc(me) < 0.80 or jps.hpInc(me) < 0.70, me },
			
			{ "rejuvenation",				jps.hpInc(me) <= 0.99 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			
			--tank checks (doubled for two tank)
			--{ "rebirth", 					tank1hp < 1 and IsSpellInRange("rebirth", tank1), tank1 }, --untested
			--{ "rebirth", 					tank2hp < 1 and IsSpellInRange("rebirth", tank2), tank2 }, --untested
			{ "ironbark", 					jps.hpInc(tank1) < 0.75, tank1 },
			{ "ironbark", 					jps.hpInc(tank2) < 0.75, tank2 },
			{ "lifebloom",					(jps.buffDuration("lifebloom",jps.findMeAggroTank()) < 1.5 or jps.buffStacks("lifebloom",jps.findMeAggroTank()) < 3), jps.findMeAggroTank() },
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.75 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.75 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
			{ "regrowth",					jps.buff("clearcasting") and (jps.hpInc(tank1) < 0.80 or jps.buffDuration("lifebloom",tank1) < 5) or jps.hpInc(tank1) < 0.50, tank1 },
			{ "regrowth",					jps.buff("clearcasting") and (jps.hpInc(tank2) < 0.80 or jps.buffDuration("lifebloom",tank2) < 5) or jps.hpInc(tank2) < 0.50, tank2 },
			{ "rejuvenation",				jps.hpInc(tank1) <= 0.99 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.hpInc(tank2) <= 0.99 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
			
			-- CDs
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.65 },
			{ "healing touch", 				jps.buff("nature's swiftness") and defaultHP < 0.70, defaultTarget },--ns use moved for guaranteed use
				--switfmend use
			--needs testing{ "rejuvenation",				swiftmendCD <= 1 and defaultHP < 0.50 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 2), defaultTarget },--needs testing
			{ "swiftmend",					defaultHP < 0.70 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
				--healing/def cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(2),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
			--aoe heals
			{ "wild growth", 				jps.countInRaidStatus(95)>3, defaultTarget }, --untested
			--{ "heart of the wild",			jps.countInRaidStatus(60)>5},
			--{ "tranquility", 				jps.countInRaidStatus(60)>5 or jps.buff("heart of the wild") }, --untested
			{ "force of nature", 			jps.countInRaidStatus(85)>5, defaultTarget },
				
			--Decurse
			{ "nature's cure",				cleanseTarget~=nil, cleanseTarget },

			--default healing
			{ "regrowth",					defaultHP < 0.60 or (jps.buff("clearcasting") and defaultHP < 0.75), defaultTarget },
			{ "swiftmend",					defaultHP < 0.75 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			{ "rejuvenation",				defaultHP < 0.85 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			

		}
	end
	--normal raid heal mode
	if(playerMana < chart_top_mana_threshold and playerMana > conservative_healing_mana_threshold) then --untested
		--[[ stop casting if conflicting heals ->>>todo
		if(true) then
		SpellStopCasting()
		end
		]]

		spellTable =
		{
		--Shift for mushroom placement
			{ "wild mushroom",				IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil},
			
			--Ctrl hotw + tranquility or ToL
			{ "heart of the wild",			IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tranquility",				IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tree of life",				IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and

			--self-preservation checks
			{ "barkskin",					jps.hpInc() < 0.65 },
			{ "swiftmend",		    		jps.hpInc(me) <= 0.65 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0), me },
			
			{ "regrowth",					jps.buff("clearcasting") and jps.hpInc(me) < 0.70 or jps.hpInc(me) < 0.55, me },
			
			{ "rejuvenation",				jps.hpInc(me) <= 0.85 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			
			--tank checks (doubled for two tank)
			--{ "rebirth", 					tank1hp = 0 and IsSpellInRange("rebirth", tank1), tank1 }, --untested
			--{ "rebirth", 					tank2hp = 0 and IsSpellInRange("rebirth", tank2), tank2 }, --untested
			{ "ironbark", 					jps.hpInc(tank1) < 0.65, tank1 },
			{ "ironbark", 					jps.hpInc(tank2) < 0.65, tank2 },
			{ "lifebloom",					(jps.buffDuration("lifebloom",jps.findMeAggroTank()) < 1.5 or jps.buffStacks("lifebloom",jps.findMeAggroTank()) < 3), jps.findMeAggroTank() },
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.65 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.65 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
			{ "regrowth",					jps.buff("clearcasting") and (jps.hpInc(tank1) < 0.70 or jps.buffDuration("lifebloom",tank1) < 5) or jps.hpInc(tank1) < 0.50, tank1 },
			{ "regrowth",					jps.buff("clearcasting") and (jps.hpInc(tank2) < 0.70 or jps.buffDuration("lifebloom",tank2) < 5) or jps.hpInc(tank2) < 0.50, tank2 },
			{ "rejuvenation",				jps.hpInc(tank1) <= 0.99 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.hpInc(tank2) <= 0.99 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
			
			-- CDs
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.40 },
			{ "healing touch", 				jps.buff("nature's swiftness") and defaultHP < 0.45, defaultTarget },--ns use moved for guaranteed use
				--switfmend use
			--needs testing{ "rejuvenation",				swiftmendCD <= 1 and defaultHP < 0.50 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 2), defaultTarget },--needs testing
			{ "swiftmend",					defaultHP < 0.65 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
				--healing/def cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(2),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
			--aoe heals
			{ "wild growth", 				jps.countInRaidStatus(85)>3, defaultTarget }, --untested
			--{ "heart of the wild",			jps.countInRaidStatus(60)>5},
			--{ "tranquility", 				jps.countInRaidStatus(60)>5 or jps.buff("heart of the wild") }, --untested
			{ "force of nature", 			jps.countInRaidStatus(85)>3, defaultTarget },
				
			--Decurse
			{ "nature's cure",				playerMana > 6 and cleanseTarget~=nil, cleanseTarget },

			--default healing
			{ "regrowth",					defaultHP < 0.55 or (jps.buff("clearcasting") and defaultHP < 0.70), defaultTarget },
			{ "swiftmend",					defaultHP < 0.65 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			{ "rejuvenation",				defaultHP < 0.75 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
		}
	end
	--mana conservation mode (leaves mana for tranq and oh shit situations while maintaining lb stacks and using cd's
	if(playerMana < conservative_healing_mana_threshold) then --untested
		spellTable =
		{
		--Shift for mushroom placement
			{ "wild mushroom",				IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil},
			
			--Ctrl hotw + tranquility or ToL
			{ "heart of the wild",			IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tranquility",				IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tree of life",				IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and

			--self-preservation checks
			{ "barkskin",					jps.hpInc() < 0.50 },
			{ "swiftmend",		    		jps.hpInc(me) <= 0.75 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0), me },
			
			{ "regrowth",					jps.buff("clearcasting") and jps.hpInc(me) < 0.70 or jps.hpInc(me) < 0.50, me },
			
			{ "rejuvenation",				jps.hpInc(me) <= 0.85 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			
			--tank checks (doubled for two tank)
			--{ "rebirth", 					tank1hp = 0 and IsSpellInRange("rebirth", tank1), tank1 }, --untested
			--{ "rebirth", 					tank2hp = 0 and IsSpellInRange("rebirth", tank2), tank2 }, --untested
			{ "ironbark", 					jps.hpInc(tank1) < 0.50, tank1 },
			{ "ironbark", 					jps.hpInc(tank2) < 0.50, tank2 },
			{ "lifebloom",					(jps.buffDuration("lifebloom",jps.findMeAggroTank()) < 1.5 or jps.buffStacks("lifebloom",jps.findMeAggroTank()) < 3), jps.findMeAggroTank() },
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.50 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.50 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
			{ "regrowth",					jps.buff("clearcasting") and (jps.hpInc(tank1) < 0.65 or jps.buffDuration("lifebloom",tank1) < 3) or jps.hpInc(tank1) < 0.45, tank1 },
			{ "regrowth",					jps.buff("clearcasting") and (jps.hpInc(tank2) < 0.65 or jps.buffDuration("lifebloom",tank2) < 3) or jps.hpInc(tank2) < 0.45, tank2 },
			{ "rejuvenation",				jps.hpInc(tank1) <= 0.75 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.hpInc(tank2) <= 0.75 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
			
			-- CDs
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.50 },
			{ "healing touch", 				jps.buff("nature's swiftness") and defaultHP < 0.55, defaultTarget },--ns use moved for guaranteed use
				--switfmend use
			--needs testing{ "rejuvenation",				swiftmendCD <= 1 and defaultHP < 0.50 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 2), defaultTarget },--needs testing
			{ "swiftmend",					defaultHP < 0.50 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
				--healing/def cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(2),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
			--aoe heals
			{ "wild growth", 				jps.countInRaidStatus(65)>5, defaultTarget }, --untested
			--{ "heart of the wild",			jps.countInRaidStatus(50)>5},
			--{ "tranquility", 				jps.countInRaidStatus(50)>5 or jps.buff("heart of the wild") }, --untested
			{ "force of nature", 			jps.countInRaidStatus(70)>5, defaultTarget },
				
			--Decurse
			{ "nature's cure",				playerMana > 6 and cleanseTarget~=nil, cleanseTarget },

			--default healing
			{ "regrowth",					defaultHP < 0.40 or (jps.buff("clearcasting") and defaultHP < 0.50), defaultTarget },
			{ "rejuvenation",				defaultHP < 0.50 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
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

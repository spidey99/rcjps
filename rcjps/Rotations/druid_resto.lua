function druid_resto(self)
	local testMode = false

	--settings
	-- 0 mana --->conservative_healing_mana_threshold--->**normal raid healing**--->conservative_healing_mana_threshold--->100% mana
	local chart_top_mana_threshold = 90
	local conservative_healing_mana_threshold = 15
	local oom = 11  --should be just above the cost of a tranquility
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
	--lifebloom tank target logic
	local lifebloom_Tank
	local boss1,realm = UnitName("boss1target")
	local boss2,realm = UnitName("boss2target")
	local boss3,realm = UnitName("boss3target")
	local boss4,realm = UnitName("boss4target")
	local tank1Name,realm = UnitName(tank1)
	local tank2Name,realm = UnitName(tank2)
	--target of boss
	--[[
	if(boss1==tank1Name) then
		lifebloom_Tank = tank1
	elseif(boss1==tank2Name) then
		lifebloom_Tank = tank2
	elseif(boss2==tank1Name) then
		lifebloom_Tank = tank1
	elseif(boss2==tank2Name) then
		lifebloom_Tank = tank2
	elseif(boss3==tank1Name) then
		lifebloom_Tank = tank1
	elseif(boss3==tank2Name) then
		lifebloom_Tank = tank2
	elseif(boss4==tank1Name) then
		lifebloom_Tank = tank1
	elseif(boss4==tank2Name) then
		lifebloom_Tank = tank2
	--need to refresh the stack before we move it	
	elseif(jps.buffDuration("lifebloom",tank1) < 3) then
		lifebloom_Tank = tank1
	elseif(jps.buffDuration("lifebloom",tank2) < 3) then
		lifebloom_Tank = tank2
	elseif(playerMana>oom) then
		lifebloom_Tank = jps.findMeAggroTank()
	--if we're oom, we're just gonna refresh stack if possible
	elseif(jps.buffStacks("lifebloom",tank1) > 0) then
		lifebloom_Tank = tank1
	elseif(jps.buffStacks("lifebloom",tank2) > 0) then
		lifebloom_Tank = tank2
	else
		lifebloom_Tank = jps.findMeAggroTank()
	end
	--]]
	if(IsSpellInRange("lifebloom", tank1))then
		lifebloom_Tank = tank1
	elseif(IsSpellInRange("lifebloom", tank2))then
		lifebloom_Tank = tank2
	else
		lifebloom_Tank = me
	end
	--Get the health of our decided targets
	local defaultHP = jps.hpInc(defaultTarget)
	local tank1HP = jps.hpInc(tank1)
	local tank2HP = jps.hpInc(tank2)
	local myHP = jps.hpInc(me)

	-- if jps.castTimeLeft(unit) do nothing (tranquility protection)
	--if(jps.castTimeLeft(me)) then return nil end --untested
	
	
	
	local spellTable = nil
	--heal chart topper mode for short pulls and low damage fights/periods (based on mana)
	if(playerMana > chart_top_mana_threshold) then --untested



		spellTable =
		{
		
			--Shift for mushroom placement
			{ "wild mushroom",				IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil},
			
			--Ctrl hotw + tranquility or ToL
			{ "heart of the wild",			IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tranquility",				not jps.Moving and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tree of life",				IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and
			
			
			--PRIORITY HEALING
			--self-preservation checks
			{ "barkskin",					myHP < 0.50 },
			{ "swiftmend",		    		myHP <= 0.50 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0.5), me },
				--ns use
			{ "nature's swiftness", 		myHP < 0.50 },
			{ "healing touch", 				jps.buff("nature's swiftness") and myHP < 0.55, me },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and myHP < 0.45, me },
			{ "rejuvenation",				jps.Moving and myHP < 0.45 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
						
			--tank checks (doubled for two tank)
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank1) ~= nil and IsSpellInRange("rebirth", tank1), tank1 }, --untested
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank2) ~= nil and IsSpellInRange("rebirth", tank2), tank2 }, --untested
			{ "ironbark", 					jps.hpInc(tank1) < 0.50, tank1 },
			{ "ironbark", 					jps.hpInc(tank2) < 0.50, tank2 },
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.55 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.55 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
				--ns use
			{ "nature's swiftness", 		tank1HP < 0.55 },
			{ "healing touch", 				jps.buff("nature's swiftness") and tank1HP < 0.60, tank1 },--ns use moved for guaranteed use
			{ "nature's swiftness", 		tank2HP < 0.55 },
			{ "healing touch", 				jps.buff("nature's swiftness") and tank2HP < 0.60, tank2 },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and jps.hpInc(tank1) < 0.50, tank1 },
			{ "regrowth",					not jps.Moving and jps.hpInc(tank2) < 0.50, tank2 },
			{ "rejuvenation",				jps.Moving and tank1HP < 0.45 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.Moving and tank2HP < 0.45 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.50)>4, defaultTarget }, --untested
			{ "heart of the wild",			jps.getNumberOfPlayersUnderXHealth(.70)>5}, --untested
			{ "tranquility", 				not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.70)>5 or jps.buff("heart of the wild") }, --untested
				--rolling rejuvs
			{ "rejuvenation",				defaultHP < 0.35 and jps.getNumberOfPlayersUnderXHealth(.40)>5 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			
			--everyone else
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.35 },
			{ "healing touch", 				jps.buff("nature's swiftness") and defaultHP < 0.45, defaultTarget },
			
			{ "swiftmend",					defaultHP < 0.40 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			
			{ "regrowth",					not jps.Moving and defaultHP < 0.35, defaultTarget },
			{ "rejuvenation",				jps.Moving and defaultHP < 0.35 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			


			--DEFAULT HEALING
			--self-preservation checks
			{ "barkskin",					jps.hpInc() < 0.70 },
			{ "swiftmend",		    		jps.hpInc(me) <= 0.75 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0), me },
			
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and jps.hpInc(me) < 0.80 or jps.hpInc(me) < 0.70, me },
			
			{ "rejuvenation",				jps.hpInc(me) <= 0.99 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			
			--tank checks (doubled for two tank)
			{ "ironbark", 					jps.hpInc(tank1) < 0.75, tank1 },
			{ "ironbark", 					jps.hpInc(tank2) < 0.75, tank2 },
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.75 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.75 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (jps.hpInc(tank1) < 0.80 or jps.buffDuration("lifebloom",tank1) < 5 and jps.buffDuration("lifebloom",tank1) < 1.5) or jps.hpInc(tank1) < 0.70, tank1 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (jps.hpInc(tank2) < 0.80 or jps.buffDuration("lifebloom",tank2) < 5 and jps.buffDuration("lifebloom",tank2) < 1.5) or jps.hpInc(tank2) < 0.70, tank2 },
			{ "rejuvenation",				jps.hpInc(tank1) <= 0.99 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.hpInc(tank2) <= 0.99 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
			--cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(2),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
				--tank bloom upkeep/switch
			{ "lifebloom",					jps.buffDuration("lifebloom",lifebloom_Tank) < 1.5 or jps.buffStacks("lifebloom",lifebloom_Tank) < 3,lifebloom_Tank},
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.95)>3, defaultTarget }, --untested
			{ "force of nature", 			jps.getNumberOfPlayersUnderXHealth(.90)>3, defaultTarget },
			
				
				--Decurse
			{ "nature's cure",				cleanseTarget~=nil, cleanseTarget }, --untested

				--default heals
			{ "regrowth",					not jps.Moving and defaultHP < 0.60 or (jps.buff("clearcasting") and defaultHP < 0.85), defaultTarget },
			{ "swiftmend",					defaultHP < 0.90 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			{ "rejuvenation",				defaultHP < 0.90 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			--add nature's swiftness use if buff is going to expire

		}
	end
	--normal raid heal mode
	if(playerMana <= chart_top_mana_threshold and playerMana > conservative_healing_mana_threshold) then --untested
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
			{ "tranquility",				not jps.Moving and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tree of life",				IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and
			
			
			--PRIORITY HEALING
			--self-preservation checks
			{ "barkskin",					myHP < 0.50 },
			{ "swiftmend",		    		myHP <= 0.45 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0.5), me },
				--ns use
			{ "nature's swiftness", 		myHP < 0.45 },
			{ "healing touch", 				jps.buff("nature's swiftness") and myHP < 0.50, me },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and myHP < 0.40, me },
			{ "rejuvenation",				jps.Moving and myHP < 0.40 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
						
			--tank checks (doubled for two tank)
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank1) ~= nil and IsSpellInRange("rebirth", tank1), tank1 }, --untested
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank2) ~= nil and IsSpellInRange("rebirth", tank2), tank2 }, --untested
			{ "ironbark", 					jps.hpInc(tank1) < 0.50, tank1 },
			{ "ironbark", 					jps.hpInc(tank2) < 0.50, tank2 },
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.55 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.55 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
				--ns use
			{ "nature's swiftness", 		tank1HP < 0.55 },
			{ "healing touch", 				jps.buff("nature's swiftness") and tank1HP < 0.60, tank1 },--ns use moved for guaranteed use
			{ "nature's swiftness", 		tank2HP < 0.55 },
			{ "healing touch", 				jps.buff("nature's swiftness") and tank2HP < 0.60, tank2 },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and jps.hpInc(tank1) < 0.50, tank1 },
			{ "regrowth",					not jps.Moving and jps.hpInc(tank2) < 0.50, tank2 },
			{ "rejuvenation",				jps.Moving and tank1HP < 0.45 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.Moving and tank2HP < 0.45 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.50)>4, defaultTarget }, --untested
			{ "heart of the wild",			jps.getNumberOfPlayersUnderXHealth(.65)>5}, --untested
			{ "tranquility", 				not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.65)>5 or jps.buff("heart of the wild") }, --untested
				--rolling rejuvs
			{ "rejuvenation",				defaultHP < 0.35 and jps.getNumberOfPlayersUnderXHealth(.40)>5 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			
			--everyone else
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.35 },
			{ "healing touch", 				jps.buff("nature's swiftness") and defaultHP < 0.45, defaultTarget },
			
			{ "swiftmend",					defaultHP < 0.40 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			
			{ "regrowth",					not jps.Moving and defaultHP < 0.35, defaultTarget },
			{ "rejuvenation",				jps.Moving and defaultHP < 0.35 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			


			--DEFAULT HEALING
			--self-preservation checks
			{ "swiftmend",		    		jps.hpInc(me) <= 0.65 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0), me },
			
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and jps.hpInc(me) < 0.70 or jps.hpInc(me) < 0.50, me },
			
			{ "rejuvenation",				jps.hpInc(me) <= 0.70 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			
			--tank checks (doubled for two tank)
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.75 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.75 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (jps.hpInc(tank1) < 0.75 or jps.buffDuration("lifebloom",tank1) < 5 and jps.buffDuration("lifebloom",tank1) < 1.5) or jps.hpInc(tank1) < 0.60, tank1 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (jps.hpInc(tank2) < 0.75 or jps.buffDuration("lifebloom",tank2) < 5 and jps.buffDuration("lifebloom",tank2) < 1.5) or jps.hpInc(tank2) < 0.60, tank2 },
			{ "rejuvenation",				jps.hpInc(tank1) <= 0.99 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.hpInc(tank2) <= 0.99 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
			--cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(2),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
				--tank bloom upkeep/switch
			{ "lifebloom",					(jps.buffDuration("lifebloom",lifebloom_Tank) < 1.5 or jps.buffStacks("lifebloom",lifebloom_Tank) < 3), lifebloom_Tank },
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.75)>3, defaultTarget }, --untested
			{ "force of nature", 			jps.getNumberOfPlayersUnderXHealth(.80)>3, defaultTarget },
							
				--Decurse
			{ "nature's cure",				cleanseTarget~=nil, cleanseTarget }, --untested

				--default heals
			{ "regrowth",					not jps.Moving and defaultHP < 0.35 or (jps.buff("clearcasting") and defaultHP < 0.75), defaultTarget },
			{ "swiftmend",					defaultHP < 0.60 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			{ "rejuvenation",				defaultHP < 0.60 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			--add nature's swiftness use if buff is going to expire

			
		}
	end
	--mana conservation mode (leaves mana for tranq and oh shit situations while maintaining lb stacks and using cd's) Our goal is be as efficient as possible by making high efficienc spells available during ideal casting opportunities
	if(playerMana <= conservative_healing_mana_threshold) then --untested
		spellTable =
		{
			--Shift for mushroom placement
			{ "wild mushroom",				IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil},
			
			--Ctrl hotw + tranquility or ToL
			{ "heart of the wild",			IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tranquility",				not jps.Moving and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			{ "tree of life",				IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and
			
			
			--PRIORITY HEALING
			--self-preservation checks (these casts veto mana concerns b/c it won't matter if you die)
			{ "barkskin",					myHP < 0.50 },
			{ "swiftmend",		    		myHP <= 0.40 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0.5), me },
				--ns use
			{ "nature's swiftness", 		myHP < 0.40 },
			{ "healing touch", 				jps.buff("nature's swiftness") and myHP < 0.45, me },--ns use moved for guaranteed use
			{ "regrowth",					playerMana > oom and not jps.Moving and myHP < 0.35, me },
			{ "regrowth",					playerMana <= oom and not jps.Moving and myHP < 0.15, me },
			{ "rejuvenation",				playerMana > oom and jps.Moving and myHP < 0.45 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			{ "rejuvenation",				playerMana <= oom and jps.Moving and myHP < 0.25 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			{ "force of nature", 			myHP < .40, me },	
						
			--tank checks (doubled for two tank)  (these casts veto mana concerns b/c if tanks drop at this point it's generally a wipe)
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank1) ~= nil and IsSpellInRange("rebirth", tank1), tank1 }, --untested
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank2) ~= nil and IsSpellInRange("rebirth", tank2), tank2 }, --untested
			{ "ironbark", 					jps.hpInc(tank1) < 0.40, tank1 },
			{ "ironbark", 					jps.hpInc(tank2) < 0.40, tank2 },
			{ "swiftmend",		    		jps.hpInc(tank1) <= 0.45 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0), tank1 },
			{ "swiftmend",		    		jps.hpInc(tank2) <= 0.45 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0), tank2 },
				--ns use
			{ "nature's swiftness", 		tank1HP < 0.45 },
			{ "healing touch", 				jps.buff("nature's swiftness") and tank1HP < 0.50, tank1 },--ns use moved for guaranteed use
			{ "nature's swiftness", 		tank2HP < 0.45 },
			{ "healing touch", 				jps.buff("nature's swiftness") and tank2HP < 0.50, tank2 },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and jps.hpInc(tank1) < 0.35, tank1 },
			{ "regrowth",					not jps.Moving and jps.hpInc(tank2) < 0.35, tank2 },
			{ "rejuvenation",				jps.Moving and tank1HP < 0.50 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1), tank1 },
			{ "rejuvenation",				jps.Moving and tank2HP < 0.50 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1), tank2 },
			
				--aoe heals
			{ "wild growth", 				playerMana > oom and jps.getNumberOfPlayersUnderXHealth(.50)>5, defaultTarget }, --untested
			{ "heart of the wild",			jps.getNumberOfPlayersUnderXHealth(.35)>6}, --untested
			{ "tranquility", 				not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.50)>5 or jps.buff("heart of the wild") }, --untested
				--rolling rejuvs
			{ "rejuvenation",				playerMana > oom and defaultHP < 0.25 and jps.getNumberOfPlayersUnderXHealth(.30)>5 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			{ "force of nature", 			jps.getNumberOfPlayersUnderXHealth(65)>3, defaultTarget }, --getting greedy with the fon's so we can save ourselves
			
			
			--everyone else
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.25 },
			{ "healing touch", 				jps.buff("nature's swiftness") and defaultHP < 0.35, defaultTarget },
			
			{ "swiftmend",					playerMana > oom and defaultHP < 0.20 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			
			{ "regrowth",					playerMana > oom and not jps.Moving and defaultHP < 0.20, defaultTarget },
			{ "rejuvenation",				playerMana > oom and jps.Moving and defaultHP < 0.15 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			


			--DEFAULT HEALING
			--cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(2),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
				--tank bloom upkeep/switch (trying to reduce lifebloom switching at low mana lvls)
			{ "lifebloom",					jps.buffDuration("lifebloom",lifebloom_Tank) < 1.5 or jps.buffStacks("lifebloom",lifebloom_Tank) <lifebloom_Tank},

				--Decurse
			{ "nature's cure",				playerMana > oom and cleanseTarget~=nil, cleanseTarget }, --untested

				--default heals
			
			--add nature's swiftness use if buff is going to expire

			
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

function jps.getNumberOfPlayersUnderXHealth(health)
	local numUnder = 0
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.hp(unit)<health and jps.canHeal(unit) then 
			numUnder=numUnder+1 
		end
	end
	return numUnder
end


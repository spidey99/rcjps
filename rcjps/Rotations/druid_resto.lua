jps.registerRotation("DRUID","RESTORATION",function()
	local testMode = false

	--settings
	-- 0 mana --->conservative_healing_mana_threshold--->**normal raid healing**--->chart_top_mana_threshold--->100% mana
	local chart_top_mana_threshold = 70
	local conservative_healing_mana_threshold = 15
	local oom = 11  --should be just above the cost of a tranquility
	local tranq = false
	--use trinkets on cd?
	local trink_1_passive = true
	local trink_2_passive = true

	local playerMana = UnitMana("player")/UnitManaMax("player") * 100
	--target selections
	local tank1 = jps.findMeATank()
	local tank2 = jps.findMeASecondTank(tank1) --untested should default to player in group or single
	local me = "player"
	-- Check if we should cleanse
	local cleanseTarget =jps.FindMeDispelTarget({"Poison"},{"Curse"},{"Magic"}) --untested
	--Default to healing lowest partymember
	local defaultTarget = jps.LowestInRaidStatus()
	--non tank with aggro or targetted
	--local non_tank_aggrod = jps.findMeAggroNotTank(tank1,tank2) --untested
	
	local tank1_can_heal = canHeal(tank1)
	local tank2_can_heal = canHeal(tank2)
	
	local defaultHP = jps.hpInc(defaultTarget)
	local tank1HP = jps.hpInc(tank1)
	local tank2HP = jps.hpInc(tank2)
	local myHP = jps.hpInc(me)
	
	local harmony_refresh = false
	if (jps.buffDuration("harmony",me) < 1.5 or not jps.buff("harmony",me))then
		harmony_refresh = true
	end
	
	
	
	local Raid = {}
	Raid = getRaidInfo(Raid)
	
	local rejuvTarget = jps.getRollingRejuvTarget(Raid)
	local rejuvTargetHP = jps.hpInc(rejuvTarget)
	local rollingLifeBloomTarget = jps.getRollingLifeBloomTarget(Raid)
	local rollingLifeBloomTargetHP = jps.hpInc(rollingLifeBloomTarget)
	
	local lifebloom_Tank
	--lifebloom tank target logic --experimental
	--[[
	local boss1,realm = UnitName("boss1target")
	local boss2,realm = UnitName("boss2target")
	local boss3,realm = UnitName("boss3target")
	local boss4,realm = UnitName("boss4target")
	local tank1Name,realm = UnitName(tank1)
	local tank2Name,realm = UnitName(tank2)
	
	--target of boss
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
	--temporary lifebloom target selection
		--to prevent spam, check for buff, then if buffduration>x reselect same target --todo
			--perhaps utilize a timer in the future??
		--refresh stacks with under 3sec left or they won't be moved
	if(jps.buffDuration("lifebloom",tank1) < 3 and jps.buff("lifebloom",tank1) and tank1_can_heal) then
		lifebloom_Tank = tank1
	elseif(jps.buffDuration("lifebloom",tank2) < 3 and jps.buff("lifebloom",tank2) and tank2_can_heal) then
		lifebloom_Tank = tank2
	--elseif(tank1_can_heal and jps_CalcThreat(tank1)==3) then
		--lifebloom_Tank = tank1
	--elseif(tank2_can_heal and jps_CalcThreat(tank2)==3) then
		--lifebloom_Tank = tank2
	elseif(tank1_can_heal and jps.buff("lifebloom",tank1))then
		lifebloom_Tank = tank1
	elseif(tank2_can_heal and jps.buff("lifebloom",tank2))then
		lifebloom_Tank = tank2
	elseif(tank1_can_heal)then
		lifebloom_Tank = tank1
	else
		lifebloom_Tank = me
	end
	--Get the health of our decided targets
	if(jps.hpInc(defaultTarget)> jps.hpInc(me)) then
		defaultTarget=me
	end
	
	-- stop casting if conflicting heals ->>>todo
	--[[
	if(jps.hpInc("target")==1 and jps.LastCast ~= "tranquility" and not jps.buff("clearcasting")) then
		SpellStopCasting()
	end
	--]]
	
	--[[
	local wrath = false
	local wrathweave = true
	local a,b,c,d,hasWrathTalent,f = GetTalentInfo(17)
	if(UnitIsEnemy("player","target") and hasWrathTalent) then
		wrath = true
	end
	]]--
	
	if(IsAltKeyDown() ~= nil ) then
			print( string.format("UnitIsEnemy(player,target) %s"), tostring(UnitIsEnemy("player","target")) )
    		--print( string.format("jps.buffStacks(lifebloom,lifebloom_Tank) < 3: %s", tostring(jps.buffStacks("lifebloom",lifebloom_Tank) < 3)) )
    		--print( string.format("playerMana > chart_top_mana_threshold: %s > %s: %s", playerMana, chart_top_mana_threshold, tostring(playerMana > chart_top_mana_threshold)) )
  	end
	local spellTable = nil
	--Tree Form table
	if(jps.buff("incarnation: tree of life")) then

		spellTable =
		{
		
			--Shift for mushroom placement
			--{ "wild mushroom",				IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil},
			
			--Ctrl hotw + tranquility or ToL
			--{ "heart of the wild",			jps.UseCDs and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			--{ "tranquility",				jps.UseCDs and tranq and not jps.Moving and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			
			
			--PRIORITY HEALING
				--self-preservation checks
			{ "barkskin",					myHP < 0.50 },
			{ "regrowth",					myHP < 0.35, me },
			{ "lifebloom",					jps.buffStacks("lifebloom",me) < 1 and myHP < 0.45, me },
						
				--tank checks (doubled for two tank)
			{ "ironbark", 					tank1HP < 0.40 and tank1_can_heal, tank1 },
			{ "ironbark", 					tank2HP < 0.40 and tank1_can_heal, tank2 },
			{ "regrowth",					tank1HP < 0.50 and tank1_can_heal, tank1 },
			{ "regrowth",					tank2HP < 0.50 and tank2_can_heal, tank2 },
			{ "lifebloom",					jps.buffStacks("lifebloom",tank1) < 1 and tank1HP < 0.65, tank1 },
			{ "lifebloom",					jps.buffStacks("lifebloom",tank2) < 1 and tank2HP < 0.65, tank2 },
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.80, Raid)>=4, defaultTarget }, --untested
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.90, Raid)>=6, defaultTarget }, --untested
			
			
				--everyone else
			{ "regrowth",					defaultHP < 0.35, defaultTarget },
			{ "regrowth",					defaultHP < 0.60 and jps.buff("clearcasting",me), defaultTarget },
			{ "lifebloom",					rollingLifeBloomTarget ~=nil, rollingLifeBloomTarget },
			{ "lifebloom",					jps.buffStacks("lifebloom",defaultTarget) < 3 and defaultHP < 0.60, defaultTarget },
			{ "lifebloom",					not oom and jps.buffDuration("lifebloom",defaultTarget) < 1.5 or jps.buffStacks("lifebloom",defaultTarget) < 1 and defaultHP < 0.75, defaultTarget },
			
			--HARMONY CHECK
			{ "regrowth",					harmony_refresh, defaultTarget },
			
			
			--DEFAULT HEALING
			--self-preservation checks
			{ "barkskin",					jps.hpInc() < 0.70 },
			{ "lifebloom",					jps.buffDuration("lifebloom",me) < 1.5 or jps.buffStacks("lifebloom",me) < 3 and myHP < 0.99, me },
			{ "regrowth",					not oom and jps.buff("clearcasting") and myHP < 0.80 or not oom and myHP < 0.70, me },
						
			--tank checks (doubled for two tank)
			{ "ironbark", 					tank1HP < 0.75, tank1 },
			{ "ironbark", 					tank2HP < 0.75, tank2 },
			{ "swiftmend",		    		tank1HP <= 0.75 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0) and tank1_can_heal, tank1 },
			{ "swiftmend",		    		tank2HP <= 0.75 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0) and tank2_can_heal, tank2 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (tank1HP < 0.80 or jps.buffDuration("lifebloom",tank1) < 5 and jps.buffDuration("lifebloom",tank1) > 1.5) or tank1HP < 0.70 and tank1_can_heal, tank1 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (tank2HP < 0.80 or jps.buffDuration("lifebloom",tank2) < 5 and jps.buffDuration("lifebloom",tank2) > 1.5) or tank2HP < 0.70 and tank2_can_heal, tank2 },
			{ "lifebloom",					jps.buffDuration("lifebloom",tank1) < 1.5 or jps.buffStacks("lifebloom",tank1) < 3, tank1 },
			{ "lifebloom",					jps.buffDuration("lifebloom",tank2) < 1.5 or jps.buffStacks("lifebloom",tank2) < 3, tank2 },
			
			--cds
			{ "Nature's Vigil", 			true},
				-- Trinkets
			{ jps.useTrinket(0),    		trink_1_passive },
			{ jps.useTrinket(1),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 72, me }, --w/e
						
				--aoe heals
			{ "wild growth", 				not oom and jps.getNumberOfPlayersUnderXHealth(.95, Raid)>3, defaultTarget }, --untested
			{ "force of nature", 			jps.getNumberOfPlayersUnderXHealth(.90, Raid)>3, defaultTarget },
			
			
			
				
				--Decurse
			{ "nature's cure",				not oom and cleanseTarget~=nil, cleanseTarget }, --untested


			{ "wrath",						jps.MultiTarget, "target"},
				--default heals
			--nature's swiftness use if buff is going to expire
			{ "healing touch", 				jps.buffDuration("nature's swiftness") < 1 and jps.buff("nature's swiftness"), defaultTarget },
			{ "regrowth",					not oom and jps.buff("clearcasting") and defaultHP < 0.85, defaultTarget },
			{ "lifebloom",					not oom and jps.buffDuration("lifebloom",defaultTarget) < 1.5 or jps.buffStacks("lifebloom",defaultTarget) < 1, defaultTarget },
			{ "lifebloom",					rollingLifeBloomTargetHP < 0.99 and rollingLifeBloomTarget ~=nil, rollingLifeBloomTarget },

		}
	elseif(playerMana > chart_top_mana_threshold) then
		spellTable =
		{
			--Chart topper mode. When you have high mana throw out heals or regen goes to waste
			
			--Shift for mushroom placement
			--{ "wild mushroom",				IsShiftKeyDown() ~= nil},
			
			--Ctrl hotw + tranquility or ToL
			--{ "heart of the wild",			jps.UseCDs and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			--{ "tranquility",				jps.UseCDs and tranq and not jps.Moving and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			--{ "tree of life",				jps.UseCDs and IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and
			
			
			--PRIORITY HEALING
			--self-preservation checks
			{ "barkskin",					myHP < 0.50 },
			{ "swiftmend",		    		myHP <= 0.50 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0.5), me },
				--ns use
			{ "nature's swiftness", 		myHP < 0.50 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and myHP < 0.55, me },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and myHP < 0.45, me },
			{ "rejuvenation",				jps.Moving and myHP < 0.45 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
						
			--tank checks (doubled for two tank)
			--{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank1) ~= nil, tank1 }, --untested
			--{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank2) ~= nil, tank2 }, --untested
			{ "ironbark", 					tank1HP < 0.50 and tank1_can_heal, tank1 },
			{ "ironbark", 					tank2HP < 0.50 and tank1_can_heal, tank2 },
			{ "swiftmend",		    		tank1HP <= 0.55 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0) and tank1_can_heal, tank1 },
			{ "swiftmend",		    		tank2HP <= 0.55 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0) and tank1_can_heal, tank2 },
				--ns use
			{ "nature's swiftness", 		tank1HP < 0.55  and tank1_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank1HP < 0.80  and tank1_can_heal, tank1 },--ns use moved for guaranteed use
			{ "nature's swiftness", 		tank2HP < 0.55  and tank2_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank2HP < 0.80 and tank2_can_heal, tank2 },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and tank1HP < 0.50 and tank1_can_heal, tank1 },
			{ "regrowth",					not jps.Moving and tank2HP < 0.50 and tank2_can_heal, tank2 },
			{ "rejuvenation",				tank1HP < 0.50 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1) and tank1_can_heal, tank1 },
			{ "rejuvenation",				tank2HP < 0.50 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1) and tank2_can_heal, tank2 },
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.80, Raid)>=4, defaultTarget },
			--{ "heart of the wild",			jps.UseCDs and jps.getNumberOfPlayersUnderXHealth(.65, Raid)>=5}, --untested
			--{ "tranquility", 				jps.UseCDs and tranq and not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.70, Raid)>=5 or jps.buff("heart of the wild") },
					--many with minor health missing
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.90, Raid)>=6, defaultTarget }, --untested
			--{ "heart of the wild",			jps.UseCDs and jps.getNumberOfPlayersUnderXHealth(.75, Raid)>=7}, --untested
			--{ "tranquility", 				jps.UseCDs and tranq and not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.75, Raid)>=7 or jps.buff("heart of the wild") },
				--rolling rejuvs
			{ "genesis",					jps.getNumberOfPlayersUnderXHealth(.75, Raid)>=5 and jps.numberOfPeopleWithBuff(Raid, "rejuvenation") >= 4},
			{ "rejuvenation",				jps.getNumberOfPlayersUnderXHealth(.75, Raid)>=5 and rejuvTarget ~=nil, rejuvTarget },
			
			
			--everyone else
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.35 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and defaultHP < 0.80, defaultTarget },
			
			{ "swiftmend",					defaultHP < 0.40 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			
			{ "regrowth",					not jps.Moving and defaultHP < 0.35, defaultTarget },
			{ "rejuvenation",				defaultHP < 0.35 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			--HARMONY CHECK
			{ "regrowth",					not jps.Moving and harmony_refresh, defaultTarget },


			--DEFAULT HEALING
			--self-preservation checks
			{ "barkskin",					jps.hpInc() < 0.70 },
			{ "swiftmend",		    		myHP <= 0.75 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0), me },
			
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and myHP < 0.80 or myHP < 0.70, me },
			
			{ "rejuvenation",				myHP <= 0.99 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			
			--tank checks (doubled for two tank)
			{ "ironbark", 					tank1HP < 0.75, tank1 },
			{ "ironbark", 					tank2HP < 0.75, tank2 },
			{ "swiftmend",		    		tank1HP <= 0.75 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0) and tank1_can_heal, tank1 },
			{ "swiftmend",		    		tank2HP <= 0.75 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0) and tank2_can_heal, tank2 },
			--
			--add 1.5 sec check for lb stack refresh
			--
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (tank1HP < 0.80 or jps.buffDuration("lifebloom",tank1) < 5 and jps.buffDuration("lifebloom",tank1) > 1.5) or tank1HP < 0.70 and tank1_can_heal, tank1 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (tank2HP < 0.80 or jps.buffDuration("lifebloom",tank2) < 5 and jps.buffDuration("lifebloom",tank2) > 1.5) or tank2HP < 0.70 and tank2_can_heal, tank2 },
			{ "rejuvenation",				(not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1) and tank1_can_heal, tank1 },
			{ "rejuvenation",				(not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1) and tank2_can_heal, tank2 },
			
			--cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(0),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 72, me }, --w/e
			
			
				--tank bloom upkeep/switch
			{ "lifebloom",					jps.buffDuration("lifebloom",lifebloom_Tank) < 1.5 or jps.buffStacks("lifebloom",lifebloom_Tank) < 3,lifebloom_Tank},
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.95, Raid)>3, defaultTarget }, --untested
			{ "force of nature", 			jps.getNumberOfPlayersUnderXHealth(.90, Raid)>3, defaultTarget },
				--rolling rejuvs
			{ "rejuvenation",				defaultHP < 0.60 and jps.getNumberOfPlayersUnderXHealth(.60, Raid)>=4 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			{ "genesis",					defaultHP < 0.70 and jps.getNumberOfPlayersUnderXHealth(.70, Raid)>=3 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1) },
			
				
				--Decurse
			{ "nature's cure",				cleanseTarget~=nil, cleanseTarget }, --untested
			
			{ "wrath",						jps.MultiTarget, "target"},

				--default heals
			{ "healing touch", 				jps.buffDuration("nature's swiftness") < 1 and jps.buff("nature's swiftness"), defaultTarget },
			{ "regrowth",					not jps.Moving and defaultHP < 0.75 or (jps.buff("clearcasting") and defaultHP < 0.85), defaultTarget },
			{ "swiftmend",					defaultHP < 0.90 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			{ "rejuvenation",				defaultHP < 0.99 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			{ "rejuvenation",				rejuvTargetHP < 0.99 and rejuvTarget ~=nil, rejuvTarget },

		}
	elseif(playerMana <= chart_top_mana_threshold and playerMana > conservative_healing_mana_threshold) then --untested
		--normal raid heal mode
	
		

		spellTable =
		{
			
			--Shift for mushroom placement
			--{ "wild mushroom",				IsShiftKeyDown() ~= nil},
			
			--Ctrl hotw + tranquility or ToL
			--{ "heart of the wild",			jps.UseCDs and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			--{ "tranquility",				jps.UseCDs and tranq and not jps.Moving and IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
			--{ "tree of life",				jps.UseCDs and IsRightControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },--todo tranquilityCD > 1 and
			
			
			--PRIORITY HEALING
			--self-preservation checks
			{ "barkskin",					myHP < 0.50 },
			{ "swiftmend",		    		myHP <= 0.45 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0.5), me },
				--ns use
			{ "nature's swiftness", 		myHP < 0.45 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and myHP < 0.50, me },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and myHP < 0.40, me },
			{ "rejuvenation",				myHP < 0.40 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
						
			--tank checks (doubled for two tank)
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank1) ~= nil, tank1 }, --untested
			{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank2) ~= nil, tank2 }, --untested
			{ "ironbark", 					tank1HP < 0.50 and tank1_can_heal, tank1 },
			{ "ironbark", 					tank2HP < 0.50 and tank2_can_heal, tank2 },
			{ "swiftmend",		    		tank1HP <= 0.55 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0) and tank1_can_heal, tank1 },
			{ "swiftmend",		    		tank2HP <= 0.55 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0) and tank2_can_heal, tank2 },
				--ns use
			{ "nature's swiftness", 		tank1HP < 0.55  and tank1_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank1HP < 0.60 and tank1_can_heal, tank1 },--ns use moved for guaranteed use
			{ "nature's swiftness", 		tank2HP < 0.55  and tank2_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank2HP < 0.60 and tank2_can_heal, tank2 },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and tank1HP < 0.50 and tank1_can_heal, tank1 },
			{ "regrowth",					not jps.Moving and tank2HP < 0.50 and tank2_can_heal, tank2 },
			{ "rejuvenation",				tank1HP < 0.45 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1) and tank1_can_heal, tank1 },
			{ "rejuvenation",				tank2HP < 0.45 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1) and tank2_can_heal, tank2 },
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.65, Raid)>=4, defaultTarget }, --untested
			--{ "heart of the wild",			jps.getNumberOfPlayersUnderXHealth(.65, Raid)>=5}, --untested
			
			--{ "tranquility", 				jps.UseCDs and tranq and not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.65, Raid)>=5 or jps.buff("heart of the wild") }, --untested
					--many with minor health missing
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.75, Raid)>=6, defaultTarget }, --untested
			--{ "heart of the wild",			jps.UseCDs and jps.getNumberOfPlayersUnderXHealth(.70, Raid)>=7}, --untested
			--{ "tranquility", 				jps.UseCDs and tranq and not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.70, Raid)>=7 or jps.buff("heart of the wild") },
					--rolling rejuvs
			{ "genesis",					jps.getNumberOfPlayersUnderXHealth(.70, Raid)>=5 and jps.numberOfPeopleWithBuff(Raid, "rejuvenation") >= 4},
			{ "rejuvenation",				jps.getNumberOfPlayersUnderXHealth(.70, Raid)>=5 and rejuvTarget ~=nil, rejuvTarget },
			
			--everyone else
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.35 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and defaultHP < 0.45, defaultTarget },
			
			{ "swiftmend",					defaultHP < 0.40 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			
			{ "regrowth",					not jps.Moving and defaultHP < 0.35, defaultTarget },
			{ "rejuvenation",				jps.Moving and defaultHP < 0.35 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			
			--HARMONY CHECK
			{ "regrowth",					not jps.Moving and harmony_refresh, defaultTarget },

			--DEFAULT HEALING
			--self-preservation checks
			{ "swiftmend",		    		myHP <= 0.65 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0), me },
			
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and myHP < 0.70 or myHP < 0.50, me },
			
			{ "rejuvenation",				myHP <= 0.70 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			
			--tank checks (doubled for two tank)
			--{ "swiftmend",		    		tank1HP <= 0.75 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0) and tank1_can_heal, tank1 },
			--{ "swiftmend",		    		tank2HP <= 0.75 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0) and tank2_can_heal, tank2 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (tank1HP < 0.75 or jps.buffDuration("lifebloom",tank1) < 5 and jps.buffDuration("lifebloom",tank1) > 1.5) or tank1HP < 0.60 and tank1_can_heal, tank1 },
			{ "regrowth",					not jps.Moving and jps.buff("clearcasting") and (tank2HP < 0.75 or jps.buffDuration("lifebloom",tank2) < 5 and jps.buffDuration("lifebloom",tank2) > 1.5) or tank2HP < 0.60 and tank2_can_heal, tank2 },
			{ "rejuvenation",				(not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1) and tank1_can_heal, tank1 },
			{ "rejuvenation",				(not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1) and tank2_can_heal, tank2 },
			
			--cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(0),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
				--tank bloom upkeep/switch
			{ "lifebloom",					( (jps.buffDuration("lifebloom",lifebloom_Tank) < 1.5 or jps.buffStacks("lifebloom",lifebloom_Tank) < 3) ), lifebloom_Tank },
			
				--aoe heals
			{ "wild growth", 				jps.getNumberOfPlayersUnderXHealth(.75, Raid)>3, defaultTarget }, --untested
			{ "force of nature", 			jps.getNumberOfPlayersUnderXHealth(.80, Raid)>3, defaultTarget },
			{ "rejuvenation",				defaultHP < 0.50 and jps.getNumberOfPlayersUnderXHealth(.50, Raid)>=4 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			{ "genesis",					defaultHP < 0.50 and jps.getNumberOfPlayersUnderXHealth(.50, Raid)>=4 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1)},
							
				--Decurse
			{ "nature's cure",				cleanseTarget~=nil, cleanseTarget }, --untested
			
			{ "wrath",						jps.MultiTarget, "target"},

				--default heals
			--nature's swiftness use if buff is going to expire
			{ "healing touch", 				jps.buffDuration("nature's swiftness") < 1 and jps.buff("nature's swiftness"), defaultTarget },
			{ "regrowth",					not jps.Moving and defaultHP < 0.35 or (jps.buff("clearcasting") and defaultHP < 0.75), defaultTarget },
			{ "swiftmend",					defaultHP < 0.60 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			{ "rejuvenation",				defaultHP < 0.60 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			{ "rejuvenation",				rejuvTargetHP < 0.80 and rejuvTarget ~=nil, rejuvTarget },
			
			
			
		}
	elseif(playerMana <= conservative_healing_mana_threshold) then --untested
		--mana conservation mode (leaves mana for tranq and oh shit situations while maintaining lb stacks and using cd's) Our goal is be as efficient as possible by making high efficienc spells available during ideal casting opportunities
	
		spellTable =
		{
			
			--PRIORITY HEALING
			--self-preservation checks (these casts veto mana concerns b/c it won't matter if you die)
			{ "barkskin",					myHP < 0.50 },
			{ "swiftmend",		    		myHP <= 0.40 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0.5), me },
				--ns use
			{ "nature's swiftness", 		myHP < 0.40 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and myHP < 0.45, me },--ns use moved for guaranteed use
			{ "regrowth",					playerMana > oom and not jps.Moving and myHP < 0.35, me },
			{ "regrowth",					playerMana <= oom and not jps.Moving and myHP < 0.15, me },
			{ "rejuvenation",				playerMana > oom and myHP < 0.45 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			{ "rejuvenation",				playerMana <= oom and myHP < 0.25 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },	
						
			--tank checks (doubled for two tank)  (these casts veto mana concerns b/c if tanks drop at this point it's generally a wipe)
			--{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank1) ~= nil, tank1 }, --untested
			--{ "rebirth", 					not jps.Moving and UnitIsDeadOrGhost(tank2) ~= nil, tank2 }, --untested
			{ "ironbark", 					tank1HP < 0.40 and tank1_can_heal, tank1 },
			{ "ironbark", 					tank2HP < 0.40 and tank2_can_heal, tank2 },
			{ "swiftmend",		    		tank1HP <= 0.45 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0) and tank1_can_heal, tank1 },
			{ "swiftmend",		    		tank2HP <= 0.45 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0) and tank2_can_heal, tank2 },
				--ns use
			{ "nature's swiftness", 		tank1HP < 0.45  and tank1_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank1HP < 0.50 and tank1_can_heal, tank1 },--ns use moved for guaranteed use
			{ "nature's swiftness", 		tank2HP < 0.45  and tank2_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank2HP < 0.50 and tank2_can_heal, tank2 },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and tank1HP < 0.35 and tank1_can_heal, tank1 },
			{ "regrowth",					not jps.Moving and tank2HP < 0.35 and tank2_can_heal, tank2 },
			{ "rejuvenation",				jps.Moving and tank1HP < 0.50 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1) and tank1_can_heal, tank1 },
			{ "rejuvenation",				jps.Moving and tank2HP < 0.50 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1) and tank2_can_heal, tank2 },
			
				--aoe heals
			{ "wild growth", 				playerMana > oom and jps.getNumberOfPlayersUnderXHealth(.50, Raid)>5, defaultTarget }, --untested
			--{ "heart of the wild",			jps.getNumberOfPlayersUnderXHealth(.50, Raid)>=5}, --untested
			--{ "tranquility", 				tranq and not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.50, Raid)>=5 or jps.buff("heart of the wild") }, --untested
					--many with minor health missing
			{ "wild growth", 				playerMana > oom and jps.getNumberOfPlayersUnderXHealth(.65, Raid)>=6, defaultTarget }, --untested
			--{ "heart of the wild",			jps.getNumberOfPlayersUnderXHealth(.65, Raid)>=7}, --untested
			--{ "tranquility", 				tranq and not jps.Moving and jps.getNumberOfPlayersUnderXHealth(.65, Raid)>=7 or jps.buff("heart of the wild") },
					--rolling rejuvs
			{ "rejuvenation",				jps.getNumberOfPlayersUnderXHealth(.40, Raid)>=4 and rejuvTarget ~=nil, rejuvTarget },
			{ "force of nature", 			jps.getNumberOfPlayersUnderXHealth(65, Raid)>3, defaultTarget }, --getting greedy with the fon's so we can save ourselves
			
			
			--everyone else
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.25 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and defaultHP < 0.35, defaultTarget },
			
			{ "swiftmend",					playerMana > oom and defaultHP < 0.20 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			
			{ "regrowth",					playerMana > oom and not jps.Moving and defaultHP < 0.20, defaultTarget },
			{ "rejuvenation",				playerMana > oom and jps.Moving and defaultHP < 0.15 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
			
			--HARMONY CHECK
			{ "regrowth",					not jps.Moving and harmony_refresh, defaultTarget },


			--DEFAULT HEALING
			--cds
			{ "Nature's Vigil", 			jps.UseCDs},
				-- Trinkets
			{ jps.useTrinket(1),    		trink_1_passive },
			{ jps.useTrinket(0),    		trink_2_passive },
				--Mana
			{ "Innervate", 					playerMana < 67, me }, --w/e
			
			
				--tank bloom upkeep/switch (trying to reduce lifebloom switching at low mana lvls)
			{ "lifebloom",					jps.buffDuration("lifebloom",lifebloom_Tank) < 1.5 or jps.buffStacks("lifebloom",lifebloom_Tank) < 3,lifebloom_Tank},

				--Decurse
			{ "nature's cure",				playerMana > oom and cleanseTarget~=nil, cleanseTarget }, --untested

				--default heals
			
			--nature's swiftness use if buff is going to expire
			{ "healing touch", 				jps.buffDuration("nature's swiftness") < 1 and jps.buff("nature's swiftness"), defaultTarget },
			
		}
	end
	
	--anticipate damage mode
	if(IsShiftKeyDown() ~= nil) then
	  	spellTable = 
		{
			--PRIORITY HEALING
			--self-preservation checks (these casts veto mana concerns b/c it won't matter if you die)
			{ "barkskin",					myHP < 0.50 },
			{ "swiftmend",		    		myHP <= 0.40 and (jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) > 0.5), me },
				--ns use
			{ "nature's swiftness", 		myHP < 0.40 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and myHP < 0.45, me },--ns use moved for guaranteed use
			{ "regrowth",					playerMana > oom and not jps.Moving and myHP < 0.35, me },
			{ "regrowth",					playerMana <= oom and not jps.Moving and myHP < 0.15, me },
			{ "rejuvenation",				playerMana > oom and myHP < 0.45 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },
			{ "rejuvenation",				playerMana <= oom and myHP < 0.25 and (not jps.buff("rejuvenation",me) or jps.buffDuration("rejuvenation",me) < 1), me },	
						
			--tank checks (doubled for two tank)  (these casts veto mana concerns b/c if tanks drop at this point it's generally a wipe)
			{ "ironbark", 					tank1HP < 0.40 and tank1_can_heal, tank1 },
			{ "ironbark", 					tank2HP < 0.40 and tank2_can_heal, tank2 },
			{ "swiftmend",		    		tank1HP <= 0.45 and (jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) > 0) and tank1_can_heal, tank1 },
			{ "swiftmend",		    		tank2HP <= 0.45 and (jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) > 0) and tank2_can_heal, tank2 },
				--ns use
			{ "nature's swiftness", 		tank1HP < 0.45  and tank1_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank1HP < 0.50 and tank1_can_heal, tank1 },--ns use moved for guaranteed use
			{ "nature's swiftness", 		tank2HP < 0.45  and tank2_can_heal},
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and tank2HP < 0.50 and tank2_can_heal, tank2 },--ns use moved for guaranteed use
			{ "regrowth",					not jps.Moving and tank1HP < 0.35 and tank1_can_heal, tank1 },
			{ "regrowth",					not jps.Moving and tank2HP < 0.35 and tank2_can_heal, tank2 },
			{ "rejuvenation",				jps.Moving and tank1HP < 0.50 and (not jps.buff("rejuvenation",tank1) or jps.buffDuration("rejuvenation",tank1) < 1) and tank1_can_heal, tank1 },
			{ "rejuvenation",				jps.Moving and tank2HP < 0.50 and (not jps.buff("rejuvenation",tank2) or jps.buffDuration("rejuvenation",tank2) < 1) and tank2_can_heal, tank2 },
			
			--everyone else
				--ns use
			{ "nature's swiftness", 		defaultHP < 0.25 },
			{ "healing touch", 				(jps.buff("nature's swiftness") or jps.buffStacks("Sage Mender",me) == 5) and defaultHP < 0.35, defaultTarget },
			
			{ "swiftmend",					playerMana > oom and defaultHP < 0.20 and (jps.buff("rejuvenation",defaultTarget) or jps.buff("regrowth",defaultTarget)), defaultTarget },
			
			{ "regrowth",					playerMana > oom and not jps.Moving and defaultHP < 0.20, defaultTarget },
			{ "rejuvenation",				playerMana > oom and jps.Moving and defaultHP < 0.15 and (not jps.buff("rejuvenation",defaultTarget) or jps.buffDuration("rejuvenation",defaultTarget) < 1), defaultTarget },
		
			--rolling rejuv
			{ "rejuvenation",				 rejuvTarget ~=nil, rejuvTarget },
		}
  	end
	
	--testing spelltable
	if(testMode) then --untested
		spellTable =
		{
			--HARMONY CHECK
			{ "regrowth",					harmony_refresh, defaultTarget },
			
		}
	end
	
	


	local spell,target = parseSpellTable(spellTable)
	--untested manual casts
	if (spell == "rebirth") then
		CastSpellByName("rebirth",target)
	elseif (spell == "Incarnation: Tree of Life") then
		CastSpell("33891")
	elseif (spell == "nature's cure") then
		CastSpellByName("Nature's Cure",target)
	elseif (spell == "tranquility") then
		--jps.createTimer("tranq",1)
	end
	
	--tranquility protection
  	if (jps.checkTimer("tranq")~=nil and jps.checkTimer("tranq")>0) then
    	spell = "tranquility"
  	end
	
	jps.Target = target
	-- Debug
  	if (IsAltKeyDown() ~= nil and spell) then
    	print( string.format("Healing: %s, Health: %s, Spell: %s", target, jps.hp(target), spell) )
    elseif(IsAltKeyDown() ~= nil ) then
    	--print( string.format("lifebloom_Tank: %s", lifebloom_Tank) )
  	end
	return spell,target

end, "Default")

function jps.findMeASecondTank(firstTank)
	local allTanks = jps.findTanksInRaid()
	if jps.tableLength(allTanks) < 2 then
		if jps.UnitExists("focus") then return "focus" end
	else
		return allTanks[2]
	end
	return "player"
end

function jps.getNumberOfPlayersUnderXHealth(health, Raid)
	local numUnder = 0
	for unit,_ in pairs(Raid) do
		if Raid[unit]<health then
			numUnder=numUnder+1 
		end
		if IsAltKeyDown() ~= nil then
    			print( string.format("unit %s: health %s", unit, Raid[unit]) )
  			end
	end
	if IsAltKeyDown() ~= nil then
    	--print( string.format("number of players under %s health: %s", health, numUnder) )
  	end
	return numUnder
end

function jps.getRollingRejuvTarget(Raid)
	local health = 2
	local target
	for unit,_ in pairs(Raid) do
		if (Raid[unit]<health and not jps.buff("rejuvenation", unit)) then
			target=unit 
		end
	end
	return target
end

function jps.getRollingLifeBloomTarget(Raid)
	local health = 1.01
	local target
	for unit,_ in pairs(Raid) do
		if (Raid[unit]<health and not jps.buff("lifebloom", unit)) then
			target=unit 
		end
	end
	return target
end

function jps.numberOfPeopleWithBuff(Raid, buff)
	local numBuffed = 0
	for unit,_ in pairs(Raid) do
		if jps.buff(buff, unit) then
			numBuffed=numBuffed+1 
		end
	end
	return numBuffed
end

function getRaidInfo(Raid)
	for unit,_ in pairs(jps.RaidStatus) do
		Raid[unit] = jps.hp(unit)
		if IsAltKeyDown() ~= nil then
    		--print( string.format("number of players under %s health: %s", health, numUnder) )
  		end
	end
	
	return Raid
end

function canHeal(unit)
	if unit=="player" then return true end
	if UnitExists(unit)~=1 then return false end
	if UnitIsVisible(unit)~=1 then return false end
	if UnitIsFriend("player",unit)~=1 then return false end
	if not UnitInRange(unit) then return false end
	if UnitIsDeadOrGhost(unit)==1 then return false end
	if jps.PlayerIsBlacklisted(unit) then return false end
	
	return true
end
--[[ --secondary aoe logic check found in priest_holy.lua
function getNumberOfPlayersNeedHealing(healthPercentage)
	return getNumberOfPlayersNeedHealing(healthPercentage, 0)
end

function getNumberOfPlayersNeedHealing(healthPercentage, forceParty)
	local group_type;
	group_type="raid"; 
	nps = 1; 
	npe = GetNumGroupMembers(); 
	if npe == 0 or forceParty == 1 then 
		group_type="party" 
		nps = 0; 
		npe = GetNumSubgroupMembers(); 
	end

	local noPlayersNeedHealing = 0;
	for i=nps,npe do 
		if i==0 then 
			tt="player" 
		else 
			tt=group_type..i 
		end 
   
		if UnitExists(tt) and UnitInRange(tt) and UnitIsDeadOrGhost(tt)~=1 then 
			local health = UnitHealth(tt) / UnitHealthMax(tt);    
			if health <= healthPercentage then 
				noPlayersNeedHealing = noPlayersNeedHealing + 1           
			end 
		end 
	end 
	return noPlayersNeedHealing;
end
]]

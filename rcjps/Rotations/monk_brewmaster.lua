function monk_brewmaster(self)
	-- Usage info:
	-- Shift to use "Dizzying Haze" at mouse position - AoE threat builder - "Hurl a keg of your finest brew"
	-- Use Ascendance in the level 45 talent

  if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
  
	local chi = UnitPower("player", "12") -- 12 is chi
	local energy = UnitPower("player", "3") -- 3 is energy
	local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")
	local playerHealth = UnitHealth("player")/UnitHealthMax("player")

	local spellTable =  
	{
		{ "Fortifying Brew",       				jps.UseCDs and playerHealth < .4 and not defensiveCDActive }, -- Fortifying Brew if you get low. 3 min CD
	    { "Diffuse Magic",       				jps.UseCDs and playerHealth < .5 and not defensiveCDActive }, -- Diffuse Magic if you get low. (talent based)
	    { "Dampen Harm",       					jps.UseCDs and playerHealth < .6 and not defensiveCDActive }, -- Dampen Harm if you get low. (talent based) - 1.5 min CD
	    
	    { "Touch of Death",       				jps.UseCDs and jps.buff("Death Note") and not jps.MultiTarget }, -- Insta-kill single target when available.

		{ "Expel Harm",							playerHealth < .35 },
		{ "Purifying Brew",						(jps.debuff("Moderate Stagger","player") and jps.buffDuration("Shuffle") > 90) or (jps.debuff("Moderate Stagger","player") and jps.buffDuration("Shuffle") > 10 and playerHealth < .9 ) or (jps.debuff("Moderate Stagger","player") and playerHealth < .77 ) or jps.debuff("Heavy Stagger","player") }, -- Purifying Brew to clear stagger when it's moderate or heavy.
		{ "Elusive Brew", 						(jps.buffStacks("Elusive Brew") >= 6 and playerHealth < .55) or (jps.buffStacks("Elusive Brew") >= 10 and playerHealth < .95) or jps.buffStacks("Elusive Brew") >= 13 }, -- Elusive Brew with 10 or more stacks.

	    -- Interrupt.
	    { "Spear Hand Strike",       			jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= 1) },
	    { "Paralysis",       					jps.shouldKick("target") and jps.Interrupts and (jps.LastCast ~= "Spear Hand Strike") and (jps.castTimeLeft("target") <= 1) },

	    { "Chi Brew",       					chi == 0 }, -- Chi Brew if we have no chi (talent based).
   		{ "Dizzying Haze",               		IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
   		{ "Summon Black Ox Statue",             not jps.buff("Sanctuary of the Ox") and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
	    
	    -- Rushing Jade Wind applies shuffle with a heal and multi-target damage. 
	    --  Use it instead of Blackout kick when it's available. (talent based)
	    { "Rushing Jade Wind",       			jps.MultiTarget or playerHealth < .85 or (not jps.buff("Shuffle") or jps.buffDuration("Shuffle") < 2) }, -- Level 90 talent

	    { "Blackout Kick",       				(not jps.buff("Shuffle") or jps.buffDuration("Shuffle") < 1.5 ) }, -- Blackout Kick if shuffle is missing or about to drop.
		{ "Guard", 								(jps.buff("Power Guard") and playerHealth < .9) or jps.buffDuration("Power Guard") < 2 }, -- Guard when Power Guard buff is available, we're taking some damage.

	    -- Use CDs
	    { jps.DPSRacial,       					jps.UseCDs },
	   	{ jps.useTrinket(1),  					jps.UseCds },
      	{ jps.useTrinket(2),  					jps.UseCds },
		-- { jps.useSlot(10),       				chi > 3 and energy >= 50 },
	    { "Lifeblood",      					jps.UseCDs },
		
		{ "Keg Smash", 							chi < 4 or not jps.debuff("Weakened Blows") }, -- Keg Smash to build some chi and keep the weakened blows debuff up.
	    { "Invoke Xuen, the White Tiger",       jps.UseCDs }, 	    -- Invoke Xuen on cooldown for single-target. (talent based)
        
		{ "Breath of Fire", 					jps.MultiTarget and IsSpellInRange("Tiger Palm", "target") == 1 }, 		-- Breath of Fire is the strongest AoE.

		{ "Expel Harm",							chi < 5 }, 		-- Expel Harm for building some chi and healing if not at full health.
	    { "Tiger Palm",       					not jps.MultiTarget and (not jps.buff("Tiger Power") or jps.buffDuration("Tiger Power") <= 1.5) }, 	    -- Tiger Palm to keep the Tiger Power buff up. No chi cost due to Brewmaster specialization at level 34.
	    
	    { "Zen Sphere",      					playerHealth < .85 }, -- Zen Sphere for threat and heal (talent based).
		{ "Chi Wave",      						}, -- Chi Wave for threat and heal (talent based).
		{ "Chi Burst",      					playerHealth < .85 }, -- Chi Burst for threat and heal (talent based).
		
		{ "Spinning Crane Kick", 				jps.MultiTarget and IsSpellInRange("Tiger Palm", "target") == 1 }, 	-- Spinning Crane Kick for multi-target threat.
		{ "Jab", 								chi < 5 }, -- Jab is our basic chi builder.
	    { "Blackout Kick",       				chi > 4 }, -- Blackout Kick as a chi dump.
		{ "Tiger Palm", 						}, -- Tiger Palm filler.
		
		{ {"macro","/startattack"}, nil, "target" },
  	}
	local spell,target = parseSpellTable(spellTable)
   	
   	return spell
end
   
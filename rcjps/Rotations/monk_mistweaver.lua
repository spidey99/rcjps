function monk_mistweaver(self)

	local spell = nil
	local focus = "focus"
	local me = "player"
	local chi = UnitPower(me, 12)
	
	local tank = jps.findMeATank()
	local playerMana = UnitMana("player")/UnitManaMax("player") 
	
	-- Check if we should Purify
	local cleanseTarget = nil
	cleanseTarget = jps.FindMeADispelTarget({"Curse"},{"Magic"})

	-- lowest friendly
	local defaultTarget = jps.lowestInRaidStatus()
	local defaultTargetHP = jps.hpInc(defaultTarget)

	-- If the tank really needs healing, make him the heal target.
  	if jps.canHeal(tank) and tankHP <= .3 then
    	defaultTarget = tank
  	end
  
  	-- Check for an active defensive CD.
  	local defensiveCDActive = jps.buff("Fortifying Brew") or jps.buff("Diffuse Magic") or jps.buff("Dampen Harm")
  
  	local channeling = UnitChannelInfo("player")
  	local soothing = false
  	if channeling then
    	soothing = channeling:find("Soothing Mist")
  	end
  
  	-- Check if we should detox
  	local dispelTarget = jps.FindMeADispelTarget({"Magic"}, {"Poison"}, {"Disease"})
  
	local possibleSpells = 
	{
    
		{ "Summon Jade Serpent Statue", 		IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		{ "Healing Sphere", 					IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
	--	{ "Healing Sphere", 	IsShiftKeyDown() ~= nil 	and GetCurrentKeyBoardFocus() == nil },
	    
	    -- TODO: Figure out a way to detect Jade Serpent
	    -- Make sure your statue is up at all times.
	-- 	{ "Summon Jade Serpent Statue",  not jps.buff("Eminence") },

		{ "Fortifying Brew",       				jps.UseCDs and jps.hp() < .4 and not defensiveCDActive }, -- Fortifying Brew if you get low.
	    { "Diffuse Magic",       				jps.UseCDs and jps.hp() < .5 and not defensiveCDActive }, -- Diffuse Magic if you get low. (talent based)
	    { "Dampen Harm",       					jps.UseCDs and jps.hp() < .6 and not defensiveCDActive }, -- Dampen Harm if you get low. (talent based)
	--    { "Healthstone",      					jps.hp() < .5 and GetItemCount("Healthstone", 0, 1) > 0 }, -- Healthstone if you get low.
	    { "Touch of Death",       				jps.UseCDs and jps.buff("Death Note") }, -- Insta-kill single target when available
	    { "Thunder Focus Tea",       			jps.UseCDs and tankHP < .6 }, -- Thunder Focus Tea on CD
		{ "Life Cocoon",      					tankHP < .5, tank }, -- Life Cocoon on the tank if he's low.
	    { "Detox",      						dispelTarget ~= nil, dispelTarget }, -- Detox if needed.
	    { "Water Spirit",      					playerMana < .6 and GetItemCount("Water Spirit", 0, 1) > 0 }, -- Water Spirit if you get low on mana.
		
		--UseCDs
		{ jps.useSynapseSprings(),       		jps.UseCDs and defaultTargetHP < .7 }, -- Engineers may have synapse springs on their gloves (slot 10).		
	    { jps.useTrinket(1), 					jps.UseCDs and playerMana < .7 },
		{ jps.useTrinket(2), 					jps.UseCDs and playerMana < .7 },
      	{ jps.DPSRacial,              			jps.UseCDs and defaultHP < 0.5 },
		{ "Lifeblood",      					jps.UseCDs and defaultTargetHP < .7 }, --Lifeblood (requires herbalism)
	    { "Invoke Xuen, the White Tiger",		jps.UseCDs and defaultTargetHP < .55 }, -- Invoke Xuen CD. (talent based)
		
		{ "Mana Tea",      						playerMana < .9 and jps.buffStacks("Mana Tea") >= 2 and not soothing }, 								-- Mana Tea when we have 2 stacks.
		{ "Uplift",      						defaultTargetHP < .75 and jps.buff("Renewing Mist", defaultTarget) and not soothing, defaultTarget }, 	-- Uplift when someone other than tank is taking heavy damage.
		{ "Expel Harm",      					jps.hp() < .85 and chi < 4 and not soothing }, 															-- Expel Harm for Chi when we've taken damage.
		{ "Renewing Mist",      				defaultTargetHP < .9 and not jps.buff("Renewing Mist", defaultTarget) and not soothing, defaultTarget }, -- Renewing Mist when someone is taking mild damage.
		{ "Soothing Mist",      				not soothing and not jps.Moving and defaultTargetHP < .85, defaultTarget }, 							-- Soothing Mist for mild damage.
		{ "Surging Mist",      					defaultTargetHP < .55 and (soothing or jps.buffStacks("Vital Mists") == 5 ), defaultTarget }, 			-- Surging Mist for heavy damage.
		{ "Enveloping Mist",      				defaultTargetHP < .75 and soothing, defaultTarget }, 													-- Enveloping Mist for moderate damage.
	    { "Tiger Palm",      					not jps.buff("Tiger Power") and IsSpellInRange("Tiger Palm", "target") and not soothing }, 				-- Maintain Tiger Power
	    { "Blackout Kick",      				( not jps.buff("Serpent's Zeal") or jps.buffStacks("Serpent's Zeal") < 2 or jps.buffDuration("Serpent's Zeal") < 5 ) and IsSpellInRange("Blackout Kick", "target") and not soothing }, -- Maintain Serpent's Zeal
		{ "Chi Wave",      						defaultTargetHP < .85 and IsSpellInRange("Jab", "target") and not soothing }, 							-- Chi Wave when we're in melee range.
	    { "Spinning Crane Kick",      			jps.MultiTarget and playerMana > .9 and chi < 4 and IsSpellInRange("Jab", "target") and not soothing }, -- Spinning Crane Kick to cap our chi when MultiTarget is toggled.
	    { "Jab",      							playerMana > .9 and chi < 4 and IsSpellInRange("Jab", "target") and not soothing }, 					-- Jab to cap our chi.
	    { "Tiger Palm",      					playerMana > .9 and chi > 2 and IsSpellInRange("Tiger Palm", "target") and not soothing }, 					-- Tiger Palm as a chi dump.
      
		{ {"macro","/startattack"}, nil, "target" },
  	}
	local spell,target = parseSpellTable(spellTable)
  
  	-- Debug
  	if IsAltKeyDown() ~= nil and spell then
    	print( string.format("Healing: %s, Health: %s, Spell: %s", defaultTarget, defaultTargetHP, spell) )
  	end
  
	return spell
end
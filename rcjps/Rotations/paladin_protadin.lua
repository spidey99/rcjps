function paladin_protadin(self)
	--Gocargo

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

	local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
	local targetHealthPercent = UnitHealth("target")/UnitHealthMax("target") * 100
	local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100
	local hPower = UnitPower("player","9")
	local stacks = jps.debuffStacks("Censure","target")
	local censure_time_left = jps.debuffDuration("Censure","target")
	local spell = nil
	local nStance = GetShapeshiftForm(nil);
	local Acharge = jps.buffStacks("Bastion of Glory")
	local targetdistance = CheckInteractDistance("target", 3)
	local mythreat = UnitThreatSituation("player", "target")  

	if(jps.MultiTarget) then
		--aoe rotation
		spellTable =
		{  
			
			-- Basic Setup Stuff
			{ "Righteous Fury",                 not jps.buff("Righteous Fury") },
			
			-- "Oh shit" cd usage
			{ "Lay on Hands",              		myHealthPercent < 10  }, --10 Minute CD
			{ "Guardian of Ancient Kings",  	myHealthPercent < 25  }, --3 Minute CD
			{ "Ardent Defender",                myHealthPercent < 15  }, --3 Minute CD
			--1 Minute CD
	
			--Active Healing
			{ "Word of Glory",            		hPower >= 3 and myHealthPercent < 75 and Acharge >= 5 },
			{ "Eternal Flame",            		hPower >= 3 and myHealthPercent < 75 and Acharge >= 5 },
			{ "Word of Glory",            		hPower >= 3 and myHealthPercent < 40  },
			{ "Eternal Flame",            		hPower >= 3 and myHealthPercent < 40  },
			
			
			  
			-- Check Seal
			{ "Seal of Righteousness",       	nStance ~= 2 },
			
			-- Cleanse
			-- { "Cleanse", 					jps.Defensive },
			-- CDs
			{ "Avenging Wrath",             	jps.UseCDs },
			{ jps.useTrinket(1),      		  	jps.UseCDs },
			{ jps.useTrinket(2),       		  	jps.UseCDs },
			{ "Execution Sentence",             "onCD"},
			{ "Divine Protection",              jps.Defensive and myHealthPercent < 99 },
			{ "Holy Avenger",           		 myHealthPercent < 35 and jps.UseCDs},
	
	
			-- Kicks
			{ "Rebuke",                         jps.shouldKick() },
			{ "Rebuke",                         jps.shouldKick("focus"), "focus" },
			{ "Arcane Torrent",                 jps.shouldKick() and IsSpellInRange("Crusader Strike","target")==1 and jps.LastCast ~= "Rebuke" },
			{ "Avenger's Shield",               jps.shouldKick() and ((jps.LastCast ~= "Rebuke") or (jps.LastCast ~= "Arcane Torrent")) },
			
			-- Holy Power Usage
			{ "Eternal Flame",       			hPower >= 3 and not jps.buff("Eternal Flame") },
			{ "Shield of the Righteous",       	hPower >= 3 },
			
			-- Proc usage
			{ "Avenger's Shield",               jps.buff("Grand Crusader") },
			
			-- Main attack priority
			{ "Holy Wrath",                     "onCD"},
			{ "Hammer of the Righteous",        "onCD"},
			{ "Consecration",                   IsSpellInRange("Crusader Strike","target")==1},
			{ "Judgment",                       "onCD"},
			{ "Avenger's Shield",               "onCD"},  
			{ "Holy Prism",						"onCD"},
			{ "Hammer of Wrath",                "onCD"},
			
			
	
			
	
			{ "Sacred Shield",                 	jps.buff("Sacred Shield")},
			{ "Hand of Purity",               	jps.Defensive			   	 },
	
			--{ "Light's Hammer",             	IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
	
			-- CDs
	
			-- { "Avenging Wrath",             	jps.UseCDs },
			{ jps.useTrinket(1),      		  	jps.UseCDs },
			{ jps.useTrinket(2),       		  	jps.UseCDs },
			{ "Execution Sentence",             			 },    
			
			{ {"macro","/startattack"}, 		nil, "target" },
		}
	else
		-- single target rotation
		spellTable =
		{  
			
			-- Basic Setup Stuff
			{ "Righteous Fury",                 not jps.buff("Righteous Fury") },
			
			-- "Oh shit" cd usage
			{ "Lay on Hands",              		myHealthPercent < 10  }, --10 Minute CD
			{ "Guardian of Ancient Kings",  	myHealthPercent < 25  }, --3 Minute CD
			{ "Ardent Defender",                myHealthPercent < 15  }, --3 Minute CD
			--1 Minute CD
	
			--Active Healing
			{ "Word of Glory",            		hPower >= 3 and myHealthPercent < 75 and Acharge >= 5 },
			{ "Eternal Flame",            		hPower >= 3 and myHealthPercent < 75 and Acharge >= 5 },
			{ "Word of Glory",            		hPower >= 3 and myHealthPercent < 40  },
			{ "Eternal Flame",            		hPower >= 3 and myHealthPercent < 40  },
			
			
			  
			-- Check for Which Seal to use
			{ "Seal of Insight",                nStance ~= 3},
			
			-- Cleanse
			-- { "Cleanse", 					jps.Defensive },
			-- CDs
			{ "Avenging Wrath",             	jps.UseCDs },
			{ jps.useTrinket(1),      		  	jps.UseCDs },
			{ jps.useTrinket(2),       		  	jps.UseCDs },
			{ "Execution Sentence",             "onCD"},
			{ "Divine Protection",              jps.Defensive and myHealthPercent < 99 },
			{ "Holy Avenger",           		jps.UseCDs},
	
	
			-- Kicks
			{ "Rebuke",                         jps.shouldKick() },
			{ "Rebuke",                         jps.shouldKick("focus"), "focus" },
			{ "Arcane Torrent",                 jps.shouldKick() and IsSpellInRange("Crusader Strike","target")==1 and jps.LastCast ~= "Rebuke" },
			{ "Avenger's Shield",               jps.shouldKick() and ((jps.LastCast ~= "Rebuke") or (jps.LastCast ~= "Arcane Torrent")) },
			
			-- Holy Power Usage
			{ "Eternal Flame",       			hPower >= 3 and not jps.buff("Eternal Flame") },
			{ "Shield of the Righteous",       	hPower >= 3 },
			
			-- Proc usage
			{ "Avenger's Shield",               jps.buff("Grand Crusader") },
			
			-- Main attack priority
			{ "Crusader Strike",                "onCD"},
			{ "Judgment",                       "onCD"},
			{ "Avenger's Shield",               "onCD"},  
			{ "Holy Prism",						"onCD"},
			{ "Holy Wrath",                     "onCD"},
			{ "Hammer of Wrath",                "onCD"},
			{ "Consecration",                   IsSpellInRange("Crusader Strike","target")==1},
			
	
			
	
			{ "Sacred Shield",                 	jps.buff("Sacred Shield")},
			{ "Hand of Purity",               	jps.Defensive			   	 },
	
			--{ "Light's Hammer",             	IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
	
			-- CDs
	
			-- { "Avenging Wrath",             	jps.UseCDs },
			{ jps.useTrinket(1),      		  	jps.UseCDs },
			{ jps.useTrinket(2),       		  	jps.UseCDs },
			{ "Execution Sentence",             			 },    
			
			{ {"macro","/startattack"}, 		nil, "target" },
		}
	end
	

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
end

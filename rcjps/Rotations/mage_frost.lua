

function mage_frost(self)

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
	
	local atBuffed = jps.buff("alter time","player")
	local apBuffed = jps.buff("Arcane Power", "player")
	local stacks = jps.debuffStacks("Frostbolt","target")
	local froststacks = jps.debuffStacks("Fingers of Frost","player")
	local fbDuration = jps.debuffDuration("Frostbolt","target")
	local ntDuration = jps.debuffDuration("Nether Tempest", "target")
	local manaGemCharges = GetItemCount("mana gem",0,1)
	local LandShark = GetItemCount("G91 Landshark",0,1) 
	local Sharks = GetItemCooldown(77589)
	local playerMana = UnitMana("player")/UnitManaMax("player")  
	local y=0;for i=1,40 do local n,_,_,_,_,_,_,_,isStealable=UnitAura("target",i);if isStealable==1 then print(n.." on target, steal it!")y=1;end end if y>=1 then end



	local spellTable =
	{
	
			--buffs
	--	{ "macro", "/run PlaySoundFile('Sound\\Character\\Orc\\OrcVocalMale\\OrcMaleCheer01.ogg') "},        jps.LastCast == "Frost Bomb"},
		{ "Frost Armor",     		not jps.buff("Frost Armor","player"), "player" 		    },
		{ "Arcane Brilliance",      not jps.buff("Arcane Brilliance","player"), "player"    },
		
		
	    -- interrupt?
	    -- Lets just check one CD before we go thru everything
	   -- { "Alter Time", 		 not jps.buff("Alter Time", "player")},
	    { "Alter Time", 		 jps.UseCDs and froststacks >= 1 and jps.buff("Brain Freeze", "player") and not jps.buff("Alter Time", "player")},
		{ "Counterspell",        jps.Interrupts and jps.shouldKick("target"), "target"  },
		{ "Spellsteal",		     y==1 and jps.Interrupts 							},
		{ "Presence of Mind",	 			 jps.UseCDs										  			 		},
		-- { "Ice Barrier",      (UnitHealth("player") / UnitHealthMax("player") < 0.10)  and not jps.buff("Ice Barrier","player"), "player" },
		
		-- Key Press Checks
		{ "Evocation",      	 IsShiftKeyDown() ~= nil },
		{ "Blink",				 IsAltKeyDown() ~= nil   },
		-- { "Rune of Power",      IsShiftKeyDown() ~= nil },	
		-- { "Flamestrike",		   IsLeftControlKeyDown() ~= nil },
		
		{ "Frostfire Bolt", 				 not jps.Moving and jps.buff("Brain Freeze", "player")					 				},
		{ "Ice Lance", 						 not jps.Moving and jps.buff("Fingers of Frost", "player")				                },
		
		{ {"macro","/use Brilliant Mana Gem"}, IsUsableItem(81901)==1 and jps.itemCooldown(81901)==0 and jps.mana("player") <= 0.85  },
		{ {"macro","/use Mana Gem"}, IsUsableItem(36799)==1 and jps.itemCooldown(36799)==0 and jps.mana("player") <= 0.85  },
		
				-- 5.2 Maintain Tier Talent Buffs
		{ "Nether Tempest", 				 not jps.debuff("Nether Tempest") or ntDuration <= 2 				},
		{ "Frost Bomb",						 not jps.debuff("Frost Bomb") and not jps.Moving					 				},
		{ "Living Bomb",					 not jps.debuff("Living Bomb") 						 				},
		
		-- Multi Target Check
		{ { "macro","/use G91 Landshark"},    LandShark >= 1 and Sharks == 0 and jps.Defensive and jps.MultiTarget and not jps.Moving },
		{ "Frozen Orb", 					 jps.MultiTarget and froststacks < 2									},
		{ "Icy Veins",			             jps.MultiTarget and jps.UseCDs 									    },
		
		-- CDs
		
		{ "Mirror Image",    	 jps.UseCDs },
		{ jps.useTrinket(1),     jps.UseCDs	},
		{ jps.useTrinket(2),     jps.UseCDs	},
		
				-- 5.2 Not Moving
		{ "Frostfire Bolt", 				 jps.buff("Brain Freeze", "player")					 				},
		{ "Ice Lance", 						 jps.buff("Fingers of Frost", "player")				                },
		{ "Rocket Barrage",																		 				},

		
		
		-- 5.2 Moving 
		
		{ "Ice Floes",					     jps.Moving											 	},
		{ "Fire Blast", 					 jps.Moving 										 	},
		{ "Ice Lance", 						 jps.Moving											 	},

	    -- Filler Spells
		{ "Frostbolt",  			not jps.Moving													},
		

	}

 local spell,target = parseSpellTable(spellTable)
   if spell == "Flamestrike" or spell == "Rune of Power" then
       jps.Cast( spell )
       jps.groundClick()
   end

   jps.Target = target
   return spell
end

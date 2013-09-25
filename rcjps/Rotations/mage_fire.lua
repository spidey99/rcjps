function mage_fire(self)

	if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
	
	local playerMana = UnitMana("player")/UnitManaMax("player")  

	local spellTable = 
	{
	
			--buffs
		{ "Molten Armor",     		not jps.buff("Molten Armor","player") 		},
		{ "Arcane Brilliance",     	not jps.buff("Arcane Brilliance","player") 	},
		{ "Temporal Shield", 		jps.Defensive											},
		
			--Power CD's
		{ "Alter Time",				jps.UseCDs and jps.buff("Pyroblast!", "player")  and not jps.buff("Evocation", "player") and not jps.buff("Alter Time") },
		{ "Mirror Image",     	    jps.UseCDs 									},
		{ jps.useTrinket(1),   		jps.UseCDs									},
		{ jps.useTrinket(2),   		jps.UseCDs									},
		{ jps.DPSRacial,      		jps.UseCDs and jps["DPS Racial"]			},	
		{ "Presence of Mind",   		jps.UseCDs							    },
		  -- Lets Go Ahead and Make a Rune at the Top
		{ "Evocation",      	 IsShiftKeyDown() ~= nil },
		
		
		  -- Mana Regen 5.2
		{ {"macro","/use Brilliant Mana Gem"}, IsUsableItem(81901)==1 and jps.itemCooldown(81901)==0 and jps.mana("player") <= 0.85  },
			
			--Interupt
		{ "Counterspell",     		jps.Interrupts and jps.shouldKick("target") },
		
			--Top Priority DPS Not Moving
		--{ "Incanter's Ward",       																	   },
		{ "Inferno Blast",    		jps.buff("Heating Up","player")   								   },
		--{ "Spell Steal",											   },
		--{ "Evocation",       		jps.mana () <= .50 and jps.UseCDs and not jps.Moving and not jps.buff("Incanter's Ward")   },
	    { "Living Bomb",      		not jps.Moving and jps.debuffDuration("Living Bomb") <= 2 							   },
	    { "Nether Tempest",      	not jps.Moving and jps.debuffDuration("Nether Tempest") <= 2 and jps.MultiTarget							   },
	    { "Combustion",       		not jps.Moving and jps.debuff("Ignite") 				   							   },
	    
	    { "Pyroblast",       		 jps.buff("Pyroblast!","player") 								   },
	    { "Inferno Blast",    		not jps.Moving and jps.buff("Heating Up","player") 								   },
		{ "Fireball",         		not jps.Moving						  										   },
		
			--Top Priority When Moving	    
	    --{ "Incanter's Ward",       																	   },
	    { "Inferno Blast",    		  								   },
	    { "Living Bomb",      		 jps.Moving and jps.debuffDuration("Living Bomb") <= 2 							   },
	    { "Nether Tempest",      	jps.MultiTarget and  jps.Moving and jps.debuffDuration("Nether Tempest") <= 2 							   },
	    { "Combustion",       		 jps.Moving and jps.debuff("Ignite") 				   							   },								   
	    { "Inferno Blast",    		 jps.Moving and jps.buff("Heating Up","player") 								   },
		{ "Scorch",         		 jps.Moving						  										   },
											
		--aoe
		{ "Dragon's Breath",  		jps.MultiTarget and CheckInteractDistance("target", 3) == 1		   }, 
		--{ "Flamestrike",      		IsShiftKeyDown() ~= nil 												   },
			
		
	}
	
   local spell,target = parseSpellTable(spellTable)
   if spell == "Rune of Power" then
       jps.Cast( spell )
       jps.groundClick()
   end

   jps.Target = target
   return spell
end

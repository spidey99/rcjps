function warlock_demo(self)

if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local mana = UnitMana("player")/UnitManaMax("player")
   local cpn_duration = jps.debuffDuration("corruption")
   local cur_duration = jps.debuffDuration("curse of the elements")
   local meta_duration = jps.buffDuration("metamorphosis")
   local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
   local dpower = UnitPower("player",15)
   local spell = nil
   local spellTable =
    
    {
    
    -- Cool Down Checking
    { "Grimoire: Felguard", 			jps.UseCDs 														},
    { "Summon Doomguard",				jps.UseCDs														},
    
    -- Key Press Checks
    { "Harvest Life",      				IsShiftKeyDown() ~= nil and jps.MultiTarget						},
    { "Summon Infernal",      			IsShiftKeyDown() ~= nil 										},
    { "Life Tap",      					IsAltKeyDown() ~= nil 											},
    
    -- Metamorphosis Phase
    { {"macro","/cast Metamorphosis"},	dpower <= 750 and jps.buff("Metamorphosis") 					}, -- Takes us back to Regular DPS roation
    { "Metamorphosis",					dpower >= 900 and not jps.buff("Metamorphosis") 				},
    { "Doom",							jps.buff("Metamorphosis") and not jps.debuff("Doom", "target")  },
    { "Soul Fire", 						jps.buff("Molten Core")										   	},
    { "Touch of Chaos",					cpn_duration <= 3 and jps.buff("Metamorphosis")					},
    { "Dark Soul: Knowledge",			jps.buff("Metamorphosis") 										},
    { "Void Ray",						jps.MultiTarget and jps.buff("Metamorphosis") 					},
    
    -- Demonic Fury Builders
    { "Corruption",						not jps.debuff("Corruption", "target")							},
    { "Fel Flame", 						jps.Moving														},
    { "Curse of the Elements",			not jps.debuff("Curse of the Elements", "target")				},  
    { "Hand of Gul'dan",				not jps.debuff("Shadowflame", "target")							},
    { "Shadow Bolt",					not jps.Moving													},
   
      
   
   }
   
      if spell == "Summon Infernal" or spell == "Insert Other Spell Here" then
       jps.Cast( spell )
       jps.groundClick()
   end
   
     local spell = parseSpellTable( spellTable )
      return spell
end
function paladin_protadin(self)
   --Gocargo
   
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
   local targetHealthPercent = UnitHealth("target")/UnitHealthMax("target") * 100
   local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100
   local hPower = UnitPower("player","9")
   local spell = nil
   local nStance = GetShapeshiftForm(nil);
   local Acharge = jps.buffStacks("Bastion of Glory")
   local targetdistance = CheckInteractDistance("target", 3)

    spellTable =
   {    
      -- Check for Which Seal to use

  
      { "Seal of Truth",          		  not jps.MultiTarget and not jps.Defensive and  nStance ~= 1 }, 
      { "Seal of Righteousness",          jps.MultiTarget and not jps.Defensive and   nStance ~= 2 }, 
      { "Seal of Insight",                jps.Defensive and  nStance ~= 3 }, 
      
       { "Word of Glory", 				   IsShiftKeyDown() ~= nil }, 
      -- { "Cleanse", 					   jps.Defensive },
       { "Crusader Strike",                },
      
       
       
      -- Defensive Cooldowns
      { "Lay on Hands",                   myHealthPercent < 10  }, --10 Minute CD
      --{ "Guardian of Ancient Kings",      myHealthPercent < 25  }, --3 Minute CD
      { "Ardent Defender",                myHealthPercent < 30  }, --3 Minute CD
     -- { "Seal of Insight",                (myHealthPercent < 50 or myManaPercent < 40 ) and nStance ~= 3 },
      { "Divine Protection",              myHealthPercent < 60  }, --1 Minute CD

      --Active Mitgations
      { "Word of Glory",                  myHealthPercent < 75 and jps.buff("Shield of the Righteous") },
      { "Word of Glory",                  myHealthPercent < 92 and Acharge > 5 and hPower >= 3 },
      { "Shield of the Righteous",        hPower >= 3 },

      -- Kicks
      { "Rebuke",                         jps.shouldKick() },
      { "Rebuke",                         jps.shouldKick("focus"), "focus" },
      { "Arcane Torrent",                 jps.shouldKick() and IsSpellInRange("Crusader Strike","target")==1 and jps.LastCast ~= "Rebuke" },
      { "Avenger's Shield",               jps.shouldKick() and ((jps.LastCast ~= "Rebuke") or (jps.LastCast ~= "Arcane Torrent")) },
      
      -- Basic Setup Stuff
      { "Righteous Fury",                 not jps.buff("Righteous Fury") },
     
      { "Sacred Shield",                  not jps.buff("Sacred Shield") },
      { "Hand of Purity",                  },
      --{ "Light's Hammer",                 IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      
      -- CDs
      { "Holy Avenger",                   jps.UseCDs },
     -- { "Avenging Wrath",                 jps.UseCDs },
      { jps.useTrinket(1),      		  jps.UseCDs },
      { jps.useTrinket(2),       		  jps.UseCDs },
      { "Execution Sentence",             jps.UseCDs },    
      -- Damage
     
      { "Hammer of the Righteous",        }, --(not jps.debuff("Weakened Blows")) or jps.MultiTarget }, 
      { "Consecration",                   }, 
      
      { "Judgment",                       },
      { "Avenger's Shield",               },      
      
      { "Hammer of Wrath",                },
     
      { "Holy Wrath",                     },

      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
    if nStance <= 7 then print (nStance);
     
   end
   jps.Target = target
   return spell
end

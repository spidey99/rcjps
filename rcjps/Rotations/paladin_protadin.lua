function paladin_protadin(self)
   --Gocargo
   
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
   local targetHealthPercent = UnitHealth("target")/UnitHealthMax("target") * 100
   local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100
   local hPower = UnitPower("player","9")
   local stacks = jps.debuffStacks("Censure","target")
   local spell = nil
   local nStance = GetShapeshiftForm(nil);
   local Acharge = jps.buffStacks("Bastion of Glory")
   local targetdistance = CheckInteractDistance("target", 3)
   local mythreat = UnitThreatSituation("player", "target")  

    spellTable =
   {    
      -- Check for Which Seal to use
       { "Seal of Truth",          	       not jps.MultiTarget and   nStance ~= 1 and stacks < 5 }, 
      --{ "Seal of Insight",                not jps.MultiTarget and jps.Defensive and nStance ~= 3 },
       { "Seal of Righteousness",          jps.MultiTarget  and nStance ~= 2 }, 
       { "Seal of Insight",                nStance ~= 3 and stacks == 5	and not jps.MultiTarget						 },
       { "Word of Glory", 				   IsAltKeyDown() ~= nil }, 
      -- { "Cleanse", 					  jps.Defensive },
       { "Shield of the Righteous",				 IsShiftKeyDown() ~= nil   },
        { "Divine Protection",              IsShiftKeyDown() ~= nil and jps.LastCast ~= "Shield of the Righteous" },
      -- { "Cleanse", 						    IsControlKeyDown() ~= nil },
       { "Holy Avenger",                    jps.UseCDs				 },
       
       
             -- Kicks
      { "Rebuke",                         jps.shouldKick() },
      { "Rebuke",                         jps.shouldKick("focus"), "focus" },
      { "Arcane Torrent",                 jps.shouldKick() and IsSpellInRange("Crusader Strike","target")==1 and jps.LastCast ~= "Rebuke" },
      { "Avenger's Shield",               jps.shouldKick() and ((jps.LastCast ~= "Rebuke") or (jps.LastCast ~= "Arcane Torrent")) },
      { "Hammer of Wrath",                },
        { "Shield of the Righteous",         hPower >= 5 },
       { "Hammer of the Righteous",       not jps.debuff("Weakened Blows", "target") or jps.MultiTarget }, 
       { "Crusader Strike",                },
       { "Avenger's Shield",               jps.buff("Grand Crusader") },
       { "Judgment",                       },
       { "Avenger's Shield",              not jps.Interrupts  },   
       
      -- Defensive Cooldowns
     -- { "Lay on Hands",                   myHealthPercent < 10  }, --10 Minute CD
      --{ "Guardian of Ancient Kings",      myHealthPercent < 25  }, --3 Minute CD
      { "Ardent Defender",                myHealthPercent < 15  }, --3 Minute CD
     -- { "Seal of Insight",                (myHealthPercent < 50 or myManaPercent < 40 ) and nStance ~= 3 },
      --1 Minute CD

      --Active Mitgations
      --{ "Word of Glory",                  myHealthPercent < 75 and jps.buff("Shield of the Righteous") },
      --{ "Word of Glory",                  myHealthPercent < 40 and Acharge >= 4  },
      
     


      
      -- Basic Setup Stuff
      { "Righteous Fury",                 not jps.buff("Righteous Fury") },
     
     
     
      { "Sacred Shield",                   jps.Defensive and not jps.buff("Sacred Shield")				 },
      { "Hand of Purity",                  jps.Defensive			   	 },
       
      --{ "Light's Hammer",                 IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      
      -- CDs
     
     -- { "Avenging Wrath",                 jps.UseCDs },
      { jps.useTrinket(1),      		  jps.UseCDs },
      { jps.useTrinket(2),       		  jps.UseCDs },
      { "Execution Sentence",             			 },    
      -- Damage
     
     
      { "Consecration",                   jps.MultiTarget and IsSpellInRange("Crusader Strike","target")==1 }, 
      
    
      { "Holy Wrath",                     },

      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end

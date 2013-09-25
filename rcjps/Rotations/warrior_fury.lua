function warrior_fury(self)
-- Modified by FuzzyHobo

-- Shift: 	Heroic Leap
-- Control:	Hamstring
-- Alt:		Staggering Shout, Piercing Howl

if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local spell = nil
   local targetHealth = UnitHealth("target")/UnitHealthMax("target") *100
   local playerHealth = UnitHealth("player")/UnitHealthMax("player") *100
   local nRage = jps.buff("Berserker Rage","player")
   local nPower = UnitPower("Player",1)
   
   if UnitThreatSituation("player") == 3 and cd("Die By The Sword") == 0 and GetNumSubgroupMembers() > 0 then
      spell = "Die By The Sword"

   else

   local spellTable = 
   {

      { nil,                IsSpellInRange("Pummel","target") == 0 },
    --Burst
      { "Battle Shout" ,    not jps.buff("Battle Shout") and not jps.buff("Roar of Courage") and not jps.buff("Horn of Winter") and not jps.buff("Strength of earth totem") },
      { "Bloodbath",        jps.UseCDs and (jps.cd("Colossus Smash") < 2 or jps.debuffDuration("Colossus Smash") >= 5) and (IsSpellInRange("Pummel", "target") == 1) },
      { "Recklessness",     jps.UseCDs and jps.buff ("Bloodbath") and (targetHealth < 20 or targetHealth >= 35) and IsSpellInRange("Pummel", "target") == 1},
    --  { "Avatar",           jps.UseCDs and IsSpellInRange("Pummel", "target") == 1 },
      { "Skull Banner",     jps.UseCDs and jps.buff("Recklessness","player") },
      { "Berserker Rage",   jps.UseCDs and (not nRage or (jps.buffStacks("Raging Blow") == 2 and targetHealth > 20 )) or (jps.buffDuration("Recklessness") >= 10 and not jps.buff("Raging Blow")) and (IsSpellInRange("Pummel", "target") == 1) },
      
      --{ "Lifeblood",        IsSpellInRange("Pummel", "target") == 1},  --if I'm an Herbalist.  Otherwise, ignore me!!
      { jps.useTrinket(1),  jps.UseCds },
      { jps.useTrinket(2),  jps.UseCds },
	  
	  -- User Intervention
      { "Hamstring",        IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- Added by FuzzyHobo
      { "Staggering Shout", IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 	-- Added by FuzzyHobo
	  { "Piercing Howl",  	IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 	-- Added by FuzzyHobo

    --Interrupts
      { "Pummel",           jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= 1) },
      { "Disrupting Shout", jps.shouldKick("target") and jps.Interrupts and (jps.LastCast ~= "Pummel") and (jps.castTimeLeft("target") <= .4) },
      { "Pummel",           jps.shouldKick("focus") and jps.Interrupts and (jps.castTimeLeft("focus") <= 1), "focus" },
      { "Disrupting Shout", jps.shouldKick("focus") and jps.Interrupts and (jps.LastCast ~= "Pummel") and (jps.castTimeLeft("focus") <= .4), "focus" },

    --Rage Dump
      { "Cleave",           jps.MultiTarget and (jps.debuff("Colossus Smash") and nPower >= 40 and targetHealth >= 20 ) or nPower >= 110 },
      { "Heroic Strike",    not jps.MultiTarget and (jps.debuff("Colossus Smash") and nPower >= 40 and targetHealth >= 20 ) or nPower >= 110 },

    --Multi-Target
      { "Whirlwind",        jps.MultiTarget and IsSpellInRange("Pummel", "target") == 1 },
      { "Raging Blow",      jps.MultiTarget and jps.buff("Meat Cleaver") and nPower>10 },

    --Single Target
      { "Heroic Leap",      IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      { "Victory Rush",     playerHealth < 75 },

      { "Raging Blow",      jps.buffStacks("Raging Blow!") == 2 and targetHealth >=20 and jps.debuff("Colossus Smash") },
      { "Bloodthirst",      (not (targetHealth < 20 and jps.debuff("Colossus Smash") and nPower >= 30)) },  -- May be broke
      { "Wild Strike",      jps.buff("Bloodsurge") and targetHealth >= 20 and jps.cooldown("Bloodthirst") <= 1  },
      { "Dragon Roar",      not jps.debuff("Colossus Smash") and jps.buff ("Bloodbath") and IsSpellInRange("Pummel", "target") == 1 },
      { "Colossus Smash",   },

      { "Execute",          nRage or jps.debuff("Colossus Smash") or nPower > 90 or targetHealth < 5 or jps.buff("Recklessness","player") },
      { "Raging Blow",      jps.buffStacks("Raging Blow!") == 2 or (jps.buff("Raging Blow!") and (jps.debuff("Colossus Smash") or jps.cd("Colossus Smash") >= 3 or (jps.cd("Bloodthirst") >= 1 and jps.buffDuration("Raging Blow!") <= 3 ))) },
      { "Storm Bolt"        },      
      { "Wild Strike",      jps.buff("Bloodsurge") },
      { "Shockwave",        },
      { "Heroic Throw",     not jps.debuff("Colossus Smash") },
      { "Battle Shout",     nPower < 70 and not jps.debuff("Colossus Smash") },
      --{ "Bladestorm",       jps.cooldown("Colossus Smash") >= 5 and not jps.debuff("Colossus Smash") and jps.cooldown("Bloodthirst") >= 2 and targetHealth >= 20 },
      { "Wild Strike",      jps.debuff("Colossus Smash") and targetHealth >= 20 },
      { "Impending Victory",targetHealth >= 20 },
      { "Wild Strike",      jps.cooldown("Colossus Smash") >= 2 and nPower >= 80 and targetHealth >= 20 },
      { "Battle Shout",     nPower < 70 },
      
      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   return parseSpellTable(spellTable)
   end
   
   return spell
end
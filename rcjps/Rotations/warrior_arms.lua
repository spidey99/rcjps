function warrior_arms(self)
--Gocargo
-- Modified by FuzzyHobo

-- Shift: 	Heroic Leap
-- Control:	Hamstring
-- Alt:		Staggering Shout, Piercing Howl

   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local spell = nil
   local targetHealth = UnitHealth("target")/UnitHealthMax("target") *100
   local playerHealth = UnitHealth("player")/UnitHealthMax("player") *100
   local nRage = jps.buff("Berserker Rage","player")
   local nPower = UnitPower("Player",1) -- Rage est PowerType 1

   if UnitThreatSituation("player") == 3 and cd("Die By The Sword") == 0 and GetNumSubgroupMembers() > 1 then
      spell = "Die By The Sword"

   else

   local spellTable = 
   {

      --Burst
      { "Battle Shout" ,      not jps.buff("Battle Shout") and not jps.buff("Roar of Courage") and not jps.buff("Horn of Winter") and not jps.buff("Strength of earth totem") },
      { "Bloodbath",          jps.UseCDs and (jps.cd("Colossus Smash") < 2 or jps.debuffDuration("Colossus Smash") >= 5) and (IsSpellInRange("Pummel", "target") == 1) },
      { "Recklessness",       jps.UseCDs and jps.buff ("Bloodbath") and (targetHealth < 20 or targetHealth >= 35) and IsSpellInRange("Pummel", "target") == 1},
    --  { "Avatar",           jps.UseCDs and IsSpellInRange("Pummel", "target") == 1 },
      { "Skull Banner",       jps.UseCDs and jps.buff("Recklessness","player") },
      { "Berserker Rage",     jps.UseCDs and not nRage and nPower <= 110 and (IsSpellInRange("Pummel", "target") == 1) },
      --{ "Lifeblood",        IsSpellInRange("Pummel", "target") == 1},  --if I'm an Herbalist.  Otherwise, ignore me!!
      { jps.useTrinket(1),    jps.UseCDs },
      { jps.useTrinket(2),    jps.UseCDs },

    --Interrupts
      { "Pummel",             jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= .6) },
      { "Disrupting Shout",   jps.shouldKick("target") and jps.Interrupts and (jps.LastCast ~= "Pummel") and (jps.castTimeLeft("target") <= .4) },
      { "Pummel",             jps.shouldKick("focus") and jps.Interrupts and (jps.castTimeLeft("focus") <= .6), "focus" },
      { "Disrupting Shout",   jps.shouldKick("focus") and jps.Interrupts and (jps.LastCast ~= "Pummel") and (jps.castTimeLeft("focus") <= .4), "focus" },
	  
	  -- User Intervention
      { "Hamstring",          IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- Added by FuzzyHobo
      { "Staggering Shout",   IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 	-- Added by FuzzyHobo
	  { "Piercing Howl",  	  IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 	-- Added by FuzzyHobo

      --Multi Target
      { "Sweeping Strikes" ,  jps.MultiTarget and IsSpellInRange("Slam", "target") == 1 },
      { "Cleave" ,            jps.MultiTarget and (((jps.debuff("Colossus Smash") and nPower >= 70) and targetHealth >= 20) or nPower >= 105) },

      --Single
      { "Heroic Leap",        IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      { "Heroic Strike" ,     (((jps.debuff("Colossus Smash") and nPower >= 70) and targetHealth >= 20) or nPower >= 105) and not jps.MultiTarget },
      { "Victory Rush" ,      playerHealth < 70 and targetHealth > 20 },
      { "Impending Victory" , playerHealth < 70 and targetHealth > 20 },
      { "Mortal Strike" ,     },
      { "Colossus Smash" ,    jps.debuffDuration("Colossus Smash") <= 1.5 },
      { "Execute" ,           jps.debuff("Colossus Smash") },
      { "Dragon Roar" ,       IsSpellInRange("Slam", "target") == 1 },
      { "Impending Victory" , targetHealth >= 20 },
      { "Execute" ,           },
      { "Whirlwind",          nPower >= 90 and jps.MultiTarget and targetHealth >= 20},
      { "Slam" ,              nPower >= 90 and not jps.MultiTarget and targetHealth >= 20 },
      { "Overpower" ,         },
      { "Whirlwind" ,         nPower >= 40 and jps.MultiTarget and targetHealth >= 20 },
      { "Slam" ,              nPower >= 40 and not jps.MultiTarget and targetHealth >= 20 },
      { "Battle Shout" ,      nPower <= 85 },
      { "Heroic Throw" ,      },

      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   return parseSpellTable(spellTable)
   end
   
   return spell
end
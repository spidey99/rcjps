function warrior_prot(self)
-- Gocargo
-- Modified by FuzzyHobo

-- Shift: 	Heroic Leap
-- Control:	Hamstring
-- Alt:		Staggering Shout, Piercing Howl

   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end
   
   local spell = nil
   local playerHealth = UnitHealth("player")/UnitHealthMax("player")
   local nRage = UnitBuff("player","Berserker Rage")
   local nPower = UnitPower("Player",1)
   local stackWeakened = jps.debuffStacks("Weakened Armor")
   local LandShark = GetItemCount("G91 Landshark",0,1) 
   local Sharks = GetItemCooldown(77589)

   local spellTable = 
   {
      --Rage Generation
      { "Battle Shout" ,         not jps.buff("Battle Shout") and not jps.buff("Roar of Courage") and not jps.buff("Horn of Winter") and not jps.buff("Strength of earth totem") },
      { "Berserker Rage" ,       not nRage , "player" },
      
      --Active Mitigation
      { "Shield Wall" ,          playerHealth < 0.39 , "player" },
      { "Last Stand" ,           playerHealth < 0.35  and not jps.buff("Shield Wall"), "player" },
      { "Impending Victory" ,    playerHealth < 0.85 },
      { jps.DPSRacial,           jps.UseCDs },
      { jps.useTrinket(1),       jps.UseCDs and playerHealth < 0.9 },
      { jps.useTrinket(2),       jps.UseCDs and jps.buff("Shield Block") and playerHealth < 0.85 and not jps.Buff("Protection of the Celestials") },
 --   { "Lifeblood" ,            playerHealth < 0.75 , "player" },
      { "Shield Barrier" ,       ((GetNumSubgroupMembers() > 3 and nPower > 60) or (playerHealth < 0.91 and nPower > 70) or (playerHealth < 0.74 and nPower > 40) or playerHealth < 0.55) and jps.Defensive },
      { "Shield Block" ,         ((UnitThreatSituation("player","target") == 3 or UnitThreatSituation("player","target") == 2) and not jps.buff("Shield Block")) and not jps.Defesnive, "player" },
      { "Shield Barrier" ,       (UnitThreatSituation("player","target") == 3 or playerHealth < .92 ) and not jps.Defesnive and (nPower == 120 or (nPower >= 95 and jps.buff("Sword and Board") and jps.cd("Shield Block") > 1) or (nPower >= 100 and jps.cd("Battle Shout") < jps.cd("Shield Block")) or (nPower >= 105 and jps.cd("Revenge") < jps.cd("Shield Block")) or (nPower >= 110 and jps.cd("Berserker Rage") < jps.cd("Shield Block"))) },
      { "Demoralizing Shout" ,   ((playerHealth < 0.90 and not (jps.buff("Shield Block") or jps.buff("Shield Barrier"))) or (playerHealth < 0.70 )) and IsSpellInRange("Shield Slam", "target")==1 },
 --   { {"macro","/use 13"},     canUseTrinket1 ~= nil and Trinket1ready == 0 }, -- 0 = no CD = trinket is ready 
 --   { {"macro","/use 14"},     canUseTrinket2 ~= nil and Trinket2ready == 0 }, 
 
      --Misc
 --   { "Enraged Regeneration" , nRage and playerHealth < 0.80 , "player" },   
 --   { "Charge" ,               jps.UseCDs , "target" },
 --   { "Taunt" ,                UnitThreatSituation("player","target")~=3 , "target" },
      --{ "Heroic Leap",           IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      { "Mocking Banner",        IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      
      --Interrupts
      { "Pummel",                jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= .6) },
      { "Disrupting Shout",      jps.shouldKick("target") and jps.Interrupts and (jps.LastCast ~= "Pummel") and (jps.castTimeLeft("target") <= .4) },
      { "Pummel",                jps.shouldKick("focus") and jps.Interrupts and (jps.castTimeLeft("focus") <= .6), "focus" },
      { "Disrupting Shout",      jps.shouldKick("focus") and jps.Interrupts and (jps.LastCast ~= "Pummel") and (jps.castTimeLeft("focus") <= .4), "focus" },
      { "Spell Reflection" ,     UnitThreatSituation("player","target") == 3 and (UnitCastingInfo("target") or UnitChannelInfo("target")), "target" },
	  
	  -- User Intervention
      { "Hamstring",          IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, -- Added by FuzzyHobo
      { "Staggering Shout",   IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 	-- Added by FuzzyHobo
	  { "Piercing Howl",  	  IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil }, 	-- Added by FuzzyHobo
      
      --Damage CDs
      --{ "Avatar" ,               jps.UseCDs and IsSpellInRange("Shield Slam", "target") == 1 },
      { "Bloodbath" ,            jps.UseCDs and jps.cd("Shield Slam") < 1 and IsSpellInRange("Shield Slam", "target") == 1 },
      { "Recklessness" ,         jps.UseCDs and jps.buff ("Bloodbath") and IsSpellInRange("Shield Slam", "target") == 1 },
      { "Skull Banner" ,         jps.UseCDs and jps.buff("Recklessness","player") and not jps.buff("Demoralizing Banner") and IsSpellInRange("Shield Slam", "target") == 1 },

      --Damage
      --{ "Heroic Leap",           IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      { "Shield Slam" ,          },
      { "Revenge" ,              not jps.MultiTarget },
 --   { "Victory Rush" ,         nVictory, "target" },
      
         --MultiTarget
         { "Shockwave" ,            jps.MultiTarget and IsSpellInRange("Shield Slam", "target") == 1 },
         { { "macro","/use G91 Landshark"},    LandShark >= 1 and Sharks == 0 and jps.MultiTarget },
         { "Thunder Clap" ,         jps.MultiTarget and IsSpellInRange("Shield Slam", "target") == 1 },
         { "Dragon Roar" ,          jps.MultiTarget and IsSpellInRange("Shield Slam", "target") == 1 },
         { "Battle Shout",          nPower < 100 },
         { "Revenge" ,              jps.MultiTarget },
         { "Cleave" ,               jps.MultiTarget and (jps.buff("Ultimatum") or jps.buff("Incite")) },
         --{ "Cleave" ,               jps.MultiTarget and nPower >= 90 },    

      --Single
      { "Heroic Strike" ,        (jps.buff("Ultimatum") or jps.buff("Incite")) and not jps.MultiTarget },
      { "Thunder Clap" ,         not jps.debuff("Weakened Blows") and IsSpellInRange("Shield Slam", "target") == 1 },        
      { "Devastate" ,            stackWeakened < 3 or jps.debuffDuration("Weakened Armor") < 2 },
      { "Battle Shout",          nPower < 100 },
      { "Dragon Roar" ,          jps.buff ("Bloodbath") and IsSpellInRange("Shield Slam", "target") == 1 },
      { "Execute" ,              playerHealth >= .78 },
      --{ "Execute" ,              nPower > 85 },
      --{ "Shockwave" ,            IsSpellInRange("Shield Slam", "target") == 1 },
      --{ "Heroic Strike" ,        nPower >= 100 , "target" },
      { "Devastate" ,            },
      
      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   jps.Target = target
   return spell
end
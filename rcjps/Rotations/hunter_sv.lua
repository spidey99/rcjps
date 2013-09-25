function hunter_sv(self)

if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

local spell = nil
local targetHealth = UnitHealth("target")/UnitHealthMax("target")
local petHealth = UnitHealth("pet")/UnitHealthMax("pet")
local fStacks = jps.buffStacks("Frenzy","player")
local sps_duration = jps.debuffDuration("serpent sting")
local focus = UnitMana("player")
local pet_focus = UnitMana("pet")
local pet_attacking = IsPetAttackActive()

-- Misdirecting to pet if not in a party
if GetNumSubgroupMembers() == 0 and jps.Opening and not UnitIsDead("pet") then
   jps.Target = "pet"
   spell = "Misdirection"
   jps.Opening = false  
   
-- Misdirecting to focus if set
elseif jps.Opening and UnitExists("focus") and cd("Misdirection") then
   print("Misdirecting to",GetUnitName("focus", showServerName)..".")
   jps.Target = "focus"
   spell = "Misdirection"
   jps.Opening = false
   
-- Main rotation (Shift to launch trap in Multi Mob situations)
elseif UnitIsDead("pet") then
   spell = "Revive Pet"

--SIMCRAFT
else

local spellTable = 
{
   { "aspect of the iron hawk",  not jps.Moving and not jps.buff("aspect of the iron hawk") },
   --{ "hunter's mark",             (targetHealth > 80 and (targetHealth > 50 or UnitHealthMax("target") > 25000 )) not jps.debuff("hunter's mark") },
   
   { "Explosive Trap",           jps.MultiTarget and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
   { "Snake Trap",               IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

   --Interrupts
   { "Silencing Shot",           jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= 1) , "target" },
   { "Scatter Shot",             IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

   { jps.DPSRacial,              jps.UseCDs },
   { "Lifeblood",                jps.UseCDs },
   { "a murder of crows",        jps.UseCDs },

   { "blink strike",             },
   { "lynx rush",                },
   { "Explosive Shot",           jps.buff("Lock and Load") },
   { "Glaive Toss",              },    --level 90 talent
   { "Powershot",                },    --level 90 talent
   { "Barrage",                  },    --level 90 talent

   { "Multi-Shot",               jps.MultiTarget },
   { "Cobra Shot",               jps.MultiTarget },

   { "Mend Pet",                 petHealth < .60 and not jps.buff("Mend Pet","pet") },
   { "Serpent Sting",            not jps.myDebuff("serpent sting") },
   { "Explosive Shot"            },
   { "Kill Shot",                },
   { "Black Arrow",              not jps.myDebuff("Black Arrow") },
   { "Multi-Shot",               sps_duration < 2 and jps.buff("Thrill of the Hunt") },
   { "Arcane Shot",              jps.buff("Thrill of the Hunt") },
   { "Rapid Fire",               jps.UseCDs },
   { "Dire Beast",               focus <= 90 },
   { "Stampede",                 jps.UseCDs and (jps.buff("Rapid Fire") or jps.bloodlusting() or targetHealth < 35) },
   { "Readiness",                jps.UseCDs and jps.cooldown("Rapid Fire") > 2 },
   { "Cobra Shot",               sps_duration < 6 },
   { "Arcane Shot",              focus >= 67 or jps.buff("The Beast Within") },
      
   { {"macro","/startattack"}, nil, "target" },
}

   local spell,target = parseSpellTable(spellTable)
   return parseSpellTable(spellTable)
   end
   
   return spell
end

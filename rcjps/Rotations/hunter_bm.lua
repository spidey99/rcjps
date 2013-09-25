function hunter_bm(self)
-- valve

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
	{ "aspect of the iron hawk", 	not jps.Moving and not jps.buff("aspect of the iron hawk") },
	--{ "hunter's mark", 				(targetHealth > 80 and (targetHealth > 50 or UnitHealthMax("target") > 25000 )) not jps.debuff("hunter's mark") },
	
	{ "Freezing Trap",        		IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
	{ "Snake Trap",        			IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

 	--Interrupts
    { "Silencing Shot",             jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= 0.5) , "target" },
	{ "Scatter Shot",        		IsAltKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

	{ "Focus Fire", 				fStacks == 5 },
	{ "Serpent Sting", 				not jps.myDebuff("serpent sting") },
	{ jps.DPSRacial, 				jps.UseCDs },
	{ "Lifeblood", 					jps.UseCDs },
	{ "Fervor", 					focus < 65 and not jps.buff("fervor") },
	{ "Bestial Wrath", 				focus > 60 and not jps.buff("the beast within") },
	
	{ "Mend Pet",					petHealth < .60 and not jps.buff("Mend Pet","pet") },

	{ "Multi-Shot", 				jps.MultiTarget },
	{ "Cobra Shot", 				jps.MultiTarget },
	
	{ "Rapid Fire", 				jps.UseCDs and not jps.buff("The Beast Within") and not jps.bloodlusting() },
	{ "Stampede", 					jps.UseCDs and (jps.buff("Rapid Fire") or jps.bloodlusting() or targetHealth < .35) },
	{ "kill shot", 					},
	{ "kill command", 				},
	{ "a murder of crows", 			jps.UseCDs },
	{ "glaive toss", 				},
	{ "lynx rush", 					},
	{ "dire beast", 				focus <= 90 },
	{ "barrage", 					},
	{ "powershot", 					},
	{ "blink strike", 				},
	{ "Readiness",					jps.UseCDs and jps.cooldown("Rapid Fire") > 2 },
	{ "arcane shot", 				jps.buff("thrill of the hunt") },
	{ "Cobra Shot", 				sps_duration < 6 },
    { "Arcane Shot", 				focus >= 61 or jps.buff("The Beast Within") },
      
    { {"macro","/startattack"}, nil, "target" },
}

	local spell,target = parseSpellTable(spellTable)
	return parseSpellTable(spellTable)
	end
	
	return spell
end

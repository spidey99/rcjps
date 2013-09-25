function monk_windwalker(self)
  
  if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end
  
  -- Using the same rotation as SimulationCraft. http://simulationcraft.org
  
  -- Tested with a 480 ilvl against a raid target dummy with only self buffs (and ghetto enchants).
  -- SimulationCraft with these settings gives a DPS of 72k.
  -- This script gives a DPS of 62k. So we're 10k off target.
  -- This script in LFR easily does between 70-85k single target.
  
  local energy = UnitMana("player")
  local playerHealth = UnitHealth("player")/UnitHealthMax("player")
  local energyPerSec = 13
  local energyTimeToMax = (100 - energy) / energyPerSec
  
  local chi = UnitPower("Player", 12)
  local defensiveCDActive = jps.buff("Touch of Karma") or jps.buff("Zen Meditation") or jps.buff("Fortifying Brew") or jps.buff("Dampen Harm") or jps.buff("Diffuse Magic")
  local tigerPowerDuration = jps.buffDuration("Tiger Power")

  -- Need to use the Tigereye Brew buff ID because it shares it's name with the stacks.
  local tigereyeActive = jps.buffID(116740)

  if UnitCanAttack("player","target") ~= 1 or UnitIsDeadOrGhost("target") == 1 then return end

  -- Spells should be ordered by priority.
  local spellTable = 
  {
    -- Defensive Cooldowns.
    -- { "Zen Meditation",              playerHealth < .4 and not defensiveCDActive },
    { "Fortifying Brew",                playerHealth < .6 and not defensiveCDActive },
    { "Diffuse Magic",                  playerHealth < .6 and not defensiveCDActive },     -- Defensive Cooldown. (talent specific)
    { "Dampen Harm",                    playerHealth < .6 and not defensiveCDActive },     -- Defensive Cooldown. (talent specific)
    { "Touch of Karma",                 jps.UseCDs and playerHealth < .65 and not defensiveCDActive },    -- Defensive Cooldown.
    
    --Execute
    { "Touch of Death",                 jps.UseCDs and jps.buff("Death Note","player") and not jps.MultiTarget }, -- Insta-kill single target when available

    -- Interrupt.
    { "Spear Hand Strike",              jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= 1) },
    { "Paralysis",                      jps.shouldKick("target") and jps.Interrupts and (jps.LastCast ~= "Spear Hand Strike") and (jps.castTimeLeft("target") <= 1) },
    { "Leg Sweep",                      jps.MultiTarget and jps.shouldKick("target") and jps.Interrupts }, -- Leg sweep on cooldown during multi-target to reduce tank damage. TODO: Check if our target is stunned already.
    
    -- Use CDs
    { jps.DPSRacial,                    jps.UseCDs },
    { jps.useTrinket(1),                jps.UseCds },
    { jps.useTrinket(2),                jps.UseCds },
    -- { jps.useSlot(10),               chi > 3 and energy >= 50 },
    
    { "Chi Brew",                       chi == 0 },     -- Chi Brew if we have no chi. (talent based)
    { "Lifeblood",                      jps.UseCDs },     -- Lifeblood CD. (herbalists)
        
    { "Rising Sun Kick",                (not jps.debuff("Rising Sun Kick")) or jps.debuffDuration("Rising Sun Kick") <= 3 }, -- Rising Sun Kick on cooldown.
    { "Tiger Palm",                     tigerPowerDuration <= 2.5 }, -- Tiger Palm single-target if the buff is close to falling off.
    { "Tigereye Brew",                  jps.UseCDs and (not tigereyeActive and (jps.buffStacks("Tigereye Brew","player") == 10)) }, -- Tigereye Brew when we have 10 stacks.
    { "Energizing Brew",                energyTimeToMax > 5 }, -- Energizing Brew whenever if it'll take approximately more than 5 seconds of regen to max energy.
    { "Invoke Xuen, the White Tiger",   jps.UseCDs }, -- Invoke Xuen CD. (talent based)
    { "Rushing Jade Wind",              },     -- Rushing Jade Wind. (talent based)
    { "Rising Sun Kick",                },     -- Rising Sun Kick on cooldown.

    --Multi Target
    { "Rising Sun Kick",                jps.MultiTarget and chi ==4 },
    { "Spinning Crane Kick",            jps.MultiTarget },
  
    --Single Target
    { "Blackout Kick",                  jps.buff("Combo Breaker: Blackout Kick") and energyTimeToMax <= 3 }, -- Blackout Kick single-target on clearcast.
    { "Blackout Kick",                  chi >= 4 and energyTimeToMax <= 3 },     -- Blackout Kick as single-target chi dump.
    { "Rising Sun Kick",                },
    { "Tiger Palm",                     jps.buff("Combo Breaker: Tiger Palm") },     -- Tiger Palm single-target if the buff is close to falling off.
    { "Fists of Fury",                  ((not jps.buff("Energizing Brew")) and energyTimeToMax >= 4) and tigerPowerDuration >= 4 and not jps.Moving and IsSpellInRange("jab","target") },
    { "Blackout Kick",                  jps.buff("Combo Breaker: Tiger Palm") }, 

    { "Chi Wave",                       playerHealth < .8 and chi >= 2 and jps.Defensive}, -- Chi Wave if we're not at full health. (talent based)
    { "Chi Burst",                      playerHealth < .8 and chi >= 2 and jps.Defensive}, -- Chi Burst if we're not at full health. (talent based)
    { "Zen Sphere",                     playerHealth < .8 and chi >= 2 and not jps.buff("Zen Sphere") and jps.Defensive}, -- Zen Sphere if we're not at full health. (talent based)
    
    { "Expel Harm",                     chi < 3 and energy >= 40 and playerHealth < .95 }, -- Expel Harm to build chi and heal if we're not at full health.

    { "Jab",                            chi <= 3 }, -- Jab to build chi if we're at 3 or less.
    { "Blackout Kick",                  (energy+(energyPerSec *  jps.cd("Rising Sun Kick") ) >=40 ) or (chi > 4) }, -- Blackout Kick when we're chi capped.
    
    
    { {"macro","/startattack"}, nil, "target" },
  }
  local spell,target = parseSpellTable(spellTable)
    
    return spell
end
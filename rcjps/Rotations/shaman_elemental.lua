function shaman_elemental(self)
   -- Updated for MoP
   -- Tier 1: Astral Shift
   -- Tier 2: Windwalk Totem
   -- Tier 3: Call of the Elements
   -- Tier 4: Echo of the Elements
   -- Tier 5: Healing Tide Totem
   -- Major Glyphs: Flame Shock (required), Spiritwalker's Grace (recommended),
   --    Telluric Currents (recommended)
   -- Minor Glyphs: Thunderstorm (required)
   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local playerHealth = UnitHealth("player")/UnitHealthMax("player") *100
   local playerMana = UnitMana("player")/UnitManaMax("player") * 100
   local spell = nil
   local lsStacks = jps.buffStacks("lightning shield")
   local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()

   -- Totems
   local _, fireName, _, _, _ = GetTotemInfo(1)
   local _, earthName, _, _, _ = GetTotemInfo(2)
   local _, waterName, _, _, _ = GetTotemInfo(3)
   local _, airName, _, _, _ = GetTotemInfo(4)

   local haveFireTotem = fireName ~= ""
   local haveEarthTotem = earthName ~= ""
   local haveWaterTotem = waterName ~= ""
   local haveAirTotem = airName ~= ""

   -- Miscellaneous
   local feared = jps.debuff("fear","player") or jps.debuff("intimidating shout","player") or jps.debuff("howl of terror","player") or jps.debuff("psychic scream","player")

   if UnitThreatSituation("player") == 3 and cd("Astral Shift") == 0 and GetNumSubgroupMembers() > 0 then
      spell = "Astral Shift"

   else

   local spellTable = 
   {
      --Get some buffs
      { "lightning shield",         not jps.buff("lightning shield") },
      { "Flametongue Weapon",       not mh},
      { "Healing Surge",            playerHealth < 65 },
      
      --Totems
      { "searing totem",            not haveFireTotem },
      { "fire elemental totem",     jps.UseCDs },
      { "earth elemental totem",    jps.UseCDs and jps.bloodlusting() },
      { "stormlash totem",          jps.UseCDs and jps.bloodlusting() },
      
      --Use some CDs to burst
      { "ascendance",               jps.UseCDs and not jps.buff("ascendance")},
      { jps.DPSRacial,              jps.UseCDs },
      { {"macro","/use 10"},        jps.glovesCooldown() == 0 and jps.UseCDs },

      --Interrupts
      { "Wind Shear",               jps.shouldKick("target") and jps.Interrupts and (jps.castTimeLeft("target") <= 0.5) , "target"  },
      
      --Damage
      { "Earthquake",               jps.MultiTarget and IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      { "Totemic Projection",       IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
      
      --{ "Unleash Elements",         jps.debuffDuration("flame shock") < 2 },
      { "Lava Burst",               jps.debuff("flame shock") and jps.debuffDuration("flame shock") > 1.5 },
      { "Flame Shock",              (not jps.debuff("flame shock") or jps.debuffDuration("flame shock") < 2 ) },
      { "Elemental Blast",          },

      { "Earth shock",              lsStacks > 5 and jps.debuffDuration("Flame Shock") > 4.5 },
      
      { "spiritwalker's grace",     jps.Moving },
      { "Unleach Elements",         jps.Moving },
      
      { "Lava Beam",                jps.MultiTarget and jps.buff("ascendance") },
      { "chain lightning",          jps.MultiTarget },
      { "thunderstorm",             jps.mana() < .6 and jps.UseCDs },
      { "lightning bolt",           },
      
      { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
   return parseSpellTable(spellTable)
   end
   
   return spell
end
function mage_arcane(self)
 -- Jokur  
if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

local atBuffed = jps.buff("alter time","player")
local apBuffed = jps.buff("Arcane Power", "player")
local stacks = jps.debuffStacks("arcane charge","player")
local aDuration = jps.debuffDuration("arcane charge","player")
local manaGemCharges = GetItemCount("mana gem",0,1) 
local playerMana = UnitMana("player")/UnitManaMax("player")  

local spellTable =
{

	-- 5.2 Section.  This is based on early Noxxic suggestions.  
	
  
  {"Incanter's Ward",		 not jps.buff("Incanter's Ward", "player")},
  
		-- Key Press Checks
		{ "Evocation",      	 IsShiftKeyDown() ~= nil },
		{ "Blink",				 IsAltKeyDown() ~= nil   },
		{ "Rune of Power",       IsShiftKeyDown() ~= nil },	
		{ "Flamestrike",		   IsLeftControlKeyDown() ~= nil },
  
  -- Forget your Buffs ?  Silly Rabbit
  { "Mage Armor",            not jps.buff("Mage Armor","player") },
  { "Arcane Brilliance",     not jps.buff("Arcane Brilliance","player") },
  
  -- Oh Shit, We are About to Die
  { "Ice Block",             ((UnitHealth("player") / UnitHealthMax("player")) < 0.10 ) and not jps.buff("Ice Block","player") },
   
  --CDs 5.2
  { "Mirror Image",          jps.UseCDs and apBuffed},
  { "arcane power",      	 jps.buffStacks("arcane missiles!","player") == 2 and jps.UseCDs and not atBuffed and stacks == 4 },
  { { "macro","/use 10"},    jps.glovesCooldown() == 0 and jps.UseCDs},
  { jps.useTrinket(1),       jps.UseCDs and apBuffed },
  { jps.useTrinket(2),       jps.UseCDs and apBuffed },
  { jps.DPSRacial,           jps.UseCDs },
  { "Nether Tempest",        not jps.debuff("Nether Tempest") },
  { "alter time",            not jps.buff("Alter Time", "player") and jps.UseCDs and apBuffed },
  

  -- Lets Spellsteal if We Can!
 
  
  -- Moving 5.2
  { "Arcane Barrage",     	 stacks == 4 }, -- jps.Moving and aDuration < 3 },
  -- Need to Review Changes  { "Fire Blast",         jps.Moving and jps.debuff("Living Bomb") },
  { "Fire Blast",            jps.Moving }, -- not Mana usefull anymore ?
  { "Ice Lance",          	 jps.Moving },
  
  -- Interupts 5.2 
  { "Counterspell",          jps.Interrupts and jps.shouldKick("target") },
  
  -- Mana Regen 5.2
  { {"macro","/use Brilliant Mana Gem"}, IsUsableItem(81901)==1 and jps.itemCooldown(81901)==0 and jps.mana("player") <= 0.85  },
  
  
  -- Main DPS Rotation 5.2
  { "arcane missiles",   	 jps.buffStacks("arcane missiles!","player") == 2 },
  { "Arcane Barrage",        jps.Moving and aDuration < 3 }, 
  { "arcane blast",       	  },



}

 local spell,target = parseSpellTable(spellTable)
 if spell == "Rune of Power" then
   jps.Cast( spell )
   jps.groundClick()
 end

 jps.Target = target
 return spell
end
function paladin_ret(self)
   -- Jokur

   if UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1 then return end

   local spell = nil
   local targetHealth = UnitHealth("target")/UnitHealthMax("target") *100
   local hPower = UnitPower("player","9")
   local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
   local nStance = GetShapeshiftForm(nil);

   local spellTable =
   {      
   
    -- Lets Check our Seal's
    { "Seal of Truth",              not jps.MultiTarget and nStance ~= 1 },
    { "Seal of Righteousness",      jps.MultiTarget and nStance ~= 2 },
    
    -- Health Check for LoH and Sacred Shield
    { "Lay on Hands",               myHealthPercent < 15 },
    { "Sacred Shield", 			    myHealthPercent < 95 and not jps.buff("Sacred Shield") },
    
    -- Interupt Checker
    { "Rebuke",                     jps.Interrupts and jps.shouldKick() and (jps.castTimeLeft("target") <= 1) },
    { "Rebuke",                     jps.Interrupts and  (jps.castTimeLeft("target") <= 1) and jps.shouldKick("focus"), "focus" },
    { "Arcane Torrent",             jps.Interrupts and jps.shouldKick() and (jps.castTimeLeft("target") <= 1) and IsSpellInRange("Crusader Strike","target")==1 and jps.LastCast ~= "Rebuke" },
    
     
   	-- Blow our CD's to get things Started	
   	{ "Avenging Wrath",             jps.UseCDs },
    { "Guardian of Ancient Kings",  jps.UseCDs },
    { jps.useTrinket(1),        	jps.UseCDs },
    { jps.useTrinket(2),        	jps.UseCDs },
    { jps.DPSRacial,            	jps.UseCDs },
    
    -- Check for Keys Being Pressed
    -- { "Light's Hammer",         	IsLeftShiftKeyDown() ~= nil },
    
    -- Hard Hitting Items to Check First 
    { "Templar's Verdict",      	hPower == 5 and not jps.MultiTarget },
    { "Divine Storm",      			hPower >= 3 and jps.MultiTarget },   
    { "Exorcism",               	jps.buff("The Art of War") },
    { "Execution Sentence",         jps.buff("Inquisition") },
    { "Hammer of Wrath",        	targetHealth < 20 or jps.buff("Avenging Wrath") },
    
    -- DPS Rotation
   	{ "inquisition",            	not jps.buff("Inquisition") or jps.buffDuration("inquisition") < 2 },
   	{ "Exorcism",               	},
   	{ "crusader strike", 			not jps.MultiTarget },
   	{ "Hammer of the Righteous",    jps.MultiTarget },
   	{ "judgment",                   },
   	{ "Templar's Verdict",      	hPower == 3 and not jps.MultiTarget },
   	{ "Divine Storm",      			hPower == 3 and jps.MultiTarget }, 
   	
   	-- End DPS Rotation
 
    { {"macro","/startattack"}, nil, "target" },
   }

   local spell,target = parseSpellTable(spellTable)
    if spell == "Light's Hammer" then
   jps.Cast( spell )
   jps.groundClick()
 end
   
   jps.Target = target
   return spell
end



-- ============================================================================
-- MobSpells Extension (Combat Log Scanner & Tooltip Injection)
-- ============================================================================

-- 1. PERSISTENT STORAGE INITIALIZATION
if not MobStats_SavedSpells then
    MobStats_SavedSpells = {}
end

-- 2. COMBAT LOG EVENT LISTENER (TURTLE WOW / VANILLA ENGLISH CLIENT)
local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")                           -- Fires when WTF data is loaded
frame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE")     -- Direct spell damage to you
frame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE")    -- Direct spell damage to party/pets
frame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE") -- Damage between NPCs/Mobs
frame:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")   -- Mobs healing/buffing themselves or others
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")       -- DoTs/Debuffs ticking on you
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")      -- DoTs/Debuffs ticking on party
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")     -- HoTs/Buffs ticking on mobs

frame:SetScript("OnEvent", function()
    -- Sync memory database with client local variables
    if event == "VARIABLES_LOADED" then
        if not MobStats_SavedSpells then
            MobStats_SavedSpells = {}
        end
        return 
    end

    if arg1 then
        local mobName, spellName
        
        -- PATTERN 1: "MobName's SpellName hits/crits..." (Direct Spell Hits)
        for bicho, hechizo in string.gfind(arg1, "([%w%s]+)'s ([%w%s]+) hits") do
            mobName, spellName = bicho, hechizo
        end
        if not mobName then
            for bicho, hechizo in string.gfind(arg1, "([%w%s]+)'s ([%w%s]+) crits") do
                mobName, spellName = bicho, hechizo
            end
        end

        -- PATTERN 2: "MobName begins to cast / perform / casts SpellName." (Casting & Performance bars)
        if not mobName then
            for bicho, hechizo in string.gfind(arg1, "([%w%s]+) begins to cast ([%w%s]+)%.") do
                mobName, spellName = bicho, hechizo
            end
        end
        if not mobName then
            -- NEW: Captures physical/channeled actions like "begins to perform Frost Breath."
            for bicho, hechizo in string.gfind(arg1, "([%w%s]+) begins to perform ([%w%s]+)%.") do
                mobName, spellName = bicho, hechizo
            end
        end
        if not mobName then
            for bicho, hechizo in string.gfind(arg1, "([%w%s]+) casts ([%w%s]+)%.") do
                mobName, spellName = bicho, hechizo
            end
        end

        -- PATTERN 3: "MobName gains SpellName." (Heals, Buffs, Shields)
        if not mobName then
            for bicho, hechizo in string.gfind(arg1, "([%w%s]+) gains ([%w%s]+)%.") do
                mobName, spellName = bicho, hechizo
            end
        end

        -- PATTERN 4: "You suffer X damage from MobName's SpellName." (Periodic DoTs/AOE)
        if not mobName then
            for bicho, hechizo in string.gfind(arg1, "damage from ([%w%s]+)'s ([%w%s]+)%.") do
                mobName, spellName = bicho, hechizo
            end
        end

        -- PATTERN 5: "You are afflicted by SpellName." (Debuffs - Anti-Player & Anti-Self Shield)
        if not mobName and string.find(arg1, "You are afflicted by") then
            for hechizo in string.gfind(arg1, "You are afflicted by ([%w%s]+)%.") do
                if hechizo ~= "Weakened Soul" then
                    local potencialBicho = UnitName("target") or UnitName("mouseover")
                    if potencialBicho then
                        -- Strict player verification to protect database from PvP/Duel pollution
                        local targetEsJugador = UnitExists("target") and UnitIsPlayer("target")
                        local mouseEsJugador = UnitExists("mouseover") and UnitIsPlayer("mouseover")
                        if not targetEsJugador and not mouseEsJugador then
                            spellName = hechizo
                            mobName = potencialBicho
                        end
                    end
                end
            end
        end

        -- DATA CLEANING & VALIDATION
        if mobName and spellName then
            mobName = string.gsub(mobName, "^%s*(.-)%s*$", "%1")
            spellName = string.gsub(spellName, "^%s*(.-)%s*$", "%1")

            -- Avoid native combat keywords and false positives
            if spellName ~= "crit" and spellName ~= "crits" and spellName ~= "hit" and spellName ~= "absorb" and spellName ~= "Weakened Soul" then
                if not MobStats_SavedSpells[mobName] then
                    MobStats_SavedSpells[mobName] = {}
                end

                local yaExiste = false
                for _, v in ipairs(MobStats_SavedSpells[mobName]) do
                    if v == spellName then yaExiste = true break end
                end

                if not yaExiste then
                    table.insert(MobStats_SavedSpells[mobName], spellName)
                    -- In-game feedback notification
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[MobSpells] Learned: " .. mobName .. " -> " .. spellName .. "|r")
                end
            end
        end
    end
end)

-- 3. GAMETOOLTIP HOOK (SAFE INJECTION)
local originalOnShow = GameTooltip:GetScript("OnShow")
GameTooltip:SetScript("OnShow", function()
    if originalOnShow then originalOnShow() end
    
    local name = UnitName("mouseover")
    if name and MobStats_SavedSpells[name] then
        local habilidades = MobStats_SavedSpells[name]
        if habilidades and table.getn(habilidades) > 0 then
            GameTooltip:AddLine(" ") -- Aesthetic separator
            GameTooltip:AddLine("|cff00ccffAbilities:|r", nil, nil, nil, 1)
            for i = 1, table.getn(habilidades) do
                GameTooltip:AddLine("|cffffffff* " .. habilidades[i] .. "|r", nil, nil, nil, 1)
            end
            GameTooltip:Show() -- Force engine layout recalculation
        end
    end
end)

-- 4. CONSOLE COMMANDS (DATABASE MAINTENANCE)
SLASH_MOBSTATSCLR1 = "/mobstats"
SlashCmdList["MOBSTATSCLR"] = function(msg)
    -- Pasamos el texto a minúsculas para evitar errores si el usuario escribe en mayúsculas
    local comando = string.lower(msg or "")
    
    if comando == "reset" or comando == "spell reset" then
        MobStats_SavedSpells = {}
        DEFAULT_CHAT_FRAME:AddMessage("|cffffaa00[MobStats] Spell database completely wiped! Rebuilding on next combat...|r")
    else
        -- Guía de ayuda rápida adaptada al comando correcto
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[MobStats] Spell Commands available:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff -> /mobstats reset : Wipes all saved monster abilities.|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cffffffff -> /mobstats spell reset : Wipes all saved monster abilities.|r")
    end
end
local IconDatabase = {}

-- Library configurations
IconDatabase.Libraries = {
    -- BuilderIcons (built into Roblox)
    BuilderIcons = {
        Type = "font",
        Path = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",
    },
    -- Solar Icons (from icones.js.org/collection/solar)
    Solar = {
        Type = "image",
        Icons = {
            ["sun-bold"] = "rbxassetid://1234567890",  -- Replace with actual IDs
            ["moon-bold"] = "rbxassetid://1234567891",
        }
    },
    -- Lucide Icons (from lucide.dev)
    Lucide = {
        Type = "image",
        Icons = {
            ["sun"] = "rbxassetid://...",
            ["moon"] = "rbxassetid://...",
        }
    },
    -- SF Symbols (from sf-symbols.pages.dev)
    SF = {
        Type = "image",
        Icons = {
            ["sun.max.fill"] = "rbxassetid://...",
            ["moon.fill"] = "rbxassetid://...",
        }
    },
    -- Geist Icons
    Geist = {
        Type = "image",
        Icons = {
            ["sun"] = "rbxassetid://...",
            ["moon"] = "rbxassetid://...",
        }
    },
    -- Craft Icons
    Craft = {
        Type = "image",
        Icons = {
            ["sun"] = "rbxassetid://...",
            ["moon"] = "rbxassetid://...",
        }
    },
}

-- Resolve an icon string like "solar:sun-bold" or "sun.min" (defaults to BuilderIcons)
function IconDatabase.Resolve(iconString)
    if not iconString then return nil end
    
    local library, iconName = iconString:match("^(%w+):(.+)$")
    
    -- If no prefix, default to BuilderIcons
    if not library then
        return {
            Type = "font",
            Path = IconDatabase.Libraries.BuilderIcons.Path,
            Icon = iconString
        }
    end
    
    local libData = IconDatabase.Libraries[library]
    if not libData then return nil end
    
    if libData.Type == "font" then
        return {
            Type = "font",
            Path = libData.Path,
            Icon = iconName
        }
    else
        local assetId = libData.Icons[iconName]
        if assetId then
            return {
                Type = "image",
                AssetId = assetId
            }
        end
    end
    
    return nil
end

-- Helper to check if a string is an icon reference
function IconDatabase.IsIconReference(str)
    return str and (str:match("^%w+:.+$") ~= nil or true) -- All strings are valid BuilderIcons
end

return IconDatabase

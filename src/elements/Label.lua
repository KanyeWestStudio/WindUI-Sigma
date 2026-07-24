local Creator = require("../modules/Creator")
local New = Creator.New
local Element = {}

function Element:New(ElementConfig)
    -- Set defaults and merge with user config
    ElementConfig.Hover = false
    ElementConfig.TextOffset = 0
    ElementConfig.ParentConfig = ElementConfig

    -- Create the module table that will be returned
    local LabelModule = {
        __type = "Label",
        Title = ElementConfig.Title or nil,
        Desc = ElementConfig.Desc or nil,
        TextSize = ElementConfig.TextSize or 16,
        DescTextSize = ElementConfig.DescTextSize or 14,
        TextXAlignment = ElementConfig.TextXAlignment or "Left",
        FontWeight = ElementConfig.FontWeight or Enum.FontWeight.Medium,
        DescFontWeight = ElementConfig.DescFontWeight or Enum.FontWeight.Light,
        TextTransparency = ElementConfig.TextTransparency or 0.05,
        DescTextTransparency = ElementConfig.DescTextTransparency or 0.4,
        Locked = ElementConfig.Locked or false,
    }

    local Label = require("../components/window/Element")(ElementConfig)
    LabelModule.LabelFrame = Label

    return LabelModule.__type, LabelModule
end

return Element

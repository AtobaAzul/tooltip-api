local env = env
---@diagnostic disable-next-line: param-type-mismatch
GLOBAL.setfenv(1, GLOBAL)
local Tooltip = require "widgets/tooltip"
-----------------------------------------------------------------
Assets = {
    Asset("IMAGE", "images/generic_tooltip.tex"),
    Asset("ATLAS", "images/generic_tooltip.xml"),
}

STRINGS.TOOLTIPS = {
    ["generic"] = {
        --    AXE = "This thing chops!"
    },
    --["pyromaniac"] = {
    --    AXE = "This chops!"
    --}
}

TheTooltipData = {}


---@param recipename string
---@return boolean
function TooltipExists(recipename)
    for k, v in pairs(STRINGS.TOOLTIPS) do
        if v[string.upper(recipename)] ~= nil then
            return true
        else
            return false
        end
    end
end

--- Adds a tooltip category
---@param name string An identifier for your tooltip
---@param atlas? string The atlas of your image. Includes the root folder and extension.  (.xml) Optional.
---@param image? string image of your tooltip, Includes only extension (.tex) Optional.
---@param tag? string The character tag for your tooltip. This limits the tooltip to only show to this character. Leave blank for any.
---@param scalemode? string Sets the scalemode, defaults to 0.01
---@param scale? table Sets the size, defaults to {.9, .9, .9}
function AddTooltipCategory(name, tag, atlas, image, scalemode, scale)
    if tag == nil then tag = "generic" end

    if STRINGS.TOOLTIPS[tag] == nil then
        STRINGS.TOOLTIPS[tag] = {}
    end

    if not image or not atlas then
        image = "generic_tooltip.tex"
        atlas = "images/generic_tooltip.xml"
    end
    table.insert(TheTooltipData, { name = name, atlas = atlas, image = image, tag = tag, scalemode = scalemode, scale = scale })
end

env.AddTooltipCategory = AddTooltipCategory

---Helper method to avoid overwriting stuff.
---@param item string
---@param text string
---@param tag? string
function AddTooltipForItem(item, text, tag)
    assert(item or text, "[TOOLTIP API] Item or text should be a string! Item:" .. item .. " (" .. type(item) .. ") " .. " " .. text .. " (" .. type(text) .. ")")

    if tag == nil then tag = "generic" end

    item = string.upper(item)

    assert(STRINGS.TOOLTIPS[tag], "[TOOLTIP API] Attempted to add tooltip to non-existing tag!\nMake sure to add a tooltip category first!")

    if STRINGS.TOOLTIPS[tag][item] ~= nil then
        STRINGS.TOOLTIPS[tag][item] = STRINGS.TOOLTIPS[tag][item] .. "\n" .. text
    else
        STRINGS.TOOLTIPS[tag][item] = text
    end
end

env.AddTooltipForItem = AddTooltipForItem
env.AddClassPostConstruct("widgets/redux/craftingmenu_hud", function(self)
    local _OldOnUpdate = self.OnUpdate

    function self:OnUpdate(...)
        if self.craftingmenu ~= nil and self.tooltip_api == nil then
            self.tooltip_api = self.craftingmenu:AddChild(Tooltip())
            self.tooltip_api:SetPosition(-105, -210)
            self.tooltip_api:SetScale(0.35)
        end

        if self.craftingmenu ~= nil and
            self.craftingmenu.crafting_hud ~= nil and
            self.craftingmenu.crafting_hud:IsCraftingOpen() and
            self.tooltip_api ~= nil and
            self.craftingmenu.details_root ~= nil and
            self.craftingmenu.details_root.data and
            self.craftingmenu.details_root.data.recipe ~= nil and
            self.craftingmenu.details_root.data.recipe.name and
            TooltipExists(self.craftingmenu.details_root.data.recipe.name) then
            self.tooltip_api.item_tip = self.craftingmenu.details_root.data.recipe.name
            self.tooltip_api.skins_spinner = self.craftingmenu.details_root.skins_spinner or nil
            self.tooltip_api:ShowTip()
        elseif self.tooltip_api ~= nil then
            self.tooltip_api.item_tip = nil
            self.tooltip_api.skins_spinner = nil
            self.tooltip_api:HideTip()
        end

        _OldOnUpdate(self, ...)
    end
end)

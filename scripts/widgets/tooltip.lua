local Widget = require "widgets/widget"
local Image = require "widgets/image"

local Tooltip = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "Tooltip")

    self.icons = {}

    self:Hide()
    self:RefreshTooltips()
    self.item_tip = nil
    self.skins_spinner = nil
end)


function Tooltip:AddIcon(data)
    if self.icons[data.name] == nil then
        self.icons[data.name] = self:AddChild(Image(data.atlas, data.image))
        self.icons[data.name].tag = data.tag --that's fine, right???

        self.icons[data.name]:SetPosition(300, 300, 0)

        if data.scalemode ~= nil then
            self.icons[data.name]:SetScaleMode(data.scalemode)
        else
            self.icons[data.name]:SetScaleMode(0.01)
        end

        if data.scale ~= nil then
            self.icons[data.name]:SetScale(data.scale, data.scale, data.scale)
        else
            self.icons[data.name]:SetScale(.9, .9, .9)
        end
    end
end

function Tooltip:ShowTip()
    self:RefreshTooltips()
    self:Show()
end

function Tooltip:HideTip()
    self:RefreshTooltips()
    self:Hide()
end

function Tooltip:RefreshTooltips()
    for k,v in pairs(TheTooltipData) do
        self:AddIcon(v)
    end

    if self.skins_spinner ~= nil then
        for k, v in pairs(self.icons) do
            v:SetPosition(300, 300, 0)
        end
    else
        for k, v in pairs(self.icons) do
            v:SetPosition(300, 245, 0)
        end
    end

    local tooltip = ""

    for k, v in pairs(STRINGS.TOOLTIPS) do
        if (ThePlayer:HasTag(k) or k == "generic") and self.item_tip ~= nil then
            tooltip = tooltip .. STRINGS.TOOLTIPS[k][string.upper(self.item_tip)] .. "\n"
        end
    end

    local child = nil
    for k, v in pairs(self.icons) do
        if (ThePlayer:HasTag(v.tag) or v.tag == "generic") and (child == nil or child == v) and tooltip ~= "" then
            v:SetTooltip(tooltip)
            v:Show()
            child = v
        else
            v:Hide()
        end
    end
end

return Tooltip

local ItemManager = require "scripts.manager.ItemManager"
local AnimManager = require "scripts.manager.AnimManager"
local Anim = require "scripts.base.Anim"

---@class Slot : Class 装备槽
---@field name string 装备槽名称
---@field itemId number 所装备的物品id
---@field anims table<string,Anim> 装备动画列表
---@field type string 装备类型
local Slot = Class('Slot')

function Slot:initialize(name, type)
    self.name = name
    self.type = type
    self.itemId = 0
end

---根据动画名称获取装备对应的动画
---@param name string 动画名称
---@return Anim|nil
function Slot:getAnim(name)
    --如果没有装备，则无需创建动画
    if self.itemId == 0 then
        return nil
    end
    --饰品是看不到的
    if self.type == "饰品" then
        return nil
    end
    if self.anims == nil then
        self.anims = {}
    end
    local anim = self.anims[name]
    --如果动画不存在，则创建
    if anim == nil then
        --获取玩家能使用的所有动画
        local equName --装备名称
        local itemId = self.itemId
        if self.type == "装备" then
            equName = ItemManager:getItem(itemId).name
        elseif self.type == "身体部件" then
            equName = ItemManager:getHair(itemId).name
        end

        --动画图片路径组合规则:以装备id为文件夹区分，以动画id为最小单位
        local imgPath = "image/equipment/" .. name .. "/" .. equName .. ".png"
        -- if not Tool.fileExists(imgPath) then
        --     error("错误:装备["..equName.."]的动画文件没有找到")
        --     return nil
        -- end
        local img = love.graphics.newImage(imgPath)
        if img == nil then
            error("目标装备动画不存在:" .. imgPath)
        end
        local animTemp = AnimManager.getAnim(name)
        ---@type Anim
        anim = Anim(animTemp.name, img, animTemp.frame)
        self.anims[anim.name] = anim
    end
    return anim
end

return Slot
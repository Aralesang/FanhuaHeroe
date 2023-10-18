local ItemManager = require "scripts.manager.item_manager"
local AnimManager = require "scripts.manager.anim_manager"
local Anim = require "scripts.base.anim"

---@class Slot : class 装备槽
---@field name string 装备槽名称
---@field itemId number 所装备的物品id
---@field anims table<string,anim> 装备动画列表
---@field type string 装备类型
---@field exclude string<string,boolean> 排除的路径,如果动画文件不存在，则记录在此，下次直接跳过
local Slot = Class('Slot')

function Slot:initialize(name, type)
    self.name = name
    self.type = type
    self.itemId = 0
    self.exclude = {}
end

---根据动画名称获取装备对应的动画
---@param name string 动画名称
---@return anim|nil
function Slot:getAnim(name)
    --如果没有装备，则无需创建动画
    if self.itemId == 0 then
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
        if not equName then
            return nil
        end
        --动画图片路径组合规则:以装备id为文件夹区分，以动画id为最小单位
        local imgPath = "image/anim/" .. equName .. "/" .. name .. ".png"
        if self.exclude[imgPath] or not love.filesystem.getInfo(imgPath) then
            if not self.exclude[imgPath] then
                self.exclude[imgPath] = true
            end
            return
        end
        local img = love.graphics.newImage(imgPath)
        if img == nil then
            error("目标装备动画不存在:" .. imgPath)
        end
        local animTemp = AnimManager.getAnim(name)
        ---@type anim
        anim = Anim(animTemp.name, img, animTemp.frame)
        self.anims[anim.name] = anim
    end
    return anim
end

return Slot

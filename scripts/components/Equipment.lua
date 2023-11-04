local Slot = require "scripts.game.slot"
local Component = require "scripts.base.component"
local ItemManager = require "scripts.manager.item_manager"

---@class Equipment:Component 装备组件
---@field slots table<string,Slot> 装备槽
---@field animation Animation | nil 动画组件
local Equipment = Class('Equipment',Component)

---构造函数
function Equipment:initialize(target)
    Component.initialize(self,target)
    self.gameObject = target
    self.animation = target.animation
    self.slots = {}
    --添加装备插槽
    self:addSlot("发型", "身体部件")
    self:addSlot("帽子", "装备")
    self:addSlot("上衣", "装备")
    self:addSlot("下装", "装备")
    self:addSlot("武器", "装备")
    self:addSlot("戒指", "饰品")
    self:addSlot("项链", "饰品")
end

function Equipment:update(dt)
    --同步所有装备图像的视口数据
    if self.animation == nil then
        error("对象未附加Animation组件")
    end
    local animName = self.animation:getAnimName()
    local frameIndex = self.animation:getFrame()
    if animName == nil then
        return
    end
    for _, slot in pairs(self.slots) do
        local anim = slot:getAnim(animName)
        if anim == nil then
            goto continue
        end
        local quad = anim.quad
        local row = self.gameObject.direction
        quad:setViewport(frameIndex * anim.width, row * anim.height, anim.width, anim.height,
            anim.image:getWidth(),
            anim.image:getHeight())
        ::continue::
    end
end

---绘制装备图像,按照装备槽被创建的先后顺序绘制
function Equipment:draw()
    --同步装备动画
    self:drawEquip("发型")
    self:drawEquip("上衣")
    self:drawEquip("下装")
    self:drawEquip("武器")
end

---绘制装备
---@param name slot
function Equipment:drawEquip(name)
    local animName = self.animation:getAnimName()
    if animName == nil then
        return
    end
    local slot = self:getSlot(name)
    if slot == nil then
        return
    end
    local anim = slot:getAnim(animName)
    if anim == nil then
        return
    end
    local image = anim.image
        local quad = anim.quad
        local gameObject = self.gameObject
        local x = gameObject.x - self.gameObject.central.x * self.gameObject.scale.x
        local y = gameObject.y - self.gameObject.central.y * self.gameObject.scale.y
        x = math.floor(x)
        y = math.floor(y)
        love.graphics.draw(image, quad, x, y, gameObject.rotate, gameObject.scale.x, gameObject.scale.y, 0, 0, 0, 0)
end

---@alias slot
---| '"帽子"'
---| '"上衣"'
---| '"下装"'
---| '"武器"'
---| '"发型"'
---| '"戒指"'
---| '"项链"'

---@alias body
---| '"装备"'
---| '"身体部件"'
---| '"饰品"'

---添加一个装备槽
---@private
---@param name slot 装备槽名称
---@param type? body 装备槽类型
function Equipment:addSlot(name, type)
    ---@type Slot
    local slot = Slot(name, type or "装备")
    self.slots[name] = slot
end

---根据槽名称获取装备槽对象
---@param name string
---@return Slot | nil
function Equipment:getSlot(name)
    return self.slots[name]
end

---装备道具
---@param itemId number 要装备的道具的id
function Equipment:equip(itemId)
    local items = self.gameObject["items"]
    --库存中寻找目标道具
    for id, num in pairs(items) do
        if id == itemId then
            local item = ItemManager:getItem(id)
            --装备目标物品
            local slotName = item.slot
            --如果目标道具没有可用装备槽
            if slotName == nil then
                print("目标道具[" .. id .. "]不可装备！")
                return
            end
            --检查目标槽中是否有装备
            local slot = self:getSlot(slotName)
            if slot == nil then
                print("装备槽:" .. slotName .. "不存在")
                return
            end
            --装备槽中本来就装备该装备，则卸除
            if slot.itemId == itemId then
                self:unequip(slotName)
                return
            elseif slot.itemId ~= 0 and slot.itemId ~= itemId then --装备槽不为空，且装备的和目标装备不同，则先卸除已有装备
                self:unequip(slotName)
            end
            local item = ItemManager:getItem(itemId)
            if item then
                item:equip(self.gameObject --[[@as Rolex]])
            end
            slot.itemId = itemId
            return
        end
    end
    print("未拥有物品:" .. itemId)
end

---卸除装备
---@param name slot 要卸除的槽
function Equipment:unequip(name)
    local slot = self:getSlot(name)
    if slot == nil then
        error("装备槽 [" .. name .. "] 不存在!")
    end
    local item = ItemManager:getItem(slot.itemId)
    if item then
        item:unequip(self.gameObject --[[@as Role]])
    end
    slot.itemId = 0
end

---设置发型
---@param id number 目标发型id
function Equipment:setHair(id)
    local slot = self:getSlot("发型")
    if slot == nil then
        error("装备槽 [发型] 不存在!")
    end
    slot.itemId = id
end

---检查物品是否正在被装备
---@param itemId number
---@return boolean
function Equipment:isEquip(itemId)
    for _, value in pairs(self.slots) do
        if value.type ~= "身体部件" then
            if value.itemId == itemId then
                return true
            end
        end
    end
    return false
end

return Equipment

local slot_class = require "scripts.game.slot"
local component = require "scripts.base.component"
local item_manager = require "scripts.manager.item_manager"

---@class equipment:component 装备组件
---@field slots table<string,slot> 装备槽
---@field animation animation | nil 动画组件
local equipment = Class('Equipment',component)

---构造函数
function equipment:initialize(target)
    component.initialize(self,target)
    self.game_object = target
    self.animation = target.animation
    self.slots = {}
    --添加装备插槽
    self:add_slot("发型", "身体部件")
    self:add_slot("帽子", "装备")
    self:add_slot("上衣", "装备")
    self:add_slot("下装", "装备")
    self:add_slot("武器", "装备")
    self:add_slot("戒指", "饰品")
    self:add_slot("项链", "饰品")
end

function equipment:update(dt)
    --同步所有装备图像的视口数据
    if self.animation == nil then
        error("对象未附加Animation组件")
    end
    local anim_name = self.animation:get_anim_name()
    local frame_index = self.animation:get_frame()
    if anim_name == nil then
        return
    end
    for _, slot in pairs(self.slots) do
        local anim = slot:get_anim(anim_name)
        if anim == nil then
            goto continue
        end
        local quad = anim.quad
        local row = self.game_object.direction
        quad:setViewport(frame_index * anim.width, row * anim.height, anim.width, anim.height,
            anim.image:getWidth(),
            anim.image:getHeight())
        ::continue::
    end
end

---绘制装备图像,按照装备槽被创建的先后顺序绘制
function equipment:draw()
    --同步装备动画
    self:draw_equip("发型")
    self:draw_equip("上衣")
    self:draw_equip("下装")
    self:draw_equip("武器")
end

---绘制装备
---@param name slot_alias
function equipment:draw_equip(name)
    local anim_name = self.animation:get_anim_name()
    if anim_name == nil then
        return
    end
    local slot = self:get_slot(name)
    if slot == nil then
        return
    end
    local anim = slot:get_anim(anim_name)
    if anim == nil then
        return
    end
    local image = anim.image
        local quad = anim.quad
        local game_object = self.game_object
        local x = game_object.x - self.game_object.central.x * self.game_object.scale.x
        local y = game_object.y - self.game_object.central.y * self.game_object.scale.y
        x = math.floor(x)
        y = math.floor(y)
        love.graphics.draw(image, quad, x, y, game_object.rotate, game_object.scale.x, game_object.scale.y, 0, 0, 0, 0)
end

---@alias slot_alias
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
---@param name slot_alias 装备槽名称
---@param type? body 装备槽类型
function equipment:add_slot(name, type)
    ---@type slot
    local slot = slot_class(name, type or "装备")
    self.slots[name] = slot
end

---根据槽名称获取装备槽对象
---@param name slot_alias
---@return slot | nil
function equipment:get_slot(name)
    return self.slots[name]
end

---装备道具
---@param itemId number 要装备的道具的id
function equipment:equip(itemId)
    local items = self.game_object["items"]
    --库存中寻找目标道具
    for id, num in pairs(items) do
        if id == itemId then
            local item = item_manager:getItem(id)
            --装备目标物品
            local slotName = item.slot
            --如果目标道具没有可用装备槽
            if slotName == nil then
                print("目标道具[" .. id .. "]不可装备！")
                return
            end
            --检查目标槽中是否有装备
            local slot = self:get_slot(slotName)
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
            local item = item_manager:getItem(itemId)
            if item then
                item:equip(self.game_object --[[@as role]])
            end
            slot.itemId = itemId
            return
        end
    end
    print("未拥有物品:" .. itemId)
end

---卸除装备
---@param name slot_alias 要卸除的槽
function equipment:unequip(name)
    local slot = self:get_slot(name)
    if slot == nil then
        error("装备槽 [" .. name .. "] 不存在!")
    end
    local item = item_manager:getItem(slot.itemId)
    if item then
        item:unequip(self.game_object --[[@as role]])
    end
    slot.itemId = 0
end

---设置发型
---@param id number 目标发型id
function equipment:setHair(id)
    local slot = self:get_slot("发型")
    if slot == nil then
        error("装备槽 [发型] 不存在!")
    end
    slot.itemId = id
end

---检查物品是否正在被装备
---@param itemId number
---@return boolean
function equipment:isEquip(itemId)
    for _, value in pairs(self.slots) do
        if value.type ~= "身体部件" then
            if value.itemId == itemId then
                return true
            end
        end
    end
    return false
end

return equipment

local Slot = require "scripts.game.Slot"
local Component = require "scripts.base.Component"
local Animation = require "scripts.components.Animation"
local Inventory = require "scripts.components.Inventory"

---@class Equipment:Component 装备组件
---@field private slots Slot[] 装备槽有序列表
---@field animName string 当前动画名称
---@field frameIndex number 当前动画帧下标
---@field animation Animation | nil 动画组件
---@field inventory Inventory | nil 库存组件
local Equipment = Component:extend()

function Equipment:extend()
    local cls = {}
    for k, v in pairs(self) do
      if k:find("__") == 1 then
        cls[k] = v
      end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
  end

---构造函数
function Equipment:new()
    self.slots = {}
end

function Equipment:awake()
    self.animation = self.gameObject:getComponent(Animation)
    if self.animation == nil then
        error("对象未附加Animation组件")
    end
    self.inventory = self.gameObject:getComponent(Inventory)
    if self.inventory == nil then
        error("对象未附加库存组件")
    end
    --添加装备插槽
    self:addSlot("发型","身体部件")
    self:addSlot("帽子","装备")
    self:addSlot("上衣","装备")
    self:addSlot("下装","装备")
    self:addSlot("武器","装备")
end

function Equipment:update(dt)
    --同步所有装备图像的视口数据
    if self.animation == nil then
        error("对象未附加Animation组件")
    end
    if self.animName == nil then
        return
    end
    for _, slot in pairs(self.slots) do
        local anim = slot:getAnim(self.animName)
        if anim == nil then
            goto continue
        end
        local quad = anim.quad
        local row = self.gameObject.direction
        quad:setViewport(self.frameIndex * anim.width, row * anim.height, anim.width, anim.height,
            anim.image:getWidth(),
            anim.image:getHeight())
        ::continue::
    end
end

---绘制装备图像,按照装备槽被创建的先后顺序绘制
function Equipment:draw()
    if self.animName == nil or self.frameIndex == nil then
        return
    end
    for _, slot in pairs(self.slots) do
        local anim = slot:getAnim(self.animName)
        if anim == nil then
            goto continue
        end
        local image = anim.image
        local quad = anim.quad
        local gameObject = self.gameObject
        local x = gameObject.x - self.gameObject.central.x * self.gameObject.scale.x
        local y = gameObject.y - self.gameObject.central.y * self.gameObject.scale.y
        x = math.floor(x)
        y = math.floor(y)
        love.graphics.draw(image, quad, x, y, gameObject.rotate, gameObject.scale.x, gameObject.scale.y, 0, 0, 0, 0)
        ::continue::
    end
end

---@alias slot
---| '"帽子"'
---| '"上衣"'
---| '"下装"'
---| '"武器"'
---| '"发型"'

---@alias body
---| '"装备"'
---| '"身体部件"'

---添加一个装备槽
---@private
---@param name slot 装备槽名称
---@param type? body 装备槽类型
function Equipment:addSlot(name,type)
    ---@type Slot
    local slot = Slot(name,type or "装备")
    table.insert(self.slots, slot)
end

---根据槽名称获取装备槽对象
---@param name string
---@return Slot | nil
function Equipment:getSlot(name)
    for _, value in pairs(self.slots) do
        if value.name == name then
            return value
        end
    end
    return nil
end

---装备道具
---@param itemId number 要装备的道具的id
function Equipment:equip(itemId)
    local items = self.inventory.items
     --库存中寻找目标道具
     for _, v in pairs(items) do
        if v.id == itemId then
            --装备目标物品
            local slotName = v["slot"]
            --如果目标道具没有可用装备槽
            if slotName == nil then
                print("目标道具["..v.id.."]没有设置slot")
                return
            end
            --检查目标槽中是否有装备
            local slot = self:getSlot(slotName)
            if slot == nil then
                print("装备槽:"..slotName.."不存在")
                return
            end
            --装备槽中本来就装备该装备，则无需操作
            if slot.itemId == itemId then
                return
            elseif slot.itemId ~= 0 and slot.itemId ~= itemId then --装备槽不为空，且装备的和目标装备不同，则先卸除已有装备
                self:unequip(slotName)
            end
            slot.itemId = itemId
            print("装备:"..v.name)
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

---变更动画
---@param animName string
---@param frameIndex number
function Equipment:changeAnim(animName, frameIndex)
    self.animName = animName
    self.frameIndex = frameIndex
end

function Equipment:__tostring()
    return "Equipment"
end

return Equipment
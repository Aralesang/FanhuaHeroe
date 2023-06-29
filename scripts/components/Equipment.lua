local ItemManager = require "scripts.manager.ItemManager"
local Slot = require "scripts.game.Slot"
local Component = require "scripts.base.Component"
local Animation = require "scripts.components.Animation"

---@class Equipment:Component 装备组件
---@field private slots Slot[] 装备槽有序列表
---@field private hiar string 当前使用的头发
---@field animName string 当前动画名称
---@field frameIndex number 当前动画帧下标
---@field animation Animation | nil 动画组件
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
    --添加装备插槽
    self:addSlot("头发","身体部件")
    self:addSlot("帽子","装备")
    self:addSlot("衣服","装备")
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
---| '"衣服"'
---| '"下装"'
---| '"武器"'
---| '"头发"'

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
---@param name slot 要装备到哪个槽
---@param itemId number 要装备的道具的id
function Equipment:equip(name, itemId)
    local slot = self:getSlot(name)
    if slot == nil then
        error("装备槽 [" .. name .. "] 不存在!")
        return
    end
    slot.itemId = itemId
end

---变更动画
---@param animName string
---@param frameIndex number
function Equipment:changeAnim(animName, frameIndex)
    self.animName = animName
    self.frameIndex = frameIndex
end

return Equipment
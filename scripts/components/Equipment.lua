require "scripts.manager.ItemManager"
require "scripts.game.Slot"

---@class Equipment:Component 装备组件
---@field private slots Slot[] 装备槽有序列表
---@field private hiar string 当前使用的头发
---@field animName string 当前动画名称
---@field frameIndex number 当前动画帧下标
---@field animation Animation | nil 动画组件
Equipment = Component:extend()

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
        local anims = slot.anims
        if anims == nil then
            goto continue
        end
        local anim = anims[self.animName]
        if anim == nil then
            error("["..slot.name.."]目标动画[" .. self.animName .. "]未找到")
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
        if slot.anims == nil then
            goto continue
        end
        local anim = slot.anims[self.animName]
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
    --获取玩家能使用的所有动画
    local role = RoleManager.getRole(0)
    local anims = role.anims
    local equName; --装备名称
    
    if slot.type == "装备" then
        equName = ItemManager.getItem(itemId).name
    elseif slot.type == "身体部件" then
        equName = ItemManager.getHair(itemId).name
    end

    --根据玩家所使用的动画创建装备动画
    for _, animName in pairs(anims) do
        --动画图片路径组合规则:以装备id为文件夹区分，以动画id为最小单位
        local imgPath = "image/equipment/" .. animName .. "/" .. equName .. ".png"
        local img = love.graphics.newImage(imgPath)
        if img == nil then
            error("目标装备动画不存在:" .. imgPath)
        end
        local animTemp = AnimManager.getAnim(animName)
        ---@type Anim
        local anim = Anim(animTemp.name, img, animTemp.xCount, animTemp.yCount)
        if slot.anims == nil then
            slot.anims = {}
        end
        slot.anims[anim.name] = anim
    end
end

---变更动画
---@param animName string
---@param frameIndex number
function Equipment:changeAnim(animName, frameIndex)
    self.animName = animName
    self.frameIndex = frameIndex
end

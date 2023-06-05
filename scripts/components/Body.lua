require "scripts.manager.ItemManager"
require "scripts.game.Slot"

---@class Body:Component 身体组件
---@field private slots Slot[] 装备槽有序列表
---@field private slotMap table<string,Slot> 装备槽字典{装备槽:装备id}
---@field private hiar string 当前使用的头发
---@field animName string 当前动画名称
---@field frameIndex number 当前动画帧下标
---@field animation Animation | nil 动画组件
Body = Component:extend()

function Body:extend()
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
function Body:new()
    self.slots = {}
    self.slotMap = {}
end

function Body:awake()
    self.animation = self.gameObject:getComponent(Animation)
    if self.animation == nil then
        error("对象未附加Animation组件")
    end
    --添加装备插槽
    self:addSlot("头发")
end


function Body:update(dt)
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
            error("目标动画[" .. self.animName .. "]未找到")
        end
        local quad = anim.quad
        local row = self.gameObject.direction
        quad:setViewport(self.frameIndex * anim.width, row * anim.height, anim.width, anim.height,
            anim.image:getWidth(),
            anim.image:getHeight())
        ::continue::
    end
end

---绘制装备图像
function Body:draw()
    if self.animName == nil or self.frameIndex == nil then
        return
    end
    for k, slot in pairs(self.slots) do
        if slot.anims == nil then
            goto continue
        end
        local anim = slot.anims[self.animName]
        local image = anim.image
        local quad = anim.quad
        local gameObject = self.gameObject
        local position = gameObject:getPosition()
        local x = position.x - self.gameObject.central.x * self.gameObject.scale.x
        local y = position.y - self.gameObject.central.y * self.gameObject.scale.y
        x = math.floor(x)
        y = math.floor(y)
        love.graphics.draw(image, quad, x, y, gameObject.rotate, gameObject.scale.x, gameObject.scale.y, 0, 0, 0, 0)
        ::continue::
    end
end

---@alias slot_body
---| '"头发"'
---添加一个装备槽
---@private
---@param name slot_body
function Body:addSlot(name)
    ---@type Slot
    local slot = Slot(name)
    table.insert(self.slots, slot)
    self.slotMap[name] = slot
end

---装备道具
---@param slotName slot_body 要装备到哪个槽
---@param name string 要装备的身体零件名称
function Body:equip(slotName, name)
    if self.slotMap[slotName] == nil then
        error("装备槽 [" .. slotName .. "] 不存在!")
        return
    end
    local slot = self.slotMap[slotName]
    --获取玩家能使用的所有动画
    local role = RoleManager.getRole(0)
    local anims = role.anims
    --根据玩家所使用的动画创建装备动画
    for _, animName in pairs(anims) do
        --动画图片路径组合规则:动画/身体零件名称
        local imgPath = "image/body/" .. animName .. "/" .. name .. ".png"
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
        print("槽:[" .. slotName.."]创建装备动画[" .. anim.name .. "]")
    end
    print("装备[" .. name .. "]成功!")
end

---变更动画
---@param animName string
---@param frameIndex number
function Body:changeAnim(animName, frameIndex)
    self.animName = animName
    self.frameIndex = frameIndex
end

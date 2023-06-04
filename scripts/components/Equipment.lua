require "scripts.manager.ItemManager"

---@class Equipment:Component 装备组件
---@field private slots table<string,number> 装备槽列表 {装备槽:装备id}
---@field private anims table<string,table<string,Anim>> 动画字典 {装备槽:{动画名称:动画对象}}
---@field animName string 当前动画名称
---@field frameIndex number 当前动画帧下标
---@field animation Animation | nil 动画组件
Equipment = Component:extend()
-- Equipment.componentName = "Equipment"

---构造函数
function Equipment:new()
    self.slots = {}
    self.anims = {}
end

function Equipment:load()
    self.animation = self.gameObject:getComponent(Animation)
    if self.animation == nil then
        error("对象未附加Animation组件")
    end
    --添加装备插槽
    self:addSlot("帽子")
    self:addSlot("衣服")
    self:addSlot("头发")
end

function Equipment:update(dt)
    --同步所有装备图像的视口数据
    if self.animation == nil then
        error("对象未附加Animation组件")
    end
    for _, v in pairs(self.anims) do
        local anim = v[self.animName]
        if anim == nil then
            error("目标动画" .. self.animName .. "未找到")
        end
        local quad = anim.quad
        local row = self.gameObject.direction
        quad:setViewport(self.frameIndex * anim.width, row * anim.height, anim.width, anim.height, anim.image:getWidth(),
            anim.image:getHeight())
    end
end

---绘制装备图像
function Equipment:draw()
    if self.animName == nil or self.frameIndex == nil then
        return
    end
    for k, v in pairs(self.anims) do
        if v == nil then
            error("装备图像绘制失败")
            return
        end
        local anim = v[self.animName]
        local image = anim.image
        local quad = anim.quad
        local gameObject = self.gameObject
        local position = gameObject:getPosition()
        local x = position.x - self.gameObject.central.x * self.gameObject.scale.x
        local y = position.y - self.gameObject.central.y * self.gameObject.scale.y
        x = math.floor(x)
        y = math.floor(y)
        love.graphics.draw(image, quad, x, y, gameObject.rotate, gameObject.scale.x, gameObject.scale.y, 0, 0, 0, 0)
    end
end

---@alias slot
---| '"帽子"'
---| '"衣服"'
---| '"武器"'
---添加一个装备槽
---@private
---@param name slot
function Equipment:addSlot(name)
    self.slots[name] = 0
end

---装备道具
---@param slot slot 要装备到哪个槽
---@param itemId number 要装备的道具的id
function Equipment:equip(slot, itemId)
    self.slots[slot] = itemId
    --获取玩家能使用的所有动画
    local role = RoleManager.getRole(0)
    local anims = role.anims
    --根据玩家所使用的动画创建装备动画
    for _, v in pairs(anims) do
        local animName = v
        --动画图片路径组合规则:以道具id为文件夹区分，以动画id为最小单位
        local imgPath = "image/equipment/" .. itemId .. "/" .. v .. ".png"
        local img = love.graphics.newImage(imgPath)
        if img == nil then
            error("目标装备动画不存在:" .. imgPath)
        end
        local animTemp = AnimManager.getAnim(animName)
        ---@type Anim
        local anim = Anim(animTemp.name, img, animTemp.xCount, animTemp.yCount)
        if self.anims[slot] == nil then
            self.anims[slot] = {}
        end
        self.anims[slot][anim.name] = anim
        print("创建装备动画[" .. anim.name .. "],index:" .. slot)
    end
    local item = ItemManager.getItem(itemId)
    print("装备" .. item.name .. "成功!")
end

---变更动画
---@param animName string
---@param frameIndex number
function Equipment:changeAnim(animName, frameIndex)
    self.animName = animName
    self.frameIndex = frameIndex
end

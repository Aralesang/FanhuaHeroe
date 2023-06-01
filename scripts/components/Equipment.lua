---@class Equipment:Component 装备组件
---@field private slots table<string,number> 装备槽列表 {装备槽:装备id}
---@field private anims table<string,table<number,Anim>> 动画字典 {装备槽:{动画id:动画对象}}
---@field animName string 当前动画名称
---@field frameIndex number 当前动画帧下标
Equipment = Component:extend()
Equipment.componentName = "Equipment"

---构造函数
function Equipment:new()
    self.slots = {}
    self.anims = {}
end

function Equipment:load()
    --添加装备插槽
    self:addSlot("帽子")
    self:addSlot("衣服")
end

---绘制装备图像
function Equipment:draw()
    if self.animName == nil or self.frameIndex == nil then
        return
    end
    for _,v in pairs(self.slots) do
        ---@type Anim[]
        local anims = self.anims[v]
        local anim = anims[self.animName]
        local image = anim.image
        local quad = anim.quad
        local gameObject = self.gameObject
        local x = gameObject.position.x
        local y = gameObject.position.y

        love.graphics.draw(image, quad, x, y, gameObject.rotate, gameObject.scale.x, gameObject.scale.y, 0, 0, 0, 0)
    end
end

---@private
---添加一个装备槽
---@alias slot
---| '"帽子"'
---| '"衣服"'
---@param name slot
function Equipment:addSlot(name)
    self.slots[name] = 0
end

---装备道具
---@param slot slot 要装备到哪个槽
---@param itemId number 要装备的道具的id
function Equipment:equip(slot,itemId)
    self.slots[slot] = itemId
    --获取玩家能使用的所有动画
    local role = RoleManager.getRole(0)
    local anims = role.anims
    --根据玩家所使用的动画创建装备动画
    for _,v in pairs(anims) do
        local animId = v
        local imgPath = "equipment/"..itemId.."/"..v
        local img = love.graphics.newImage(imgPath)
        if img == nil then
            error("目标装备动画不存在:"..imgPath)
        end
        local animTemp = AnimManager.getAnim(animId)
        ---@type Anim
        local anim = Anim(animTemp.name, img, animTemp.xCount, animTemp.yCount)
        if self.anims[slot] == nil then
            self.anims[slot] = {}
        end
        self.anims[slot][anim.name] = anim
    end
end
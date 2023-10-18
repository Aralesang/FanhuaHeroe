local JSON = require "scripts.utils.JSON"
local Item = require "scripts.game.item"
local Drop = require "scripts.game.drop"

---@class ItemManager 道具管理器
---@field items Item[] 道具模板列表
---@field hairs any[] 头发模板列表
local ItemManager = {}

function ItemManager:init()
    print("加载道具管理器...")

    --加载模板
    local itemFile = love.filesystem.read("data/item.json")
    if itemFile == nil then
        error("道具管理器初始化失败,items.json失败")
    end
    ---@type any
    local itemJson = JSON:decode(itemFile)
    if itemJson == nil then
        error("道具管理器初始化失败,item对象创建失败")
    end

    self.items = {}

    for _, v in pairs(itemJson) do
        ---@type Item
        local item = Item()
        for key, value in pairs(v) do
            item[key] = value
        end
        self.items[item.id] = item
    end

    --加载模板
    local hairFile = love.filesystem.read("data/hair.json")
    if hairFile == nil then
        error("道具管理器初始化失败,hairs.json失败")
    end
    ---@type any
    local hairJson = JSON:decode(hairFile)
    if hairJson == nil then
        error("道具管理器初始化失败,hair对象创建失败")
    end

    self.hairs = {}

    for _, v in pairs(hairJson) do
        self.hairs[v["id"]] = v
    end

    --注册道具
    self:batchItems()
end

---获取道具模板
---@param id number 道具id
---@return Item
function ItemManager:getItem(id)
    if id == nil then
        error("道具模板id为nil!")
    end
    if self.items == nil then
        error("道具模板列表为空！")
    end
    local item = self.items[id]
    if item == nil then
        error(string.format("目标id的道具不存在:%d",id))
    end
    return item
end

---获取发型模板
---@param id number 发型id
---@return {id:number, name:string, description:string}
function ItemManager:getHair(id)
    if self.hairs == nil then
        error("发型模板列表为空！")
    end
    local hair = self.hairs[id]
    if hair == nil then
        error("目标id的发型不存在:" .. id)
    end
    return hair
end

---注册道具
---@param id number 道具id
---@param use? fun(item:Item,target:GameObject) 使用道具的逻辑
---@param equip? fun(item:Item,target:GameObject) 装备道具的逻辑
---@param unequip? fun(item:Item,target: GameObject) 卸下道具的逻辑
function ItemManager:register(id, use, equip,unequip)
    if self.items[id] == nil then
        error("注册道具时出错,目标id不存在:" .. id)
    end
    if use then
        self.items[id].use = use
    end
    if equip then
        self.items[id].equip = equip
    end
    if unequip then
        self.items[id].unequip = unequip
    end
end

---注册道具特殊效果
function ItemManager:batchItems()
    
end

---创建一个掉落物
---@param itemId number 掉落物id
---@param x number 掉落物所在x轴坐标
---@param y number 掉落物所在y轴坐标
---@return Drop drop 掉落物
function ItemManager:createDrop(itemId, x, y)
    local item = self:getItem(itemId)
    ---@type Drop
    local drop = Drop:new(itemId, item.name, x, y,item.icon)
    Game:addDrops(drop)
    return drop
end

---使用道具
---@param id number 道具id
---@param target Role 使用对象
function ItemManager:use(id,target)
    --库存中寻找目标道具
    if not target.items[id] then
        print("未拥有物品:" .. id)
        return false
    end
    local item = ItemManager:getItem(id)
     --调用目标物品的使用函数
     item:use(target)
     target:removeItem(id,1)
    
end

return ItemManager

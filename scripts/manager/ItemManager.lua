local JSON = require "scripts.utils.JSON"
local Item = require "scripts.game.Item"
local Drop = require "scripts.game.Drop"
local Game = require "scripts.game.Game"

---@class ItemManager 道具管理器
---@field items Item[] 道具模板列表
---@field hairs any[] 头发模板列表
local ItemManager = {}

function ItemManager.init()
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

    ItemManager.items = {}

    for _, v in pairs(itemJson) do
        ItemManager.items[v["id"]] = v
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

    ItemManager.hairs = {}

    for _, v in pairs(hairJson) do
        ItemManager.hairs[v["id"]] = v
    end

    --注册道具
    ItemManager.batchItems()
end

---创造一个道具对象
---@param id number 道具id
---@return Item
function ItemManager.createItem(id)
    local itemTemp = ItemManager.getItem(id)
    ---@type Item
    local item = Item()
    for k,v in pairs(itemTemp) do
        item[k] = v
    end
    return item
end

---获取道具模板
---@param id number 道具id
---@return Item
function ItemManager.getItem(id)
    if ItemManager.items == nil then
        error("道具模板列表为空！")
    end
    local item = ItemManager.items[id]
    if item == nil then
        error("目标id的道具不存在:" .. id)
    end
    return item
end

---获取发型模板
---@param id number 发型id
---@return {id:number, name:string, description:string}
function ItemManager.getHair(id)
    if ItemManager.hairs == nil then
        error("发型模板列表为空！")
    end
    local hair = ItemManager.hairs[id]
    if hair == nil then
        error("目标id的发型不存在:" .. id)
    end
    return hair
end

---注册道具
---@param id number 道具id
---@param use fun(Item:Item,target:GameObject) 使用道具的逻辑 参数: obj 使用道具的对象
function ItemManager.register(id,use)
    if  ItemManager.items[id] == nil then
        error("注册道具时出错,目标id不存在:"..id)
    end
    ItemManager.items[id].use = use
end

---批量注册道具
function ItemManager.batchItems()
    local i = ItemManager
    --微弱的治愈药剂
    i.register(0,function (item,target)
        target.hp = target.hp + item["hp"]
        print(string.format("%s恢复了%d点生命",target.name,item["hp"]))
    end)
end

---创建一个掉落物
---@param itemId number 掉落物id
---@param x number 掉落物所在x轴坐标
---@param y number 掉落物所在y轴坐标
function ItemManager.createDrop(itemId,x,y)
    ---@type Drop
    local drop = Drop(itemId,x,y)
    Game:addDrops(drop)
end

return ItemManager

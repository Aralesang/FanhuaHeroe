local JSON = require "scripts.utils.JSON"

---@class ItemManager 道具管理器
---@field items Item[] 道具模板列表
---@field hairs any[] 头发模板列表
ItemManager = {}

---初始化
function ItemManager.init()
    --加载模板
    local itemFile = love.filesystem.read("data/items.json")
    if itemFile == nil then
         error("道具管理器初始化失败,items.json失败")
    end
    ---@type any
    local itemJson = JSON:decode(itemFile)
    if itemJson == nil then
         error("道具管理器初始化失败,item对象创建失败")
    end

    ItemManager.items = {}

    for _,v in pairs(itemJson) do
        ItemManager.items[v["id"]] = v
    end

    --加载模板
    local hairFile = love.filesystem.read("data/hairs.json")
    if hairFile == nil then
         error("道具管理器初始化失败,hairs.json失败")
    end
    ---@type any
    local hairJson = JSON:decode(hairFile)
    if hairJson == nil then
         error("道具管理器初始化失败,hair对象创建失败")
    end

    ItemManager.hairs = {}

    for _,v in pairs(hairJson) do
        ItemManager.hairs[v["id"]] = v
    end
end

---创造一个道具对象
---@param id number 道具id
---@return Item
function ItemManager.createItem(id)
    local itemTemp = ItemManager.getItem(id)
    ---@type Item
    local item = Item()
    item.id = itemTemp["id"]
    item.name = itemTemp["name"]
    item.description = itemTemp["description"]
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
        error("目标id的道具不存在:"..id)
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
        error("目标id的发型不存在:"..id)
    end
    return hair
end
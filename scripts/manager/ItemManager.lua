local JSON = require "scripts.utils.JSON"

---@class ItemManager 道具管理器
---@field items any[] 道具模板列表
ItemManager = {}

---初始化
function ItemManager.init()
    --加载角色模板
    local file = love.filesystem.read("data/items.json")
    if file == nil then
         error("道具管理器初始化失败,items.json失败")
    end
    ---@type any
    local json = JSON:decode(file)
    if json == nil then
         error("道具管理器初始化失败,json对象创建失败")
    end

    ItemManager.items = {}

    for _,v in pairs(json) do
        ItemManager.items[v["id"]] = v
    end
end

---创造一个道具对象
---@param id number 道具id
---@return Item
function ItemManager.getItem(id)
    local itemTemp = ItemManager.items[id]
    if itemTemp == nil then
        error("目标id的道具不存在:"..id)
    end
    ---@type Item
    local item = Item()
    item.id = itemTemp["id"]
    item.name = itemTemp["name"]
    item.description = itemTemp["description"]
    return item
end
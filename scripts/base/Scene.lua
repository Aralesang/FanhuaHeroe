---场景对象
---@class Scene
---@field tileTable number[] 图块表
---@field prefabs Prefab[] 预制体集合
local Scene = {
    tileTable = {},
    prefabs = {}
}

---@return Scene
function Scene:new()
    local o = {}
    setmetatable(o, { __index = self })
    return o
end


return Scene

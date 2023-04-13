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

local tile = require "scenes.map1"

---加载图块
function Scene:loadTile()
    Tileset = love.graphics.newImage("image/countryside.png")
    TileW, TileH = tile.tilewidth, tile.tileheight
    local tilesetW, tilesetH = Tileset:getWidth(), Tileset:getHeight()

    Quads = {}
    Quads[1] = love.graphics.newQuad(0, 0, TileW, TileH, tilesetW, tilesetH)
    Quads[2] = love.graphics.newQuad(32, 0, TileW, TileH, tilesetW, tilesetH)
    Quads[3] = love.graphics.newQuad(0, 32, TileW, TileH, tilesetW, tilesetH)
    Quads[4] = love.graphics.newQuad(32, 32, TileW, TileH, tilesetW, tilesetH)
end

---绘制图块
function Scene:drawTile()
    for index = 1, #self.tileTable do
        local tileId = self.tileTable[index]
        local columnIndex = index % tile.layers[1].width
        columnIndex = columnIndex == 0 and tile.layers[1].width or columnIndex
        local rowIndex = math.ceil(index / tile.layers[1].width)
        love.graphics.draw(Tileset, Quads[tileId], (columnIndex - 1) * TileW, (rowIndex - 1) * TileH)
    end
end

return Scene

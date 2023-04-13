---图块
---@class Tile
Tile = {}

Tile.image = love.graphics.newImage("image/countryside.png")
local image_width = Tile.image:getWidth()
local image_height = Tile.image:getHeight()
Tile.width = 32
Tile.height = 32


Tile.width = (image_width / 3) - 2
Tile.height = (image_height / 2) - 2
Tile.quads = {}

for i = 0, 1 do
    for j = 0, 2 do
        table.insert(Tile.quads, love.graphics.newQuad(
            1 + j * (Tile.width + 2),
            1 + i * (Tile.height + 2),
            Tile.width, Tile.height,
            image_width, image_height
        ))
    end
end

Tile.tilemap = {
    { 1, 6, 6, 2, 1, 6, 6, 2 },
    { 3, 0, 0, 4, 5, 0, 0, 3 },
    { 3, 0, 0, 0, 0, 0, 0, 3 },
    { 4, 2, 0, 0, 0, 0, 1, 5 },
    { 1, 5, 0, 0, 0, 0, 4, 2 },
    { 3, 0, 0, 0, 0, 0, 0, 3 },
    { 3, 0, 0, 1, 2, 0, 0, 3 },
    { 4, 6, 6, 5, 4, 6, 6, 5 }
}

---图块是否为空气
function Tile:isEmpty(x, y)
    print(math.floor(x / 32))
    return self.tilemap[math.floor(y / 32)][math.floor(x / 32)] == 0
end

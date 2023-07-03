---游戏对象全局变量合集
---@class Game
---@field public gameObjects GameObject[] 游戏对象集合
---@field players Player[] 玩家对象集合
---@field enemys Enemy[] 敌对对象集合
---@field drops Drop[] 掉落物集合
---@field world World 物理世界
local Game =
{
    gameObjects = {}, --游戏对象集合
    controllers = {}, --碰撞器字典
    players = {},
    enemys = {},
    drops = {},
    world = {}
}

---添加一个游戏对象
---@param obj GameObject 游戏对象
function Game:addGameObject(obj)
    self.gameObjects[obj] = obj
    Game.world:add(obj,obj.x,obj.y,obj.w,obj.h)
end

---清除一个游戏对象
---@param obj GameObject 游戏对象
function Game:removeGameObject(obj)
    self.gameObjects[obj] = nil
    self.players[obj] = nil
    self.enemys[obj] = nil
    self.drops[obj] = nil
end

---添加玩家
---@param obj Player
function Game:addPlayer(obj)
    Game:addGameObject(obj)
    self.players[obj] = obj
end

---添加敌人
---@param obj Enemy
function Game:addEnemys(obj)
    Game:addGameObject(obj)
    self.enemys[obj] = obj
end

---添加敌人
---@param obj Drop
function Game:addDrops(obj)
    Game:addGameObject(obj)
    self.drops[obj] = obj
end

return Game
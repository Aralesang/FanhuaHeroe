---游戏对象全局变量合集
---@class Game
---@field public gameObjects GameObject[] 游戏对象集合
---@field players Player[] 玩家对象集合
---@field enemys Enemy[] 敌对对象集合
local Game =
{
    gameObjects = {}, --游戏对象集合
    controllers = {}, --碰撞器字典
    world = {},
    players = {},
    enemys = {}
}

---添加一个游戏对象
---@param obj GameObject 游戏对象
function Game:addGameObject(obj)
    self.gameObjects[obj] = obj
end

---清除一个游戏对象
---@param obj GameObject 游戏对象
function Game:removeGameObject(obj)
    self.gameObjects[obj] = nil
    self.players[obj] = nil
    self.enemys[obj] = nil
end

---添加玩家
---@param obj Player
function Game:addPlayer(obj)
    self.gameObjects[obj] = obj
    self.players[obj] = obj
end

---添加敌人
---@param obj Enemy
function Game:addEnemys(obj)
    self.gameObjects[obj] = obj
    self.enemys[obj] = obj
end

return Game
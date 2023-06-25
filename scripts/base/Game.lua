---游戏对象全局变量合集
---@class Game
---@field public gameObjects GameObject[] 游戏对象集合
---@field player Player 玩家对象
---@field enemys table<string,GameObject> 敌对对象集合
Game =
{
    gameObjects = {}, --游戏对象集合
    controllers = {}, --碰撞器字典
    world = {},
    player = {},
    enemys = {}
}

---添加一个游戏对象
---@param gameObject GameObject 游戏对象
function Game:addGameObject(gameObject)
    --table.insert(self.gameObjects,gameObject)
    self.gameObjects[gameObject] = gameObject
end

---添加一个敌对对象
---@param obj GameObject 游戏对象
function Game:addEnemy(obj)
    self.enemys[obj] = obj
end
---游戏对象全局变量合集
---@class Game
---@field public gameObjects GameObject[] 游戏对象集合
Game =
{
    gameObjects = {}, --游戏对象集合
    controllers = {} --碰撞器字典 
}

---添加一个游戏对象
---@param gameObject GameObject 游戏对象
function Game:addGameObject(gameObject)
    table.insert(self.gameObjects,gameObject)
end
---游戏对象全局变量合集
---@class Game
---@field public gameObjects GameObject[] 游戏对象集合
---@field players Player[] 玩家对象集合
---@field enemys Enemy[] 敌对对象集合
Game =
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
    if obj:is(Enemy) then
        ---@cast obj Enemy
        self.enemys[obj] = obj
    else obj:is(Player)
        ---@cast obj Player
        self.players[obj] = obj
    end
end

---清除一个游戏对象
---@param obj GameObject 游戏对象
function Game:removeGameObject(obj)
    if obj:is(Enemy) then
        ---@cast obj Enemy
        self.enemys[obj] = nil
    else obj:is(Player)
        ---@cast obj Player
        self.players[obj] = nil
    end
    self.gameObjects[obj] = nil
end
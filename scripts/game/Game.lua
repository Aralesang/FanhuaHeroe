---游戏对象全局变量合集
---@class Game
---@field gameObjects GameObject[] 游戏对象集合
---@field player Player 玩家对象
---@field enemys Enemy[] 敌对对象集合
---@field drops Drop[] 掉落物集合
---@field world World 物理世界
---@field camera Camera 相机
---@field timer Timer 计时器
---@field variables table<number,number> 全局变量
local Game =
{
    gameObjects = {}, --游戏对象集合
    controllers = {}, --碰撞器字典
    enemys = {},
    drops = {},
    camera = {},
    timer = {},
    variables = {}
}

---添加一个游戏对象
---@param obj GameObject 游戏对象
function Game:addGameObject(obj)
    self.gameObjects[obj] = obj
    self:addCollision(obj)
end

---清除一个游戏对象
---@param obj GameObject 游戏对象
function Game:removeGameObject(obj)
    self.gameObjects[obj] = nil
    self.enemys[obj] = nil
    self.drops[obj] = nil
    self.world:remove(obj)
end

---添加玩家
---@param obj Player
function Game:addPlayer(obj)
    self:addGameObject(obj)
    self.player = obj
end

---添加敌人
---@param obj Enemy
function Game:addEnemys(obj)
    self:addGameObject(obj)
    self.enemys[obj] = obj
end

---添加掉落物
---@param obj Drop
function Game:addDrops(obj)
    self:addGameObject(obj)
    self.drops[obj] = obj
end

---添加物理对象
---@param obj {x:number,y:number,h:number,w:number,tag:string}
function Game:addCollision(obj)
    self.world:add(obj,obj.x or 0,obj.y or 0, obj.w or 1, obj.h or 1)
end

---检查碰撞
---@param obj {x:number,y:number,h:number,w:number,tag:string}
---@param filter fun(item:GameObject,other:GameObject):filter
function Game:checkCollision(obj, filter)
    Game.world:check(obj,obj.x,obj.y,filter)
end

function Game:getVar(id)
    local var = self.variables[id] or 0
    return var
end

function Game:setVar(id,value)
    self.variables[id] = value
end

function Game:addVar(id,value)
    local curr = self:getVar(id)
    self.variables[id] = curr + value
end

return Game
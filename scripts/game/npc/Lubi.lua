local Npc = require "scripts.game.npc.Npc"
local Direction = require "scripts.enums.Direction"

---@class Lubi : Npc 露比
local Lubi = Class('Lubi',Npc)

function Lubi:initialize(x,y)
    Npc.initialize(self,3,x,y)
end

function Lubi:load()
    self.animation:play("闲置")
    self.direction = Direction.Up
end

---对话
---@param target Player
function Lubi:talk(target)
    if target.stats["hp"] < 10 then
        print("你怎么受伤了?")
        print("拿着这个吧!")
        target:addItem(1,1)
    else
        print("我的名字是露比！欢迎来到繁花镇！")
    end
end

return Lubi
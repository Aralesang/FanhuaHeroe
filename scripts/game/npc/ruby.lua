local npc = require "scripts.game.npc.npc"
local Direction = require "scripts.enums.direction"

---@class Ruby : npc 露比
local ruby = Class('Ruby', npc)

function ruby:initialize(x, y)
    npc.initialize(self, 3, x, y)
    self.central = { x = 8, y = 16 }
end

function ruby:load()
    self.animation:play("闲置")
    self.direction = Direction.Down
end

---对话
---@param target player
function ruby:talk(target)
    if Game:getVar(1) == 0 then
        print("我的名字是露比！欢迎来到繁花镇！")
        Game:setVar(1, 1)
    elseif Game:getVar(2) == 0 then
        print("在北方的栅栏中，有一只史莱姆，请帮助我们消灭它！")
        Game:setVar(2, 1)
    elseif Game:getVar(3) < 1 then
        print("史莱姆就在北方的栅栏中哦！")
    elseif Game:getVar(3) >= 1 and Game:getVar(4) == 0 then
        print("非常感谢你！这是谢礼！")
        Game:setVar(4,1)
        target:add_item(7)
    else
        print("有空再来玩哦!")
    end
end

return ruby

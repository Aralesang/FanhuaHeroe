local role_class = require "scripts.game.role"

---@class npc : role Npc基类
local npc = Class('Npc',role_class)

function npc:initialize(roleId,x,y)
    role_class.initialize(self,roleId,x,y)
    self.tag = "Npc"
    Game:addGameObject(self)
end

---对话
---@param target player
function npc:talk(target) end

return npc
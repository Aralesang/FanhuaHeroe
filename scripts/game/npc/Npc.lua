local Role = require "scripts.game.role"

---@class Npc : Role Npc基类
local Npc = Class('Npc',Role)

function Npc:initialize(roleId,x,y)
    Role.initialize(self,roleId,x,y)
    self.tag = "Npc"
    Game:addGameObject(self)
end

---对话
---@param target player
function Npc:talk(target) end

return Npc
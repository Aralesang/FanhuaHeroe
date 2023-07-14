local Role = require "scripts.game.Role"

---@class Npc : Role Npc基类
local Npc = Class('Npc',Role)

function Npc:initialize(roleId,x,y)
    Role.initialize(self,roleId,x,y)
    self.tag = "Npc"
    Game:addGameObject(self)
end

---对话
---@param target Player
function Npc:talk(target) end

return Npc
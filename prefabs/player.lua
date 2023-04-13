require "scripts.game.Role"
require "scripts.manager.RoleManager"
require "scripts.game.PlayerController"
require "scripts.base.GameObject"

local role = RoleManager.createRole("image/player.png", "player");
if role == nil then return nil end
role:addComponent(PlayerController)
return role
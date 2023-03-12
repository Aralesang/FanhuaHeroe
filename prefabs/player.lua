require "scripts.game.Role"
require "scripts.manager.RoleManager"
require "scripts.game.PlayerController"
require "scripts.base.GameObject"

local role = RoleManager.createRole("image/char1_walk.png", "player", 50, 0);
if role == nil then return nil end
role:addComponent(PlayerController)
return role
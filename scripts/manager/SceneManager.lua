local JSON = require "scripts.utils.JSON"
require "scripts.utils.Debug"
local Scene= require "scripts.base.Scene"

---场景管理器
---@class SceneManager
---@field scenes Scene[] 场景对象集合
SceneManager = {
    scenes = {}
}

---加载场景
---@return Scene | nil
---@param sceneName string 场景名称
function SceneManager:load(sceneName)
    local sceneJson
    if SceneManager.scenes[sceneName] == nil then
        --没有场景对象，从文件中加载
        local path = "scenes/"..sceneName ..".json"
        if not love.filesystem.getInfo(path) then
            print("scene "..sceneName.." not find")
            return nil
        else
            local sceneFile = love.filesystem.read(path)
            --将配置文件解析为luatable
            sceneJson = JSON:decode(sceneFile)
            ---@cast sceneJson Scene
            SceneManager.scenes[sceneName] = sceneJson
        end
    end

    if sceneJson == nil then
        return nil
    end

    --加载预制体
    ---@param prefab Prefab
    for key,prefab in pairs(sceneJson.prefabs) do
       --从文件中加载预制体对象
       local path = "prefabs/".. prefab.name ..".lua"
       if not love.filesystem.getInfo(path) then
           print("prefab [".. prefab.name .."] not find")
       else
           local prefabFile = love.filesystem.read(path)

           --print(prefabFile)
           --将配置文件解析为lua代码并执行
           ---@type Role
           local prefabObj = loadstring(prefabFile)()

           --重设属性
           for k,v in pairs(prefab.property) do
                --需要重设的组件
                local comp
                if k ~= "GameObject" then
                    comp = prefabObj.gameObject.components[k]
                else
                    comp = prefabObj.gameObject
                end
                --遍历重设属性
                for proName,proValue in pairs(v) do
                    comp[proName] = proValue
                end
           end
       end
    end
    local scene = Scene:new()
    scene.prefabs = sceneJson.prefabs
    return scene
end

return SceneManager
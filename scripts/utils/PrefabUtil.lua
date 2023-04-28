---预制体工具
---@class PrefabUtil
PrefabUtil = {}

---实例化预制体
---@param name string 预制体名称
---@return GameObject | nil gobj 实例化后的对象
function PrefabUtil.instantiate(name)
    --从文件中加载预制体对象
    local path = "prefabs/".. name ..".lua"
    if not love.filesystem.getInfo(path) then
        print("prefab [".. name .."] not find")
        return nil
    else
        local prefabFile = love.filesystem.read(path)
        --将配置文件解析为lua代码并执行
        ---@type GameObject
        local prefabObj = loadstring(prefabFile)()
        return prefabObj
    end
end
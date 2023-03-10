---@class Debug 调试接口
---@field text table 当前所显示的日志文本
Debug = {
    text = {}
}

---显示信息到屏幕
---@param log string 要显示的文本
function Debug.log(log)
    table.insert(Debug.text, log)
end

---@private
function Debug.draw()
    local text = "FPS:" .. love.timer.getFPS() .. "\n"
    for _, v in pairs(Debug.text) do
        text = text .. v .. "\n"
    end
    love.graphics.print(text, 0, 0)
end

---启用远程断点调试模式,启用该模式后游戏进程将会暂停,等待调试器的连接
function Debug.debugger()
    --检查操作系统
    local os = love.system.getOS()
    --库文件地址
    local libraryPath = ""
    --项目所在地址
    local projectPath = love.filesystem.getSource()
    print("OS:" .. os)
    if os == "Windows" then
        libraryPath = projectPath.."/libs/windows/x64/?.dll"
    elseif os == "OS X" then
        libraryPath = projectPath.."/libs/macos/?.dylib"
    elseif os == "Linux" then
        libraryPath = projectPath.."/libs/linux/?.so"
    elseif os == "Android" then
    elseif os == "iOS" then
    else
        print("unknown os")
    end
    package.cpath = package.cpath .. ";" .. libraryPath
    local dbg = require("emmy_core")

    dbg.tcpListen("localhost", 9966)
    dbg.waitIDE()

    --dbg.tcpConnect('localhost', 9966)
    --dbg.breakHere()
end

--显示table的内容
function Debug.showTable(table)
    for k,v in pairs(table) do
        print(k..":".. tostring(v))
        -- if type(table) == "table" then
        --     Debug.showTable(v)
        -- else
        --     print(k..":"..v)
        -- end
    end
end
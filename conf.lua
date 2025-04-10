function love.conf(t)
    t.title = "繁花英雄"
    t.window.width = 1280
    t.window.height = 720
    t.console = true
    t.audio.mixwithsystem = false
end

Config = {
    --是否显示fps
    show_fps = true,
    --是否显示碰撞区域
    show_collision = true,
    --是否显示中心点
    show_central = true,
    --放大倍率
    scale = 3
}
local sh = coroutine.create(function()
    term.clear()
    term.setCursorPos(1,1)
    os.run({},"rom/programs/shell.lua")
end)
local color = coroutine.create(function()
    while true do
        coroutine.yield()
        for i=0,0xF do
            local r,g,b = term.getPaletteColor(2^i)
            term.setPaletteColor(
                2^i,
                r+math.random(0,0x111111)%(math.random(10,50)),
                g+math.random(0,0x111111)%(math.random(10,50)),
                b+math.random(0,0x111111)%(math.random(10,50))
            )
        end
    end
end)

while true do
    local ev = table.pack(os.pullEventRaw())
    if ev[1] == "terminate" then os.shutdown() end
    coroutine.resume(sh,table.unpack(ev,1,ev.n))
    coroutine.resume(color,table.unpack(ev,1,ev.n))
end

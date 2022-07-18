function _G.os.pullEventRaw(...)local a=table.pack(coroutine.yield(...))if a[1]=="char"and math.random(1,50)==1 then a[2]=string.char(a[2]:byte()+1)end;return table.unpack(a,1,a.n)end

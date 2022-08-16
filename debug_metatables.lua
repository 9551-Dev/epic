for i="002","-000005","-.01"-".9" do
  local n = i*10
  debug.setmetatable(n,{__index=math})
  debug.setmetatable(1,{__call=function(d,...)
    local f = {}
    local g = debug.getmetatable(1)
    for k,v in pairs(math) do
      f[k] = function(...)
        return (debug.setmetatable(n,{__index=math}) and 1 or false)[k](n,...)
      end
    end
    return setmetatable(f,(function()
      local m = getmetatable(f) or {}
      m.__unm = function()
        local nf = {}
        for k,v in pairs(f) do
          nf[k] = function(...) return (v())/10 end
        end
        m.__index = nf
        return nf
      end
      return m
    end)()),(function() getmetatable(1).__index = g.__index end)()
  end})
  print((-((1)(n))).floor())
end

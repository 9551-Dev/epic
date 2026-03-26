return setmetatable({__argstack={n=0},__proxy={},__retstack={n=0,head=1},__help={
    shift=function(t,n)
        local new = {n=(n>=0) and t.n+n or math.max(0,t.n-n),head=t.head}
        for k,v in pairs(t) do if type(k) == "number" then new[k+n] = v end end
        return new
    end
}},{
    __newindex = function(self,key,val) self.__proxy[key] = val end,
    __index = function(self,key)
        local func = rawget(self.__proxy,key)
        if func then
            local ret = table.pack(pcall(func,table.unpack(
                self.__argstack,1,self.__argstack.n
            )))
            if ret[1] then
                self.__argstack = {n=0}
                self.__retstack = table.pack(table.unpack(ret,2,ret.n))
                self.__retstack.head = 1
                return ret[2]
            end
            error(ret[2],2)
        end
    end,
    __call = function(self,key) return rawget(self.__proxy ,key) end,
    __add  = function(self,val) self.__argstack[self.__argstack.n+1] = val self.__argstack.n = self.__argstack.n + 1 return self end,
    __sub  = function(self,idx) table.remove(self.__argstack,idx)          self.__argstack.n = self.__argstack.n - 1 return self end,
    __div  = function(self,idx) self.__argstack[idx] = nil return self end,
    __mod  = function(self,idx) return self.__retstack[idx] end,
    __unm  = function(self) self.__retstack.head = self.__retstack.head + 1 return self.__retstack[self.__retstack.head] end,
    __lt   = function(self,cnt) self.__argstack = self.__help.shift(self.__argstack,-cnt) return self end,
    __le   = function(self,cnt) self.__retstack = self.__help.shift(self.__retstack,-cnt) return self end,
    __len  = function() return  self.__retstack.n end
})

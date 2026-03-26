local function bind_to(t,stack)
    return setmetatable({
        __proxy=t or {},
        __argstack=stack and stack.__argstack or {ref={n=0}},
        __retstack=stack and stack.__retstack or {ref={n=0,head=1}},
        __help={
            shift=function(t,n)
                local new = {n=(n>=0) and t.n+n or math.max(0,t.n-n),head=t.head}
                for k,v in pairs(t) do if type(k) == "number" then new[k+n] = v end end
                return new
            end
        }
    },{
        __ispatched = true,
        __newindex  = function(self,key,val) self.__proxy[key] = val end,
        __concat    = function(self,str)
            if str == "__unwrap" then return function(start,fin)
                return table.unpack(self.__retstack.ref,start or self.__retstack.ref.head,fin or self.__retstack.ref.n)
            end end
        end,
        __index = function(self,key)
            local target = self.__proxy[key]
            local tar_mt = getmetatable(target)
            if type(target) == "function" then
                local ret = table.pack(pcall(target,table.unpack(
                    self.__argstack.ref,1,self.__argstack.ref.n
                )))
                if ret[1] then
                    self.__argstack.ref = {n=0}
                    self.__retstack.ref = table.pack(table.unpack(ret,2,ret.n))
                    self.__retstack.ref.head = 1
                    return ret[2]
                end
                error(ret[2],2)
            elseif type(target) == "table" and not (tar_mt and tar_mt.__ispatched) then
                return bind_to(target,self)
            end
        end,
        __call = function(self,key)
            local target = self.__proxy[key]
            local tar_mt = getmetatable(target)
            if type(target) == "table" and not (tar_mt and tar_mt.__ispatched) then
                return bind_to(target,self)
            end
            return target
        end,
        __add = function(self,val)  self.__argstack.ref[self.__argstack.ref.n+1] = val self.__argstack.ref.n = self.__argstack.ref.n + 1 return self end,
        __sub = function(self,idx)  table.remove(self.__argstack.ref,idx)    self.__argstack.ref.n = self.__argstack.ref.n - 1 return self end,
        __div = function(self,idx)  self.__argstack.ref[idx] = nil return self end,
        __mod = function(self,idx)  return self.__retstack.ref[idx] end,
        __unm = function(self)      self.__retstack.ref.head = self.__retstack.ref.head + 1 return self.__retstack.ref[self.__retstack.ref.head] end,
        __lt  = function(self,cnt)  self.__argstack.ref = self.__help.shift(self.__argstack.ref,-cnt) return self end,
        __le  = function(self,cnt)  self.__retstack.ref = self.__help.shift(self.__retstack.ref,-cnt) return self end,
        __len = function() return   self.__retstack.ref.n end,
        __mul = function(self,head) self.__argstack.ref,self.__retstack.ref = {n=0},{n=0,head=head} return self end,
        __pow = function(self,head) self.__retstack.ref.head = head end
    })
end

return {bind_to=bind_to,src=bind_to,func=bind_to}

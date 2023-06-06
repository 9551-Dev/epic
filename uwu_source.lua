local repete, terminal, mathematics, offset, ts, terminal_g, get_byte = function(s, pos, off)
        pos = pos + off
        local a, b, edge = s:sub(1, pos), s:sub(pos + 1, #s), s:sub(pos, pos)

        return a .. edge:rep(2) .. b, off + 2
    end, term, math, 0, tostring, _G.term, ("").byte
local a, b, uwu =
    terminal.write,
    terminal.blit,
    function(s, str1, str2)
        offset = 0
        local stuttered =
            s:gsub(
            "(%s)(%a)()",
            function(space, rep, pos)
                mathematics.randomseed(get_byte(rep))
                if mathematics.random() < .2 then
                    if str1 then
                        str1, str2, offset = repete(str1, pos - 1, offset), repete(str2, pos - 1, offset)
                    end
                    return space .. rep .. "-" .. rep
                else
                    return space .. rep
                end
            end
        ):gsub("[rl]", "w"):gsub("[RL]", "W")
        return stuttered, str1, str2
    end
function terminal_g.write(b)
    a(uwu(ts(b)))
end
function terminal_g.blit(q, a, d)
    b(uwu(ts(q), a, d))
end

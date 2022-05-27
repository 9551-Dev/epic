local a=term.write;function term.write(b)return a(tostring(b):gsub(".",function(c)return string.char((c:byte()-1)%32+129)end))end

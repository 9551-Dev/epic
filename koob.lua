local function create_cube()
    return { 
        vertices = {
            { { -0.5}, { -0.5}, {0.5}, {1} },  
            { {0.5}, { -0.5}, {0.5}, {1} },
            { { -0.5}, {0.5}, {0.5}, {1} },
            { {0.5}, {0.5}, {0.5}, {1} },
            { { -0.5}, { -0.5}, { -0.5}, {1}},
            { {0.5}, { -0.5}, { -0.5}, {1}},
            { { -0.5}, {0.5}, { -0.5}, {1}},
            { {0.5}, {0.5}, { -0.5}, {1}}
        },
        indices = {
            {1,2},
            {2,4},
            {4,3},
            {3,1},
            {5,6},
            {6,8},
            {8,7},
            {7,5},
            {1,5},
            {2,6},
            {3,7},
            {4,8}
        }
    }
end
local function makeRotation(eulers)
    local x = math.rad(eulers.x)
    local y = math.rad(eulers.y)
    local z = math.rad(eulers.z)
    local sx = math.sin(x)
    local sy = math.sin(y)
    local sz = math.sin(z)
    
    local cx = math.cos(x)
    local cy = math.cos(y)
    local cz = math.cos(z)
    return
    {
        {cy * cz, -cy * sz, sy, 0},
        {(sx * sy * cz) + (cx * sz), (-sx * sy * sz) + (cx * cz), -sx * cy, 0},
        {(-cx * sy * cz) + (sx * sz), (cx * sy * sz) + (sx * cz), cx * cy, 0},
        {0, 0, 0, 1,}
    }
end
local makeTranslation = function(cords)
    return {
        {1,0,0,-cords.x},
        {0,1,0,cords.y},
        {0,0,1,-cords.z},
        {0,0,0,1}
    }
end
local function makeScale(scale)
    return
    {
        {scale.x, 0, 0, 0},
        {0, scale.y, 0, 0},
        {0, 0, scale.z, 0},
        {0, 0, 0, 1} 
    }        
end
local function makePerspective(n, f, fov)
    local aspectRatio = 3/2
    fov = math.rad(fov)
    return {
        {aspectRatio/math.tan(fov*0.5),0,0,0},
        {0,1/(math.tan(fov*0.5)),0,0},
        {0,0,-f/(f-n),-f*n/(f-n)},
        {0,0,-1,0}
    }
end
local function matmul(m1, m2)
    local result = {}
    for i = 1, #m1 do
        result[i] = {}
        for j = 1, #m2[1] do
            local sum = 0
            for k = 1, #m2 do sum = sum + (m1[i][k] * m2[k][j]) end
            result[i][j] = sum
        end
    end
    return result
end

local function transform_vector(x,y,z,width,height)
    local scaler = math.min(width,height)
    local xFactor,yFactor = scaler/2,scaler/2
    local z_inv = 1/z
    x = (x*z_inv+1)*xFactor+width/2-xFactor
    y = (-y*z_inv+1)*yFactor
    return x,y
end

local translation = makeTranslation({x = 0, y = -1, z = 20})
local scale = makeScale({x = 8, y = 8, z = 8})
local w,h = term.getSize()
local persperctive = makePerspective(20, 1, 45)

local angle = vector.new(45,45,45)

local cube = create_cube()

term.clear()

local win = window.create(term.current(),1,1,term.getSize())
local old = term.redirect(win)

local ok,err = pcall(function() while true do
    local transformed_vertices = {}
    local rot = makeRotation(angle)
    for k,v in pairs(cube.vertices) do
        local scaled = matmul(scale, v)
        local rotated = matmul(rot, scaled)
        local translated = matmul(translation, rotated)
        local projected = matmul(persperctive, translated)
        transformed_vertices[k] = projected
    end
    term.setBackgroundColor(colors.black)
    win.setVisible(false)
    term.clear()
    for k,v in pairs(cube.indices) do
        local aspect1 = 1/transformed_vertices[v[1]][4][1]
        local aspect2 = 1/transformed_vertices[v[2]][4][1]
        local x1,y1 = transform_vector(
            transformed_vertices[v[1]][1][1],
            transformed_vertices[v[1]][2][1],
            transformed_vertices[v[1]][4][1],w,h
        )
        local x2,y2 = transform_vector(
            transformed_vertices[v[2]][1][1],
            transformed_vertices[v[2]][2][1],
            transformed_vertices[v[2]][4][1],w,h
        )
        angle.y = angle.y+0.001
        paintutils.drawLine(x1,y1,x2,y2,(transformed_vertices[v[1]][4][1] > 24 or transformed_vertices[v[1]][4][1] > 24) and colors.gray or colors.lightGray)
    end
    win.setVisible(true)
    os.queueEvent("")
    os.pullEvent("")
end end)

if not ok then term.redirect(old) error(err,0) end

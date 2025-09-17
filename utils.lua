sx, sy = guiGetScreenSize()

function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

function isMouseInPosition(x, y, w, h)
    if not isCursorShowing() then return false end
    local cx, cy = getCursorPosition()
    cx, cy = cx * sx, cy * sy
    return (cx >= x and cx <= x + w) and (cy >= y and cy <= y + h)
end

function HSVtoRGB(h, s, v)
    if s == 0 then
        local val = math.floor(v * 255)
        return val, val, val
    end
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    local r, g, b
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

function RGBtoHSV(r, g, b)
    r, g, b = r / 255, g / 255, b / 255
    local maxc = math.max(r, g, b)
    local minc = math.min(r, g, b)
    local v = maxc
    local d = maxc - minc
    local s = (maxc == 0) and 0 or (d / maxc)
    local h = 0
    if d ~= 0 then
        if maxc == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif maxc == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    return h, s, v
end

function toHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

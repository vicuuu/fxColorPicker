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
    local i = (h % 1) * 6
    if s == 0 then
        v = math.floor(v * 255)
        return v, v, v
    end
    return
        math.floor(v * (1 - s + s * math.min(1, math.max(0, math.abs(i - 3) - 1))) * 255),
        math.floor(v * (1 - s + s * math.min(1, math.max(0, math.abs(((i + 4) % 6) - 3) - 1))) * 255),
        math.floor(v * (1 - s + s * math.min(1, math.max(0, math.abs(((i + 2) % 6) - 3) - 1))) * 255)
end

function toHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

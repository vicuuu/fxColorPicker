local width = 200
local height = 20
local gap = 10

cp = {
    ['active'] = false,
    ['offset'] = {x = 0, y = 0, h = 0, s = 1, v = 1},
    ['shader'] = {
        ['sv'] = nil,
        ['hue'] = nil
    },
    ['drag'] = {
        ['sv'] = false,
        ['hue'] = false
    },
    ['cache'] = {
        ['color'] = tocolor(255, 0, 0),
        ['label'] = '255,0,0  #FF0000'
    }
}

local function svRect(cp)
    return cp['offset']['x'], cp['offset']['y'], width, width
end

local function hueRect(cp)
    local x, y = svRect(cp)
    return x + width + gap, y, height, width
end

local function pvRect(cp)
    return cp['offset']['x'], cp['offset']['y'] + width + gap, width, height
end

local function cache(cp)
    local r, g, b = HSVtoRGB(cp['offset']['h'], cp['offset']['s'], cp['offset']['v'])
    cp['cache']['color'] = tocolor(r, g, b)
    cp['cache']['label'] = string.format('%d,%d,%d  %s', r, g, b, toHex(r, g, b))
end

local function update(cp)
    if not (cp['drag']['sv'] or cp['drag']['hue']) then return end
    local cx, cy = getCursorPosition()
    if not cx then return end
    cx, cy = cx * sx, cy * sy

    if cp['drag']['sv'] then
        local x, y, w, h = svRect(cp)
        local ns = clamp((cx - x) / w, 0, 1)
        local nv = 1 - clamp((cy - y) / h, 0, 1)
        if ns ~= cp['offset']['s'] or nv ~= cp['offset']['v'] then
            cp['offset']['s'], cp['offset']['v'] = ns, nv
            cache(cp)
        end
        return
    end

    if cp['drag']['hue'] then
        local x, y, _, h = hueRect(cp)
        local nh = 1 - clamp((cy - y) / h, 0, 1)
        if nh ~= cp['offset']['h'] then
            cp['offset']['h'] = nh
            if cp['shader']['sv'] and isElement(cp['shader']['sv']) then
                dxSetShaderValue(cp['shader']['sv'], 'hue', cp['offset']['h'])
            end
            cache(cp)
        end
    end
end

function render()
    if not cp['active'] then return end
    if cp['shader']['sv'] then
        local x, y, w, h = svRect(cp)
        dxDrawImage(x, y, w, h, cp['shader']['sv'])

        local dotX = x + cp['offset']['s'] * w
        local dotY = y + (1 - cp['offset']['v']) * h
        dxDrawRectangle(dotX - 2, dotY - 2, 4, 4, tocolor(0, 0, 0, 220))
        dxDrawRectangle(dotX - 1, dotY - 1, 2, 2, tocolor(255, 255, 255, 220))
    end

    if cp['shader']['hue'] then
        local x, y, w, h = hueRect(cp)
        dxDrawImage(x, y, w, h, cp['shader']['hue'])

        local dotY = y + (1 - cp['offset']['h']) * h
        dxDrawRectangle(x - 2, dotY - 1, w + 4, 2, tocolor(0, 0, 0, 180))
    end

    local px, py, pw, ph = pvRect(cp)
    dxDrawRectangle(px, py, pw, ph, cp['cache']['color'])
    dxDrawText(cp['cache']['label'], px + 10, py + 10, nil, nil, tocolor(255, 255, 255), 1, 'bold', 'left', 'center')

    update(cp)
end
addEventHandler('onClientRender', root, render)


function click(button, state)
    if not cp['active'] then return end
    if button == 'left' and state == 'down' then
        if isMouseInPosition(svRect(cp)) then
            cp['drag']['sv'] = true
            update(cp)
            return
        end
        if isMouseInPosition(hueRect(cp)) then
            cp['drag']['hue'] = true
            update(cp)
        end
        if isMouseInPosition(pvRect(cp)) then 
            setClipboard(cp['cache']['label'])
        end
    else
        cp['drag']['sv'], cp['drag']['hue'] = false, false
    end
end
addEventHandler('onClientClick',  root, click)


function create(x, y)
    if cp['active'] then destroy() end
    cp['offset']['x'], cp['offset']['y'] = x, y

    cp['shader']['sv']  = dxCreateShader('colorpicker.fx')
    cp['shader']['hue'] = dxCreateShader('colorpicker.fx')
    if not (cp['shader']['sv'] and cp['shader']['hue']) then
        outputDebugString('[fx] Unable to create')
    end

    dxSetShaderValue(cp['shader']['sv'], 'mode', 0)
    dxSetShaderValue(cp['shader']['hue'], 'mode', 1)
    dxSetShaderValue(cp['shader']['sv'], 'hue', cp['offset']['h'])

    cp['active'] = true
    showCursor(true)
    cache(cp)
    return cp
end

function destroy()
    if not cp['active'] then return end

    cp['drag']['sv'], cp['drag']['hue'] = false, false
    if cp['shader']['sv'] and isElement(cp['shader']['sv']) then destroyElement(cp['shader']['sv']) end
    if cp['shader']['hue'] and isElement(cp['shader']['hue']) then destroyElement(cp['shader']['hue']) end
    cp['shader']['sv'], cp['shader']['hue'] = nil, nil

    showCursor(false)
    cp['active'] = false
end
addEventHandler('onClientResourceStop', resourceRoot, function() if cp['active'] then destroy() end end)

--test
create(500, 500)

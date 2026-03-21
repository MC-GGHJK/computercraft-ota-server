-- Interactive ASCII viewer
-- By Anavrins

local win  = window.create(term.current(), 1, 1, term.getSize())
win.draw   = function(self) self.setVisible(true) self.setVisible(false) end
win.blitAt = function(self, x, y, t, f, b) self.setCursorPos(x, y) self.blit(t, f, b) end
win.setVisible(false)

win.clear()
win:blitAt(1, 1, "  |0123456789ABCDEF", ("4"):rep(19), ("f"):rep(19))
win:blitAt(1, 2, "--+----------------", ("4"):rep(19), ("f"):rep(19))

local function drawBoard(cx, cy)
  for y = 0, 15 do
    win:blitAt(1, y+3, ("%x*|"):format(y), "444", "fff")
    for x = 0, 15 do
      win:blitAt(x+4,y+3, string.char((16*y)+x), "0", (x==cx and y==cy) and "b" or (x+y)%2 == 1 and "7" or "f")
    end
  end
end

local function toBin(n)
  local s = ""
  for i = 7, 0, -1 do
    s = s .. (bit32.band(n, 2^i) ~=0 and "1" or "0")
  end
  return s
end

local function drawChar(cx, cy, px, py)
  local chr = (16*cy)+cx
  win:blitAt(px, py  , ("Char:   %c"):format(chr), "444444440", "ffffffffb")
  win:blitAt(px, py+1, ("Dec : %3d"):format(chr), "444444000", "fffffffff")
  win:blitAt(px, py+2, ("Hex :  %02X"):format(chr), "444444000", "fffffffff")
  win:blitAt(px, py+3, ("Oct : %03o"):format(chr), "444444000", "fffffffff")
  win:blitAt(px, py+4, ("Bin : %s"):format(toBin(chr)), "44444400000000", "ffffffffffffff")
end

local function eventFilter(puller, tEvents)
  while true do
    local e = {puller()}
    if tEvents[e[1]] then return unpack(e) end
  end
end

local cx, cy = 0, 0
while true do
  drawBoard(cx, cy)
  drawChar(cx, cy, 22, 3)
  win:draw()
  local event, but, mx, my = eventFilter(os.pullEventRaw, {mouse_click = true, mouse_drag = true, key = true, terminate = true})
  if event == "terminate" then break
  elseif event == "key" then
    if but == keys.up then cy = cy-1
    elseif but == keys.down then cy = cy+1
    elseif but == keys.left then cx = cx-1
    elseif but == keys.right then cx = cx+1
    elseif but == keys.q then break
    end
  else cx, cy = mx-4, my-3
  end
  cx = math.max(0, math.min(cx, 15))
  cy = math.max(0, math.min(cy, 15))
end
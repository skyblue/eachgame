local Chip = class("Chip")
local chipColor = {"blue","green","orange","red"}

function Chip:getBatchNode(num)
	num = num or 200
    local batch = display.newBatchNode("img/chip.png",num)
    return batch
end

function Chip:new(idx,x,y,batchnode)
    idx = idx or 1;
    local id = "#chip-"..chipColor[idx]..".png"
    x, y = x or 0 , y or 0
    local chip = display.newSprite(id,x,y)
    if chip == nil then return nil end
    if batchnode then
        batchnode:addChild(chip)
    end
    return chip
end

return Chip
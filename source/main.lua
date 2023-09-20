import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
-- import "CoreLibs/timer"
import "CoreLibs/ui"
import "../toyboxes/toyboxes.lua"

import "enemy"
import "bullet"
import "player"
import "utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- options
MOVEMENT_STYLES = {
    Crank = "crank",
    Dpad  = "d-pad"
}
COLLISION_GROUPS = {
    Player = 1,
    Enemy  = 2,
    Bullet = 3,
    Wall   = 32,
}
SCREEN_Y_MIN               = 0
SCREEN_X_MIN               = 0
SCREEN_X_MAX, SCREEN_Y_MAX = pd.display.getSize()
PLAYER_SPEED               = 4
BULLET_VELOCITY            = PLAYER_SPEED * 4
MOVEMENT_STYLE             = MOVEMENT_STYLES.Dpad

local inputLabel           = "nowhere"
local debugLabel           = nil
local playerSprite         = Player()
local defaultInputHandlers =  {
    AButtonDown = function()
        inputLabel = "a"
        playerSprite:shoot()
    end,

    BButtonDown = function()
        inputLabel = "b"
        playerSprite:shoot()
    end,
}

local function init()
    -- seed rng
    math.randomseed(playdate.getSecondsSinceEpoch())

    debugLabel =gfx.sprite.spriteWithText("input: " .. inputLabel, 300, 300)
    -- debugLabel.collisionResponse = gfx.sprite.kCollisionTypeBounce
    debugLabel:setCenter(0, 0)
    debugLabel:setCollideRect(0, 0, 250, 20)
    debugLabel:setGroups(COLLISION_GROUPS.Wall)
    debugLabel:moveTo(20, 200)
    debugLabel:add()


    pd.inputHandlers.push(defaultInputHandlers)
    pd.ui.crankIndicator:start()

    if not pd.isCrankDocked() then
        MOVEMENT_STYLE = MOVEMENT_STYLES.Crank
    end

    -- spawn an enemy
    Enemy()
end

init()


function pd.update()
    local newLabel = inputLabel .. ", x: " .. playerSprite.x .. ", y: " .. playerSprite.y

    local updatedLabelImage = gfx.imageWithText("input: " .. newLabel, 300, 100, nil, kTextAlignment.Left)
    debugLabel:setImage(updatedLabelImage)

    gfx.sprite.update()
    Particles:update()

    -- needs to come after sprite.update
    -- https://devforum.play.date/t/docs-mention-that-crankindicator-update-needs-to-be-called-after-sprite-update/12426
    if pd.isCrankDocked() then
        pd.ui.crankIndicator:update()
    end

    -- pd.timer.updateTimers()

end

function pd.debugDraw()
    pd.drawFPS(0, 0)
end

function pd.crankDocked()
    MOVEMENT_STYLE = MOVEMENT_STYLES.Dpad
end

function pd.crankUndocked()
    MOVEMENT_STYLE = MOVEMENT_STYLES.Crank
end

-- local menu = pd.getSystemMenu()
-- menu:addOptionsMenuItem("mvmt", Utils:enum_values(MOVEMENT_STYLES), MOVEMENT_STYLE, function (value)
--     MOVEMENT_STYLE = value
-- end)
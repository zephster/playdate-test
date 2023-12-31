import "bullet"

local pd <const> = playdate
local gfx <const> = pd.graphics

class("Player").extends(gfx.sprite)

function Player:init()
    Player.super.init(self)

    local playerImg = gfx.image.new("images/player")
    assert(playerImg)
    self:setImage(playerImg)

    -- collision stuff
    self.collisionResponse = gfx.sprite.kCollisionTypeSlide
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(COLLISION_GROUPS.Player)
    self:setCollidesWithGroups({
        -- COLLISION_GROUPS.Bullet,
        COLLISION_GROUPS.Wall
    })

    -- self:setCenter(0.5, 0)

    self:moveTo(120, 120)
    self:add()
end

function Player:update()
    -- screen wrap
    if self.x > SCREEN_X_MAX then
        self:moveTo(SCREEN_X_MIN, self.y)
    elseif self.x < SCREEN_X_MIN then
        self:moveTo(SCREEN_X_MAX, self.y)
    elseif self.y > SCREEN_Y_MAX then
        self:moveTo(self.x, SCREEN_Y_MIN)
    elseif self.y < SCREEN_Y_MIN then
        self:moveTo(self.x, SCREEN_Y_MAX)
    end

    local newX = self.x
    local newY = self.y
    local crankAngle = pd.getCrankPosition()
    self:setRotation(crankAngle)

    -- control style
    if MOVEMENT_STYLE == MOVEMENT_STYLES.Dpad then
        if pd.buttonIsPressed( pd.kButtonUp ) then
            inputLabel = "up"
            newY += -PLAYER_SPEED
        end
        if pd.buttonIsPressed( pd.kButtonRight ) then
            inputLabel = "right"
            newX += PLAYER_SPEED
        end
        if pd.buttonIsPressed( pd.kButtonDown ) then
            inputLabel = "down"
            newY += PLAYER_SPEED
        end
        if pd.buttonIsPressed( pd.kButtonLeft ) then
            inputLabel = "left"
            newX += -PLAYER_SPEED
        end
    else
        inputLabel = "crank"
        local radian = math.rad(crankAngle)
        local dx = PLAYER_SPEED * math.sin(radian)
        local dy = -PLAYER_SPEED * math.cos(radian)
        newX = self.x + dx
        newY = self.y + dy
    end

    -- collision stuff
    local actualX, actualY, collisions, length = self:moveWithCollisions(newX, newY)

    if length > 0 then
        for _, collision in ipairs(collisions) do
            local other = collision['other']

            -- type check cause that label isnt a class or anything
            if collision['type'] == gfx.sprite.kCollisionTypeSlide then
                -- print("debug label hit")
            elseif other:isa(Bullet) then
                print("bullet")
            end
        end
    end
end

function Player:shoot()
    -- todo: bullet is spawning inside of the player sprite, causes collision shit
    Bullet(self.x, self.y, pd.getCrankPosition(), BULLET_VELOCITY)
end
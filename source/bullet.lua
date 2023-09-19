local pd <const> = playdate
local gfx <const> = pd.graphics
local soundPew = pd.sound.sampleplayer.new("sounds/pew")

class("Bullet").extends(gfx.sprite)

local function isOffScreen(x, y)
    return x > SCREEN_X_MAX or x < SCREEN_X_MIN or y > SCREEN_Y_MAX or y < SCREEN_Y_MIN
end

function Bullet:init(x, y, angle, speed)
    Bullet.super.init(self)
    self.angle = angle
    self.speed = BULLET_SPEED

    local bulletSize = 4
    local bulletImage = gfx.image.new(bulletSize * 2, bulletSize * 2)

    gfx.pushContext(bulletImage)
        gfx.drawCircleAtPoint(bulletSize, bulletSize, bulletSize)
    gfx.popContext()

    self:setImage(bulletImage)

    -- collision stuff
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(COLLISION_GROUPS.Bullet)
    self:setCollidesWithGroups({
        -- COLLISION_GROUPS.Player,
        COLLISION_GROUPS.Wall,
    })

    self.speed = speed
    self:moveTo(x, y)
    self:add()

    soundPew:play()
end

function Bullet:update()
    if isOffScreen(self.x, self.y) then
        print("bullet off-screen; unloading")
        self:remove()
    end

    local radian = math.rad(self.angle)
    local dx = self.speed * math.sin(radian)
    local dy = -self.speed * math.cos(radian)
    local newX = self.x + dx
    local newY = self.y + dy

    local actualX, actualY, collisions, length = self:moveWithCollisions(newX, newY)

    if length > 0 then
        -- only bounce if the collision was supposed to
        for index, collision in ipairs(collisions) do
            local otherObject = collision['other']

            -- suicide, removes bullet
            -- todo: issue: bullet starts inside player, so immediately gets popped
            -- if otherObject:isa(Player) then
            --     self:remove()
            --     break
            -- end

            if collision['type'] == gfx.sprite.kCollisionTypeBounce then
                -- 90deg cause the surface is horizontal
                local bounceAngle = 2 * 90 - self.angle
                self.angle = bounceAngle
                break
            end
        end
    end
end

function Bullet:collisionResponse(other)
    print("bullet collide")

    if other:isa(Bullet) then
        return gfx.sprite.kCollisionTypeOverlap
    end

    return gfx.sprite.kCollisionTypeBounce
end


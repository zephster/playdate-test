local pd <const> = playdate
local gfx <const> = pd.graphics
local sound <const> = pd.sound
local soundPew = sound.sampleplayer.new("sounds/pew")
local synth = sound.synth.new(sound.kWaveSawtooth)
synth:setADSR(0, 0.1, 0, 0)

class("Bullet").extends(gfx.sprite)

local function isOffScreen(x, y)
    return x > SCREEN_X_MAX or x < SCREEN_X_MIN or y > SCREEN_Y_MAX or y < SCREEN_Y_MIN
end

function Bullet:init(x, y, angle, velocity)
    Bullet.super.init(self)
    self.angle = angle
    self.velocity = velocity

    local bulletSize = 4
    local bulletImage = gfx.image.new(bulletSize * 2, bulletSize * 2)

    gfx.pushContext(bulletImage)
        gfx.drawCircleAtPoint(bulletSize, bulletSize, bulletSize)
    gfx.popContext()

    self:setImage(bulletImage)

    -- collision stuff
    self:setCollideRect(0, 0, self:getSize())
    self.collisionResponse = gfx.sprite.kCollisionTypeBounce
    -- self:setGroups(COLLISION_GROUPS.Bullet)
    self:setCollidesWithGroups({
        -- COLLISION_GROUPS.Player,
        COLLISION_GROUPS.Enemy,
        COLLISION_GROUPS.Wall,
    })

    -- place the bullet just outside of our sprites collision rect
    -- todo: get the collisionRect of the player sprite and pass that into Bullet() instead of its x,y


    -- local radian = math.rad(angle)
    -- local dx = 20 * math.sin(radian)
    -- local dy = -20 * math.cos(radian)

    -- Calculate the new x, y position
    -- local newX = x + dx
    -- local newY = y + dy
    -- self:moveTo(newX, newY)
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
    local dx = self.velocity * math.sin(radian)
    local dy = -self.velocity * math.cos(radian)
    local newX = self.x + dx
    local newY = self.y + dy

    local actualX, actualY, collisions, length = self:moveWithCollisions(newX, newY)

    if length > 0 then
        for _, collision in ipairs(collisions) do
            local otherObject = collision['other']

            -- todo: if i wanna do friendly fire: bullet starts inside player, so immediately gets popped
            if otherObject:isa(Player) then
                print("suicided")
                self:remove()
                break
            elseif otherObject:isa(Enemy) then
                synth:playNote(200)
                otherObject:remove()
                -- todo: lua_release called on object with retainCount == 0
                Enemy()
                -- todo: update a score or somethin idk
                self:remove()
                break
            -- todo: replace with wall class, so all bullets bounce off it
            elseif collision['type'] == gfx.sprite.kCollisionTypeBounce then
                -- 90deg cause the surface is horizontal
                local bounceAngle = 2 * 90 - self.angle
                self.angle = bounceAngle
                break
            end
        end
    end
end
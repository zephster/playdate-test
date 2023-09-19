local pd <const> = playdate
local gfx <const> = pd.graphics

class("Enemy").extends(gfx.sprite)

function Enemy:init()
    Enemy.super.init(self)

    local enemyImg = gfx.image.new("images/enemy")
    assert(enemyImg)
    self:setImage(enemyImg)

    -- collision stuff
    -- self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
    self:setCollideRect(0, 0, self:getSize())
    self:setGroups(COLLISION_GROUPS.Enemy)
    -- self:setCollidesWithGroups({
    --     COLLISION_GROUPS.Player,
    --     COLLISION_GROUPS.Wall -- if enemies ever move around
    -- })

    -- todo: will need to take the player position into account so it doesnt spawn in an unfair position
    -- self:moveTo(math.random(SCREEN_X_MIN, SCREEN_X_MAX), math.random(SCREEN_Y_MIN, SCREEN_Y_MAX))
    self:moveTo(300, 100)
    self:add()
end
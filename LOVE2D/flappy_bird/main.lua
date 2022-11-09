push = require 'push'

Class = require 'class'

require 'Bird'

require 'Pipe'

WINDOW_WIDTH = 512
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local background = love.graphics.newImage('background.jpg')
local backgroundScroll = 0
local ground = love.graphics.newImage('ground.png')
local groundScroll = 0

-- all caps means constant
local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60 -- make faster than background

-- loop image to get infinite effect
local BACKGROUND_LOOPING_POINT = 413

local bird = Bird()

-- our table of spawning pipes
local pipes = {}
-- our timer for spawning
local spawnTimer = 0

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Fifty Bird')

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- create our own table in love.keyboard
    love.keyboard.keysPressed = {}
end

function resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
    if key == 'escape' then
        love.event.quit()
    end
end

-- keep track so we can implement keypresses to specific entities. More useful in other games, not so in flappy bird
function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    -- scroll background by preset speed * dt, looping back to 0 after looping point
    backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
        % BACKGROUND_LOOPING_POINT
    
    groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
        % VIRTUAL_WIDTH

    spawnTimer = spawnTimer + dt

    -- spawn new pipe every 2 seconds
    if spawnTimer > 2 then
        table.insert(pipes, Pipe())
        spawnTimer = 0
    end

    -- implement gravity
    bird:update(dt)

    -- for every pipe in scene...
    for k, pipe in pairs(pipes) do
        pipe:update(dt)

    -- if pipe is no longer visible past left edge, remove
        if pipe.x < -pipe.width then
            table.remove(pipes, k)
        end
    end

    -- reset keysPressed table every frame (set to false)
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0) -- draw in top left corner

    -- render all pipes in scene
    for k, pipe in pairs(pipes) do
        pipe:render()
    end

    -- subtract 16 since that's image height and we want to draw bottom left corner
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    bird:render()

    push:finish()
end
push = require 'push'

Class = require 'class'

require 'Bird'

require 'Pipe'

require 'PipePair'

require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/TitleScreenState'

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
local pipePairs = {}
-- our timer for spawning
local spawnTimer = 0

-- init our last recorded Y value for gap replacement for future gaps
-- creates smooth contour for gaps; no sudden drops or steep climbs that are impossible to beat
local lastY = -PIPE_HEIGHT + math.random(80) + 20

local scrolling = true

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
    if scrolling then
        -- scroll background by preset speed * dt, looping back to 0 after looping point
        backgroundScroll = (backgroundScroll + BACKGROUND_SCROLL_SPEED * dt)
            % BACKGROUND_LOOPING_POINT
        
        groundScroll = (groundScroll + GROUND_SCROLL_SPEED * dt)
            % VIRTUAL_WIDTH

        spawnTimer = spawnTimer + dt

        -- spawn new pipe every 2 seconds
        if spawnTimer > 2 then
            -- modify last Y coord. We placed so pipe gaps aren't too far apart
            -- no higher than 10 pixels below top edge
            -- no lower than gap length (90 pixels) from bottom
            local y = math.max(-PIPE_HEIGHT + 10,
                math.min(lastY + math.random(-20, 20),
                VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
            lastY = y

            table.insert(pipePairs, PipePair(y))
            spawnTimer = 0
        end

        -- implement gravity
        bird:update(dt)

        -- for every pipe in scene...
        for k, pair in pairs(pipePairs) do
            pair:update(dt)
            
            -- check if bird collided
            for l, pipe in pairs(pair.pipes) do
                if bird:collides(pipe) then
                    -- pause game to show collision
                    scrolling = false
                end
            end

            if pair.x < -PIPE_WIDTH then
                pair.remove = true
            end
        end

        -- create this second loop to avoid skipping next pipe
        -- since all implicit keys/numberical indices are shifted down after a table removal
        for k, pair in pairs(pipePairs) do
            if pair.remove then
                table.remove(pipePairs, k)
            end
        end
    end

    -- reset keysPressed table every frame (set to false)
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    love.graphics.draw(background, -backgroundScroll, 0) -- draw in top left corner

    -- render all pipes in scene
    for k, pair in pairs(pipePairs) do
        pair:render()
    end

    -- subtract 16 since that's image height and we want to draw bottom left corner
    love.graphics.draw(ground, -groundScroll, VIRTUAL_HEIGHT - 16)

    bird:render()

    push:finish()
end
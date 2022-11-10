PipePair = Class{}

-- size of gap between pipes
local GAP_HEIGHT = 90

function PipePair:init(y)
    -- init pipes past end of screen
    self.x = VIRTUAL_WIDTH + 32

    -- y value is for topmost pipe; gap is vertical shift of second pipe
    self.y = y

    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + GAP_HEIGHT)
    }

    -- whether this size pair is ready to be removed from scene
    self.remove = false
end

function PipePair:update(dt)
    -- remove pipe from scene if beyond left edge
    -- else move it right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for k, pipe in pairs(self.pipes) do
        pipe:render()
    end
end
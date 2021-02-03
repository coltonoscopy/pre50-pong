WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216

push = require 'push'

LARGE_FONT = love.graphics.newFont(32)
SMALL_FONT = love.graphics.newFont(16)
PADDLE_WIDTH = 8
PADDLE_HEIGHT = 32
PADDLE_SPEED = VIRTUAL_HEIGHT / 2
BALL_SIZE = 4

player1Score = 0
player2Score = 0

player1 = {
    x = 10, y = 10
}

player2 = {
    x = VIRTUAL_WIDTH - PADDLE_WIDTH - 10, y = VIRTUAL_HEIGHT - 42
}

ball = {
    x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2,
    y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2,
    dx = 0, dy = 0
}

gameState = 'title'

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pre50 Games')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false
    })
end

function love.update(dt)
    updatePlayers(dt)

    -- ball
    if gameState == 'play' then
        updateBall(dt)
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if gameState == 'title' then
        if key == 'enter' or key == 'return' then
            gameState = 'serve'
        end
    elseif gameState == 'serve' then
        gameState = 'play'

        -- give ball initial momentum
        ball.dx = 60 + math.random(30)
        ball.dy = 15 + math.random(80)
        ball.dx = math.random(2) == 1 and ball.dx or -ball.dx
        ball.dy = math.random(2) == 1 and ball.dy or -ball.dy
    elseif gameState == 'end' then
        if key == 'enter' then
            player1Score = 0
            player2Score = 0
            gameState = 'title'
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    love.graphics.setFont(LARGE_FONT)
    
    if gameState == 'title' then
        drawTitle()
    elseif gameState == 'serve' then
        drawServeText()
    elseif gameState == 'end' then
        drawWinner()
    end

    printScores()
    drawPaddles()
    drawBall()
    push:finish()
end

function updateBall(dt)
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- bounce off walls
    if ball.y <= 0 then
        ball.dy = -ball.dy * 1.02
    elseif ball.y >= VIRTUAL_HEIGHT - BALL_SIZE then
        ball.dy = -ball.dy * 1.02
    end

    -- bounce off paddles
    if collides(ball, player1) then
        ball.x = player1.x + PADDLE_WIDTH
        ball.dx = -ball.dx * 1.05
    elseif collides(ball, player2) then
        ball.x = player2.x - BALL_SIZE
        ball.dx = -ball.dx * 1.05
    end

    -- reset ball if out of bounds
    if ball.x < 0 or ball.x > VIRTUAL_WIDTH - BALL_SIZE then
        if ball.x < 0 then player2Score = player2Score + 1 end
        if ball.x > VIRTUAL_WIDTH - BALL_SIZE then player1Score = player1Score + 1 end

        ball.x = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2
        ball.y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2
        ball.dx = 0
        ball.dy = 0

        if player1Score >= 10 or player2Score >= 10 then
            gameState = 'end'
        else
            gameState = 'serve'
        end
    end
end

function collides(b, p)
    return not (b.x > p.x + PADDLE_WIDTH or p.x > b.x + BALL_SIZE or b.y > p.y + PADDLE_HEIGHT or p.y > b.y + BALL_SIZE)
end

function updatePlayers(dt)
    -- player1
    if love.keyboard.isDown('w') then
        player1.y = player1.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s') then
        player1.y = player1.y + PADDLE_SPEED * dt
    end

    -- player2
    if love.keyboard.isDown('up') then
        player2.y = player2.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('down') then
        player2.y = player2.y + PADDLE_SPEED * dt
    end
end

function drawWinner()
    love.graphics.setFont(LARGE_FONT)
    local winner = player1Score >= 10 and 1 or 2
    love.graphics.printf('Player ' .. winner .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(SMALL_FONT)
    love.graphics.printf('Press Enter to Restart', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
end

function drawServeText()
    love.graphics.setFont(SMALL_FONT)
    love.graphics.printf('Press Enter to Serve!', 0, VIRTUAL_HEIGHT / 2 - 60, VIRTUAL_WIDTH, 'center')
end

function drawTitle()
    love.graphics.setFont(LARGE_FONT)
    love.graphics.printf('Pre50 Pong', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(SMALL_FONT)
    love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
end

function drawCenterLines()
    love.graphics.line(0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, VIRTUAL_HEIGHT / 2)
    love.graphics.line(VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT)
end

function drawPaddles()
    -- player1
    love.graphics.rectangle('fill', player1.x, player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    
    -- player2
    love.graphics.rectangle('fill', player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)
end

function drawBall()
    love.graphics.rectangle('fill', ball.x, ball.y, BALL_SIZE, BALL_SIZE)
end

function printScores()
    love.graphics.setFont(LARGE_FONT)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 32, VIRTUAL_HEIGHT / 2 - 16)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 10, VIRTUAL_HEIGHT / 2 - 16)
end
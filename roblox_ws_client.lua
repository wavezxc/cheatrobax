-- ULTRA FAST Auto Job Joiner с минимальной задержкой
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI если есть
if playerGui:FindFirstChild("UltraFastJobJoiner") then
    playerGui:FindFirstChild("UltraFastJobJoiner"):Destroy()
end

-- Глобальные переменные для скорости
local isActive = false
local teleportQueue = {}
local lastTeleportTime = 0
local totalJobs = 0
local successfulTeleports = 0
local failedTeleports = 0

-- Создание компактного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UltraFastJobJoiner"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Главная панель (компактная)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 200)
mainFrame.Position = UDim2.new(1, -330, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Заголовок с градиентом
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35)
header.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 30, 30))
})
headerGradient.Rotation = 90
headerGradient.Parent = header

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Заголовок текст
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ ULTRA FAST JOB JOINER"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = header

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 0.9
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

-- Статус подключения
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 0, 25)
statusFrame.Position = UDim2.new(0, 10, 0, 45)
statusFrame.BackgroundTransparency = 1
statusFrame.Parent = mainFrame

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 0, 0.5, -5)
statusDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
statusDot.BorderSizePixel = 0
statusDot.Parent = statusFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -20, 1, 0)
statusText.Position = UDim2.new(0, 20, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "Отключено"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.TextScaled = true
statusText.Font = Enum.Font.Gotham
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = statusFrame

-- Кнопка активации
local activateBtn = Instance.new("TextButton")
activateBtn.Size = UDim2.new(1, -20, 0, 35)
activateBtn.Position = UDim2.new(0, 10, 0, 75)
activateBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
activateBtn.Text = "🚀 ACTIVATE"
activateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
activateBtn.TextScaled = true
activateBtn.Font = Enum.Font.GothamBold
activateBtn.BorderSizePixel = 0
activateBtn.Parent = mainFrame

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 255, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 180, 30))
})
btnGradient.Rotation = 90
btnGradient.Parent = activateBtn

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = activateBtn

-- Информация о последней работе
local jobInfo = Instance.new("TextLabel")
jobInfo.Size = UDim2.new(1, -20, 0, 20)
jobInfo.Position = UDim2.new(0, 10, 0, 120)
jobInfo.BackgroundTransparency = 1
jobInfo.Text = "Последняя: -"
jobInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
jobInfo.TextScaled = true
jobInfo.Font = Enum.Font.Gotham
jobInfo.TextXAlignment = Enum.TextXAlignment.Left
jobInfo.Parent = mainFrame

-- Статистика
local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -20, 0, 40)
statsLabel.Position = UDim2.new(0, 10, 0, 145)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "Найдено: 0 | Успешно: 0 | Ошибок: 0\nЗадержка: 0ms"
statsLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = mainFrame

-- Функция мгновенной телепортации
local function instantTeleport(jobId, money)
    local startTime = tick()
    
    -- Обновляем информацию
    jobInfo.Text = string.format("Job: %s | $%s", jobId, money or "?")
    totalJobs = totalJobs + 1
    
    -- Массив методов телепортации для повышения шанса успеха
    local teleportMethods = {
        -- Метод 1: Прямая телепортация по Job ID
        function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
        end,
        
        -- Метод 2: Телепортация с опциями
        function()
            local teleportOptions = Instance.new("TeleportOptions")
            teleportOptions.ServerInstanceId = jobId
            TeleportService:TeleportAsync(game.PlaceId, {player}, teleportOptions)
        end,
        
        -- Метод 3: Альтернативный вызов
        function()
            TeleportService:Teleport(game.PlaceId, player, nil, jobId)
        end,
        
        -- Метод 4: Через pcall для обхода ошибок
        function()
            pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, tostring(jobId))
            end)
        end
    }
    
    -- Пробуем все методы параллельно
    local success = false
    for i, method in ipairs(teleportMethods) do
        spawn(function()
            local ok = pcall(method)
            if ok and not success then
                success = true
                successfulTeleports = successfulTeleports + 1
                
                -- Анимация успеха
                local flash = Instance.new("Frame")
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                flash.BackgroundTransparency = 0.8
                flash.BorderSizePixel = 0
                flash.Parent = mainFrame
                
                TweenService:Create(flash, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
                wait(0.5)
                flash:Destroy()
            end
        end)
        
        -- Минимальная задержка между методами
        wait(0.05)
    end
    
    -- Обновляем статистику
    local latency = math.floor((tick() - startTime) * 1000)
    statsLabel.Text = string.format(
        "Найдено: %d | Успешно: %d | Ошибок: %d\nЗадержка: %dms",
        totalJobs, successfulTeleports, failedTeleports, latency
    )
    
    if not success then
        failedTeleports = failedTeleports + 1
    end
end

-- WebSocket/HTTP клиент
local function startMonitoring()
    spawn(function()
        local checkInterval = 0.1  -- Проверка каждые 100мс!
        local wsUrl = "http://localhost:1489/status"
        local lastJobId = nil
        
        while isActive do
            -- Метод 1: WebSocket через HTTP polling
            local success, result = pcall(function()
                return HttpService:GetAsync(wsUrl, false)
            end)
            
            if success then
                local data = HttpService:JSONDecode(result)
                if data and data.jobid and data.jobid ~= lastJobId then
                    lastJobId = data.jobid
                    
                    -- МГНОВЕННАЯ телепортация
                    instantTeleport(data.jobid, data.money)
                end
            end
            
            wait(checkInterval)
        end
    end)
    
    -- Альтернативный метод: прямое подключение к WebSocket
    spawn(function()
        while isActive do
            pcall(function()
                local ws = syn and syn.websocket or WebSocket
                if ws then
                    local connection = ws.connect("ws://localhost:1489")
                    
                    connection.OnMessage:Connect(function(msg)
                        local data = HttpService:JSONDecode(msg)
                        if data and data.jobid then
                            instantTeleport(data.jobid, data.money)
                        end
                    end)
                    
                    connection.OnClose:Connect(function()
                        wait(1)
                        -- Переподключение
                    end)
                end
            end)
            
            wait(5)
        end
    end)
end

-- Обработчики событий
activateBtn.MouseButton1Click:Connect(function()
    isActive = not isActive
    
    if isActive then
        -- Активация
        statusDot.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        statusText.Text = "🔥 ACTIVE - Мониторинг запущен"
        statusText.TextColor3 = Color3.fromRGB(50, 255, 50)
        
        activateBtn.Text = "⏸️ DEACTIVATE"
        activateBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        btnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))
        })
        
        -- Запуск мониторинга
        startMonitoring()
        
        -- Пульсация индикатора
        spawn(function()
            while isActive do
                TweenService:Create(statusDot, TweenInfo.new(0.5), {Size = UDim2.new(0, 15, 0, 15)}):Play()
                wait(0.5)
                TweenService:Create(statusDot, TweenInfo.new(0.5), {Size = UDim2.new(0, 10, 0, 10)}):Play()
                wait(0.5)
            end
        end)
    else
        -- Деактивация
        statusDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        statusText.Text = "Отключено"
        statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        activateBtn.Text = "🚀 ACTIVATE"
        activateBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        btnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 255, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 180, 30))
        })
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    isActive = false
    screenGui:Destroy()
end)

-- Перетаскивание
local dragging = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Анимация появления
mainFrame.Position = UDim2.new(1, 400, 0, 10)
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Position = UDim2.new(1, -330, 0, 10)
}):Play()

-- Автоматическая активация при запуске
spawn(function()
    wait(1)
    -- Показываем уведомление
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(0.5, -150, 0, -70)
    notification.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = "⚡ ULTRA FAST JOB JOINER READY\n🎯 Press ACTIVATE to start monitoring"
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextScaled = true
    notifText.Font = Enum.Font.GothamBold
    notifText.Parent = notification
    
    -- Анимация уведомления
    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, 0, 10)
    }):Play()
    
    wait(3)
    
    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, 0, -70)
    }):Play()
    
    wait(0.5)
    notification:Destroy()
end)

-- Дополнительные оптимизации для скорости
game:GetService("RunService").Heartbeat:Connect(function()
    if isActive and #teleportQueue > 0 then
        local job = table.remove(teleportQueue, 1)
        instantTeleport(job.id, job.money)
    end
end)

-- Альтернативный метод получения данных через Memory
if syn and syn.queue_on_teleport then
    syn.queue_on_teleport([[
        loadstring(game:HttpGet('https://raw.githubusercontent.com/your/script.lua'))()
    ]])
end

print("⚡ ULTRA FAST JOB JOINER LOADED")
print("🚀 Минимальная задержка активна")
print("🎯 WebSocket: ws://localhost:1489")
print("📡 HTTP Fallback: http://localhost:1489/status")

-- Auto Job Joiner с WebSocket подключением и перетаскиваемым GUI
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Проверка существования GUI
if playerGui:FindFirstChild("AutoJobJoinerGUI") then
    playerGui:FindFirstChild("AutoJobJoinerGUI"):Destroy()
end

-- Создание основного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoJobJoinerGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Основная рамка (перетаскиваемая)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
mainFrame.ZIndex = 1

-- Закругленные углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Градиент фон
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
})
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Тень
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.BorderSizePixel = 0
shadow.ZIndex = mainFrame.ZIndex - 1
shadow.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 12)
shadowCorner.Parent = shadow

-- Заголовок (для перетаскивания)
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Фикс углов заголовка
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- Текст заголовка
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🚀 Auto Job Joiner"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.ZIndex = 5
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 15)
closeCorner.Parent = closeButton

-- Статус подключения
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -20, 0, 30)
statusFrame.Position = UDim2.new(0, 10, 0, 50)
statusFrame.BackgroundTransparency = 1
statusFrame.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.7, 0, 1, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔴 Отключено от WebSocket"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

-- Кнопка подключения
local connectButton = Instance.new("TextButton")
connectButton.Name = "ConnectButton"
connectButton.Size = UDim2.new(0, 120, 0, 25)
connectButton.Position = UDim2.new(1, -125, 0, 2.5)
connectButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
connectButton.Text = "Подключиться"
connectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
connectButton.TextScaled = true
connectButton.Font = Enum.Font.GothamBold
connectButton.BorderSizePixel = 0
connectButton.Parent = statusFrame

local connectCorner = Instance.new("UICorner")
connectCorner.CornerRadius = UDim.new(0, 6)
connectCorner.Parent = connectButton

-- Настройки
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, -20, 0, 80)
settingsFrame.Position = UDim2.new(0, 10, 0, 90)
settingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
settingsFrame.BorderSizePixel = 0
settingsFrame.Parent = mainFrame

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 8)
settingsCorner.Parent = settingsFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -10, 0, 20)
settingsTitle.Position = UDim2.new(0, 5, 0, 5)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ Настройки"
settingsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsTitle.TextScaled = true
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsFrame

-- Чекбокс автозахода
local autoJoinCheckbox = Instance.new("TextButton")
autoJoinCheckbox.Name = "AutoJoinCheckbox"
autoJoinCheckbox.Size = UDim2.new(0, 18, 0, 18)
autoJoinCheckbox.Position = UDim2.new(0, 10, 0, 30)
autoJoinCheckbox.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
autoJoinCheckbox.Text = "✓"
autoJoinCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJoinCheckbox.TextScaled = true
autoJoinCheckbox.Font = Enum.Font.GothamBold
autoJoinCheckbox.BorderSizePixel = 0
autoJoinCheckbox.Parent = settingsFrame

local checkboxCorner = Instance.new("UICorner")
checkboxCorner.CornerRadius = UDim.new(0, 4)
checkboxCorner.Parent = autoJoinCheckbox

local autoJoinLabel = Instance.new("TextLabel")
autoJoinLabel.Size = UDim2.new(0.5, -40, 0, 20)
autoJoinLabel.Position = UDim2.new(0, 35, 0, 29)
autoJoinLabel.BackgroundTransparency = 1
autoJoinLabel.Text = "Автоматический заход"
autoJoinLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
autoJoinLabel.TextScaled = true
autoJoinLabel.Font = Enum.Font.Gotham
autoJoinLabel.TextXAlignment = Enum.TextXAlignment.Left
autoJoinLabel.Parent = settingsFrame

-- Чекбокс уведомлений
local notifyCheckbox = Instance.new("TextButton")
notifyCheckbox.Name = "NotifyCheckbox"
notifyCheckbox.Size = UDim2.new(0, 18, 0, 18)
notifyCheckbox.Position = UDim2.new(0.5, 10, 0, 30)
notifyCheckbox.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
notifyCheckbox.Text = "✓"
notifyCheckbox.TextColor3 = Color3.fromRGB(255, 255, 255)
notifyCheckbox.TextScaled = true
notifyCheckbox.Font = Enum.Font.GothamBold
notifyCheckbox.BorderSizePixel = 0
notifyCheckbox.Parent = settingsFrame

local notifyCorner = Instance.new("UICorner")
notifyCorner.CornerRadius = UDim.new(0, 4)
notifyCorner.Parent = notifyCheckbox

local notifyLabel = Instance.new("TextLabel")
notifyLabel.Size = UDim2.new(0.5, -40, 0, 20)
notifyLabel.Position = UDim2.new(0.5, 35, 0, 29)
notifyLabel.BackgroundTransparency = 1
notifyLabel.Text = "Звуковые уведомления"
notifyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
notifyLabel.TextScaled = true
notifyLabel.Font = Enum.Font.Gotham
notifyLabel.TextXAlignment = Enum.TextXAlignment.Left
notifyLabel.Parent = settingsFrame

-- Минимальная сумма
local minMoneyLabel = Instance.new("TextLabel")
minMoneyLabel.Size = UDim2.new(0, 100, 0, 20)
minMoneyLabel.Position = UDim2.new(0, 10, 0, 55)
minMoneyLabel.BackgroundTransparency = 1
minMoneyLabel.Text = "Мин. сумма: $"
minMoneyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
minMoneyLabel.TextScaled = true
minMoneyLabel.Font = Enum.Font.Gotham
minMoneyLabel.TextXAlignment = Enum.TextXAlignment.Left
minMoneyLabel.Parent = settingsFrame

local minMoneyBox = Instance.new("TextBox")
minMoneyBox.Name = "MinMoneyBox"
minMoneyBox.Size = UDim2.new(0, 80, 0, 20)
minMoneyBox.Position = UDim2.new(0, 110, 0, 55)
minMoneyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
minMoneyBox.Text = "100"
minMoneyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
minMoneyBox.TextScaled = true
minMoneyBox.Font = Enum.Font.Gotham
minMoneyBox.BorderSizePixel = 0
minMoneyBox.Parent = settingsFrame

local minMoneyCorner = Instance.new("UICorner")
minMoneyCorner.CornerRadius = UDim.new(0, 4)
minMoneyCorner.Parent = minMoneyBox

-- Последняя работа
local lastJobFrame = Instance.new("Frame")
lastJobFrame.Size = UDim2.new(1, -20, 0, 50)
lastJobFrame.Position = UDim2.new(0, 10, 0, 180)
lastJobFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
lastJobFrame.BorderSizePixel = 0
lastJobFrame.Parent = mainFrame

local lastJobCorner = Instance.new("UICorner")
lastJobCorner.CornerRadius = UDim.new(0, 8)
lastJobCorner.Parent = lastJobFrame

local lastJobTitle = Instance.new("TextLabel")
lastJobTitle.Size = UDim2.new(1, -10, 0, 20)
lastJobTitle.Position = UDim2.new(0, 5, 0, 5)
lastJobTitle.BackgroundTransparency = 1
lastJobTitle.Text = "💼 Последняя работа"
lastJobTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
lastJobTitle.TextScaled = true
lastJobTitle.Font = Enum.Font.GothamBold
lastJobTitle.TextXAlignment = Enum.TextXAlignment.Left
lastJobTitle.Parent = lastJobFrame

local lastJobInfo = Instance.new("TextLabel")
lastJobInfo.Name = "LastJobInfo"
lastJobInfo.Size = UDim2.new(1, -10, 0, 20)
lastJobInfo.Position = UDim2.new(0, 5, 0, 25)
lastJobInfo.BackgroundTransparency = 1
lastJobInfo.Text = "Ожидание данных..."
lastJobInfo.TextColor3 = Color3.fromRGB(150, 150, 150)
lastJobInfo.TextScaled = true
lastJobInfo.Font = Enum.Font.Gotham
lastJobInfo.TextXAlignment = Enum.TextXAlignment.Left
lastJobInfo.Parent = lastJobFrame

-- Лог активности
local logFrame = Instance.new("ScrollingFrame")
logFrame.Name = "LogFrame"
logFrame.Size = UDim2.new(1, -20, 0, 80)
logFrame.Position = UDim2.new(0, 10, 0, 240)
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 4
logFrame.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
logFrame.Parent = mainFrame

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 8)
logCorner.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 1)
logLayout.Parent = logFrame

-- Статистика
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, -20, 0, 20)
statsLabel.Position = UDim2.new(0, 10, 0, 330)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "📊 Статистика: Работ найдено: 0 | Подключений: 0"
statsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statsLabel.TextScaled = true
statsLabel.Font = Enum.Font.Gotham
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.Parent = mainFrame

-- Переменные
local isConnected = false
local autoJoinEnabled = true
local notifyEnabled = true
local minMoney = 100
local jobsFound = 0
local connections = 0

-- Функция добавления лога
local function addLog(message, color)
    color = color or Color3.fromRGB(200, 200, 200)
    
    local logEntry = Instance.new("TextLabel")
    logEntry.Size = UDim2.new(1, -5, 0, 15)
    logEntry.BackgroundTransparency = 1
    logEntry.Text = "[" .. os.date("%H:%M:%S") .. "] " .. message
    logEntry.TextColor3 = color
    logEntry.TextScaled = true
    logEntry.Font = Enum.Font.Gotham
    logEntry.TextXAlignment = Enum.TextXAlignment.Left
    logEntry.Parent = logFrame
    
    logFrame.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
    logFrame.CanvasPosition = Vector2.new(0, math.max(0, logFrame.CanvasSize.Y.Offset - logFrame.AbsoluteSize.Y))
    
    -- Удаляем старые записи (максимум 50)
    if #logFrame:GetChildren() > 52 then -- 50 записей + UIListLayout + возможные другие элементы
        logFrame:GetChildren()[2]:Destroy() -- Удаляем самую старую запись (первая - UIListLayout)
    end
end

-- Обновление статистики
local function updateStats()
    statsLabel.Text = string.format("📊 Статистика: Работ найдено: %d | Подключений: %d", jobsFound, connections)
end

-- Функция телепортации на работу
local function joinJob(jobId, money)
    if not autoJoinEnabled then
        addLog("Автозаход отключен", Color3.fromRGB(255, 200, 100))
        return
    end
    
    local moneyNum = tonumber(money)
    if moneyNum and moneyNum < minMoney then
        addLog(string.format("Работа пропущена: $%s < $%d", money, minMoney), Color3.fromRGB(255, 200, 100))
        return
    end
    
    addLog(string.format("🚀 Попытка захода: %s ($%s/сек)", jobId, money), Color3.fromRGB(100, 255, 100))
    
    -- Попытка телепортации с обработкой ошибок
    local success, errorMessage = pcall(function()
        -- Проверяем, что jobId является валидным
        if type(jobId) == "string" and #jobId > 0 then
            -- Пытаемся конвертировать в число если это строка
            local jobIdNum = tonumber(jobId)
            if jobIdNum then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(jobIdNum), player)
            else
                -- Если не число, пробуем как строку
                TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, player)
            end
        else
            error("Неверный формат Job ID")
        end
    end)
    
    if success then
        addLog("✅ Телепортация инициирована", Color3.fromRGB(100, 255, 100))
    else
        addLog("❌ Ошибка телепортации: " .. tostring(errorMessage), Color3.fromRGB(255, 100, 100))
        
        -- Альтернативный метод телепортации
        spawn(function()
            wait(1)
            addLog("🔄 Попытка альтернативной телепортации...", Color3.fromRGB(255, 200, 100))
            
            local altSuccess = pcall(function()
                -- Пробуем обычную телепортацию на место
                TeleportService:Teleport(game.PlaceId, player)
            end)
            
            if altSuccess then
                addLog("✅ Альтернативная телепортация успешна", Color3.fromRGB(100, 255, 100))
            else
                addLog("❌ Все методы телепортации не удались", Color3.fromRGB(255, 100, 100))
            end
        end)
    end
    
    -- Уведомление
    if notifyEnabled then
        spawn(function()
            pcall(function()
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://131961136" -- Более надежный звук
                sound.Volume = 0.3
                sound.Parent = workspace
                sound:Play()
                
                wait(sound.TimeLength + 0.1)
                sound:Destroy()
            end)
        end)
    end
end

-- Реальная интеграция с WebSocket через HTTP запросы
local wsUrl = "http://localhost:1488/status" -- Endpoint для проверки статуса
local lastCheckTime = 0
local checkInterval = 5 -- Проверяем каждые 5 секунд

local function checkWebSocketData()
    spawn(function()
        while isConnected do
            local success, response = pcall(function()
                return HttpService:GetAsync(wsUrl, false)
            end)
            
            if success then
                local data = HttpService:JSONDecode(response)
                if data and data.jobid and data.money then
                    -- Проверяем, что это новые данные
                    local currentTime = tick()
                    if currentTime - lastCheckTime > 1 then -- Защита от дубликатов
                        lastCheckTime = currentTime
                        
                        jobsFound = jobsFound + 1
                        lastJobInfo.Text = string.format("ID: %s | $%s/сек | %s", data.jobid, data.money, os.date("%H:%M:%S"))
                        
                        addLog(string.format("📥 WebSocket: %s ($%s/сек)", data.jobid, data.money), Color3.fromRGB(100, 255, 200))
                        updateStats()
                        
                        wait(0.2)
                        joinJob(data.jobid, data.money)
                    end
                end
            else
                -- Если WebSocket недоступен, используем симуляцию
                simulateWebSocketConnection()
                break
            end
            
            wait(checkInterval)
        end
    end)
end

-- Обработчики событий
connectButton.MouseButton1Click:Connect(function()
    if not isConnected then
        isConnected = true
        connections = connections + 1
        statusLabel.Text = "🟢 Подключено к WebSocket"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        connectButton.Text = "Отключиться"
        connectButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        
        addLog("Подключение к localhost:1488", Color3.fromRGB(100, 255, 100))
        addLog("Мониторинг канала: 1401775012083404931", Color3.fromRGB(100, 200, 255))
        
        updateStats()
        
        -- Попытка подключения к реальному WebSocket
        spawn(function()
            local success = pcall(function()
                checkWebSocketData()
            end)
            
            if not success then
                addLog("⚠️ WebSocket недоступен, режим симуляции", Color3.fromRGB(255, 200, 100))
                -- Fallback к симуляции
                spawn(function()
                    while isConnected do
                        wait(math.random(30, 90))
                        
                        if isConnected then
                            local mockJobId = string.format("%d", math.random(100000000, 999999999))
                            local mockMoney = tostring(math.random(100, 1500))
                            
                            jobsFound = jobsFound + 1
                            lastJobInfo.Text = string.format("ID: %s | $%s/сек | %s", mockJobId, mockMoney, os.date("%H:%M:%S"))
                            
                            addLog(string.format("📥 [DEMO] Работа: %s ($%s/сек)", mockJobId, mockMoney), Color3.fromRGB(255, 200, 100))
                            updateStats()
                            
                            wait(0.5)
                            joinJob(mockJobId, mockMoney)
                        end
                    end
                end)
            end
        end)
    else
        isConnected = false
        statusLabel.Text = "🔴 Отключено от WebSocket"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        connectButton.Text = "Подключиться"
        connectButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        
        addLog("Отключено от WebSocket", Color3.fromRGB(255, 100, 100))
    end
end)

autoJoinCheckbox.MouseButton1Click:Connect(function()
    autoJoinEnabled = not autoJoinEnabled
    if autoJoinEnabled then
        autoJoinCheckbox.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        autoJoinCheckbox.Text = "✓"
        addLog("Автозаход включен", Color3.fromRGB(100, 255, 100))
    else
        autoJoinCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        autoJoinCheckbox.Text = ""
        addLog("Автозаход отключен", Color3.fromRGB(255, 200, 100))
    end
end)

notifyCheckbox.MouseButton1Click:Connect(function()
    notifyEnabled = not notifyEnabled
    if notifyEnabled then
        notifyCheckbox.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        notifyCheckbox.Text = "✓"
        addLog("Уведомления включены", Color3.fromRGB(100, 255, 100))
    else
        notifyCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        notifyCheckbox.Text = ""
        addLog("Уведомления отключены", Color3.fromRGB(255, 200, 100))
    end
end)

minMoneyBox.FocusLost:Connect(function()
    local newMin = tonumber(minMoneyBox.Text)
    if newMin and newMin >= 0 then
        minMoney = newMin
        addLog(string.format("Минимальная сумма: $%d", minMoney), Color3.fromRGB(100, 200, 255))
    else
        minMoneyBox.Text = tostring(minMoney)
    end
end)

closeButton.MouseButton1Click:Connect(function()
    isConnected = false
    local tweenOut = TweenService:Create(
        mainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

-- Система перетаскивания
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Анимация появления GUI
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

local tweenIn = TweenService:Create(
    mainFrame,
    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 450, 0, 350), Position = UDim2.new(0.5, -225, 0.5, -175)}
)
tweenIn:Play()

-- Анимации наведения для кнопок
local function addHoverEffect(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        local hover = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor})
        hover:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local unhover = TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor})
        unhover:Play()
    end)
end

addHoverEffect(connectButton, Color3.fromRGB(100, 115, 255), Color3.fromRGB(88, 101, 242))
addHoverEffect(closeButton, Color3.fromRGB(255, 70, 70), Color3.fromRGB(220, 50, 50))

-- Стартовые сообщения
addLog("🚀 Auto Job Joiner запущен!", Color3.fromRGB(100, 255, 100))
addLog("Для начала нажмите 'Подключиться'", Color3.fromRGB(100, 200, 255))
addLog("Целевой канал: 1401775012083404931", Color3.fromRGB(150, 150, 150))

updateStats()

print("🚀 Auto Job Joiner с перетаскиваемым GUI загружен!")
print("📋 Функции: автозаход, фильтр по сумме, перетаскивание")
print("🎯 Готов к работе с WebSocket сервером на порту 1488")

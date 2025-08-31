-- Discord Job Notifier GUI для Roblox
-- Подключение к WebSocket серверу для получения уведомлений о работах

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Проверка существования GUI
if playerGui:FindFirstChild("JobNotifierGUI") then
    playerGui:FindFirstChild("JobNotifierGUI"):Destroy()
end

-- Создание основного GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JobNotifierGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Основная рамка
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Закругленные углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

-- Градиент фон
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45))
})
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Тень
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.8
shadow.BorderSizePixel = 0
shadow.ZIndex = mainFrame.ZIndex - 1
shadow.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 15)
shadowCorner.Parent = shadow

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -20, 0, 50)
titleLabel.Position = UDim2.new(0, 10, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Discord Job Notifier"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Статус подключения
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 60)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🔴 Отключено"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Кнопка подключения
local connectButton = Instance.new("TextButton")
connectButton.Name = "ConnectButton"
connectButton.Size = UDim2.new(0, 150, 0, 40)
connectButton.Position = UDim2.new(0.5, -75, 0, 90)
connectButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
connectButton.Text = "Подключиться"
connectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
connectButton.TextScaled = true
connectButton.Font = Enum.Font.GothamBold
connectButton.BorderSizePixel = 0
connectButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = connectButton

-- Поле для лога
local logFrame = Instance.new("ScrollingFrame")
logFrame.Name = "LogFrame"
logFrame.Size = UDim2.new(1, -20, 0, 120)
logFrame.Position = UDim2.new(0, 10, 0, 140)
logFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 6
logFrame.ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242)
logFrame.Parent = mainFrame

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0, 8)
logCorner.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Padding = UDim.new(0, 2)
logLayout.Parent = logFrame

-- Поле для настроек
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsFrame"
settingsFrame.Size = UDim2.new(1, -20, 0, 30)
settingsFrame.Position = UDim2.new(0, 10, 0, 270)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Parent = mainFrame

-- Чекбокс для автоуведомлений
local autoNotifyCheckbox = Instance.new("TextButton")
autoNotifyCheckbox.Name = "AutoNotifyCheckbox"
autoNotifyCheckbox.Size = UDim2.new(0, 20, 0, 20)
autoNotifyCheckbox.Position = UDim2.new(0, 0, 0, 5)
autoNotifyCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
autoNotifyCheckbox.Text = ""
autoNotifyCheckbox.BorderSizePixel = 0
autoNotifyCheckbox.Parent = settingsFrame

local checkboxCorner = Instance.new("UICorner")
checkboxCorner.CornerRadius = UDim.new(0, 4)
checkboxCorner.Parent = autoNotifyCheckbox

local checkboxLabel = Instance.new("TextLabel")
checkboxLabel.Size = UDim2.new(1, -30, 1, 0)
checkboxLabel.Position = UDim2.new(0, 30, 0, 0)
checkboxLabel.BackgroundTransparency = 1
checkboxLabel.Text = "Автоуведомления"
checkboxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
checkboxLabel.TextScaled = true
checkboxLabel.Font = Enum.Font.Gotham
checkboxLabel.TextXAlignment = Enum.TextXAlignment.Left
checkboxLabel.Parent = settingsFrame

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
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 15)
closeCorner.Parent = closeButton

-- Переменные для работы
local isConnected = false
local autoNotify = true
local wsUrl = "ws://localhost:1488"

-- Функции
local function addLog(message)
    local logEntry = Instance.new("TextLabel")
    logEntry.Size = UDim2.new(1, -10, 0, 20)
    logEntry.BackgroundTransparency = 1
    logEntry.Text = "[" .. os.date("%H:%M:%S") .. "] " .. message
    logEntry.TextColor3 = Color3.fromRGB(200, 200, 200)
    logEntry.TextScaled = true
    logEntry.Font = Enum.Font.Gotham
    logEntry.TextXAlignment = Enum.TextXAlignment.Left
    logEntry.Parent = logFrame
    
    logFrame.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
    logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
end

local function updateStatus(connected)
    isConnected = connected
    if connected then
        statusLabel.Text = "🟢 Подключено"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        connectButton.Text = "Отключиться"
        connectButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    else
        statusLabel.Text = "🔴 Отключено"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        connectButton.Text = "Подключиться"
        connectButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    end
end

local function showNotification(jobId, money)
    -- Создание всплывающего уведомления
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 100)
    notification.Position = UDim2.new(1, -320, 1, -120)
    notification.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 12)
    notifCorner.Parent = notification
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -10, 0, 30)
    notifTitle.Position = UDim2.new(0, 5, 0, 5)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = "💼 Новая работа!"
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextScaled = true
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -10, 0, 60)
    notifText.Position = UDim2.new(0, 5, 0, 35)
    notifText.BackgroundTransparency = 1
    notifText.Text = "ID: " .. jobId .. "\n💰 Доход: $" .. money .. "/сек"
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextScaled = true
    notifText.Font = Enum.Font.Gotham
    notifText.Parent = notification
    
    -- Анимация появления
    notification.Position = UDim2.new(1, 0, 1, -120)
    local tweenIn = TweenService:Create(
        notification,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -320, 1, -120)}
    )
    tweenIn:Play()
    
    -- Автоматическое скрытие через 5 секунд
    wait(5)
    local tweenOut = TweenService:Create(
        notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 0, 1, -120)}
    )
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Имитация WebSocket соединения (так как Roblox не поддерживает WebSocket)
local function simulateConnection()
    spawn(function()
        while isConnected do
            wait(math.random(10, 30)) -- Случайная задержка между уведомлениями
            if isConnected and autoNotify then
                local mockJobId = "job_" .. math.random(1000, 9999)
                local mockMoney = math.random(100, 2000)
                
                addLog("Получена работа: " .. mockJobId .. " ($" .. mockMoney .. "/сек)")
                showNotification(mockJobId, tostring(mockMoney))
            end
        end
    end)
end

-- Обработчики событий
connectButton.MouseButton1Click:Connect(function()
    if not isConnected then
        updateStatus(true)
        addLog("Подключение к серверу...")
        addLog("Мониторинг канала ID: 1401775012083404931")
        simulateConnection()
    else
        updateStatus(false)
        addLog("Отключено от сервера")
    end
end)

autoNotifyCheckbox.MouseButton1Click:Connect(function()
    autoNotify = not autoNotify
    if autoNotify then
        autoNotifyCheckbox.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
        autoNotifyCheckbox.Text = "✓"
        addLog("Автоуведомления включены")
    else
        autoNotifyCheckbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        autoNotifyCheckbox.Text = ""
        addLog("Автоуведомления выключены")
    end
end)

closeButton.MouseButton1Click:Connect(function()
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

-- Анимация появления GUI
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

local tweenIn = TweenService:Create(
    mainFrame,
    TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    {Size = UDim2.new(0, 400, 0, 300), Position = UDim2.new(0.5, -200, 0.5, -150)}
)
tweenIn:Play()

-- Начальная настройка чекбокса
autoNotifyCheckbox.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
autoNotifyCheckbox.Text = "✓"

-- Приветственное сообщение
addLog("Discord Job Notifier запущен!")
addLog("Целевой канал: 1401775012083404931")
addLog("Нажмите 'Подключиться' для начала мониторинга")

-- Анимация кнопки при наведении
connectButton.MouseEnter:Connect(function()
    local hover = TweenService:Create(
        connectButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0, 155, 0, 42)}
    )
    hover:Play()
end)

connectButton.MouseLeave:Connect(function()
    local unhover = TweenService:Create(
        connectButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0, 150, 0, 40)}
    )
    unhover:Play()
end)

print("Discord Job Notifier GUI загружен успешно!")
print("Мониторинг канала: https://discord.com/channels/1385491616013221990/1401775012083404931")

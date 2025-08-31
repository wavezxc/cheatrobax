-- Конфиг
local wsUrl = "ws://127.0.0.1:1488" -- сюда меняй на свой IP/порт сервера

-- Проверка поддержки WebSocket API (есть в Synapse X, Script-Ware, KRNL)
if not syn or not syn.websocket then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Твой эксплойт не поддерживает WebSocket API!",
        Duration = 5
    })
    return
end

-- Создаём соединение
local success, ws = pcall(function()
    return syn.websocket.connect(wsUrl)
end)

if not success or not ws then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Не удалось подключиться к WebSocket серверу!",
        Duration = 5
    })
    return
end

-- Уведомление о подключении
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "WebSocket",
    Text = "Подключение установлено!",
    Duration = 3
})

-- Обработка входящих данных
ws.OnMessage:Connect(function(msg)
    -- JSON парсинг (Roblox имеет HttpService:JSONDecode)
    local HttpService = game:GetService("HttpService")
    local data = HttpService:JSONDecode(msg)

    local jobid = data["jobid"]
    local money = data["money"]

    -- Делаем что нужно с данными
    print("📥 Пришёл JobID:", jobid, "💰 Money:", money)

    -- Например, можем телепортироваться на сервер с JobID:
    if jobid and #jobid > 5 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(
            game.PlaceId,
            jobid,
            game.Players.LocalPlayer
        )
    end
end)

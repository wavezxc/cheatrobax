-- Roblox GUI client for Python server
-- Supports websocket (syn.websocket) and HTTP polling fallback

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local WS_URL = "ws://127.0.0.1:1488"
local HTTP_URL = "http://127.0.0.1:1488/latest"

local use_ws = false
local ws
local latestJobId = nil
local autoTeleport = false

-- GUI setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1,0,0,30)
Status.TextColor3 = Color3.new(1,1,1)
Status.Text = "Connecting..."

local JobInfo = Instance.new("TextLabel", Frame)
JobInfo.Position = UDim2.new(0,0,0,40)
JobInfo.Size = UDim2.new(1,0,0,30)
JobInfo.TextColor3 = Color3.new(1,1,1)
JobInfo.Text = "JobID: none"

local AutoTeleportBtn = Instance.new("TextButton", Frame)
AutoTeleportBtn.Position = UDim2.new(0,0,0,80)
AutoTeleportBtn.Size = UDim2.new(1,0,0,30)
AutoTeleportBtn.Text = "AutoTeleport: OFF"

AutoTeleportBtn.MouseButton1Click:Connect(function()
    autoTeleport = not autoTeleport
    AutoTeleportBtn.Text = "AutoTeleport: " .. (autoTeleport and "ON" or "OFF")
end)

-- Handle new data
local function handleData(data)
    if data.jobid and data.money then
        latestJobId = data.jobid
        JobInfo.Text = "JobID: " .. data.jobid .. " | $" .. data.money .. "/s"
        if autoTeleport then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, latestJobId, LocalPlayer)
        end
    end
end

-- Try websocket first
pcall(function()
    if syn and syn.websocket then
        ws = syn.websocket.connect(WS_URL)
        use_ws = true
        Status.Text = "Connected via WS"
        ws.OnMessage:Connect(function(msg)
            local ok, data = pcall(function() return HttpService:JSONDecode(msg) end)
            if ok then handleData(data) end
        end)
    end
end)

-- If no websocket, use HTTP polling
if not use_ws then
    Status.Text = "Using HTTP polling"
    task.spawn(function()
        while task.wait(7) do
            local ok, response = pcall(function()
                return game:HttpGet(HTTP_URL)
            end)
            if ok and response and response ~= "" then
                local ok2, data = pcall(function() return HttpService:JSONDecode(response) end)
                if ok2 then handleData(data) end
            end
        end
    end)
end

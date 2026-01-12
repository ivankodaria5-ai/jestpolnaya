-- ==================== ЭКСТРЕМАЛЬНЫЙ АВТОХОП ====================
-- Версия 3.0 - ВСЕ методы автозапуска

local VERSION = "3.0-ЭКСТРИМ"

-- ПЕРВОЕ УВЕДОМЛЕНИЕ
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔥 v" .. VERSION,
        Text = "Тестируем ВСЕ методы!",
        Duration = 10,
    })
end)

local PLACE_ID = 142823291
local AUTOHOP_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/jestpolnaya/refs/heads/main/mm2autofarm.lua"
local SCRIPT_URL = "https://raw.githubusercontent.com/Azura83/Murder-Mystery-2/refs/heads/main/Script.lua"
local WORK_TIME = 30

-- Сервисы
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
end

-- ==================== МЕТОД 1: _G + LocalScript ====================
-- Сохраняем скрипт в _G (переживает телепорт)
_G.AutoHopScript = game:HttpGet(AUTOHOP_URL)
_G.AutoHopEnabled = true

-- Создаём LocalScript в CoreGui (может пережить телепорт)
pcall(function()
    local script = Instance.new("LocalScript")
    script.Name = "AutoHopPersist"
    script.Source = [[
        wait(5)
        if _G.AutoHopEnabled and _G.AutoHopScript then
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🟢 МЕТОД 1",
                    Text = "LocalScript сработал!",
                    Duration = 10,
                })
                loadstring(_G.AutoHopScript)()
            end)
        end
    ]]
    script.Parent = game:GetService("CoreGui")
    notify("✅ Метод 1", "LocalScript создан!")
end)

-- ==================== МЕТОД 2: RunService Heartbeat ====================
-- Проверка на каждом кадре - запустился ли на новом сервере?
pcall(function()
    _G.LastJobId = game.JobId
    RunService.Heartbeat:Connect(function()
        if _G.AutoHopEnabled and game.JobId ~= _G.LastJobId then
            _G.LastJobId = game.JobId
            wait(3)
            notify("🟢 МЕТОД 2", "Heartbeat детект!")
            loadstring(game:HttpGet(AUTOHOP_URL))()
        end
    end)
    notify("✅ Метод 2", "Heartbeat хук создан!")
end)

-- ==================== МЕТОД 3: PlayerGui Script ====================
pcall(function()
    local playerGui = player:WaitForChild("PlayerGui", 5)
    if playerGui then
        local script = Instance.new("LocalScript")
        script.Name = "AutoHopGuiPersist"
        script.Source = [[
            wait(3)
            if _G.AutoHopEnabled and _G.AutoHopScript then
                pcall(function()
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "🟢 МЕТОД 3",
                        Text = "PlayerGui скрипт!",
                        Duration = 10,
                    })
                    loadstring(_G.AutoHopScript)()
                end)
            end
        ]]
        script.Parent = playerGui
        notify("✅ Метод 3", "PlayerGui скрипт создан!")
    end
end)

-- ==================== МЕТОД 4: Стандартный queueonteleport ====================
local queueFunc = queueonteleport or queue_on_teleport or (syn and syn.queue_on_teleport)

-- ==================== МЕТОД 5: BindableEvent ====================
pcall(function()
    local bindable = Instance.new("BindableEvent")
    bindable.Name = "AutoHopEvent"
    bindable.Parent = game:GetService("ReplicatedStorage")
    
    bindable.Event:Connect(function()
        wait(3)
        notify("🟢 МЕТОД 5", "BindableEvent сработал!")
        loadstring(game:HttpGet(AUTOHOP_URL))()
    end)
    
    -- Триггерим при CharacterAdded
    player.CharacterAdded:Connect(function()
        wait(2)
        if _G.AutoHopEnabled then
            bindable:Fire()
        end
    end)
    
    notify("✅ Метод 5", "BindableEvent создан!")
end)

-- ==================== ОСНОВНОЙ КОД ====================
notify("🟢 v" .. VERSION, "Запущен!")
notify("🌐 JobId", string.sub(game.JobId, 1, 8))

-- Ждём персонажа
if not player.Character then
    player.CharacterAdded:Wait()
end
wait(5)

-- Загружаем MM2 в фоне
notify("📥 MM2", "Загружаю...")
spawn(function()
    wait(2)
    pcall(function()
        loadstring(game:HttpGet(SCRIPT_URL))()
    end)
    wait(3)
    notify("✅ MM2", "Загружен!")
end)

-- Таймер хопа
spawn(function()
    wait(5)
    notify("⏰ ТАЙМЕР", WORK_TIME .. " сек до хопа")
    
    for i = WORK_TIME, 0, -10 do
        if i > 0 and i <= 30 then
            notify("⏱️ " .. i .. " сек", "До хопа...")
        end
        wait(10)
    end
    
    -- ХОП
    notify("🔄 ХОП", "Меняю сервер...")
    notify("📋 Методы", "5 методов активны!")
    
    -- Метод 4: queue
    if queueFunc then
        pcall(function()
            queueFunc([[
                wait(3)
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🟢 МЕТОД 4",
                    Text = "Queue сработал!",
                    Duration = 10,
                })
                if _G.AutoHopScript then
                    loadstring(_G.AutoHopScript)()
                end
            ]])
        end)
        notify("✅ Метод 4", "Queue активирован!")
    end
    
    wait(2)
    
    -- ТЕЛЕПОРТ
    pcall(function()
        TeleportService:Teleport(PLACE_ID, player)
    end)
    notify("✅ ТЕЛЕПОРТ", "Ухожу на новый сервер!")
end)

notify("✅ ГОТОВО", "5 методов работают!")
print("[АВТОХОП] v" .. VERSION .. " - Все методы активны!")

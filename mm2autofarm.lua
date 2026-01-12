-- ==================== ПРОСТОЙ АВТОХОП ДЛЯ MM2 ====================
-- Версия 2.2 - Тест queue

local VERSION = "2.2-ТЕСТ"

-- САМОЕ ПЕРВОЕ УВЕДОМЛЕНИЕ
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔵 QUEUE v" .. VERSION,
        Text = "Код в queue выполнился!",
        Duration = 10,
    })
end)

-- ОЧИСТКА
_G.AutoHopRunning = nil
_G.AutoHopVersion = nil
wait(1)

-- ЗАЩИТА ОТ ДВОЙНОГО ЗАПУСКА
if _G.AutoHopRunning then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚠️ УЖЕ ЗАПУЩЕН",
        Text = "Версия: " .. (_G.AutoHopVersion or "???"),
        Duration = 5,
    })
    return
end
_G.AutoHopRunning = true
_G.AutoHopVersion = VERSION

local PLACE_ID = 142823291
local AUTOHOP_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/jestpolnaya/refs/heads/main/mm2autofarm.lua"
local WORK_TIME = 30

-- Сервисы
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- Функция уведомлений
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
end

-- Queue функция
local queueFunc = queueonteleport or queue_on_teleport or (syn and syn.queue_on_teleport)

-- ==================== СТАРТ ====================
notify("🟢 v" .. VERSION, "Автохоп запущен!")
notify("🌐 JobId", string.sub(game.JobId, 1, 8) .. "...")

-- Ждём персонажа
if not player.Character then
    notify("⏳ Ожидание", "Жду персонажа...")
    player.CharacterAdded:Wait()
end
wait(5)
notify("✅ Загружен", "Персонаж готов!")

-- Запускаем таймер
spawn(function()
    wait(5)
    notify("⏰ ТАЙМЕР", WORK_TIME .. " секунд до хопа")
    
    -- Отсчёт
    for i = WORK_TIME, 0, -10 do
        if i > 0 and i <= 30 then
            notify("⏱️ " .. i .. " сек", "До смены сервера...")
        end
        wait(10)
    end
    
    -- Меняем сервер
    notify("🔄 ХОП", "Меняю сервер...")
    
    -- ТЕСТИРУЕМ QUEUE
    if queueFunc then
        notify("✅ Queue", "Поддерживается!")
        
        -- ПРОСТОЙ КОД ДЛЯ ТЕСТА
        local testCode = [[
            wait(3)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ QUEUE OK!",
                Text = "Код в queue сработал!",
                Duration = 10,
            })
            wait(2)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ivankodaria5-ai/jestpolnaya/refs/heads/main/mm2autofarm.lua"))()
        ]]
        
        pcall(function()
            queueFunc(testCode)
        end)
        
        notify("✅ Очередь", "Тестовый код в очереди!")
    else
        notify("❌ Queue", "НЕ поддерживается!")
    end
    
    wait(2)
    
    -- ТЕЛЕПОРТ
    local tpSuccess = pcall(function()
        TeleportService:Teleport(PLACE_ID, player)
    end)
    
    if tpSuccess then
        notify("✅ ТЕЛЕПОРТ", "Телепортируюсь!")
    else
        notify("❌ ОШИБКА", "Телепорт не работает")
    end
end)

notify("✅ ГОТОВО", "Автохоп работает!")
print("[АВТОХОП] v" .. VERSION .. " запущен!")

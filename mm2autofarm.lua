-- ==================== ПРОСТОЙ АВТОХОП ДЛЯ MM2 ====================
-- Каждые 30 секунд меняет сервер

local PLACE_ID = 142823291  -- Murder Mystery 2
local SCRIPT_URL = "https://raw.githubusercontent.com/Azura83/Murder-Mystery-2/refs/heads/main/Script.lua"
local AUTOHOP_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/jestpolnaya/refs/heads/main/mm2autofarm.lua"
local WORK_TIME = 30  -- 30 секунд перед хопом

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

-- Функция для постановки скрипта в очередь
local queueFunc = queueonteleport or queue_on_teleport or (syn and syn.queue_on_teleport)

-- ==================== СТАРТ ====================
notify("🟢 АВТОХОП", "Скрипт запущен!")

-- Ждём персонажа
if not player.Character then
    player.CharacterAdded:Wait()
end
wait(2)

-- Загружаем MM2 скрипт в фоне
notify("📥 MM2", "Загружаю MM2 скрипт...")
spawn(function()
    wait(1)
    pcall(function()
        loadstring(game:HttpGet(SCRIPT_URL))()
    end)
    wait(3)
    notify("✅ MM2", "MM2 скрипт загружен!")
end)

-- Запускаем таймер автохопа
spawn(function()
    wait(5) -- Даём MM2 загрузиться
    
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
    
    -- Ставим скрипт в очередь для следующего сервера
    if queueFunc then
        pcall(function()
            queueFunc('wait(3); loadstring(game:HttpGet("' .. AUTOHOP_URL .. '"))()')
        end)
        notify("✅ Очередь", "Скрипт в очереди!")
    else
        notify("⚠️ Очередь", "Queue не поддерживается")
    end
    
    wait(2)
    
    -- ТЕЛЕПОРТ на случайный сервер
    local tpSuccess = pcall(function()
        TeleportService:Teleport(PLACE_ID, player)
    end)
    
    if tpSuccess then
        notify("✅ ТЕЛЕПОРТ", "Телепортируюсь!")
    else
        notify("❌ ОШИБКА", "Телепорт не работает")
        
        -- Пробуем альтернативный способ
        wait(2)
        notify("🔄 План Б", "Пробую другой метод...")
        pcall(function()
            TeleportService:TeleportToPlaceInstance(PLACE_ID, game.JobId, player)
        end)
    end
end)

notify("✅ ГОТОВО", "Автохоп работает!")
print("[АВТОХОП] Скрипт запущен! Хоп через " .. WORK_TIME .. " секунд")

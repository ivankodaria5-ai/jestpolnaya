-- ==================== ПРОСТОЙ АВТОХОП ДЛЯ MM2 ====================
-- Версия 2.1 - Фикс queueonteleport

local VERSION = "2.1-ФИКС"

-- САМОЕ ПЕРВОЕ УВЕДОМЛЕНИЕ (до всех проверок!)
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🔵 QUEUE РАБОТАЕТ!",
        Text = "Версия: " .. VERSION,
        Duration = 10,
    })
end)

-- ОЧИСТКА СТАРЫХ ДАННЫХ
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

local PLACE_ID = 142823291  -- Murder Mystery 2
local SCRIPT_URL = "https://raw.githubusercontent.com/Azura83/Murder-Mystery-2/refs/heads/main/Script.lua"
local AUTOHOP_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/jestpolnaya/refs/heads/main/mm2autofarm.lua"
local WORK_TIME = 30  -- 30 секунд перед хопом
local LOAD_MM2 = false  -- ВРЕМЕННО ВЫКЛЮЧАЕМ MM2 для теста

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
notify("🟢 v" .. VERSION, "Автохоп запущен!")
notify("🌐 JobId", string.sub(game.JobId, 1, 8) .. "...")
wait(1)
notify("📋 Тест", "БЕЗ MM2, queue фикс")

-- Ждём персонажа
if not player.Character then
    notify("⏳ Ожидание", "Жду персонажа...")
    player.CharacterAdded:Wait()
end

-- Даём игре время полностью загрузиться
wait(5)
notify("✅ Загружен", "Персонаж готов!")

-- Загружаем MM2 скрипт в фоне (если включено)
if LOAD_MM2 then
    notify("📥 MM2", "Загружаю MM2 скрипт...")
    spawn(function()
        wait(3)
        pcall(function()
            loadstring(game:HttpGet(SCRIPT_URL))()
        end)
        wait(5)
        notify("✅ MM2", "MM2 скрипт загружен!")
    end)
else
    notify("⚠️ MM2", "MM2 выключен для теста!")
end

-- Запускаем таймер автохопа
spawn(function()
    wait(5) -- Уменьшаем ожидание т.к. MM2 выключен
    
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
    notify("📋 Queue", "Проверка поддержки...")
    
    if queueFunc then
        notify("✅ Queue", "Поддерживается!")
        
        -- Пробуем все возможные варианты
        pcall(function()
            queueFunc('wait(5); loadstring(game:HttpGet("' .. AUTOHOP_URL .. '"))()')
        end)
        
        pcall(function()
            if queueonteleport then
                queueonteleport('wait(5); loadstring(game:HttpGet("' .. AUTOHOP_URL .. '"))()')
            end
        end)
        
        pcall(function()
            if queue_on_teleport then
                queue_on_teleport('wait(5); loadstring(game:HttpGet("' .. AUTOHOP_URL .. '"))()')
            end
        end)
        
        notify("✅ Очередь", "Скрипт в очереди (x3)!")
    else
        notify("❌ Очередь", "Queue НЕ поддерживается!")
        notify("⚠️ Внимание", "Автозапуск не будет работать!")
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

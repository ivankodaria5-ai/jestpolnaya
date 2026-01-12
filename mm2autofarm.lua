-- Обернём весь скрипт в pcall для отлова ошибок
local success, error = pcall(function()

-- ==================== КОНФИГУРАЦИЯ ====================
local PLACE_ID = 142823291  -- Murder Mystery 2 Place ID
local SCRIPT_URL = "https://raw.githubusercontent.com/Azura83/Murder-Mystery-2/refs/heads/main/Script.lua"
local AUTOHOP_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/jestpolnaya/refs/heads/main/mm2autofarm.lua"
local WORK_TIME = 120  -- Сколько секунд работать перед сменой сервера (2 минуты)
local MIN_PLAYERS = 5  -- Минимум игроков на сервере
local MAX_PLAYERS = 12  -- Максимум игроков на сервере

-- ==================== СЕРВИСЫ ====================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

-- Первое уведомление - скрипт запустился
StarterGui:SetCore("SendNotification", {
    Title = "🟢 СТАРТ",
    Text = "Скрипт начал работу!",
    Duration = 5,
})

-- ==================== ПОДДЕРЖКА РАЗНЫХ ЭКСПЛОЙТОВ ====================
StarterGui:SetCore("SendNotification", {
    Title = "🔍 Шаг 1",
    Text = "Проверка эксплойта...",
    Duration = 3,
})

local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local queueFunc = queueonteleport or queue_on_teleport or (syn and syn.queue_on_teleport) or function() end

StarterGui:SetCore("SendNotification", {
    Title = "✅ Шаг 1",
    Text = "Эксплойт проверен!",
    Duration = 3,
})

-- ==================== ПРОСТОЕ ЛОГИРОВАНИЕ ====================
local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
        })
    end)
    print("[АВТОХОП] " .. title .. ": " .. text)
end

local function log(msg)
    print("[АВТОХОП] " .. msg)
end

StarterGui:SetCore("SendNotification", {
    Title = "🔍 Шаг 2",
    Text = "Функции созданы",
    Duration = 3,
})

-- ==================== НАЧАЛЬНАЯ ПРОВЕРКА ====================
notify("🔄 АВТОХОП", "Скрипт загружен!")
log("════════════════════════════════════════")
log("  АВТОМАТИЧЕСКИЙ СЕРВЕР-ХОППЕР")
log("  Murder Mystery 2 - Мобильная версия")
log("════════════════════════════════════════")

-- Проверка функций
log("🔍 Проверка поддержки функций...")
if httprequest then
    log("✅ httprequest работает")
    notify("✅ Проверка", "httprequest работает")
else
    log("❌ httprequest НЕ работает!")
    notify("❌ ОШИБКА", "httprequest не поддерживается!")
end

if queueonteleport or queue_on_teleport then
    log("✅ queueonteleport работает")
else
    log("⚠️ queueonteleport НЕ работает")
    notify("⚠️ Внимание", "Автозапуск может не работать")
end

log("🎮 JobId: " .. tostring(game.JobId))
log("👥 Игроков: " .. #Players:GetPlayers())

-- ==================== ЗАГРУЗКА MM2 СКРИПТА ====================
local function loadMainScript()
    log("📥 Загружаю MM2 скрипт...")
    notify("📥 Загрузка", "Загружаю MM2 скрипт...")
    
    -- ВАЖНО: Запускаем MM2 в фоне, чтобы не блокировать таймер!
    spawn(function()
        wait(1)
        local success, err = pcall(function()
            loadstring(game:HttpGet(SCRIPT_URL))()
        end)
        
        if success then
            log("✅ MM2 скрипт загружен!")
            notify("✅ Успех", "MM2 скрипт загружен!")
        else
            log("❌ Ошибка: " .. tostring(err))
            notify("❌ Ошибка", "Не удалось загрузить MM2")
        end
    end)
    
    -- Сразу возвращаемся, не ждём загрузки
    notify("🔄 Фон", "MM2 загружается в фоне...")
end

-- ==================== СМЕНА СЕРВЕРА ====================
local function serverHop()
    log("🔄 Начинаю поиск сервера...")
    notify("🔄 Хоп", "Ищу новый сервер...")
    
    if not httprequest then
        log("❌ httprequest не работает!")
        notify("❌ ОШИБКА", "HTTP не поддерживается!")
        return
    end
    
    local cursor = ""
    local hopped = false
    local attempts = 0
    
    while not hopped and attempts < 5 do
        attempts = attempts + 1
        log("🔍 Попытка " .. attempts .. "/5")
        
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
            PLACE_ID
        )
        
        local success, response = pcall(function()
            return httprequest({Url = url, Method = "GET"})
        end)
        
        if success and response and response.Body then
            log("✅ HTTP ответ получен")
            
            local bodySuccess, body = pcall(function() 
                return HttpService:JSONDecode(response.Body) 
            end)
            
            if bodySuccess and body and body.data then
                local servers = {}
                
                for _, server in pairs(body.data) do
                    if server.id ~= game.JobId 
                        and server.playing >= MIN_PLAYERS 
                        and server.playing <= MAX_PLAYERS then
                        table.insert(servers, server)
                    end
                end
                
                log("✅ Найдено серверов: " .. #servers)
                
                if #servers > 0 then
                    local selected = servers[1]
                    log("🚀 Телепорт на сервер: " .. selected.playing .. "/" .. selected.maxPlayers)
                    notify("🚀 Телепорт", selected.playing .. "/" .. selected.maxPlayers .. " игроков")
                    
                    -- Ставим скрипт в очередь
                    log("📋 Ставлю скрипт в очередь...")
                    local queueSuccess = pcall(function()
                        queueFunc('wait(3); loadstring(game:HttpGet("' .. AUTOHOP_URL .. '"))()')
                    end)
                    if queueSuccess then
                        log("✅ Скрипт в очереди")
                        notify("✅ Очередь", "Скрипт в очереди")
                    else
                        log("⚠️ Queue не сработал")
                    end
                    
                    log("🌐 JobId сервера: " .. tostring(selected.id))
                    log("🎮 Текущий JobId: " .. tostring(game.JobId))
                    
                    local tpSuccess, tpErr = pcall(function()
                        TeleportService:TeleportToPlaceInstance(PLACE_ID, selected.id, player)
                    end)
                    
                    if tpSuccess then
                        log("✅ Телепорт начат!")
                        notify("✅ Успех", "Телепортируюсь...")
                        hopped = true
                        wait(10)
                        break
                    else
                        log("❌ Ошибка телепорта: " .. tostring(tpErr))
                        notify("❌ Ошибка ТП", tostring(tpErr))
                        wait(2)
                    end
                else
                    log("⚠️ Нет подходящих серверов")
                end
            end
        else
            log("❌ HTTP ошибка")
            wait(3)
        end
    end
    
    if not hopped then
        log("❌ Не удалось найти сервер")
        notify("❌ Ошибка", "Не удалось сменить сервер")
    end
end

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
notify("🔍 Шаг 3", "Проверка персонажа...")

-- Ждем загрузки персонажа
if not player.Character then
    notify("⏳ Ожидание", "Жду персонажа...")
    player.CharacterAdded:Wait()
end
wait(2)

notify("✅ Шаг 3", "Персонаж загружен!")

-- Загружаем MM2 скрипт
notify("🔍 Шаг 4", "Загрузка MM2...")
loadMainScript()
notify("✅ Шаг 4", "MM2 загружен!")

-- Запускаем таймер в фоне
notify("🔍 Шаг 5", "Запуск таймера...")
spawn(function()
    wait(3)
    log("⏰ Таймер: " .. WORK_TIME .. " секунд")
    notify("⏰ Таймер", WORK_TIME .. " секунд до хопа")
    
    local elapsed = 0
    while elapsed < WORK_TIME do
        wait(10)
        elapsed = elapsed + 10
        if elapsed < WORK_TIME then
            local remaining = WORK_TIME - elapsed
            log("⏱️ Осталось: " .. remaining .. "с")
            -- Уведомления каждые 30 секунд
            if remaining % 30 == 0 or remaining <= 30 then
                notify("⏱️ Таймер", remaining .. " секунд до хопа")
            end
        end
    end
    
    log("⏰ Время вышло! Меняю сервер...")
    notify("⏰ Время вышло", "Меняю сервер...")
    serverHop()
end)

log("✅ Автохоп запущен!")
notify("✅ Запущен", "Автохоп работает!")

end) -- Конец pcall

-- Если была ошибка - покажем её
if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ ОШИБКА",
        Text = "Ошибка: " .. tostring(error),
        Duration = 10,
    })
    print("[АВТОХОП] КРИТИЧЕСКАЯ ОШИБКА: " .. tostring(error))
end

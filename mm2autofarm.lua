-- ==================== КОНФИГУРАЦИЯ ====================
local PLACE_ID = 142823291  -- Murder Mystery 2 Place ID
local SCRIPT_URL = "https://raw.githubusercontent.com/Azura83/Murder-Mystery-2/refs/heads/main/Script.lua"
local AUTOHOP_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/jestpolnaya/refs/heads/main/mm2autofarm.lua"
local WORK_TIME = 60  -- Сколько секунд работать перед сменой сервера (1 минута)
local MIN_PLAYERS = 5  -- Минимум игроков на сервере
local MAX_PLAYERS = 12  -- Максимум игроков на сервере

-- ==================== СЕРВИСЫ ====================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- ==================== ПОДДЕРЖКА РАЗНЫХ ЭКСПЛОЙТОВ ====================
local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local queueFunc = queueonteleport or queue_on_teleport or (syn and syn.queue_on_teleport) or function() 
    print("[АВТОХОП] Queue не поддерживается на этом эксплойте!") 
end

-- ==================== ЛОГИРОВАНИЕ ====================
local function log(msg)
    print("[АВТОХОП] " .. msg)
end

-- ==================== ЗАГРУЗКА ОСНОВНОГО СКРИПТА ====================
local function loadMainScript()
    log("Загружаю Murder Mystery 2 скрипт...")
    
    -- ВАЖНО: Запускаем скрипт АСИНХРОННО, чтобы он не блокировал автохоп
    task.spawn(function()
        local success, err = pcall(function()
            loadstring(game:HttpGet(SCRIPT_URL))()
        end)
        
        if success then
            log("✅ Скрипт Murder Mystery 2 загружен!")
        else
            log("❌ Ошибка загрузки: " .. tostring(err))
        end
    end)
    
    -- Даем скрипту время загрузиться
    task.wait(3)
    log("✅ Основной скрипт запущен в фоне!")
end

-- ==================== СМЕНА СЕРВЕРА ====================
local function serverHop()
    log("Начинаю поиск нового сервера...")
    
    local cursor = ""
    local hopped = false
    local attempts = 0
    local MAX_ATTEMPTS = 10
    
    while not hopped and attempts < MAX_ATTEMPTS do
        attempts = attempts + 1
        
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
            PLACE_ID,
            cursor ~= "" and "&cursor=" .. cursor or ""
        )
        
        local success, response = pcall(function()
            return httprequest({Url = url, Method = "GET"})
        end)
        
        if not success or not response or not response.Body then
            log("Ошибка HTTP запроса, попытка " .. attempts .. "/" .. MAX_ATTEMPTS)
            task.wait(3)
            continue
        end
        
        local bodySuccess, body = pcall(function() 
            return HttpService:JSONDecode(response.Body) 
        end)
        
        if bodySuccess and body and body.data then
            local servers = {}
            
            -- Собираем подходящие сервера
            for _, server in pairs(body.data) do
                if server.id ~= game.JobId 
                    and server.playing >= MIN_PLAYERS 
                    and server.playing <= MAX_PLAYERS then
                    table.insert(servers, server)
                end
            end
            
            if #servers > 0 then
                log("Найдено " .. #servers .. " подходящих серверов")
                
                -- Пробуем телепортироваться
                for _, selected in ipairs(servers) do
                    log("Телепорт на сервер: " .. selected.playing .. "/" .. selected.maxPlayers .. " игроков")
                    
                    -- КЛЮЧЕВОЙ МОМЕНТ: Ставим НАШ автохоп скрипт в очередь для следующего сервера
                    -- Это обеспечит автоматический запуск на новом сервере
                    local queueCode = 'wait(3); loadstring(game:HttpGet("' .. AUTOHOP_URL .. '"))()'
                    queueFunc(queueCode)
                    log("🔄 Автохоп поставлен в очередь для следующего сервера")
                    
                    local tpSuccess, tpErr = pcall(function()
                        TeleportService:TeleportToPlaceInstance(PLACE_ID, selected.id, player)
                    end)
                    
                    if tpSuccess then
                        log("✅ Телепорт начат! Увидимся на новом сервере...")
                        hopped = true
                        task.wait(10)
                        break
                    else
                        log("❌ Ошибка телепорта: " .. tostring(tpErr))
                        task.wait(2)
                    end
                end
            else
                log("Нет подходящих серверов на этой странице")
            end
            
            -- Переходим к следующей странице
            if body.nextPageCursor and not hopped then
                cursor = body.nextPageCursor
                log("Проверяю следующую страницу...")
            else
                if not hopped then
                    log("Все страницы проверены. Повтор через 10 секунд...")
                    task.wait(10)
                    cursor = ""
                end
            end
        else
            log("Ошибка парсинга ответа")
            task.wait(3)
            cursor = ""
        end
    end
    
    if not hopped then
        log("❌ Не удалось найти сервер после " .. MAX_ATTEMPTS .. " попыток")
    end
end

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
log("════════════════════════════════════════")
log("  АВТОМАТИЧЕСКИЙ СЕРВЕР-ХОППЕР")
log("  Murder Mystery 2 - Мобильная версия")
log("════════════════════════════════════════")
log("⏱️  Время работы: " .. WORK_TIME .. " секунд")
log("🎮 Place ID: " .. PLACE_ID)
log("📱 Эксплойт: JJSploit Mobile")
log("════════════════════════════════════════")

-- Ждем полной загрузки персонажа
if not player.Character then
    player.CharacterAdded:Wait()
end
task.wait(2)

-- Загружаем основной скрипт
loadMainScript()

-- Ждем указанное время с отчетом каждые 10 секунд
log("⏳ Работаю " .. WORK_TIME .. " секунд перед сменой сервера...")
local elapsed = 0
while elapsed < WORK_TIME do
    task.wait(10)
    elapsed = elapsed + 10
    if elapsed < WORK_TIME then
        local remaining = WORK_TIME - elapsed
        log("⏱️  Осталось " .. remaining .. " секунд до смены сервера...")
    end
end

-- Меняем сервер
log("⏰ Время вышло! Меняю сервер...")
serverHop()

log("════════════════════════════════════════")
log("  СКРИПТ ЗАВЕРШЕН")
log("════════════════════════════════════════")
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

-- ==================== GUI ДЕБАГГЕР ДЛЯ МОБИЛЬНОГО ====================
local logGui = Instance.new("ScreenGui")
logGui.Name = "AutoHopDebugger"
logGui.ResetOnSpawn = false
logGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(0, 380, 0, 450)
logFrame.Position = UDim2.new(0, 10, 0, 10)
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logFrame.BackgroundTransparency = 0.3
logFrame.BorderSizePixel = 2
logFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
logFrame.Parent = logGui

local logTitle = Instance.new("TextLabel")
logTitle.Size = UDim2.new(0.6, 0, 0, 30)
logTitle.Position = UDim2.new(0, 0, 0, 0)
logTitle.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
logTitle.BorderSizePixel = 0
logTitle.Text = "🔄 АВТОХОП ДЕБАГГЕР"
logTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
logTitle.TextSize = 14
logTitle.Font = Enum.Font.GothamBold
logTitle.Parent = logFrame

local hopButton = Instance.new("TextButton")
hopButton.Size = UDim2.new(0.4, -5, 0, 30)
hopButton.Position = UDim2.new(0.6, 5, 0, 0)
hopButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
hopButton.BorderSizePixel = 0
hopButton.Text = "🚀 ХОП СЕЙЧАС"
hopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hopButton.TextSize = 12
hopButton.Font = Enum.Font.GothamBold
hopButton.Parent = logFrame

local logScroll = Instance.new("ScrollingFrame")
logScroll.Size = UDim2.new(1, -10, 1, -40)
logScroll.Position = UDim2.new(0, 5, 0, 35)
logScroll.BackgroundTransparency = 1
logScroll.BorderSizePixel = 0
logScroll.ScrollBarThickness = 6
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.Parent = logFrame

local logText = Instance.new("TextLabel")
logText.Size = UDim2.new(1, -10, 1, 0)
logText.Position = UDim2.new(0, 5, 0, 0)
logText.BackgroundTransparency = 1
logText.Text = ""
logText.TextColor3 = Color3.fromRGB(0, 255, 0)
logText.TextSize = 12
logText.Font = Enum.Font.Code
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextYAlignment = Enum.TextYAlignment.Top
logText.TextWrapped = true
logText.Parent = logScroll

-- Делаем GUI перетаскиваемым
local dragging = false
local dragStart = nil
local startPos = nil

logTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = logFrame.Position
    end
end)

logTitle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        logFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Пробуем разместить в CoreGui, если не работает - в PlayerGui
local guiParent = nil
pcall(function()
    guiParent = game:GetService("CoreGui")
end)
if not guiParent then
    guiParent = player:WaitForChild("PlayerGui")
end
logGui.Parent = guiParent
log("✅ GUI создан!")

local logLines = {}
local MAX_LOG_LINES = 50

-- ==================== ЛОГИРОВАНИЕ ====================
local function log(msg)
    local timestamp = os.date("%H:%M:%S")
    local fullMsg = "[" .. timestamp .. "] " .. msg
    print(fullMsg)
    
    table.insert(logLines, fullMsg)
    if #logLines > MAX_LOG_LINES then
        table.remove(logLines, 1)
    end
    
    logText.Text = table.concat(logLines, "\n")
    
    -- Автопрокрутка вниз (безопасно для мобильного)
    spawn(function()
        wait(0.1)
        pcall(function()
            logScroll.CanvasSize = UDim2.new(0, 0, 0, logText.TextBounds.Y + 10)
            logScroll.CanvasPosition = Vector2.new(0, logText.TextBounds.Y)
        end)
    end)
end

-- ==================== ЗАГРУЗКА ОСНОВНОГО СКРИПТА ====================
local function loadMainScript()
    log("📥 Загружаю Murder Mystery 2 скрипт...")
    log("🌐 URL: " .. SCRIPT_URL)
    
    local success, err = pcall(function()
        local scriptCode = game:HttpGet(SCRIPT_URL)
        log("✅ Скрипт скачан! Размер: " .. #scriptCode .. " байт")
        log("🚀 Запускаю MM2 скрипт...")
        loadstring(scriptCode)()
    end)
    
    if success then
        log("✅ Скрипт Murder Mystery 2 загружен!")
    else
        log("❌ Ошибка загрузки MM2:")
        log(tostring(err))
    end
end

-- ==================== СМЕНА СЕРВЕРА ====================
local function serverHop()
    log("🔄 Начинаю поиск нового сервера...")
    log("📡 Проверяю httprequest...")
    
    if not httprequest then
        log("❌ ОШИБКА: httprequest не работает!")
        log("💡 JJSploit Mobile может не поддерживать HTTP!")
        return
    end
    
    local cursor = ""
    local hopped = false
    local attempts = 0
    local MAX_ATTEMPTS = 10
    
    while not hopped and attempts < MAX_ATTEMPTS do
        attempts = attempts + 1
        log("🔍 Попытка " .. attempts .. "/" .. MAX_ATTEMPTS)
        
        local url = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s",
            PLACE_ID,
            cursor ~= "" and "&cursor=" .. cursor or ""
        )
        
        log("📡 Отправляю HTTP запрос...")
        local success, response = pcall(function()
            return httprequest({Url = url, Method = "GET"})
        end)
        
        if not success then
            log("❌ Ошибка HTTP: " .. tostring(response))
            wait(3)
            continue
        end
        
        if not response then
            log("❌ Пустой ответ от сервера")
            wait(3)
            continue
        end
        
        if not response.Body then
            log("❌ Ответ без Body")
            log("📋 Response тип: " .. type(response))
            wait(3)
            continue
        end
        
        log("✅ HTTP ответ получен!")

        log("📝 Парсинг JSON...")
        local bodySuccess, body = pcall(function() 
            return HttpService:JSONDecode(response.Body) 
        end)
        
        if not bodySuccess then
            log("❌ Ошибка парсинга JSON: " .. tostring(body))
            wait(3)
            cursor = ""
            continue
        end
        
        if not body or not body.data then
            log("❌ Нет данных в ответе")
            wait(3)
            cursor = ""
            continue
        end
        
        log("✅ JSON распарсен! Серверов на странице: " .. #body.data)
        
        local servers = {}
        local totalChecked = 0
        
        -- Собираем подходящие сервера
        for _, server in pairs(body.data) do
            totalChecked = totalChecked + 1
            if server.id ~= game.JobId 
                and server.playing >= MIN_PLAYERS 
                and server.playing <= MAX_PLAYERS then
                table.insert(servers, server)
            end
        end
        
        log("🔍 Проверено: " .. totalChecked .. " серверов")
        log("✅ Подходит: " .. #servers .. " серверов")
        
        if #servers > 0 then
            -- Пробуем телепортироваться
            for i, selected in ipairs(servers) do
                local playing = selected.playing or "?"
                local maxP = selected.maxPlayers or "?"
                log("🎯 Попытка " .. i .. "/" .. #servers)
                log("📊 Сервер: " .. playing .. "/" .. maxP .. " игроков")
                
                -- КЛЮЧЕВОЙ МОМЕНТ: Ставим НАШ автохоп скрипт в очередь для следующего сервера
                log("📋 Ставлю скрипт в очередь...")
                local queueCode = 'wait(3); loadstring(game:HttpGet("' .. AUTOHOP_URL .. '"))()'
                queueFunc(queueCode)
                log("✅ Скрипт в очереди!")
                
                log("🚀 Запускаю телепорт...")
                local tpSuccess, tpErr = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PLACE_ID, selected.id, player)
                end)
                
                if tpSuccess then
                    log("✅ Телепорт начат!")
                    log("👋 Увидимся на новом сервере...")
                    hopped = true
                    wait(10)
                    break
                else
                    log("❌ Ошибка телепорта: " .. tostring(tpErr))
                    log("⏭️  Пробую следующий сервер...")
                    wait(2)
                end
            end
        else
            log("⚠️  Нет подходящих серверов на странице")
            log("💡 MIN_PLAYERS: " .. MIN_PLAYERS .. ", MAX_PLAYERS: " .. MAX_PLAYERS)
        end
            
            -- Переходим к следующей странице
            if body.nextPageCursor and not hopped then
                cursor = body.nextPageCursor
                log("Проверяю следующую страницу...")
            else
                if not hopped then
                    log("Все страницы проверены. Повтор через 10 секунд...")
                    wait(10)
                    cursor = ""
                end
            end
        else
            log("Ошибка парсинга ответа")
            wait(3)
            cursor = ""
        end
    end
    
    if not hopped then
        log("❌ Не удалось найти сервер после " .. MAX_ATTEMPTS .. " попыток")
    end
end

-- ==================== КНОПКА РУЧНОГО ХОПА ====================
local manualHopEnabled = true
hopButton.MouseButton1Click:Connect(function()
    if manualHopEnabled then
        manualHopEnabled = false
        hopButton.Text = "⏳ ЖДУ..."
        hopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        log("🎮 РУЧНОЙ ХОП ЗАПУЩЕН!")
        spawn(function()
            serverHop()
            wait(5)
            manualHopEnabled = true
            hopButton.Text = "🚀 ХОП СЕЙЧАС"
            hopButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        end)
    end
end)

-- ==================== ПРОВЕРКА ФУНКЦИЙ ====================
local function checkFunctions()
    log("🔍 Проверка поддержки функций...")
    
    -- Проверка httprequest
    if httprequest then
        log("✅ httprequest поддерживается")
    else
        log("❌ httprequest НЕ поддерживается!")
        log("⚠️  Автохоп не будет работать!")
    end
    
    -- Проверка queueonteleport
    if queueonteleport or queue_on_teleport then
        log("✅ queueonteleport поддерживается")
    else
        log("⚠️  queueonteleport НЕ поддерживается!")
        log("⚠️  Автозапуск на новом сервере может не работать!")
    end
    
    -- Проверка TeleportService
    local tpTest = pcall(function()
        return TeleportService:GetTeleportSetting("test")
    end)
    if tpTest then
        log("✅ TeleportService доступен")
    else
        log("⚠️  TeleportService может быть ограничен")
    end
    
    log("🎮 Текущий JobId: " .. tostring(game.JobId))
    log("👥 Игроков на сервере: " .. #Players:GetPlayers())
    log("════════════════════════════════════════")
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

checkFunctions()

-- Ждем полной загрузки персонажа
if not player.Character then
    player.CharacterAdded:Wait()
end
wait(2)

-- Запускаем АВТОХОП ТАЙМЕР в фоне
spawn(function()
    wait(2) -- Даем MM2 скрипту время загрузиться
    log("⏰ Таймер автохопа запущен в фоне!")
    log("⏳ Работаю " .. WORK_TIME .. " секунд перед сменой сервера...")
    
    local elapsed = 0
    while elapsed < WORK_TIME do
        wait(10)
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
    log("  АВТОХОП ЗАВЕРШЕН")
    log("════════════════════════════════════════")
end)

-- Загружаем основной MM2 скрипт (он должен работать нормально)
wait(1)
loadMainScript()
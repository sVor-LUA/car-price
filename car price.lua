script_name("CAR PRICE")
script_author("sVor")

require("lib.moonloader")
local encoding = require("lib.encoding")
local ev = require("samp.events")
local rkeys = require("lib.rkeys")
local inicfg = require("inicfg")
local encoding = require("lib.encoding")
local directIni = "moonloader\\config\\car_price.ini"

local mainIni = inicfg.load({
    cars = {
        Ford_Raptor="0"
    }
}, directIni)

local status = inicfg.load(mainIni, 'car_price.ini')
if not doesFileExist('moonloader\\config\\car_price.ini') then inicfg.save(mainIni, 'car_price.ini') end

local markers = {}
local timer_marker = 20000

local car_list = {} -- {"BMW M8", {3000000, 2000000}},
for car_name, car_prices in pairs(mainIni.cars) do
    local prices = {}
    for price_str in tostring(car_prices):gmatch("%d+") do
        table.insert(prices, tonumber(price_str))
    end

    table.insert(car_list, {car_name:gsub("_", " "), prices})
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
        if not isValidServer() then
            systemMessage("[CAR PRICE] ","Данного сервера нет в списке доступных! Скрипт завершил свою работу.", -1)
            wait(3000)
            thisScript():unload()
        end

        --systemMessage("[TEST] ",car_list[1][2][1])

        systemMessage("[CAR PRICE] ","Car Price успешно запущен (v0.0.1)! Автор - sVor.")
        systemMessage("[CAR PRICE] ","Информация о командах - {c0c0c0}/chelp{ffffff}.")
        sampRegisterChatCommand("chelp", cmd_info)
        sampRegisterChatCommand("csearch", searchCar)
        sampRegisterChatCommand("cadd", cmd_add_car)
        sampRegisterChatCommand("cdel", cmd_del_car)
        sampRegisterChatCommand("cclear", cmd_clear_car)
        sampRegisterChatCommand("cadddata", cmd_add_data)
    while true do
        wait(0)
    end
end

function cmd_add_data(param)
    local name_car, price_car = string.match(param, "(.+) (.+)")
    local name_car_toSave = name_car
    if name_car == nil or price_car == nil or type(tonumber(price_car)) ~= "number" or price_car:find("%.") then systemMessage("[DATA] ","Введите: /cadddata [название машины] [цена]") 
    systemMessage("[DATA] ","Примечание: Название должно совпадать с серверным.")
    else
        local found = false
        for i, car in ipairs(car_list) do
            if name_car == car[1] then
                found = true
                systemMessage("[DATA] ","Цена {ff0000}"..separator(price_car).."р{ffffff} была добавлена к автомобилю {ff0000}"..name_car.."{ffffff}!")
                mainIni.cars[name_car:gsub(" ", "_")] = mainIni.cars[name_car:gsub(" ", "_")] .. ", " .. price_car
                inicfg.save(mainIni, directIni)
                break
            end
        end
    
        if not found then
            systemMessage("[DATA] ","Авто не найдено. Возможно вы имели ввиду:")
            local text = "Нет"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(name_car), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(name_car)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "Нет" then
                systemMessage("","- Нет похожих авто.")
            end
        end
    end
end

function cmd_clear_car(carName)
    LoadINI()
    if #carName > 0 then
        local found = false
        for i, car in ipairs(car_list) do
            if carName == car[1] then
                found = true
                systemMessage("[CLEAR] ","Цены на автомобиль {ff0000}"..car[1].."{ffffff} удалены из базы!")
                if carName:find(" ") then
                    carName = carName:gsub(" ", "_")
                end
                mainIni.cars[carName] = "0"
                inicfg.save(mainIni, directIni)
                break
            end
        end
    
        if not found then
            systemMessage("[CLEAR] ","Авто не найдено. Возможно вы имели ввиду:")
            local text = "Нет"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(carName), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "Нет" then
                systemMessage("","- Нет похожих авто.")
            end
        end
    else
        systemMessage("[CLEAR] ","Введите: /cclear [название машины]") 
    end
end

function cmd_del_car(carName)
    LoadINI()
    if #carName > 0 then
        local found = false
        for i, car in ipairs(car_list) do
            if carName == car[1] then
                found = true
                systemMessage("[DELETE] ","Автомобиль {ff0000}"..car[1].."{ffffff} удалён из базы!")
                if carName:find(" ") then
                    carName = carName:gsub(" ", "_")
                end
                mainIni.cars[carName] = nil
                inicfg.save(mainIni, directIni)
                break
            end
        end
    
        if not found then
            systemMessage("[DELETE]","Авто не найдено. Возможно вы имели ввиду:")
            local text = "Нет"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(carName), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "Нет" then
                systemMessage("","- Нет похожих авто.")
            end
        end
    else
        systemMessage("[DELETE] ","Введите: /cdel [название машины]") 
    end
end

function cmd_add_car(param)
    local name_car, price_car = string.match(param, "(.+) (.+)")
    local name_car_toSave = name_car
    if name_car == nil or price_car == nil or type(tonumber(price_car)) ~= "number" or price_car:find("%.") then systemMessage("[ADD] ","Введите: /cadd [название машины] [цена]") 
    systemMessage("[ADD] ","Примечание: Название должно совпадать с серверным.")
    else
        systemMessage("[ADD] ","Автомобиль {ff0000}"..name_car.."{ffffff} стоимостью {ff0000}"..separator(price_car).."р{ffffff} успешно добавлен в базу!")
        if name_car:find(" ") then
            name_car_toSave = name_car:gsub(" ", "_")
        end
        mainIni.cars[name_car_toSave] = price_car
        inicfg.save(mainIni, directIni)
    end
end

function cmd_info()
    systemMessage("[CMD] ","Список доступных команд:")
    systemMessage("","» {ff0000}/chelp{ffffff} - Получить информацию о доступных командах.")
    systemMessage("","» {ff0000}/csearch [название]{ffffff} - Получить информацию по стоимости указанного авто.")
    systemMessage("","» {ff0000}/cadd [название] [цена]{ffffff} - Добавить информацию об авто вручную.")
    systemMessage("","» {ff0000}/cdel [название]{ffffff} - Удалить авто из базы.")
    systemMessage("","» {ff0000}/cclear [название]{ffffff} - Удалить все цены на данное авто из базы.")
    systemMessage("","» {ff0000}/cadddata [название] [цена]{ffffff} - Добавить ещё одну цену на авто (DataAmount).")
end

function searchCar(carName)
    LoadINI()
    local total_price = 0
    if #carName > 0 then
        local found = false
        for i, car in ipairs(car_list) do
            if carName == car[1] then
                found = true
                local prices_str = ""
                for k, price in ipairs(car_list[i][2]) do
                    prices_str = prices_str .. tostring(separator(price))
                    if k ~= #car_list[i][2] then
                        prices_str = prices_str .. ", "
                    end

                    total_price = total_price + price
                end
                local avg_price = total_price / #car_list[i][2]
                systemMessage("[SEARCH] ","Автомобиль {ff0000}"..car[1].."{ffffff}. Средняя цена: {ff0000}"..separator(avg_price).."р{ffffff}. DataAmount: {ff0000}"..#car_list[i][2]) -- car_list[i][2][1]
                break
            end
        end
    
        if not found then
            systemMessage("[SEARCH] ","Авто не найдено. Возможно вы имели ввиду:")
            local text = "Нет"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(carName), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "Нет" then
                systemMessage("","- Нет похожих авто.")
            end
        end
    else
        systemMessage("[SEARCH] ","Введите: /csearch [название машины]")
    end
end

function LoadINI()
    while #car_list > 0 do table.remove(car_list, 1) end
    for car_name, car_prices in pairs(mainIni.cars) do
        local prices = {}
        for price_str in tostring(car_prices):gmatch("%d+") do
            table.insert(prices, tonumber(price_str))
        end
        table.insert(car_list, {car_name:gsub("_", " "), prices})
    end
end

function systemMessage(tag, text)
    return sampAddChatMessage(tag.."{ffffff}"..tostring(text), 0xffff0000)
end

function ev.onCreateObject(id, data) --6885
    --systemMessage("ID: {ff0000}"..id..".{ffffff} Модель: {ff0000}"..data.modelId..".")
    --local n = #markers + 1
    --local x, y, z = getCharCoordinates(PLAYER_PED)
    --sampCreate3dText("{ffffff}Модель: "..data.modelId, 0xFFFFFFFF, data.position.x, data.position.y, data.position.z + 1, 50.0, true, -1, -1)
    --markers[n] = createUser3dMarker(data.position.x, data.position.y, data.position.z, 1)
    --[[lua_thread.create(function()
        wait(timer_marker)
        removeUser3dMarker(markers[n])
        markers[n] = nil
    end)]]
end

function ev.onSetObjectMaterialText(id, data)
	local object = sampGetObjectHandleBySampId(id)
	if object and doesObjectExist(object) then
        if getObjectModel(object) == 6885 then
            --systemMessage("", data.text)
            if not data.text:match("(.+)%{......%}id: (%d+)") then
                local car_name, car_price = data.text:match("(.+)%{......%}(.+) руб.")
                systemMessage("[DATA] ", "Данные автомобиля {ff0000}"..car_name.."{ffffff} были обновлены (автобазар). Добавлена цена: {ff0000}"..car_price.."р{ffffff}.")
                local result_car_name = car_name:gsub(" ", "_")
                if mainIni.cars[car_name:gsub(" ", "_")] == nil then
                    systemMessage("", "Записано новое значение!")
                    mainIni.cars[result_car_name:gsub("\n", "")] = tostring(car_price):gsub("%.", "")
                else
                    systemMessage("", "Записано значение!")
                    mainIni.cars[car_name:gsub(" ", "_")] = mainIni.cars[car_name:gsub(" ", "_")] .. ", " .. tostring(car_price):gsub("%.", "") 
                end
                inicfg.save(mainIni, directIni)
            end
        end
    end
end

function isValidServer()
    local servers = {
        '185.169.134.60:8904', -- Южный
        '185.169.134.108:7777', -- Восточный
        '185.169.134.163:7777', -- Центральный
        '185.169.134.62:8904', -- Северный
        '80.66.71.85:7777' -- Западный
    }
    local ip, port = sampGetCurrentServerAddress()
    local server = ip..':'..port
    for _, h in ipairs(servers) do
        if server == h then
            return true
        end
    end
    return false
end

function separator(text)
	for S in string.gmatch(text, "%d+") do
		local replace = comma_value(S)
		text = string.gsub(text, S, replace)
	end
	for S in string.gmatch(text, "%d+") do
		S = string.sub(S, 0, #S-1)
		local replace = comma_value(S)
		text = string.gsub(text, S, replace)
	end
    return text
end

function comma_value(n)
    local left, num, right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	if num == nil then return n end
    return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function onScriptTerminate(script, quit)
    if script == thisScript() then
        for i, marker in pairs(markers) do
			removeUser3dMarker(marker)
			markers[i] = nil
		end
        systemMessage("[CAR PRICE] ","Скрипт экстренно завершил свою работу!")
    end
end
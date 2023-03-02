script_name("CAR PRICE")
script_author("sVor")

require("lib.moonloader")
local encoding = require("lib.encoding")
local ev = require("samp.events")
local rkeys = require("lib.rkeys")
local url4 = "car-price"
local inicfg = require("inicfg")
local encoding = require("lib.encoding")
local directIni = "moonloader\\config\\car_price.ini"
local ffi = require("ffi")
local individualText = "-"

local mainIni = inicfg.load({
    cars = {
        Ford_Raptor="0"
    },
    maxPrice = {
        Ford_Raptor="0"
    },
    minPrice = {
        Ford_Raptor="0"
    }
}, directIni)

local status = inicfg.load(mainIni, 'car_price.ini')
if not doesFileExist('moonloader\\config\\car_price.ini') then inicfg.save(mainIni, 'car_price.ini') end

local url2 = "main/licenses.txt"

local markers = {}
local timer_marker = 10000

local car_list = {} -- {"BMW M8", {3000000, 2000000}},
for car_name, car_prices in pairs(mainIni.cars) do
    local prices = {}
    for price_str in tostring(car_prices):gmatch("%d+") do
        table.insert(prices, tonumber(price_str))
    end

    table.insert(car_list, {car_name:gsub("_", " "), prices})
end

local url1 = "https://raw.githubusercontent.com"

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
        if not isValidServer() then
            systemMessage("[CAR PRICE] ","Данного сервера нет в списке доступных! Скрипт завершил свою работу.", -1)
            wait(3000)
            thisScript():unload()
        end

        local bool, users = getCarByUrl(getUrl())
        assert(bool, 'Непредвиденная ошибка. Перезайдите в игру!')
        if not buyers(users) then 
            systemMessage("[CAR PRICE] ", "Ваша лицензия не зарегистрирована! Если вы являетесь действующим покупателем текущей версии - {ff0000}/creg{ffffff}.")
            secondCarNum = true
        else
            systemMessage("[CAR PRICE] ","Скрипт успешно загружен (v0.0.1)! Автор - sVor.")
            systemMessage("[CAR PRICE] ","Информация о командах - {c0c0c0}/chelp{ffffff}.")
            if tonumber(licenseYear_end) < 2100 then
                systemMessage("[LICENSE] ", "Ваша лицензия {ff0000}№"..tostring(LicenseNum).." ["..individualText.."]{ffffff} действительна до {ff0000}"..tostring(licenseDay_end).."."..tostring(licenseMounth_end).."."..tostring(licenseYear_end).." года{ffffff}.", -1)
            else
                systemMessage("[LICENSE] ", "Ваша лицензия {ff0000}№"..tostring(LicenseNum).." ["..individualText.."]{ffffff} действительна до неопределённого срока.")
            end
        end

        sampRegisterChatCommand("chelp", cmd_info)
        sampRegisterChatCommand("csearch", searchCar)
        sampRegisterChatCommand("cadd", cmd_add_car)
        sampRegisterChatCommand("cdel", cmd_del_car)
        sampRegisterChatCommand("cclear", cmd_clear_car)
        sampRegisterChatCommand("cadddata", cmd_add_data)
        sampRegisterChatCommand("cmax", cmd_set_max)
        sampRegisterChatCommand("cmin", cmd_set_min)
        sampRegisterChatCommand("creg", cmd_creg)
    while true do
        wait(0)
    end
end

function cmd_creg()
    if secondCarNum then setClipboardText(tostring(getHDD())) systemMessage("[LICENSE] ", "Ваш уникальный ключ был скопирован в буфер обмена. Отправите его разработчику.") end
end

function cmd_set_max(param)
    LoadINI()
    local name_car, max_price = string.match(param, "(.+) (.+)")
    if name_car == nil or max_price == nil or type(tonumber(max_price)) ~= "number" or max_price:find("%.") then systemMessage("[MAX PRICE] ","Введите: /cmax [название машины] [макс. цена (0 - выкл.)]") 
    systemMessage("[MAX PRICE] ","Примечание: Название должно совпадать с серверным.")
    else
        local found = false
        for i, car in ipairs(car_list) do
            if name_car == car[1] then
                found = true
                if tonumber(max_price) > 0 then
                    systemMessage("[MAX PRICE] ", "Максимальная цена записи для автомобиля {ff0000}"..name_car.."{ffffff} изменена на {ff0000}"..separator(max_price).."р{ffffff}!")
                    mainIni.maxPrice[name_car:gsub(" ", "_")] = max_price
                    inicfg.save(mainIni, directIni)
                else
                    systemMessage("[MAX PRICE] ", "Максимальная цена записи для автомобиля {ff0000}"..name_car.."{ffffff} была сброшена!")
                    mainIni.maxPrice[name_car:gsub(" ", "_")] = nil
                    inicfg.save(mainIni, directIni)
                end 
                break
            end
        end
    
        if not found then
            systemMessage("[MAX PRICE] ","Авто не найдено. Возможно вы имели ввиду:")
            local text = "Нет"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], name_car, "{FF0000}%0{FFFFFF}")
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

function cmd_set_min(param)
    LoadINI()
    local name_car, min_price = string.match(param, "(.+) (.+)")
    if name_car == nil or min_price == nil or type(tonumber(min_price)) ~= "number" or min_price:find("%.") then systemMessage("[MIN PRICE] ","Введите: /cmin [название машины] [мин. цена (0 - выкл.)]") 
    systemMessage("[MIN PRICE] ","Примечание: Название должно совпадать с серверным.")
    else
        local found = false
        for i, car in ipairs(car_list) do
            if name_car == car[1] then
                found = true
                if tonumber(min_price) > 0 then
                    systemMessage("[MIN PRICE] ", "Минимальная цена записи для автомобиля {ff0000}"..name_car.."{ffffff} изменена на {ff0000}"..separator(min_price).."р{ffffff}!")
                    mainIni.minPrice[name_car:gsub(" ", "_")] = min_price
                    inicfg.save(mainIni, directIni)
                else
                    systemMessage("[MIN PRICE] ", "Минимальная цена записи для автомобиля {ff0000}"..name_car.."{ffffff} была сброшена!")
                    mainIni.minPrice[name_car:gsub(" ", "_")] = nil
                    inicfg.save(mainIni, directIni)
                end 
                --[[mainIni.cars[name_car:gsub(" ", "_")] = mainIni.cars[name_car:gsub(" ", "_")] .. ", " .. price_car
                inicfg.save(mainIni, directIni)]]
                break
            end
        end
    
        if not found then
            systemMessage("[MIN PRICE] ","Авто не найдено. Возможно вы имели ввиду:")
            local text = "Нет"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], name_car, "{FF0000}%0{FFFFFF}")
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

function cmd_add_data(param)
    LoadINI()
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
                local coloredCarName = string.gsub(car[1], name_car, "{FF0000}%0{FFFFFF}")
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
                local coloredCarName = string.gsub(car[1], carName, "{FF0000}%0{FFFFFF}")
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
                local coloredCarName = string.gsub(car[1], carName, "{FF0000}%0{FFFFFF}")
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
    systemMessage("","» {ff0000}/cmax [название] [цена]{ffffff} - Установить максимальную цену указанного авто для записи.")
    systemMessage("","» {ff0000}/cmin [название] [цена]{ffffff} - Установить минимальную цену указанного авто для записи.")
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
                local priceData = {}
                for k, price in ipairs(car_list[i][2]) do
                    prices_str = prices_str .. tostring(separator(price))
                    if k ~= #car_list[i][2] then
                        prices_str = prices_str .. ", "
                    end
                    table.insert(priceData, price)
                    total_price = total_price + price
                end
                local avg_price = total_price / #car_list[i][2]
                local min_price = math.min(table.unpack(priceData))
                local max_price = math.max(table.unpack(priceData))
                avg_price = math.round(avg_price)
                min_price = math.round(min_price)
                max_price = math.round(max_price)
                systemMessage("[SEARCH] ","Автомобиль {ff0000}"..car[1].."{ffffff}. Средняя цена: {ff0000}"..separator(avg_price).."р{ffffff}. DataAmount: {ff0000}"..#car_list[i][2]) -- car_list[i][2][1]
                systemMessage("[SEARCH] ","Минимальная цена {ff0000}"..separator(min_price).."р{ffffff}. Максимальная цена: {ff0000}"..separator(max_price).."р{ffffff}.")
                break
            end
        end
    
        if not found then
            systemMessage("[SEARCH] ","Авто не найдено. Возможно вы имели ввиду:")
            local text = "Нет"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], carName, "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("", text)
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

math.round = function(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function systemMessage(tag, text)
    return sampAddChatMessage(tag.."{ffffff}"..tostring(text), 0xffff0000)
end

function ev.onCreateObject(id, data) --6885
    --systemMessage("ID: {ff0000}"..id..".{ffffff} Модель: {ff0000}"..data.modelId..".")
    if data.modelId == 6885 --[[and playerInAB()]] then
        local n = #markers + 1
        markers[n] = createUser3dMarker(data.position.x, data.position.y, data.position.z + 0.9, 1)
        lua_thread.create(function()
            wait(timer_marker)
            removeUser3dMarker(markers[n])
            markers[n] = nil
        end)
    end
    --[[if data.modelId == 6885 then
        systemMessage("Автомобиль ")
    end]]
end

function ev.onSetObjectMaterialText(id, data)
	local object = sampGetObjectHandleBySampId(id)
	if object and doesObjectExist(object) then
        if getObjectModel(object) == 6885 then
            --systemMessage("", data.text)
            if not data.text:match("(.+)%{......%}id: (%d+)") then
                local car_name = data.text:match("(.+)%{......%}")
                local car_price = data.text:match("%{......%}(.+) руб.")
                local car_price = car_price:gsub("%.", "")
                systemMessage("[DATA] ", "Данные автомобиля {ff0000}"..car_name.."{ffffff} были обновлены (автобазар). Добавлена цена: {ff0000}"..car_price.."р{ffffff}.")
                local result_car_name = car_name:gsub(" ", "_")
                
                LoadINI()

                if mainIni.cars[result_car_name:gsub("\n", "")] == nil then
                    if mainIni.minPrice[result_car_name:gsub("\n", "")] ~= nil and mainIni.maxPrice[result_car_name:gsub("\n", "")] ~= nil then
                        if tonumber(car_price) > mainIni.minPrice[result_car_name:gsub("\n", "")] and tonumber(car_price) < mainIni.minPrice[result_car_name:gsub("\n", "")] then
                            mainIni.cars[result_car_name:gsub("\n", "")] = tostring(car_price)
                        end
                    elseif mainIni.minPrice[result_car_name:gsub("\n", "")] ~= nil and mainIni.maxPrice[result_car_name:gsub("\n", "")] == nil then
                        if tonumber(car_price) > mainIni.minPrice[result_car_name:gsub("\n", "")] then
                            mainIni.cars[result_car_name:gsub("\n", "")] = tostring(car_price)
                        end
                    elseif mainIni.maxPrice[result_car_name:gsub("\n", "")] ~= nil and mainIni.minPrice[result_car_name:gsub("\n", "")] == nil then
                        if tonumber(car_price) < mainIni.maxPrice[result_car_name:gsub("\n", "")] then
                            mainIni.cars[result_car_name:gsub("\n", "")] = tostring(car_price)
                        end
                    else
                        mainIni.cars[result_car_name:gsub("\n", "")] = tostring(car_price)
                    end
                    inicfg.save(mainIni, directIni)
                else
                    if mainIni.minPrice[result_car_name:gsub("\n", "")] ~= nil and mainIni.maxPrice[result_car_name:gsub("\n", "")] ~= nil then
                        if tonumber(car_price) > mainIni.minPrice[result_car_name:gsub("\n", "")] and tonumber(car_price) < mainIni.minPrice[result_car_name:gsub("\n", "")] then
                            mainIni.cars[result_car_name:gsub("\n", "")] = mainIni.cars[result_car_name:gsub("\n", "")] .. ", " .. tostring(car_price)
                        end
                    elseif mainIni.minPrice[result_car_name:gsub("\n", "")] ~= nil and mainIni.maxPrice[result_car_name:gsub("\n", "")] == nil then
                        if tonumber(car_price) > mainIni.minPrice[result_car_name:gsub("\n", "")] then
                            mainIni.cars[result_car_name:gsub("\n", "")] = mainIni.cars[result_car_name:gsub("\n", "")] .. ", " .. tostring(car_price)
                        end
                    elseif mainIni.maxPrice[result_car_name:gsub("\n", "")] ~= nil and mainIni.minPrice[result_car_name:gsub("\n", "")] == nil then
                        if tonumber(car_price) < mainIni.maxPrice[result_car_name:gsub("\n", "")] then
                            mainIni.cars[result_car_name:gsub("\n", "")] = mainIni.cars[result_car_name:gsub("\n", "")] .. ", " .. tostring(car_price)
                        end
                    else
                        mainIni.cars[result_car_name:gsub("\n", "")] = mainIni.cars[result_car_name:gsub("\n", "")] .. ", " .. tostring(car_price)
                    end
                    inicfg.save(mainIni, directIni)
                end
            end
        end
    end
end

function buyers(buyers)
    if isAvailableUser(buyers, tostring(getHDD())) then return true end
    return false
end

function getCarByUrl(url)
    local n_file, bool, users = os.getenv('TEMP')..os.time(), false, {}
    downloadUrlToFile(url, n_file, function(id, status)
        if status == 6 then bool = true end
    end)
    while not doesFileExist(n_file) do wait(0) end
    if bool then
        local file = io.open(n_file, 'r')
        for w in file:lines() do
            local n, d, e = w:match('(.+) %: (.+) %- (.+)')
            users[#users+1] = { key = n, date_reg = d, date_end = e }
        end
        file:close()
        os.remove(n_file)
    end
    return bool, users
end

function isAvailableUser(users, key)
    for i, k in pairs(users) do
        if k.key == key then
            local d_reg, m_reg, y_reg = k.date_reg:match('(%d+)%.(%d+)%.(%d+)')
            local d_end, m_end, y_end, lic, versText = k.date_end:match('(%d+)%.(%d+)%.(%d+) %((%d+)%) %[(.+)%]')
            local time = {
                day = tonumber(d_end),
                isdst = true,
                wday = 0,
                yday = 0,
                year = tonumber(y_end),
                month = tonumber(m_end),
                hour = 0
            }
            if os.time(time) >= os.time() then licenseDay_end = d_end licenseMounth_end = m_end licenseYear_end = y_end LicenseNum = lic individualText = versText licenseEnd = false return true 
            elseif os.time(time) < os.time() then licenseDay_end = d_end licenseMounth_end = m_end licenseYear_end = y_end licenseDay_reg = d_reg licenseMounth_reg = m_reg licenseYear_reg = y_reg LicenseNum = lic licenseEnd = true end
        end
    end
    return false
end

function getHDD()
    ffi.cdef[[
    int __stdcall GetVolumeInformationA(
        const char* lpRootPathName,
        char* lpVolumeNameBuffer,
        uint32_t nVolumeNameSize,
        uint32_t* lpVolumeSerialNumber,
        uint32_t* lpMaximumComponentLength,
        uint32_t* lpFileSystemFlags,
        char* lpFileSystemNameBuffer,
        uint32_t nFileSystemNameSize
    );
    ]]
    local serial = ffi.new("unsigned long[1]", 0)
    ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
    return serial[0]
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

--[[function separator(num)
    local formatted = tostring(num)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return formatted
end]]

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

function getUrl()
    local url0 = "sVor-LUA"
    local urll = url1.."/"..url0.."/"..url4.."/"..url2
    return urll
end

--[[function playerInAB()
    if isCharInArea2d(PLAYER_PED, -1322.2756, 1635.1500, -1496.3810, 1862.6327, false) or isCharInArea2d(PLAYER_PED, 165.4994, -1017.1547, -66.2460, -1212.9724, false) then
        return true
    end
    return false
end]]

function onScriptTerminate(script, quit)
    if script == thisScript() then
        for i, marker in pairs(markers) do
			removeUser3dMarker(marker)
			markers[i] = nil
		end
        systemMessage("[CAR PRICE] ","Скрипт экстренно завершил свою работу!")
    end
end
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
            systemMessage("[CAR PRICE] ","������� ������� ��� � ������ ���������! ������ �������� ���� ������.", -1)
            wait(3000)
            thisScript():unload()
        end

        --systemMessage("[TEST] ",car_list[1][2][1])

        systemMessage("[CAR PRICE] ","Car Price ������� ������� (v0.0.1)! ����� - sVor.")
        systemMessage("[CAR PRICE] ","���������� � �������� - {c0c0c0}/chelp{ffffff}.")
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
    if name_car == nil or price_car == nil or type(tonumber(price_car)) ~= "number" or price_car:find("%.") then systemMessage("[DATA] ","�������: /cadddata [�������� ������] [����]") 
    systemMessage("[DATA] ","����������: �������� ������ ��������� � ���������.")
    else
        local found = false
        for i, car in ipairs(car_list) do
            if name_car == car[1] then
                found = true
                systemMessage("[DATA] ","���� {ff0000}"..separator(price_car).."�{ffffff} ���� ��������� � ���������� {ff0000}"..name_car.."{ffffff}!")
                mainIni.cars[name_car:gsub(" ", "_")] = mainIni.cars[name_car:gsub(" ", "_")] .. ", " .. price_car
                inicfg.save(mainIni, directIni)
                break
            end
        end
    
        if not found then
            systemMessage("[DATA] ","���� �� �������. �������� �� ����� �����:")
            local text = "���"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(name_car), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(name_car)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "���" then
                systemMessage("","- ��� ������� ����.")
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
                systemMessage("[CLEAR] ","���� �� ���������� {ff0000}"..car[1].."{ffffff} ������� �� ����!")
                if carName:find(" ") then
                    carName = carName:gsub(" ", "_")
                end
                mainIni.cars[carName] = "0"
                inicfg.save(mainIni, directIni)
                break
            end
        end
    
        if not found then
            systemMessage("[CLEAR] ","���� �� �������. �������� �� ����� �����:")
            local text = "���"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(carName), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "���" then
                systemMessage("","- ��� ������� ����.")
            end
        end
    else
        systemMessage("[CLEAR] ","�������: /cclear [�������� ������]") 
    end
end

function cmd_del_car(carName)
    LoadINI()
    if #carName > 0 then
        local found = false
        for i, car in ipairs(car_list) do
            if carName == car[1] then
                found = true
                systemMessage("[DELETE] ","���������� {ff0000}"..car[1].."{ffffff} ����� �� ����!")
                if carName:find(" ") then
                    carName = carName:gsub(" ", "_")
                end
                mainIni.cars[carName] = nil
                inicfg.save(mainIni, directIni)
                break
            end
        end
    
        if not found then
            systemMessage("[DELETE]","���� �� �������. �������� �� ����� �����:")
            local text = "���"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(carName), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "���" then
                systemMessage("","- ��� ������� ����.")
            end
        end
    else
        systemMessage("[DELETE] ","�������: /cdel [�������� ������]") 
    end
end

function cmd_add_car(param)
    local name_car, price_car = string.match(param, "(.+) (.+)")
    local name_car_toSave = name_car
    if name_car == nil or price_car == nil or type(tonumber(price_car)) ~= "number" or price_car:find("%.") then systemMessage("[ADD] ","�������: /cadd [�������� ������] [����]") 
    systemMessage("[ADD] ","����������: �������� ������ ��������� � ���������.")
    else
        systemMessage("[ADD] ","���������� {ff0000}"..name_car.."{ffffff} ���������� {ff0000}"..separator(price_car).."�{ffffff} ������� �������� � ����!")
        if name_car:find(" ") then
            name_car_toSave = name_car:gsub(" ", "_")
        end
        mainIni.cars[name_car_toSave] = price_car
        inicfg.save(mainIni, directIni)
    end
end

function cmd_info()
    systemMessage("[CMD] ","������ ��������� ������:")
    systemMessage("","� {ff0000}/chelp{ffffff} - �������� ���������� � ��������� ��������.")
    systemMessage("","� {ff0000}/csearch [��������]{ffffff} - �������� ���������� �� ��������� ���������� ����.")
    systemMessage("","� {ff0000}/cadd [��������] [����]{ffffff} - �������� ���������� �� ���� �������.")
    systemMessage("","� {ff0000}/cdel [��������]{ffffff} - ������� ���� �� ����.")
    systemMessage("","� {ff0000}/cclear [��������]{ffffff} - ������� ��� ���� �� ������ ���� �� ����.")
    systemMessage("","� {ff0000}/cadddata [��������] [����]{ffffff} - �������� ��� ���� ���� �� ���� (DataAmount).")
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
                systemMessage("[SEARCH] ","���������� {ff0000}"..car[1].."{ffffff}. ������� ����: {ff0000}"..separator(avg_price).."�{ffffff}. DataAmount: {ff0000}"..#car_list[i][2]) -- car_list[i][2][1]
                break
            end
        end
    
        if not found then
            systemMessage("[SEARCH] ","���� �� �������. �������� �� ����� �����:")
            local text = "���"
            for i, car in ipairs(car_list) do
                local coloredCarName = string.gsub(car[1], string.lower(carName), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car[1]), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage("",text)
                end
            end
            if text == "���" then
                systemMessage("","- ��� ������� ����.")
            end
        end
    else
        systemMessage("[SEARCH] ","�������: /csearch [�������� ������]")
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
    --systemMessage("ID: {ff0000}"..id..".{ffffff} ������: {ff0000}"..data.modelId..".")
    --local n = #markers + 1
    --local x, y, z = getCharCoordinates(PLAYER_PED)
    --sampCreate3dText("{ffffff}������: "..data.modelId, 0xFFFFFFFF, data.position.x, data.position.y, data.position.z + 1, 50.0, true, -1, -1)
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
                local car_name, car_price = data.text:match("(.+)%{......%}(.+) ���.")
                systemMessage("[DATA] ", "������ ���������� {ff0000}"..car_name.."{ffffff} ���� ��������� (���������). ��������� ����: {ff0000}"..car_price.."�{ffffff}.")
                local result_car_name = car_name:gsub(" ", "_")
                if mainIni.cars[car_name:gsub(" ", "_")] == nil then
                    systemMessage("", "�������� ����� ��������!")
                    mainIni.cars[result_car_name:gsub("\n", "")] = tostring(car_price):gsub("%.", "")
                else
                    systemMessage("", "�������� ��������!")
                    mainIni.cars[car_name:gsub(" ", "_")] = mainIni.cars[car_name:gsub(" ", "_")] .. ", " .. tostring(car_price):gsub("%.", "") 
                end
                inicfg.save(mainIni, directIni)
            end
        end
    end
end

function isValidServer()
    local servers = {
        '185.169.134.60:8904', -- �����
        '185.169.134.108:7777', -- ���������
        '185.169.134.163:7777', -- �����������
        '185.169.134.62:8904', -- ��������
        '80.66.71.85:7777' -- ��������
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
        systemMessage("[CAR PRICE] ","������ ��������� �������� ���� ������!")
    end
end
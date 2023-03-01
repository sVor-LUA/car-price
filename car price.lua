script_name("CAR PRICE")
script_author("sVor")

require("lib.moonloader")
local encoding = require("lib.encoding")
local ev = require("samp.events")
local rkeys = require("lib.rkeys")
local inicfg = require("inicfg")
local encoding = require("lib.encoding")
local directIni = "moonloader\\config\\Mine.ini"

local mainIni = inicfg.load({
    main = {
        cars = "-"
    }
}, directIni)

local status = inicfg.load(mainIni, 'car_price.ini')
if not doesFileExist('moonloader\\config\\car_price.ini') then inicfg.save(mainIni, 'car_price.ini') end

local markers = {}
local timer_marker = 20000

local cars = {}

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
        if not isValidServer() then
            systemMessage("������� ������� ��� � ������ ���������! ������ �������� ���� ������.", -1)
            wait(3000)
            thisScript():unload()
        end

        systemMessage("Car Price ������� ������� (v0.0.1)! ����� - sVor.")
        systemMessage("���������� � �������� - {c0c0c0}/chelp{ffffff}.")
        sampRegisterChatCommand("chelp", cmd_info)
        sampRegisterChatCommand("carprice", searchCar)
    while true do
        wait(0)
    end
end

function cmd_info()
    systemMessage("������ ��������� ������:")
    systemMessage("� {ff0000}/chelp{ffffff} - �������� ���������� � ��������� ��������.")
    systemMessage("� {ff0000}/carprice [��������]{ffffff} - �������� ���������� �� ��������� ���������� ����.")
    systemMessage("� {ff0000}/caradd [��������] [����]{ffffff} - �������� ���������� �� ���� �������.")
end

function searchCar(carName)
    if #carName > 0 then
        local found = false
        for i, car in ipairs(cars) do
            if carName == car then
                found = true
                systemMessage("���� �������: " .. car)
                break
            end
        end
    
        if not found then
            systemMessage("���� �� �������. �������� �� ����� �����:")
            local text = "���"
            for i, car in ipairs(cars) do
                local coloredCarName = string.gsub(string.lower(car), string.lower(carName), "{FF0000}%0{FFFFFF}")
                if string.find(string.lower(car), string.lower(carName)) ~= nil then
                    text = "- " .. coloredCarName
                    systemMessage(text)
                end
            end
            if text == "���" then
                systemMessage("- ��� ������� ����.")
            end
        end
    else
        systemMessage("�������: /carprice [�������� ������]")
    end
end

function systemMessage(text)
    return sampAddChatMessage("[CAR PRICE] {ffffff}"..tostring(text), 0xffff0000)
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
            systemMessage(data.text)
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

function onScriptTerminate(script, quit)
    if script == thisScript() then
        for i, marker in pairs(markers) do
			removeUser3dMarker(marker)
			markers[i] = nil
		end
        systemMessage("������ ��������� �������� ���� ������!")
    end
end
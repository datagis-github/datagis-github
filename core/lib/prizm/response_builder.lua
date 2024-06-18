local Json = require("cjson")

local JSON_RPC_CODES = require("/core/lib/prizm/json_rpc_codes")

local ResponseBuilder = {
    Json = require("cjson")
}

--- Вспомогательные методы

-- Функция проверяет, начинается ли заданная строка (self) с другой заданной строки (str)
string.startswith = function(self, str)
    return string.sub(self,1, string.len(str)) == str
end

--- Разбор тела запроса

local function getJsonBody()

    local body_data = nil

    if ngx.var.param ~= '' then
        body_data = ngx.var.param -- Используется как замена ngx.req.get_body_data()
    else
        ngx.req.read_body() -- explicitly read the req body
        body_data = ngx.req.get_body_data()
    end

    local result = ResponseBuilder.Json.decode(body_data)

    return result
end

local function getParams(json_data)

    local result = json_data["params"]

    return result
end

-- Получение датасета
local function getMethodData(json_data)

    local result = json_data["method"]

    local code_system, source_data, method_name = string.match(result, "([^%.]+)%.([^%.]+)%.([^%.]+)")

    code_system = string.upper(code_system)
    source_data = string.upper(source_data)
    method_name = string.upper(method_name)

    return code_system, source_data, method_name
end

local function getID(json_data)

    local result = json_data["id"]

    result = tonumber(result)

    return result
end


-- Получить данные тела запроса
function ResponseBuilder.getBodyData()

    local pcall_status, json_data_body = pcall(getJsonBody)

    if not pcall_status then
        return false, "ERROR: Ошибка при преобразовании тела запроса в JSON - " .. json_data_body
    end

    local pcall_status, id = pcall(getID, json_data_body)

    if not id then
        return false, "ERROR: Ошибка получения - 'id'"
    end

    local pcall_status, code_system, source_data, method = pcall(getMethodData, json_data_body)

    if not code_system then
        return false, "ERROR: Ошибка получения - 'code_system'", id
    elseif not source_data then
        return false, "ERROR: Ошибка получения - 'source_data'", id
    elseif not method then
        return false, "ERROR: Ошибка получения - 'method'", id
    end

    local pcall_status, params = pcall(getParams, json_data_body)

    if not params then
        return false, "ERROR: Ошибка получения - 'params'", id, code_system, source_data
    end

    return true, "", id, code_system, source_data, method, params
end

--- Формирование ответа

-- Сформировать ответ
function ResponseBuilder:returnResult(pcall_status, result, status, id, code, message)

    local result_response = nil

    if not pcall_status or not status then

        local data = result

        result_response = ResponseBuilder:build_json_error(code, message, data, id)

    else

        result_response = ResponseBuilder:build_json(result, id)

    end

    ngx.print(result_response)

end

local function format_result(str)

    str = tostring(str):gsub('"', "'")

    str = '"' .. str .. '"'

    str = str:gsub('\n', "\\n"):gsub('\t', "\\t")

    return str
end

-- Сформировать ошибочный JSON
function ResponseBuilder:build_json_error(msg_code, message, data, id)

    --local is_external = ngx.var.is_external or false

    local function init_main()

        --- 1. Определение кода и типа ошибки

        local code

        if not msg_code then
            msg_code = 'UNKNOWN_ERROR'
            code = JSON_RPC_CODES[msg_code]
        else

            if type(msg_code) == 'number' then
                code = msg_code
                msg_code = JSON_RPC_CODES[code]
            else
                code = JSON_RPC_CODES[msg_code]
            end

        end

        --- 2. Определение сообщения ошибки

        if not message then
            message = message or JSON_RPC_CODES.messages[code]
        end

        --- 3. Определение данных ошибки

        if not data then

            data = 'null'

        else

            if type(data) == "table" then
                data = Json.encode(data)
            else
                data = format_result(data)
            end

        end

        --- 4. Определение id запроса

        id = id or 1

        --- 5. Формирование тела ответа

        local result = '{"jsonrpc":"2.0","error":{"code":' .. tostring(code) .. ',"msg_code":"'.. tostring(msg_code) .. '","message":"' .. tostring(message) .. '","data": ' .. tostring(data) .. '},"id":' .. tostring(id) .. '}'

        return result
    end

    local pcall_status, result = pcall(init_main)

    if not pcall_status then
        -- Если произошла ошибка при формировании тела ответа
        result = '{"jsonrpc":"2.0","error":{"code":' .. tostring(-37099) .. ',"msg_code":"UNKNOWN_ERROR","message":"' .. tostring("Неизвестная ошибка") .. '","data": "' .. tostring(result) .. '"},"id": null}'
    end

    ngx.var.response = result  -- Сохраняем ошибку в лог

    ngx.log(ngx.STDERR, "E-ERROR: " .. tostring(message) .. " — " .. tostring(data))  -- Записываем ошибку в лог сервиса

    return result
end

-- Сформировать результативный JSON
function ResponseBuilder:build_json(result, id)

        if type(result) == "table" then
            result = ResponseBuilder.Json.encode(result)
        elseif not tostring(result):startswith('[') and not tostring(result):startswith('{') then -- Если строка
            result = format_result(result)
        end

        result = tostring(result)

        id = id or 1

        return '{"jsonrpc": "2.0","result": ' .. result .. ',"id": ' .. tostring(id) ..'}'

end

return ResponseBuilder
local Json = require("cjson")
local SQL = require("/core/lib/funs_sql")
local Utils = require("/core/lib/utils")

local ResponseBuilder = require("/core/lib/prizm/response_builder")

ngx.var.service_name = 'dataset'

local function init(id, code_system, source_data, method_name, params)

    -- Инициализация параметров по умолчанию

    if Utils:is_array(params) then

        for _, param in pairs(params) do
            param._config_user_id = ngx.var.configUserId
            param._config_dataset = code_system .. '.' .. source_data
        end

    else

        params._config_user_id = ngx.var.configUserId
        params._config_dataset = code_system .. '.' .. source_data

    end

    -- Запись переменных в лог

    ngx.var.params = Json.encode(params);

    -- Запрос к БД

    local connect, status, code = SQL:createConnectionByConnectPG(Json.decode(ngx.var.connectPG))

    if not status then return connect, status, code end

    method_name = method_name:lower():gsub('data', '')  -- Определение имени функции

    if method_name ~= 'get' and method_name ~= 'update' and method_name ~= 'insert' and method_name ~= 'delete' then
        return 'Метод неверный', false
    end

    local result_query, status, code = SQL:get_query(connect,
            "SELECT r_json::text FROM config.pr_" .. method_name .. "_json_data(%s::text)",
            {ngx.var.params})

    if not status then return result_query, status, code end

    SQL:disconnect(connect)

    -- Формирование ответа

    local result = result_query[1].r_json

    return result, true
end


local pcall_status, status, result, id, code_system, source_data, method, params, code = pcall(ResponseBuilder.getBodyData, ngx)

if pcall_status and status then
    pcall_status, result, status, code = pcall(init, id, code_system, source_data, method, params)
end

ResponseBuilder:returnResult(pcall_status, result, status, id, code)
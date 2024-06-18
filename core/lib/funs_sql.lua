local PGmoon = require("pgmoon")

local Envs = require("/envs")

local SQL = {}

-- Отформатировать параметры
local function format_params(connect, query, params)

    local _, count_args = query:gsub("%%", "")

    for i=1, count_args do

        if params[i] == nil then
            params[i] = 'null'  -- Если nil
        else
            params[i] = tostring(params[i])  -- Перевод в строку
            params[i] = connect:escape_literal(params[i])  -- Экранирование
        end

    end

    return params
end

-- Получение коннекта к БД через connectPG
function SQL:createConnectionByConnectPG(connectPG, timeout)

    local connect = PGmoon.new(connectPG)

    local _, err = connect:connect()

    if err then
        return tostring(err) .. " (БД: " .. tostring(connectPG.database) .. ")", false, 'DB_CONNECTION_ERROR'
    end

    if not timeout then
        timeout = Envs.TIMEOUT_DB
    end

    connect:settimeout(timeout)

    return connect, true
end

-- Сбросить/Отключить соединение
function SQL:disconnect(connect)
    local function init()
        connect:disconnect()
    end
    pcall(init)
end

-- Выполнение запроса
function SQL:get_query(connect, query, params)

    if params ~= nil then
        params = format_params(connect, query, params)
        query = string.format(query, table.unpack(params))
    else

        local _, count_args = query:gsub("%%", "")

        if count_args > 0 then
            SQL:disconnect(connect)
            return tostring("Не были переданы все аргументы в процедуру"), false, 'DB_QUERY_EXECUTION_ERROR'
        end

    end

    local result_query, err = connect:query(query)

    if err ~= 1 then
        SQL:disconnect(connect)
        ngx.log(ngx.STDERR, "ERROR: Ошибка выполнения запроса: '" .. tostring(query) .. "' - " .. tostring(err))
        return tostring(err), false, 'DB_QUERY_EXECUTION_ERROR'
    end

    return result_query, true
end

return SQL
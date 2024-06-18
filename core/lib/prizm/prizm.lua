local Request = require ("/core/lib/prizm/request")
local Proxy = require("/core/lib/prizm/proxy") -- модуль обратного прокси-сервера, управление запросами к сервисам и агрегирование ответов
local ResponseBuilder = require("/core/lib/prizm/response_builder")

local Json = ResponseBuilder.Json

local Prizm = {}

--- Создание нового экземпляра Prizm
function Prizm:new()

    -- Определение мета-таблицы для объекта
    local obj = setmetatable({}, self)
    self.__index = self

    -- Инициализация полей
    obj.responses = {}

    return obj
end

--- Получить тело запроса
local function get_body()

    ngx.req.read_body() -- explicitly read the req body

    local result = ngx.req.get_body_data()

    -- Проверка наличия тела в запросе
    if result == nil then
        ngx.print(ResponseBuilder:build_json_error('ERR_EMPTY_REQUEST'))
        return ngx.exit(ngx.HTTP_OK)
    end

    return result
end

--- Парсинг исходного тела
local function get_decoded_body(body)

    local pcall_status, result = pcall(Json.decode, body)

    -- Проверка корректности декодирования
    if pcall_status == false then
        ngx.print(ResponseBuilder:build_json_error('ERR_INVALID_REQUEST'))
        return ngx.exit(ngx.HTTP_OK)
    end

    return result
end

--- Проверка, является ли запрос пакетным
local function is_batch_body(body)
    return string.sub(body, 1, 1) == "["
end

-----------

--- Получить запросы
local function get_requests(body, decoded_body, is_batch)

    local requests = {}

    if is_batch then

        for _, part_of_body in ipairs(decoded_body) do
            table.insert(requests, Request:new(Json.encode(part_of_body), part_of_body))
        end

    else
        table.insert(requests, Request:new(body, decoded_body))
    end

    return requests
end

--- Получение адреса для метода JSON-RPC
local function get_address(routes, method)

    local method_name = string.match(method, '[^.]+$')

    return routes[method_name]
end


--- Создание группы запросов, связанных с конечными точками
function Prizm:prepare_map_requests(routes, requests)

    local map_requests = {}

    for _, request in ipairs(requests) do

        if request:is_valid() then

            local addr = get_address(routes, request:get_method())

            if addr then
                map_requests[addr] = map_requests[addr] or {}
                table.insert(map_requests[addr], request)
            else
                table.insert(self.responses,  ResponseBuilder:build_json_error('ERR_METHOD_NOT_FOUND', nil, nil, request:get_id()))
            end

        else
            table.insert(self.responses, ResponseBuilder:build_json_error('ERR_INVALID_REQUEST', nil, nil, request:get_id()))
        end

    end

    return map_requests
end

--- Выполнение запросов приготовленных для вызова в ngx.location.capture_multi
function Prizm:run(proxy, map_requests)

    if next(map_requests) then
        proxy:do_requests(self.responses, map_requests)
    end

end

--- Получение ответов в виде строки
function Prizm:get_result(is_batch)

    if is_batch then
        return '[' .. table.concat(self.responses, ",") .. ']'
    end

    return self.responses[1]
end

--- Вывести результат выполнения запросов
local function print_result(responses)
    ngx.print(responses)
    ngx.exit(ngx.HTTP_OK)
end

--- Выполнение обработки запроса
function Prizm:main(routes)

    local function init()

        --- 1) Получение тела запроса

        local body = get_body()

        local decoded_body = get_decoded_body(body)

        local is_batch = is_batch_body(body)

        --- 2) Инициализация

        local proxy = Proxy:new(ResponseBuilder)

        local requests = get_requests(body, decoded_body, is_batch)  -- Получить запросы

        --- 3) Выполнение

        local rpcprizm = self:new()

        local map_requests = rpcprizm:prepare_map_requests(routes, requests)  -- Создание группы запросов, связанных с конечными точками

        rpcprizm:run(proxy, map_requests)

        local responses = rpcprizm:get_result(is_batch)

        --- 4) Вывести результат выполнения запросов

        print_result(responses)

    end

    local pcall_status, error_msg = pcall(init)

    if not pcall_status then
        ngx.print(ResponseBuilder:build_json_error('UNKNOWN_ERROR', nil, error_msg, 1))
        ngx.exit(ngx.HTTP_OK)
    end

    ngx.eof()
end

return Prizm
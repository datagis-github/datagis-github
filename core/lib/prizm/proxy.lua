local HttpStatuses = require ("/core/lib/prizm/http_statuses")

local Proxy = {}

--- Создание обратного прокси-сервера
function Proxy:new(response_builder)

    local obj = setmetatable({}, self)
    self.__index = self

    obj.response_builder = response_builder

    return obj
end

--- Проверка, является ли ответ корректным
local function is_valid_json(str)
    local first_char = string.sub(str, 1, 1)
    local last_char = string.sub(str, -1)

    return ('' ~= str) and (('{' == first_char or '[' == first_char) and ('}' == last_char or ']' == last_char))
end

--- Очистка ответа ("trim")
local function clean_response(response)
    local response_body = response.body or response
    return response_body:match'^()%s*$' and '' or response_body:match'^%s*(.*%S)'
end

--- Построение запросов в формате, приемлемом для nginx
local function get_ngx_request(addr, requests)

    local rpc_requests = {}

    for _, request in ipairs(requests) do
        table.insert(rpc_requests, request:get_body())
    end

    local body = ''

    if #requests > 1 then
        body = '[' .. table.concat(rpc_requests, ",") .. ']'
    else
        body = rpc_requests[1]
    end

    return { addr, {method = 8, body = body, args = ngx.req.get_uri_args(), ctx = ngx.ctx, vars = {}, share_all_vars = true, copy_all_vars = true} }
end

--- Построение запросов nginx из rpc-запросов
-- @param[type=table] map_requests Таблица rpc-запросов, связанных с конечными точками
-- @return[type=table] ngx_requests Массив запросов nginx к сервисам, каждый запрос может содержать несколько rpc-запросов
-- @return[type=table] request_groups Массив rpc-запросов, сгруппированных по конечным точкам для сопоставления с ответами сервисов
local function get_ngx_requests(map_requests)

    local ngx_requests = {}
    local request_groups = {}

    for addr, requests in pairs(map_requests) do
        table.insert(ngx_requests, get_ngx_request(addr, requests))
        table.insert(request_groups, {addr=addr, reqs=requests})
    end

    return ngx_requests, request_groups
end

--- Обработка ответов от сервисов
function Proxy:handle_responses(responses, ngx_responses, request_groups)

    for i, response in ipairs(ngx_responses) do

        --table.insert(responses, response.body)

        local resp_body = clean_response(response)

        if is_valid_json(resp_body) then
            table.insert(responses, resp_body)
        else

            local response_msg

            if ngx.HTTP_OK ~= response.status then
                response_msg = HttpStatuses[response.status] or 'Unknown error'
                response_msg = response.status .. ' ' .. response_msg
            end

            for _, request in ipairs(request_groups[i]['reqs']) do
                table.insert(responses, self.response_builder:build_json_error('ERR_SERVER_ERROR', response_msg, resp_body, request:get_id()))
            end

        end

    end

end

--- Отправка запросов к сервисам и обработка ответов
function Proxy:do_requests(responses, map_requests)

    local ngx_requests, request_groups = get_ngx_requests(map_requests)
    local ngx_responses = { ngx.location.capture_multi(ngx_requests) }
    self:handle_responses(responses, ngx_responses, request_groups)

end

return Proxy
local Request = {}

--- Создание запроса
function Request:new(body, decoded_body)

  -- Определение мета-таблицы для объекта
  local obj = setmetatable({}, self)
  self.__index = self

  -- Инициализация полей
  obj.body = body
  obj.decoded_body = decoded_body

  return obj
end

--- Проверка, является ли запрос корректным
function Request:is_valid()

  if self.valid == nil then
    self.valid = self.decoded_body.method ~= nil
  end

  return self.valid
end

--- Получить версию JSON-RPC
function Request:get_jsonrpc()
  return self.decoded_body.jsonrpc
end

--- Получить метод
function Request:get_method()
  return self.decoded_body.method
end

--- Получить параметры
function Request:get_params()
  return self.decoded_body.params
end

--- Получить ID
function Request:get_id()
  return self.decoded_body.id
end

--- Получить тело запроса
function Request:get_body()
  return self.body
end

return Request
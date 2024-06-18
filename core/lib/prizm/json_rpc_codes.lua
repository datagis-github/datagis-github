
local JSON_RPC_CODES = {

    -- DEFAULTS

    ERR_PARSE_ERROR = -32700, [-32700] = 'ERR_PARSE_ERROR',
    ERR_INVALID_REQUEST = -32600, [-32600] = 'ERR_INVALID_REQUEST',
    ERR_METHOD_NOT_FOUND = -32601, [-32601] = 'ERR_METHOD_NOT_FOUND',
    ERR_INVALID_PARAMS = -32602, [-32602] = 'ERR_INVALID_PARAMS',
    ERR_INTERNAL_ERROR = -32603, [-32603] = 'ERR_INTERNAL_ERROR',
    ERR_SERVER_ERROR = -32000, [-32000] = 'ERR_SERVER_ERROR',
    ERR_EMPTY_REQUEST = -32097, [-32097] = 'ERR_EMPTY_REQUEST',

    -- Из HTTP-CONTROL

    ACCESS_DENIED = -37000, [-37000] = 'ACCESS_DENIED',

    NO_DATA_METHOD = -37001, [-37001] = 'NO_DATA_METHOD',

    REDIS_CONNECTION_ERROR = -37002, [-37002] = 'REDIS_CONNECTION_ERROR',
    NO_TOKEN = -37003, [-37003] = 'NO_TOKEN',
    ERROR_IN_RIGHTS = -37004, [-37004] = 'ERROR_IN_RIGHTS',

    ERROR_RECEIVING_DATA_FROM_SESSION_SERVICE = -37005, [-37005] = 'ERROR_RECEIVING_DATA_FROM_SESSION_SERVICE',
    NO_DATA_IN_SERVICE_SESSION_BY_TOKEN = -37006, [-37006] = 'NO_DATA_IN_SERVICE_SESSION_BY_TOKEN',
    SESSION_EXPIRED = -37007, [-37007] = 'SESSION_EXPIRED',

    RIGHTS_NO_SERVICE_RIGHT = -37008, [-37008] = 'RIGHTS_NO_SERVICE_RIGHT',
    RIGHTS_NO_DATASETS = -37009, [-37009] = 'RIGHTS_NO_DATASETS',
    RIGHTS_NO_DATASET = -37010, [-37010] = 'RIGHTS_NO_DATASET',
    RIGHTS_NO_CONFIG_DATASET = -37015, [-37015] = 'RIGHTS_NO_CONFIG_DATASET',

    -- Другие

    DB_CONNECTION_ERROR = -37011, [-37011] = 'DB_CONNECTION_ERROR',
    DB_QUERY_EXECUTION_ERROR = -37012, [-37012] = 'DB_QUERY_EXECUTION_ERROR',

    RESTY_COOKIE_ERROR = -37013, [-37013] = 'RESTY_COOKIE_ERROR',
    REQUEST_ERROR = -37014, [-37014] = 'REQUEST_ERROR',

    UNKNOWN_ERROR = -37099, [-37099] = 'UNKNOWN_ERROR',

}

JSON_RPC_CODES.messages = {

    -- DEFAULTS

    [JSON_RPC_CODES.ERR_PARSE_ERROR] = 'Сервер получил недействительный JSON. На сервере произошла ошибка при разборе JSON',
    [JSON_RPC_CODES.ERR_INVALID_REQUEST] = 'Некорректное тело запроса',
    [JSON_RPC_CODES.ERR_METHOD_NOT_FOUND] = 'Указанный метод не найден',
    [JSON_RPC_CODES.ERR_INVALID_PARAMS] = 'Недействительные параметры метода',
    [JSON_RPC_CODES.ERR_INTERNAL_ERROR] = 'Внутренняя ошибка JSON-RPC',
    [JSON_RPC_CODES.ERR_SERVER_ERROR] = 'Серверная ошибка. Некорректный ответ JSON-RPC.',
    [JSON_RPC_CODES.ERR_EMPTY_REQUEST] = 'Пустой запрос',

    -- Из HTTP-CONTROL

    [JSON_RPC_CODES.ACCESS_DENIED] = 'Ошибка доступа к сервису',

    [JSON_RPC_CODES.REDIS_CONNECTION_ERROR] = 'Ошибка подключения к redis',
    [JSON_RPC_CODES.NO_TOKEN] = 'Нет токена или токен не имеет значения',
    [JSON_RPC_CODES.ERROR_IN_RIGHTS] = 'Ошибка в данных прав',

    [JSON_RPC_CODES.ERROR_RECEIVING_DATA_FROM_SESSION_SERVICE] = 'Ошибка получения данных из сервиса сессий',
    [JSON_RPC_CODES.NO_DATA_IN_SERVICE_SESSION_BY_TOKEN] = 'Нет данных в сервисе сессий по полученному токену',
    [JSON_RPC_CODES.SESSION_EXPIRED] = 'Сессия токена истекла',

    [JSON_RPC_CODES.RIGHTS_NO_SERVICE_RIGHT] = 'Нет доступа к сервису',
    [JSON_RPC_CODES.RIGHTS_NO_CONFIG_DATASET] = 'Нет доступа к датасету',
    [JSON_RPC_CODES.RIGHTS_NO_DATASETS] = 'В правах пользователя нет датасетов',
    [JSON_RPC_CODES.RIGHTS_NO_DATASET] = 'В правах пользователя нет указанного датасета',

    -- Другие

    [JSON_RPC_CODES.DB_CONNECTION_ERROR] = 'Ошибка подключения к БД',
    [JSON_RPC_CODES.DB_QUERY_EXECUTION_ERROR] = 'Ошибка выполнения запроса в БД',

    [JSON_RPC_CODES.RESTY_COOKIE_ERROR] = 'Ошибка получения cookie',

    [JSON_RPC_CODES.REQUEST_ERROR] = 'Ошибка выполнения запроса',

    [JSON_RPC_CODES.UNKNOWN_ERROR] = 'Ошибка выполнения метода',

}

function JSON_RPC_CODES:get_code(short_desc_code)

    local code = JSON_RPC_CODES[short_desc_code]

    return code
end

return JSON_RPC_CODES


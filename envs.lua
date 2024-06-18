local Envs = {

    SESSION_TIME = 1440, -- Время сессии в минутах
    TIMEOUT_DB = 75000,  -- Время запроса в БД в миллисекундах
    REDIS_KEYS_TTL = 172800, -- Время жизни ключей редиса в секундах

    REDIS_KEYS_EXPIRE = true, -- Истечение срока действия ключей редиса по времени

    connect = {

        POSTGRES_CONNECTIONS = {
            name = "БД connections",
            str = {
                host = "",
                port = "",
                database = "",
                user = "",
                password = ""
            }
        },

        CONFIG_DSCONFIG = {
            name = "БД dsconfig",
            str = {
                host = "",
                port = "",
                database = "",
                user = "",
                password = ""
            }
        },

        REDIS = {
            name = "Redis",
            str = {
                host = "",
                port = "",
                pass = ""
            }
        },

    }

}


function Envs:is(code_system)
    return Envs.connect[string.upper(code_system)] ~= nil
end

function Envs:get(code_system)
    return Envs.connect[string.upper(code_system)].str
end

function Envs:getName(code_system)
    return Envs.connect[string.upper(code_system)].name
end

return Envs

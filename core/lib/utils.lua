local Utils = {}

--- Проверки

-- Таблица - массив?
function Utils:is_array(t)

	if t == nil or type(t) ~= "table" then
		return false
	end

	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then return false end
	end

	return true
end

--- Работа со строками

function Utils:split(text, sep)

	local result = {}

	for value in string.gmatch(text, "([^"..sep.."]+)") do
		table.insert(result, value)
	end

	return result
end

return Utils

class("Utils").extends()

function Utils:init()
    Utils.super.init(self)
end

function Utils:enum_values(t)
    local values = {}
    for _, v in pairs(t) do table.insert(values, v) end
    return values
end
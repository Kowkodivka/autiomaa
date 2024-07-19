local fs = require("fs")

function string.split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local handler = {}

handler.prefixes = {"norka!"}
handler.commands = {}
handler.commands_path = "./modules/commands"

function handler.load_commands()
    for _, filename in ipairs(fs.readdirSync(handler.commands_path)) do
        if filename:sub(-4) == ".lua" then
            local data = require("./commands/" .. filename)
            local name, extension = filename:match("(.+)(%.%w+)$")
            if extension then
                handler.commands[name] = data
                print("Loaded command: " .. filename)
            end
        end
    end
end

function handler.parse_command(content)
    local command = {
        name = nil,
        arguments = {}
    }

    local parts = content:split(" ")

    command.name = parts[1]

    local i = 2
    while i <= #parts do
        local part = parts[i]
        if part:sub(1, 2) == "--" then
            local key = part:sub(3)
            local value = ""
            i = i + 1

            while i <= #parts and parts[i]:sub(1, 2) ~= "--" do
                value = value .. parts[i] .. " "
                i = i + 1
            end

            value = value:sub(1, -2)

            command.arguments[key] = value
        end
    end

    return command
end

function handler.validate_arguments(command, options)
    local valid = true

    for _, option in ipairs(options) do
        if option.required and not command.arguments[option.name] then
            valid = false
            break
        end
        if command.arguments[option.name] then
            if option.type == "number" and not tonumber(command.arguments[option.name]) then
                valid = false
                break
            end
        end
    end

    return valid
end

function handler.handle_message(message)
    if message.user == _G.client.user then return end

    local context = {
        user = message.user,
        channel = message.channel,
        command = nil
    }

    for _, prefix in ipairs(handler.prefixes) do
        if message.content:sub(1, #prefix) == prefix then
            context.command = handler.parse_command(message.content:sub(#prefix + 1))
            break
        end
    end

    if context.command then
        if handler.commands[context.command.name] then
            local target = handler.commands[context.command.name]
            if handler.validate_arguments(context.command, target.options) then
                target.run(context)
            else
                context.channel:send("Invalid arguments.")
            end
        else
            return
        end
    end
end

return handler
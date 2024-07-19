return {
    description = "Outputs a list of available commands.",
    category = "System",
    options = {},
    run = function (context)
        local message = "**Available commands:**\n"
        for command_name, command in pairs(_G["handler"].commands) do
            message = message .. "**` " .. command_name .. " `** - " .. command.description
            if #command.options > 0 then
                message = message .. "\n  - **Options:**\n"
                for option_name, option in pairs(command.options) do
                    message = message .. "     - `" .. option_name .. "` (" .. option.type .. ") - " .. option.description .. "\n"
                end
            end
            message = message .. "\n"
        end
        context.channel:send(message)
    end
}

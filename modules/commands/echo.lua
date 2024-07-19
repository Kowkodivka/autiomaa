return {
    description = "Responds to a message with your own message.",
    category = "System",
    options = {
        ["content"] = {
            description = "Message content.",
            type = "string",
            required = true
        }
    },
    run = function (context)
        context.channel:send(context.command.arguments["content"])
    end
}
return {
    name = "messageCreate",
    run = function(message)
        _G["handler"].handle_message(message)
    end
}
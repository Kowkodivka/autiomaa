return {
    name = "ready",
    run = function()
        print("Logged in as " .. _G.client.user.username)
        _G["handler"].load_commands()
    end
}
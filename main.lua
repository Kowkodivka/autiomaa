local fs = require("fs")
local json = require("json")
local discordia = require("discordia")

local function load_config(filename)
    local file = io.open(filename, "r")
    if not file then error("Failed to open the configuration file: " .. filename) end
    local content = file:read("*a")
    file:close()
    return json.decode(content)
end

local modules_path = "./modules"
local events_path = "./events"

local config = load_config("./config.json")
_G.config = config

local client = discordia.Client()
client:enableIntents(discordia.enums.gatewayIntent.messageContent)

_G.client = client

for _, filename in ipairs(fs.readdirSync(modules_path)) do
    if filename:sub(-4) == ".lua" then
        local data = require(modules_path .. "/" .. filename)
        local name, extension = filename:match("(.+)(%.%w+)$")
        if extension then
            _G[name] = data
            print("Loaded module: " .. filename)
        end
    end
end

for _, filename in ipairs(fs.readdirSync(events_path)) do
    if filename:sub(-4) == ".lua" then
        local event_data = require(events_path .. "/" .. filename)
        client:on(event_data["name"], function (...) event_data["run"](...) end)
        print("Loaded event: " .. filename)
    end
end

client:run(config["token"])
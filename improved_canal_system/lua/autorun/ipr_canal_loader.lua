-- Script By Inj3
-- https://steamcommunity.com/id/Inj3/
local ipr_PLoader = {
    {
        configsys = {
            file = "improved_canal_system/configuration/*",
            text = "Configuration",
            send = {
                addcs = true,
                include = true,
            }
        }
    },
    {
        clientsys = {
            file = "improved_canal_system/ipr_lua_client/*",
            text = "Client",
            send = {
                addcs = true,
                include = false,
            }
        }
    },
    {
        serversys = {
            file = "improved_canal_system/ipr_lua_server/*",
            text = "Server",
            only_sv = true,
            send = {
                addcs = false,
                include = true,
            }
        }
    },
}
ipr_PLoader.Script = "Improved Canal System"
ipr_PLoader.Version = "1.1"

local function ipr_SendFile(tbl, tbl_)
    local ipr_tb = tbl.file
    local ipr_find = string.find(ipr_tb, "*")
    if (ipr_find) then
        ipr_tb = string.Replace(ipr_tb, "*", "")
    else
        tbl_ = ""
    end

    if (CLIENT) then
        include(ipr_tb.. "" ..tbl_)
        return
    end
    if (tbl.send.include) then
        include(ipr_tb.. "" ..tbl_)
    end
    if (tbl.send.addcs) then
        AddCSLuaFile(ipr_tb.. "" ..tbl_)
    end
end

local ipr_tx = {
    s = SERVER and "SERVER" or "CLIENT",
    c = SERVER and Color(3, 169, 244) or Color(222, 169, 9),
}

local function ipr_AddFile(tbl)
    local ipr_find = file.Find(tbl.file, "LUA")
    local ipr_find_c = #ipr_find
    local ipr_ex = tbl.ex

    if (CLIENT and tbl.only_sv) then
        return
    end
    for c, f in ipairs (ipr_find) do
        if (c == 1) then
            MsgC(ipr_tx.c, "\nFile found [" ..tbl.text.. "] :")
        end
        local ipr_m = ipr_ex and 100 or math.Round((c/ipr_find_c) * 100)
        MsgC(ipr_tx.c, "\n-> File loading " ..f.. " - " ..c.."/" ..ipr_find_c.." - 100% - progress : " ..ipr_m.. "%")

        if (ipr_ex ~= nil) then
            if (f ~= ipr_ex) then
                continue
            else
                ipr_SendFile(tbl, f)
                MsgC(ipr_tx.c, "\n" ..ipr_PLoader.Script.. " " ..tbl.text.. " - " ..ipr_tx.s.. " - 1 file(s) loaded correctly \n")
                break
            end
        end

        ipr_SendFile(tbl, f)
        if (c == ipr_find_c) then
            MsgC(ipr_tx.c, "\n" ..ipr_PLoader.Script.. " " ..tbl.text.. " - " ..ipr_tx.s.. " - " ..ipr_find_c.. " file(s) loaded correctly \n")
        end
    end
end

if (SERVER) then
    resource.AddFile( "resource/fonts/Rajdhani-Bold.ttf" )
else
    surface.CreateFont("ipr_font_canal", {
        font = "Rajdhani Bold",
        size = 16,
        weight = 200,
        antialias = true,
    })
end

MsgC(ipr_tx.c, "\n\n" ..ipr_PLoader.Script.. " - loading files in progress.. Please Wait\n-----------" )
ipr_CanalGroup = ipr_CanalGroup or {}
for _, func in ipairs(ipr_PLoader) do
    for _, d in pairs(func) do
        ipr_AddFile(d)
    end
end
MsgC(ipr_tx.c, "-----------\n" ..ipr_PLoader.Script.. " v" ..ipr_PLoader.Version.. " by Inj3 \n" )
ipr_PLoader = nil

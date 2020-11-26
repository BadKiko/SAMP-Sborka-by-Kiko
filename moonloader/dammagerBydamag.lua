damage = 0
damag = 5.28

function main()
    repeat wait(0) until isSampAvailable()
    msg("damager | /admg")
    sampRegisterChatCommand("admg", admg)
    wait(-1)
end

function admg(param)
    lua_thread.create(function()
        if param ~= "" and param:match("%d") then
            for i = 0, 25 do
                damage = damage + 5.28
                math.randomseed(os.time()); dw = math.random(3,9)
                printStringNow("~Y~iTarget: ~S~"..param.."~n~~Y~iDamage: ~S~"..damage.."~n~~Y~iCount: ~S~"..i, 1500)
                sampSendGiveDamage(param, damag, 0, dw)
                wait(228)
            end
            damage = 0
        else
            msg("error param")
        end
    end)
end

function msg(text)
    return sampAddChatMessage(text, -1)
end
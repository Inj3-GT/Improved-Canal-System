-- Script By Inj3
-- https://steamcommunity.com/id/Inj3/
util.AddNetworkString("ipr_channels_status")
util.AddNetworkString("ipr_channels_update")
util.AddNetworkString("ipr_channels_close")
 
local ipr_Channels, ipr_Queue = {}, "ipr_queue"
local function ipr_UpdateTable(k, p, u)
    if not ipr_Channels[k] then
        ipr_Channels[k] = {}
    end
    if not u then
        u = ipr_Queue --- Queued for update
    end
    if not ipr_Channels[k][u] then
        ipr_Channels[k][u] = {}
        if (u ~= ipr_Queue) then
        ipr_Channels[k][u].Locked = false
        end
    end
    if not ipr_Channels[k][u][p] then
        ipr_Channels[k][u][p] = {}
    end
end
 
local function ipr_Allowkey(p, x, t)
    local ipr_PSearch = p.ipr_Channel.pkey
    local ipr_ChannelAllow = ipr_CanalGroup.Allowed[ipr_PSearch]

    if (ipr_ChannelAllow) then
        local ipr_PSelect = {[1] = "exclude_channels", [2] = "can_lock_channels"}
        local ipr_PGroup = p:GetUserGroup()
        ipr_PSelect = ipr_PSelect[x]

        if (ipr_ChannelAllow.Permissions.job[t].rank_access[ipr_PGroup] or ipr_ChannelAllow.Permissions.job[t][ipr_PSelect]) then
            return true
        end
    end
    return false
end

local function ipr_CountNotSeq(v)
    local i = 0
    if (v) then
        for _, x in pairs(v) do
            if not istable(x) then
                continue
            end
            i = i + 1
        end
    end
    return i
end

local function ipr_ClearTable(p)
    local ipr_PSearch = p.ipr_Channel.pkey
    local ipr_PKey = ipr_Channels[ipr_PSearch]
    if not ipr_PKey then
        return
    end

    local ipr_PRank = false
    for x, y in pairs(ipr_PKey) do
        for i in pairs(y) do
            if not IsValid(i) then
               continue
            end
            if (i == p) then
                ipr_PKey[x][p] = nil
                continue
            end
            if not ipr_PRank then
                local ipr_PTeam = team.GetName(i:Team())
                if ipr_Allowkey(i, 2, ipr_PTeam) then
                    ipr_PRank = true
                end
            end
        end
        if not ipr_PRank then
            ipr_PKey[x].Locked = false
        end
        local ipr_c = ipr_CountNotSeq(y)
        if (ipr_c == 0) then
            ipr_PKey[x] = nil
        end
    end
    if (ipr_CountNotSeq(ipr_PKey) == 0) then
        ipr_Channels[ipr_PSearch] = nil
    end
end

local function ipr_SendToPlayer(k, p, j)
    local ipr_PKey = ipr_Channels[k]

    net.Start("ipr_channels_update")
    net.WriteUInt(k, 6)
    net.WriteUInt(1, 1)
    net.WriteTable(ipr_PKey)
    net.WriteString(j)
    net.Send(p)
end

local function ipr_SendOmit(p)
    local ipr_PSearch  = p.ipr_Channel.pkey
    local ipr_PKey = ipr_Channels[ipr_PSearch]
    if not ipr_PKey then
        return
    end

    for _, y in pairs(ipr_PKey) do
        for x in pairs(y) do
            if not IsValid(x) then
               continue
            end

            net.Start("ipr_channels_update")
            net.WriteUInt(ipr_PSearch, 6)
            net.WriteUInt(0, 1)
            net.WriteTable(ipr_PKey)
            net.Send(x)
        end
    end
end

local function ipr_Update(k, p, u)
    p.ipr_Channel = {pkey = k, pcanal = not u and ipr_Queue or u}
    -----
    ipr_ClearTable(p)
    ipr_UpdateTable(k, p, u)
    ipr_SendOmit(p)
end

local function ipr_ClosePanel(p)
    net.Start("ipr_channels_close")
    net.Send(p)
end

do
    local ipr_TblGroup, ipr_TblCount = {}, 0
    for k, v in ipairs(ipr_CanalGroup.Allowed) do
        for i, d in pairs(v.Permissions.job) do
            ipr_TblCount = ipr_TblCount + 1

            ipr_TblGroup[ipr_TblCount] = {}
            ipr_TblGroup[ipr_TblCount][i] = true
            ipr_TblGroup[ipr_TblCount].j = k
        end
    end
    hook.Add("OnPlayerChangedTeam", "ipr_Channels_ChangedTeam", function(ply, oldTeam, newTeam)
        local ipr_Count = #ipr_TblGroup
        newTeam = team.GetName(newTeam)

        for k, v in ipairs(ipr_TblGroup) do
            if v[newTeam] then
                if (ply.ipr_Channel) then
                    ipr_ClearTable(ply)
                    ipr_ClosePanel(ply)
                    ipr_SendOmit(ply)
                end
                ipr_UpdateTable(v.j, ply, nil)
                ipr_SendToPlayer(v.j, ply, newTeam)
                ply.ipr_Channel = {pkey = v.j, pcanal = ipr_Queue}
                break
            end
            if (k == ipr_Count) and ply.ipr_Channel then
                ipr_ClearTable(ply)
                ipr_ClosePanel(ply)
                ipr_SendOmit(ply)
                ply.ipr_Channel = nil
            end
        end
    end)
end

local ipr_Channel_AntiSpam = {}
hook.Add("PlayerDisconnected", "ipr_Channels_Disconnected", function(ply)
    if (ply.ipr_Channel) then
        ipr_ClearTable(ply)
        ipr_SendOmit(ply)

        if (ipr_Channel_AntiSpam[ply]) then
            ipr_Channel_AntiSpam[ply] = nil
        end
    end
end)

local function ipr_CanalVoice(listener, talker)
    if (talker.ipr_Channel) then
        local ipr_PFindKey, ipr_PFindCanal = ipr_Channels[talker.ipr_Channel.pkey], listener.ipr_Channel.pcanal
        ipr_PFindCanal = (ipr_PFindCanal ~= ipr_Queue) and ipr_PFindCanal or false

        local ipr_PFindVoice = (ipr_PFindKey and ipr_PFindCanal)
        if (ipr_PFindVoice) then
            if ipr_PFindKey[ipr_PFindCanal][talker] and ipr_PFindKey[ipr_PFindCanal][listener] then
                if not talker.ipr_ChanMic and not listener.ipr_GChan then
                    return true
                end
            end
        end
    end
end

local function ipr_CanalAntiSpam(ply)
    if not IsValid(ply) then
        return false
    end

    local ipr_cur = CurTime()
    if (ipr_Channel_AntiSpam[ply]) then
        if (ipr_cur <= ipr_Channel_AntiSpam[ply].cur) then
            return false, ply:ChatPrint("Un message réseau est déjà en cours, veuillez patientez " ..math.Round(ipr_Channel_AntiSpam[ply].cur - ipr_cur, 1).. " secondes !")
        end

        if (ipr_cur > ipr_Channel_AntiSpam[ply].cur) then
            ipr_Channel_AntiSpam[ply] = nil
        end
    end

    if not ipr_Channel_AntiSpam[ply] then
        ipr_Channel_AntiSpam[ply] = {}
        ipr_Channel_AntiSpam[ply].cur = ipr_cur + ipr_CanalGroup.AntiSpam
        return true
    end
end

local function ipr_CanalChange(len, ply)
    if not IsValid(ply) or not ipr_CanalAntiSpam(ply) then
        return
    end
    local ipr_Pkey, ipr_PCanal = ply.ipr_Channel.pkey, ply.ipr_Channel.pcanal
    if not ipr_Channels[ipr_Pkey] or not ipr_Channels[ipr_Pkey][ipr_PCanal] then
        return
    end

    local ipr_Int = net.ReadUInt(3)
    local ipr_Team = team.GetName(ply:Team())
    if (ipr_Int == 1) then
        local ipr_Int_ = net.ReadUInt(1)
        local ipr_String = net.ReadString()
        local ipr_ForcedLimit = ipr_Allowkey(ply, 1, ipr_Team)

        if (ipr_Int_ == 0) then
            ipr_Update(ipr_Pkey, ply, nil)
            return
        else
            if not ipr_ForcedLimit and ipr_Channels[ipr_Pkey][ipr_String] and ipr_Channels[ipr_Pkey][ipr_String].Locked then
                return ply:ChatPrint(ipr_CanalGroup.Lang.Lock_channel)
            end
        end

        local ipr_c = ipr_CountNotSeq(ipr_Channels[ipr_Pkey][ipr_String])
        for k, v in ipairs(ipr_CanalGroup.Allowed[ipr_Pkey].Channels) do
            if (v.Title ~= ipr_String) then
                continue
            end

            if not ipr_ForcedLimit and (ipr_c >= v.Limit_Access) then
                ply:ChatPrint(ipr_CanalGroup.Lang.Limit_exceeded)
            else
                ipr_Update(ipr_Pkey, ply, ipr_String)
            end
        end
    elseif (ipr_Int == 2) then
        local ipr_EntityExclude = net.ReadPlayer()
        if not IsValid(ipr_EntityExclude) then
            return
        end
        local ipr_EntCanal = ipr_EntityExclude.ipr_Channel.pcanal
        if (ipr_EntCanal ~= ipr_PCanal) then
            return ply:ChatPrint(ipr_CanalGroup.Lang.Channel_not_Correspond)
        end
        local ipr_PTeam_Exclude = team.GetName(ipr_EntityExclude:Team())
        if ipr_Allowkey(ipr_EntityExclude, 1, ipr_PTeam_Exclude) then
            return ply:ChatPrint(ipr_CanalGroup.Lang.Channel_not_Exclude)
        end
        local ipr_EntKey = ipr_CanalGroup.Allowed[ipr_EntityExclude.ipr_Channel.pkey]
        if not ipr_EntKey or not ipr_EntKey.Permissions.job[ipr_PTeam_Exclude] then
            return ply:ChatPrint(ipr_CanalGroup.Lang.Channel_not_Authorized)
        end

        ipr_Update(ipr_Pkey, ipr_EntityExclude, nil)
        ply:ChatPrint(ipr_CanalGroup.Lang.Exclude_Player.. " " ..ipr_EntityExclude:Nick())
    elseif (ipr_Int == 3) then
        if not ipr_Allowkey(ply, 2, ipr_Team) then
            return ply:ChatPrint(ipr_CanalGroup.Lang.Channel_not_Lock)
        end
        local ipr_String = net.ReadString()
        local ipr_Bool = net.ReadBool()
        if not ipr_Channels[ipr_Pkey] or not ipr_Channels[ipr_Pkey][ipr_String] then
            return ply:ChatPrint(ipr_CanalGroup.Lang.Channel_Join)
        end
        ipr_Channels[ipr_Pkey][ipr_String].Locked = ipr_Bool
        ipr_Bool = ipr_Bool and "verrouillé" or "déverrouillé"
        
        ipr_SendOmit(ply)
        ply:ChatPrint("Le canal est maintenant " ..ipr_Bool.. " !")
    elseif (ipr_Int == 4) then
        if not ipr_CanalGroup.Allowed[ipr_Pkey] or not ipr_CanalGroup.Allowed[ipr_Pkey].Permissions.job[ipr_Team] then
            return ply:ChatPrint(ipr_CanalGroup.Lang.No_permission)
        end

        local ipr_Int, ipr_PMic, ipr_GCh = net.ReadUInt(1), ply.ipr_ChanMic, ply.ipr_GChan
        if (ipr_Int == 0) then
            local ipr_MicEmit = net.ReadUInt(1)
            ipr_PMic = (ipr_MicEmit == 0)
            if ply.ipr_GChan then
                ply.ipr_GChan = false
            end
            ply.ipr_ChanMic = ipr_PMic
        elseif (ipr_Int == 1) then
            local ipr_CanalMuted = net.ReadUInt(1)
            ipr_GCh = (ipr_CanalMuted == 0)
            if not ply.ipr_ChanMic then
               ply.ipr_ChanMic = true
            end
            ply.ipr_GChan = ipr_GCh
        end

        net.Start("ipr_channels_status")
        net.WriteUInt(not ply.ipr_ChanMic and 1 or 0, 1)
        net.WriteUInt(not ply.ipr_GChan and 1 or 0, 1)
        net.Send(ply)
    end
end

net.Receive("ipr_channels_status", ipr_CanalChange)
hook.Add("PlayerCanHearPlayersVoice", "ipr_Channels_Voice", ipr_CanalVoice)

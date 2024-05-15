-- Script By Inj3
-- https://steamcommunity.com/id/Inj3/
local ipr, ipr_Csw, ipr_Csh, ipr_Channel = {}, ScrW(), ScrH()
ipr.Font = "ipr_font_canal"
ipr.MaxChar = 20

hook.Add("OnScreenSizeChanged", "ipr_Canal_ChangeRes", function()
    ipr_Csw, ipr_Csh = ScrW(), ScrH()
end)

local function Ipr_CreateBlur(gui, col, br)
    if not IsValid(gui) then
        return
    end
    surface.SetDrawColor(ipr.Color.white_rgb.r, ipr.Color.white_rgb.g, ipr.Color.white_rgb.b)
    surface.SetMaterial(ipr.Mat.blur)

    local ipr_Posx, ipr_Posy = gui:LocalToScreen(0, 0)
    ipr.Mat.blur:SetInt("$blur", 2)
    ipr.Mat.blur:Recompute()
    render.UpdateScreenEffectTexture()

    surface.DrawTexturedRect(-ipr_Posx, -ipr_Posy, ipr_Csw, ipr_Csh)
    local ipr_Gwide, ipr_GTall = gui:GetWide(), gui:GetTall()
    draw.RoundedBoxEx(br, 0, 0, ipr_Gwide, ipr_GTall, col, true, true, true, true)
end
 
local function ipr_CreateVgui(ply, seq, pos)
    local ipr_TitleBut = vgui.Create("DLabel")
    local Ipr_VguiOption = vgui.Create("DImageButton")
    local ipr_ParentScroll = vgui.Create("DScrollPanel")
    local ipr_EnableDisableMic = vgui.Create("DButton")
    local ipr_MuteCanal = vgui.Create("DButton")
    local ipr_PosW, ipr_PosH = pos, 10

    ipr_TitleBut:SetPos(ipr_PosW, ipr_PosH)
    local ipr_PSizeW, ipr_PSizeH = 200, 20
    ipr_TitleBut:SetSize(ipr_PSizeW, ipr_PSizeH)
    ipr_TitleBut:SetText("")
    ipr_TitleBut.Paint = function(self, w, h)
        Ipr_CreateBlur(self, ipr_CanalGroup.Allowed[seq].Colors.Canal, 7)
        draw.SimpleText(ipr_CanalGroup.Allowed[seq].Title_Channel, ipr.Font, w / 2 + 5, 3, color_white, TEXT_ALIGN_CENTER)
    end
    ipr_TitleBut.OnRemove = function()
        if IsValid(Ipr_VguiOption) then
            Ipr_VguiOption:Remove()
        end
        if IsValid(ipr_EnableDisableMic) then
            ipr_EnableDisableMic:Remove()
        end
        if IsValid(ipr_MuteCanal) then
            ipr_MuteCanal:Remove()
        end
        if IsValid(ipr_ParentScroll) then
            ipr_ParentScroll:Remove()
        end
    end
    ipr_Channel = not ipr_Channel and {} or ipr_Channel
    ipr_PosH = ipr_PosH + ipr.Setting.Vgui_SP

    Ipr_VguiOption:SetPos(ipr_PosW + 90, ipr_PosH)
    Ipr_VguiOption:SetSize(19, 19)
    Ipr_VguiOption:SetImage(ipr.Mat.option)
    local ipr_Status = true
    Ipr_VguiOption.DoClick = function()
        local ipr_Derma = DermaMenu()
        local ipr_Derma_Hide = ipr_Derma:AddOption(ipr_Status and ipr_CanalGroup.Lang.Hide_channels or ipr_CanalGroup.Lang.display_channels, function()
            ipr_Status = not ipr_Status
            for _, v in pairs(ipr_Channel) do
                local ipr_vgui = v.ipr_VguiParent
                if not IsValid(ipr_vgui) then
                   continue
                end

                if (ipr_vgui.Height) then
                    ipr_vgui:SetPos(0, ipr_vgui.Height)
                    ipr_vgui.Height = nil
                end
                ipr_vgui:SetVisible(ipr_Status)
            end
            Ipr_VguiOption:SetImage(ipr_Status and ipr.Mat.option or ipr.Mat.option_enable)
            ipr_ParentScroll:Rebuild()
        end)
        ipr_Derma_Hide:SetIcon(ipr_Status and ipr.Mat.hide_channels or ipr.Mat.display_channels)
        ipr_Derma:AddSpacer()
        local ipr_Derma_HOnly = ipr_Derma:AddOption(ipr_Status and ipr_CanalGroup.Lang.Show_channels or ipr_CanalGroup.Lang.ShowAll_channels, function()
            if not ipr.VguiOpen then
                return ply:ChatPrint(ipr_CanalGroup.Lang.Join_HideChannel)
            end
            ipr_Status = not ipr_Status
            for _, v in pairs(ipr_Channel) do
                local ipr_vgui = v.ipr_VguiParent
                if not IsValid(ipr_vgui) then
                   continue
                end
                if (ipr_vgui.Height) then
                    ipr_vgui:SetPos(0, ipr_vgui.Height)
                    ipr_vgui.Height = nil
                    continue
                end

                if not ipr_Status and (ipr_vgui.Title == ipr.VguiOpen) then
                    local _, vgui_pos = ipr_vgui:GetPos()
                    ipr_vgui.Height = vgui_pos
                    ipr_vgui:SetPos(0, 0)
                else
                    ipr_vgui:SetVisible(ipr_Status)
                end
            end
            Ipr_VguiOption:SetImage(ipr_Status and ipr.Mat.option or ipr.Mat.option_enable)
            ipr_ParentScroll:Rebuild()
        end)
        ipr_Derma_HOnly:SetIcon(ipr_Status and ipr.Mat.show_channels or ipr.Mat.showAll_channels)
        ipr_Derma:Open()
    end

    ipr_EnableDisableMic:SetPos(ipr_PosW, ipr_PosH)
    ipr_EnableDisableMic:SetSize(85, 20)
    ipr_EnableDisableMic:SetText("")
    ipr_EnableDisableMic.Paint = function(self, w, h)
        Ipr_CreateBlur(self, ipr_CanalGroup.Allowed[seq].Colors.Canal, 5)
        draw.SimpleText(not ipr.Setting.MicMuted and ipr_CanalGroup.Lang.Mic_On or ipr_CanalGroup.Lang.Mic_Off, ipr.Font, w / 2 + 5, 3, not ipr.Setting.MicMuted and ipr.Color.green or ipr.Color.red, TEXT_ALIGN_CENTER)
    end
    ipr_EnableDisableMic.LFunc = function(b)
        ipr_EnableDisableMic:SetImage(not b and ipr.Mat.enablemic or ipr.Mat.disablemic)
        ipr.Setting.MicMuted = b
    end
    ipr_EnableDisableMic.DoClick = function()
        net.Start("ipr_channels_status")
        net.WriteUInt(4, 3)
        net.WriteUInt(0, 1)
        net.WriteUInt(not ipr.Setting.MicMuted and 0 or 1, 1)
        net.SendToServer()
    end

    ipr_MuteCanal:SetPos(ipr_PosW + 115, ipr_PosH)
    ipr_MuteCanal:SetSize(85, 20)
    ipr_MuteCanal:SetText("")
    ipr_MuteCanal.Paint = function(self, w, h)
        Ipr_CreateBlur(self, ipr_CanalGroup.Allowed[seq].Colors.Canal, 5)
        draw.SimpleText(not ipr.Setting.CanalMuted and ipr_CanalGroup.Lang.Channel_On or ipr_CanalGroup.Lang.Channel_Off, ipr.Font, w / 2 + 5, 3, not ipr.Setting.CanalMuted and ipr.Color.green or ipr.Color.red, TEXT_ALIGN_CENTER)
    end
    ipr_MuteCanal.LFunc = function(b)
        ipr_MuteCanal:SetImage(not b and ipr.Mat.unmutechannel or ipr.Mat.mutechannel)
        ipr.Setting.CanalMuted = b
    end
    ipr_MuteCanal.DoClick = function()
        net.Start("ipr_channels_status")
        net.WriteUInt(4, 3)
        net.WriteUInt(1, 1)
        net.WriteUInt(not ipr.Setting.CanalMuted and 0 or 1, 1)
        net.SendToServer()
    end

    ipr_ParentScroll:SetSize(ipr_PSizeW + 10, 300)
    ipr_ParentScroll:SetPos(ipr_PosW, ipr_PosH + ipr.Setting.Vgui_SP)
    local ipr_ParentScroll_vBar = ipr_ParentScroll:GetVBar()
    ipr_ParentScroll_vBar:SetWidth(5)
    function ipr_ParentScroll_vBar.btnUp:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, ipr.Color.red)
    end
    function ipr_ParentScroll_vBar.btnDown:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, ipr.Color.red)
    end
    function ipr_ParentScroll_vBar.btnGrip:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, ipr.Color.blue)
    end

    local ipr_CanalJoin = {
        [ipr_CanalGroup.Lang.Join_Channel] = true,
        [ipr_CanalGroup.Lang.Full] = true,
    }
    for _, v in ipairs(ipr_CanalGroup.Allowed[seq].Channels) do
        local ipr_VguiParent = vgui.Create("DPanel", ipr_ParentScroll)
        local ipr_ChildBut = vgui.Create("DButton", ipr_VguiParent)
        local ipr_Lock = vgui.Create("DImageButton", ipr_VguiParent)

        ipr_VguiParent:SetWidth(ipr_PSizeW)
        ipr_VguiParent.Title = v.Title
        ipr_VguiParent.PlayerInCanal = 0
        ipr_VguiParent.Paint = function(self, w, h)
            Ipr_CreateBlur(self, ipr_CanalGroup.Allowed[seq].Colors.Canal, ipr_CanalGroup.Allowed[seq].Colors.Canal_BoxRounded)
            draw.SimpleText("Canal " ..self.Title, ipr.Font, 5, 4, color_white, TEXT_ALIGN_LEFT)
            draw.SimpleText(not ipr_Lock.LockStatus and ipr_CanalGroup.Lang.Lock or ipr_CanalGroup.Lang.Unlock, ipr.Font, w- 18, 3, not ipr_Lock.LockStatus and ipr.Color.green or ipr.Color.red, TEXT_ALIGN_RIGHT)
            draw.SimpleText("Limit " ..self.PlayerInCanal.. "/" ..v.Limit_Access, ipr.Font, 6, h-18, (self.PlayerInCanal > 0) and ipr.Color.green or ipr.Color.red, TEXT_ALIGN_LEFT)
        end

        ipr_ChildBut:SetSize(ipr_PSizeW / 2 + 2, 18)
        ipr_ChildBut:SetFont(ipr.Font)
        ipr_ChildBut:SetTextColor(color_white)
        ipr_ChildBut.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(ipr_CanalGroup.Allowed[seq].Colors.Canal_BoxRounded, 0, 0, w, h, ipr.Color.ChildBut_Hover)
            end
            draw.RoundedBox(ipr_CanalGroup.Allowed[seq].Colors.Canal_BoxRounded, 0, 0, w, h, ipr_CanalGroup.Allowed[seq].Colors.Canal_But)
        end
        ipr_ChildBut.DoClick = function()
            local ipr_ChildText = ipr_ChildBut:GetText()
            local ipr_SendServer = ipr_CanalJoin[ipr_ChildText] and v.Title or nil
            if not ipr_Status then
                for _, v in pairs(ipr_Channel) do
                    local ipr_vgui = v.ipr_VguiParent
                    if not IsValid(ipr_vgui) then
                       continue
                    end
                    ipr_vgui.Height = nil
                    ipr_vgui:SetVisible(true)
                end
                ipr_Status = true
                Ipr_VguiOption:SetImage(ipr.Mat.option)
            end

            net.Start("ipr_channels_status")
            net.WriteUInt(1, 3)
            net.WriteUInt(not ipr_SendServer and 0 or 1, 1)
            net.WriteString(v.Title)
            net.SendToServer()
        end

        ipr_Lock:SetPos(ipr_PSizeW - 15, 5)
        ipr_Lock:SetSize(11, 11)
        ipr_Lock.LFunc = function(b)
            ipr_Lock:SetImage(not b and ipr.Mat.unlock or ipr.Mat.lock)
            ipr_Lock.LockStatus = b
        end
        ipr_Lock.DoClick = function()
            if (ipr.VguiOpen ~= v.Title) then
                return ply:ChatPrint(ipr_CanalGroup.Lang.Join_LockChannel)
            end

            net.Start("ipr_channels_status")
            net.WriteUInt(3, 3)
            net.WriteString(v.Title)
            net.WriteBool(not ipr_Lock.LockStatus)
            net.SendToServer()
        end

        ipr_Channel[v.Title] = {ipr_VguiParent = ipr_VguiParent, ipr_ChildBut = ipr_ChildBut, ipr_Lock = ipr_Lock}
        ipr_Lock.LFunc(false)
    end

    local function ipr_UpdateVoice()
        local ipr_VoiceMic = net.ReadUInt(1)
        local ipr_VoiceCanal = net.ReadUInt(1)

        ipr_EnableDisableMic.LFunc(ipr_VoiceMic == 0)
        ipr_MuteCanal.LFunc(ipr_VoiceCanal == 0)
    end

    ipr_Channel.d = {ipr_TitleBut = ipr_TitleBut}
    ipr_EnableDisableMic.LFunc(ipr.Setting.MicMuted)
    ipr_MuteCanal.LFunc(ipr.Setting.CanalMuted)
    ipr.PosH = ipr_PosH + ipr.Setting.Vgui_SP

    net.Receive("ipr_channels_status", ipr_UpdateVoice)
end

do
    local function Ipr_CountNotSeq(v)
        local i = 0
        if (v) then
            for p in pairs(v) do
                if not IsValid(p) then
                   continue
                end
                i = i + 1
            end
        end
        return i
    end
 
    local function ipr_UpdateVgui()
        local ipr_Ply = LocalPlayer()
        local ipr_Seq_Update = net.ReadUInt(6)
        local ipr_PosPanel = {
            ["droite"] = ipr_Csw - 220,
            ["gauche"] = 20,
            ["centre"] = ipr_Csw / 2 - 95,
        }
        ipr.VguiOpen = nil
        ipr_PosPanel = ipr_PosPanel[string.lower(ipr_CanalGroup.Allowed[ipr_Seq_Update].Channels_Pos)]
        if not ipr_Channel then
            ipr_CreateVgui(ipr_Ply, ipr_Seq_Update, ipr_PosPanel)
        end

        local ipr_Seq_Team = net.ReadUInt(1)
        local ipr_TableC = ipr_CanalGroup.Allowed[ipr_Seq_Update].Permissions.job
        local ipr_TableRcv = net.ReadTable()
        local ipr_PlayerVar = (ipr_Seq_Team ~= 0) and net.ReadString() or team.GetName(ipr_Ply:Team())
        local ipr_Exclude = ipr_TableC[ipr_PlayerVar]["exclude_channels"]
        local ipr_AccessRank = ipr_TableC[ipr_PlayerVar].rank_access[ipr_Ply:GetUserGroup()]
        local ipr_sPos_H, ipr_Nick = 0, ipr_Ply:Nick()

        for _, v in ipairs(ipr_CanalGroup.Allowed[ipr_Seq_Update].Channels) do
            local ipr_PanelKey = ipr_Channel[v.Title]
            if not ipr_PanelKey then
               continue
            end
            local ipr_Panel = ipr_PanelKey.ipr_VguiParent
            if not ipr_Panel then
               continue
            end
            ipr_Panel.PlayerInCanal = 0
            local ipr_Pchild = ipr_Panel:GetChildren()
            if (ipr_Pchild) then
                for _, v in ipairs(ipr_Pchild) do
                    if (v.c) then
                        v:Remove()
                    end
                end
            end
            local ipr_PFind = ipr_TableRcv[v.Title]
            if (ipr_PanelKey.ipr_Lock.LockStatus) and not ipr_PFind then
                ipr_PanelKey.ipr_Lock.LFunc(false)
            end
            
            local ipr_Start_H, ipr_sEnd_H_, ipr_Swide, ipr_InCanal = 27, 0, ipr_Panel:GetWide()
            if (ipr_PFind) then
                local ipr_CTable = Ipr_CountNotSeq(ipr_PFind)
                local ipr_ForcedJoin = (ipr_CTable > 1)
                ipr_Panel.PlayerInCanal = ipr_CTable
                ipr_InCanal = ipr_PFind[ipr_Ply]
                if (ipr_InCanal) then
                    ipr.VguiOpen = v.Title
                end
                
                for p, b in pairs(ipr_PFind) do
                    if not istable(b) then
                        ipr_PanelKey.ipr_Lock.LFunc(b)
                    else
                        if not IsValid(p) then
                           continue
                        end
                        local ipr_PlayerT = p:Nick()
                        local ipr_PlayerC = (ipr_PlayerT == ipr_Nick)
                        if (string.len(ipr_PlayerT) >= ipr.MaxChar) then 
                            ipr_PlayerT = string.sub(ipr_PlayerT, 1, ipr.MaxChar).. ".." 
                        end

                        local ipr_Dlabel = vgui.Create("DLabel", ipr_Panel)
                        ipr_Dlabel:SetPos(5, ipr_Start_H + 4)
                        local ipr_Player = "► " ..ipr_PlayerT
                        ipr_Dlabel:SetText(ipr_Player)
                        ipr_Dlabel:SetFont(ipr.Font)
                        ipr_Dlabel.c = true
                        ipr_Dlabel:SizeToContents()

                        if (ipr_InCanal) then
                            local ipr_PlayerJ = team.GetName(p:Team())
                            local ipr_PlayerU = p:GetUserGroup()

                            if ipr_TableC[ipr_PlayerJ] and (ipr_TableC[ipr_PlayerJ].rank_access[ipr_PlayerU] or ipr_TableC[ipr_PlayerJ]["can_lock_channels"]) then
                            ipr_Dlabel:SetText(ipr_Player.. " ★")
                            ipr_Dlabel:SizeToContents()
                            end

                            local ipr_MicIcon = vgui.Create("DImage", ipr_Panel)
                            ipr_MicIcon:SetPos(ipr_Swide - 15, ipr_Start_H + 5)
                            ipr_MicIcon:SetSize(11, 11)
                            ipr_MicIcon.c = true
                            ipr_MicIcon.Think = function()
                                local ipr_CurTime = CurTime()

                                if (ipr_CurTime >= (ipr_MicIcon.t or 0)) then
                                   local ipr_Pspeak = p:IsSpeaking()
                                   
                                   if (p.EnableMic and ipr_Pspeak) then 
                                    ipr_MicIcon:SetImage(ipr.Mat.mictransmit) 
                                    p.EnableMic = false 
                                   elseif not p.EnableMic and not ipr_Pspeak then 
                                    ipr_MicIcon:SetImage(ipr.Mat.nomictransmit) 
                                    p.EnableMic = true 
                                   end
                                   ipr_MicIcon.t = ipr_CurTime + 0.2
                                end
                            end

                            if not ipr_PlayerC and (ipr_ForcedJoin) and (ipr_AccessRank or ipr_Exclude) then
                                local ipr_CloseBut = vgui.Create("DImageButton", ipr_Panel)
                                ipr_CloseBut:SetPos(ipr_Swide - 30, ipr_Start_H + 6)
                                ipr_CloseBut:SetSize(11, 11)
                                ipr_CloseBut:SetImage(ipr.Mat.close)
                                ipr_CloseBut.c = true
                                ipr_CloseBut.DoClick = function()
                                    net.Start("ipr_channels_status")
                                    net.WriteUInt(2, 3)
                                    net.WritePlayer(p)
                                    net.SendToServer()
                                end
                            end

                            p.EnableMic = false
                        end

                        local ipr_MembTall = ipr_Dlabel:GetTall()
                        ipr_Start_H = ipr_Start_H + ipr_MembTall + ipr.Setting.Player_SP
                        if (ipr_sEnd_H_ == 0) then
                        ipr_sEnd_H_ = ipr.Setting.PlayerPanel_SP
                        end
                    end
                end
            end
            local ipr_Child = ipr_PanelKey.ipr_ChildBut
            if IsValid(ipr_Child) then
                local ipr_Panel_Limit = (Ipr_CountNotSeq(ipr_PFind) >= v.Limit_Access)
                ipr_Child:SetText((ipr_InCanal) and ipr_CanalGroup.Lang.Close or (not ipr_Panel_Limit and not ipr_InCanal) and ipr_CanalGroup.Lang.Join_Channel or ipr_CanalGroup.Lang.Full)
                ipr_Child:SetPos(ipr_Swide / 2 - 3, ipr_Start_H + ipr.Setting.Panel_SP + ipr_sEnd_H_)
            end
            ipr_Panel:SetTall(ipr_Start_H + ipr.Setting.Vgui_SP + ipr_sEnd_H_)
            ipr_Panel:SetPos(0, ipr_Panel.Height or ipr_sPos_H)

            local ipr_PanelTall = ipr_Panel:GetTall()
            ipr_sPos_H = ipr_sPos_H + ipr_PanelTall + ipr.Setting.Panel_SP
        end
    end

    net.Receive("ipr_channels_update", ipr_UpdateVgui)
end

local function ipr_CloseVgui()
    for _, v in pairs(ipr_Channel) do
        for _, p in pairs(v) do
            if not ispanel(p) then
               continue
            end
            p:Remove()
        end
    end
    ipr_Channel = nil
end

ipr.Setting = {
    MicMuted = false,
    CanalMuted = false,
    Vgui_SP = 25,
    Player_SP = 5,
    Panel_SP = 5,
    PlayerPanel_SP = 3,
}
ipr.Mat = {
    blur = Material("pp/blurscreen"),
    option = "icon16/cog_add.png",
    option_enable = "icon16/cog_delete.png",
    hide_channels = "icon16/page_delete.png",
    display_channels = "icon16/page_add.png",
    show_channels = "icon16/table_delete.png",
    showAll_channels = "icon16/table_add.png",
    enablemic = "icon16/phone_sound.png",
    disablemic = "icon16/phone_delete.png",
    mutechannel = "icon16/sound_mute.png",
    unmutechannel = "icon16/sound_low.png",
    unlock = "icon16/lock_add.png",
    lock = "icon16/lock_break.png",
    mictransmit = "icon16/transmit_blue.png",
    nomictransmit = "icon16/transmit.png",
    close = "icon16/cross.png",
}
ipr.Color = {
    red = Color(255, 0, 0),
    green = Color(100, 221, 23),
    blue = Color(44, 62, 80),
    white_rgb = {r = "255", g = "255", b = "255"},
    ChildBut_Hover = Color(255, 0, 0),
}
net.Receive("ipr_channels_close", ipr_CloseVgui)
-- Script By Inj3
-- Collaboration : Inj3 & Autorun__
-- Idea : Autorun__
-- Code : Inj3

-------- Configuration
ipr_CanalGroup.Allowed = {
    {
        Title_Channel = "Marchand Noir - CANAUX", --- Le nom du panel.
        Channels_Pos = "Droite", --- La position des canaux sur votre écran (Droite, Gauche, Centre)
        Channels = { --- Le nom de vos canaux, définissez une limite et donnez-leur un nom unique.
            {Title = "Marchand 1", Limit_Access = 3},
            {Title = "Marchand 2", Limit_Access = 7},
            {Title = "Marchand 3", Limit_Access = 6},
            {Title = "Marchand 4", Limit_Access = 2},
            {Title = "Marchand 5", Limit_Access = 10},
        },
        Permissions = {
            job = {
                ["Chef Pizza"] = { --- Le métier qui accédera au panel.
                    ["exclude_channels"] = false, --- (true) Exclure les joueurs du canal.
                    ["can_bypass_limit"] = false, --- (true) Contourner la limite (Limit_Access) pour rejoindre un canal.
                    ["can_lock_channels"] = false, --- (true) Verrouiller un canal pour empêcher que des joueurs puissent le rejoindre (seuls les groupes appartenant à "rank_access" ou "can_bypass_limit" pourront y accéder)..

                    rank_access = { --- Le rang a toutes les permissions et hérite de toutes les autorisations ci-dessus !
                        ["superadmin"] = true,
                    },
                },
                ["Marchand Noir"] = {
                    ["exclude_channels"] = false,
                    ["can_bypass_limit"] = false,
                    ["can_lock_channels"] = true, 

                    rank_access = {
                        ["superadmin"] = true,
                        ["admin"] = true,
                    },
                },
            },
        },
        Colors = { --- Modifier la couleur du panel (rgb).
            Canal = Color(44, 62, 80, 215),  
            Canal_But = Color(205, 92, 92, 220),
            Canal_BoxRounded = 4,
        },   
    },
    
    {
        Title_Channel = "Vendeur d'armes - CANAUX",
        Channels_Pos = "Gauche",
        Channels = {
            {Title = "Vendeur 1", Limit_Access = 4},
            {Title = "Vendeur 2", Limit_Access = 4},
            {Title = "Vendeur 3", Limit_Access = 4},
            {Title = "Vendeur 4", Limit_Access = 4},
        },
        Permissions = {
            job = {
                ["Vendeur d'armes"] = {
                    ["exclude_channels"] = false,
                    ["can_bypass_limit"] = false,
                    ["can_lock_channels"] = false, 

                    rank_access = {
                        ["superadmin"] = true,
                        ["admin"] = true,
                    },
                },
                ["Vendeur d'armes Expert"] = {
                    ["exclude_channels"] = true,
                    ["can_bypass_limit"] = false,
                    ["can_lock_channels"] = true,

                    rank_access = {
                        ["superadmin"] = true,
                        ["admin"] = true,
                    },
                },
            },
        },
        Colors = {
            Canal = Color(0, 0, 0, 150),
            Canal_But = Color(205, 92, 92, 220),
            Canal_BoxRounded = 1,
        },    
    },
}

if (SERVER) then
    ipr_CanalGroup.AntiSpam = 0.7 --- anti-spam net (délai)

    ipr_CanalGroup.Lang = {
        Lock_channel = "Le canal est lock !",
        Limit_exceeded = "Vous ne pouvez pas rejoindre ce canal, vous n'avez pas les permissions, celui-ci est complet !",
        Channel_not_Correspond = "Le joueur fait partie d'un canal différent, il ne peut pas être exclu !",
        Channel_not_Exclude = "Ce joueur ne peut être exclu, celui-doit être dans le groupe 'rank_access', vous n'avez pas les permissions !",
        Channel_not_Authorized = "Ce joueur ne fait pas partie d'un canal, ou son job n'est pas conforme !",
        Channel_not_Lock = "Ce canal ne peut être verrouillé, vous n'avez pas les permissions !",
        Channel_Join = "Veuillez rejoindre le canal !",
        Exclude_Player = "Vous avez exclu le joueur :",
        No_permission = "Vous n'avez pas les permissions !",
    }
else
    ipr_CanalGroup.Lang = {
        Hide_channels = "Cacher tout les canaux",
        display_channels = "Afficher tout les canaux",
        Show_channels = "Cacher et laisser visible seulement votre canal",
        ShowAll_channels = "Afficher les canaux masqués",
        Join_HideChannel = "Veuillez rejoindre un canal pour masquer les autres panneaux visibles !",
        Join_Channel = "Rejoindre Canal",
        Channel_On = "Canal On",
        Channel_Off = "Canal Off",
        Lock = "(Ouvert)",
        Unlock = "(Fermé)",
        Join_LockChannel = "Veuillez rejoindre le canal pour modifier son statut !",
        Close = "Quitter Canal",
        Full = "Complet",
        Mic_On = "Micro On",
        Mic_Off = "Micro Off",
    }
end
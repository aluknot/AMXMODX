/* link https://forums.alliedmods.net/showthread.php?t=102369?t=102369 */

#include <amxmodx>
#include <fun>
#include <cstrike>

#define PLUGIN    "DM Points"
#define AUTHOR    "Alucard"
#define VERSION    "1.0"

new p_HudColor, p_Enabler, p_HudPosx, p_HudPosy, p_HudCT, p_HudT, p_NoFrags

new HudSync, g_MaxPlayers

new MapName[24]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    register_cvar("dm_points", VERSION,FCVAR_SERVER|FCVAR_SPONLY)

    register_message(get_user_msgid("ScoreInfo"), "HookScoreInfo")

    register_event( "30", "EndMap", "a" )

    p_Enabler = register_cvar("dtp_enable", "1")
    p_NoFrags = register_cvar("dtp_nofrags", "1")

    p_HudColor = register_cvar("dtp_hudcolor", "0 80 100")
    p_HudPosx = register_cvar("dtp_hudposx", "0.020")
    p_HudPosy = register_cvar("dtp_hudposy", "0.25")
    p_HudCT = register_cvar("dtp_ct", "CT")
    p_HudT = register_cvar("dtp_t", "T")

    set_task(1.0, "ShowPoints", 0, "", 0, "b")

    get_mapname(MapName, 23)

    g_MaxPlayers = get_maxplayers()
    HudSync = CreateHudSyncObj()
}

public HookScoreInfo(const msg_id, const msg_type, const id)
{
    if(get_pcvar_num(p_NoFrags) )
    {
        if ( (msg_type == MSG_ALL || msg_type == MSG_BROADCAST) && get_msg_arg_int(2))
        {
            set_msg_arg_int(2, ARG_SHORT, 0)
            set_msg_arg_int(3, ARG_SHORT, 0)
        }
    }
}

public ShowPoints()
{
    new CTfrags, Tfrags

    if(get_pcvar_num(p_Enabler) )
    {
        for(new i = 1; i <= g_MaxPlayers; i++)
        {
            if(is_user_connected(i) )
            {
                switch(cs_get_user_team(i) )
                {
                    case CS_TEAM_CT:
                    CTfrags += get_user_frags(i)
                    case CS_TEAM_T:
                    Tfrags += get_user_frags(i)
                }
            }
        }
        new Color[12], CT[32], T[32], rgb[3][4], iRed, iGreen, iBlue

        get_pcvar_string(p_HudColor, Color, charsmax(Color) )

        parse(Color, rgb[0], 3, rgb[1], 3, rgb[2], 3)

        iRed = clamp(str_to_num(rgb[0]), 0, 255)
        iGreen = clamp(str_to_num(rgb[1]), 0, 255)
        iBlue = clamp(str_to_num(rgb[2]), 0, 255)

        get_pcvar_string(p_HudCT, CT, charsmax(CT) )
        get_pcvar_string(p_HudT, T, charsmax(T) )

        set_hudmessage(iRed, iGreen, iBlue, get_pcvar_float(p_HudPosx), get_pcvar_float(p_HudPosy), 0, 1.0, 1.0, 0.1, 0.2, -1)
        ShowSyncHudMsg(0, HudSync, "%s %i | %s %i", CT, CTfrags, T, Tfrags)
    }
    return PLUGIN_CONTINUE
}

public EndMap()
{
    if(get_pcvar_num(p_Enabler) )
        client_print(0, print_chat, "[DM Points] Mapa: %s  |  Team Ganador: %s", Mapname, )
}

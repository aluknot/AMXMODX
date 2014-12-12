/* link pedido https://forums.alliedmods.net/showthread.php?t=108373 */

#include <amxmodx>
#include <hamsandwich>

#define PLUGIN    "Ready Mix"
#define AUTHOR    "Alucard"
#define VERSION    "1.0"

new bool:Ready[33], bool:FirstRespawn[33]

new p_PunishType, p_BanTime, p_Enabler

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    p_Enabler = register_cvar("r_enable", "1")
    p_PunishType = register_cvar("r_punishtype", "1")
    p_BanTime = register_cvar("r_bantime", "120")

    register_clcmd("say /ready", "HookCmdReady")
    register_clcmd("say /noready", "HookCmdNoReady")

    RegisterHam(Ham_Spawn, "player", "HookSpawnPL", 1)
}

public client_putinserver(id)
{
    FirstRespawn[id] = true
}

public client_disconnect(id)
{
    remove_task(id+1337)
}

public HookSpawnPL(id)
{
    if(FirstRespawn[id] && get_pcvar_num(p_Enabler) )
    {
        client_print(id, print_chat, "You have 2 minutes to put /ready after you get banned/kicked")

        set_task(120.0, "TimeToLeave", id+1337)

        FirstRespawn[id] = false
    }
}

public HookCmdReady(id)
{
    if(!Ready[id] && get_pcvar_num(p_Enabler) )
    {
        client_print(id, print_chat, "Now, you are ready, you will not get kicked/banned")

        Ready[id] = true

        remove_task(id+1337)
    }
    else
    {
        client_print(id, print_chat, "You are ready, if you want to get unready use /noready")
    }

    return PLUGIN_HANDLED
}

public HookCmdNoReady(id)
{
    if(Ready[id] && get_pcvar_num(p_Enabler) )
    {
        client_print(id, print_chat, "Now, you are unready, you get kicked/banned after 2 minuts")

        Ready[id] = false

        set_task(120.0, "TimeToLeave", id+1337)
    }
    else
    {
        client_print(id, print_chat, "You are unready, if you want to get ready use /ready")
    }

    return PLUGIN_HANDLED
}

public TimeToLeave(taskid)
{
    new id = taskid-1337

    if(!Ready[id] && get_pcvar_num(p_Enabler) )
    {
        new userid = get_user_userid(id)

        switch(get_pcvar_num(p_PunishType) )
        {
            case 1: server_cmd("kick #%d", userid)
            case 2:
            {
                new ip[32]
                get_user_ip(id, ip, 31, 1)

                server_cmd("kick #%d; addip %d %s;writeip", userid, get_pcvar_num(p_BanTime), ip)
            }
        }
    }
}

/* link pedido https://forums.alliedmods.net/showthread.php?t=129210 */

#include <amxmisc>

#define PLUGIN  "Admin Exec CFG"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

#define IsUserAdmin(%1)  (get_user_flags(%1) & ADMIN_KICK)

new const mrCFG[] = "mr15.cfg";

new const prCFG[] = "practice.cfg";

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say", "HookCmdSay");
}

public HookCmdSay(id)
{
    new szSay[192];
    read_args(szSay, 191);
    remove_quotes(szSay);

    if(!strlen(szSay) || szSay[0] == ' ' || szSay[0] != '!')
        return PLUGIN_CONTINUE;

    if(!IsUserAdmin(id) )
        return PLUGIN_HANDLED_MAIN;

    if(equali(szSay[1], "rr", 2) )
    {
        server_cmd("sv_restart 1");
    }
    else if(equali(szSay[1], "mr15", 4) )
    {
        server_cmd("exec %s", mrCFG);
        server_exec(); // dunno if is needed...
    }
    else if(equali(szSay[1], "prac", 4) )
    {
        server_cmd("exec %s", prCFG);
        server_exec(); // dunno if is needed...
    }
    else return PLUGIN_CONTINUE;

    return PLUGIN_HANDLED_MAIN;
}

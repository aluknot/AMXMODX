/* link pedido https://forums.alliedmods.net/showthread.php?p=1206572#post1206572 */

#include <amxmodx>
#include <amxmisc>

#define PLUGIN  "Redirect Plugin (Lite Version)"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

#define MAX_SERVERS 5

new fileName[192];

new g_Servers[MAX_SERVERS][256];

new g_Total;

public plugin_cfg()
{
    get_configsdir(fileName, 191);
    add(fileName, 191, "/servers");

    if(!dir_exists(fileName) )
        mkdir(fileName);

    add(fileName, 191, "/servers_menu.ini");

    if(!file_exists(fileName) )
        fclose(fopen(fileName, "wt") );
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_clcmd("say /servers", "HookCmdServers");

    if(!LoadServers() )
        pause("a");
}

public HookCmdServers(id)
{
    new menu = menu_create("\rServers Menu", "HandlerMenuServers");

    new szItem[128], szName[64], szSlots[2], szTarget[2];

    new iTarget;
    for(new i = 0; i < g_Total; i++)
    {
        iTarget++;
        num_to_str(iTarget, szTarget, 1);

        parse(g_Servers[i], "", 0, szName, 63, szSlots, 1);
        formatex(szItem, 127, "%s [%s]", szName, szSlots);
        menu_additem(menu, szItem, szTarget);
    }

    return PLUGIN_HANDLED;
}

public HandlerMenuServers(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[6], iName[48], Access, callback;
    menu_item_getinfo(menu, item, Access, data, 5, iName, 63, callback);

    new szIP[64];
    parse(g_Servers[item-1], szIP, 63);

    client_cmd(id, "connect %s", szIP);

    new szName[32];
    get_user_name(id, szName, 31);

    client_print(0, print_chat, "%s fue redireccionado al server %s", szName, szIP);

    return PLUGIN_HANDLED;
}

LoadServers()
{
    new szLine[256];
    new iLine, iLen;

    while(read_file(fileName, iLine++, szLine, 255, iLen) )
    {
        copy(g_Servers[g_Total], 255, szLine);

        g_Total++;

        if(g_Total == MAX_SERVERS) break;
    }

    if(!g_Total) return 0;

    return 1;
}

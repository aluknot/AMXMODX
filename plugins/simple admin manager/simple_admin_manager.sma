/* link pedido https://forums.alliedmods.net/showpost.php?p=1213020&postcount=86 */

#include <amxmodx>

#define PLUGIN  "Simple Admin Manager"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

#define IsUserAdmin(%1)     (get_user_flags(%1) & ADMIN_RCON)

#define MAX_CHARS 32    // maxima cantidad de caracteres de la password a setear

#define SECOND_FLAGS 3  // "ab"

enum
{
    ADMIN_PRO,
    ADMIN_NOR
}

new const g_AdmFlags[][] =
{
    "abcdefghijklmnopqrstu",   // flags del admin PRO
    "abcdefghijkmnopqrstu"     // flags del admin NORMAL
};

new g_AdminPro, g_AdminNor, g_MaxPlayers;

new g_AccesMode[33], g_TargetPlr[33], g_TargetName[33][32];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say /adm", "HookCmdAdmin");

    register_clcmd("_______ENTER_PASSWORD", "HookMessageModePw");

    g_AdminPro = read_flags(g_AdmFlags[ADMIN_PRO]);
    g_AdminNor = read_flags(g_AdmFlags[ADMIN_NOR]);

    g_MaxPlayers = get_maxplayers();
}

public client_connect(id)
    g_AccesMode[id] = 0;

public HookCmdAdmin(id)
{
    if(!IsUserAdmin(id) )
        return PLUGIN_HANDLED;

    new menu = menu_create("\rAgregar Admin:", "HookAdminHandler");

    new szItem[64];
    formatex(szItem, 63, "Admin Pro [\y%s\w]", g_AdmFlags[ADMIN_PRO]);
    menu_additem(menu, szItem, "1");

    formatex(szItem, 63, "Admin Normal [\y%s\w]", g_AdmFlags[ADMIN_NOR]);
    menu_additem(menu, szItem, "2");

    menu_display(id, menu);
    return PLUGIN_HANDLED;
}

public HookAdminHandler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new iData[6], iName[64];
    new iAccess, iCallback;

    menu_item_getinfo(menu, item, iAccess, iData, 5, iName, 63, iCallback);

    switch(str_to_num(iData) )
    {
        case 1:
        {
            ShowPlayers(id);
            g_AccesMode[id] = 1;
        }
        case 2:
        {
            ShowPlayers(id);
            g_AccesMode[id] = 2;
        }
    }

    return PLUGIN_HANDLED;
}

ShowPlayers(index)
{
    new menu = menu_create("\rElegir Player:", "HookPlayerHandler");

    new szName[32], szTarget[2], iTarget;

    for(new i = 1; i <= g_MaxPlayers; i++)
    {
        if(!is_user_connected(i) ) continue;

        iTarget++;
        num_to_str(iTarget, szTarget, 1);

        get_user_name(i, szName, 31);
        menu_additem(menu, szName, szTarget);
    }

    menu_display(index, menu);
    return PLUGIN_HANDLED;
}

public HookPlayerHandler(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new iData[6], iName[64];
    new iAccess, iCallback;

    menu_item_getinfo(menu, item, iAccess, iData, 5, iName, 63, iCallback);

    new iTarget = str_to_num(iData);

    if(IsUserAdmin(iTarget) )
    {
        client_print(id, print_chat, "El player seleccionado ya es admin!");
        return PLUGIN_HANDLED;
    }

    g_TargetPlr[id] = iTarget;
    copy(g_TargetName[id], 31, iName);

    client_cmd(id, "messagemode _______ENTER_PASSWORD");
    return PLUGIN_HANDLED;
}

public HookMessageModePw(id)
{
    new szArg[MAX_CHARS];
    read_argv(1, szArg, charsmax(szArg) );

    if(!strlen(szArg) || szArg[0] == ' ')
    {
        client_cmd(id, "messagemode _______ENTER_PASSWORD");
        return PLUGIN_HANDLED;
    }

    admins_push(g_TargetName[id], szArg, g_AccesMode[id] == 1 ? g_AdminPro : g_AdminNor, SECOND_FLAGS);
    return PLUGIN_HANDLED;
}

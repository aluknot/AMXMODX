#include <amxmodx>
#include <fakemeta>

#define PLUGIN    "Get angles & origin"
#define AUTHOR    "Alucard"
#define VERSION    "2.0"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("say /origin", "get_origin")
    register_clcmd("say /angles", "get_angles")
    register_clcmd("say /vangles", "get_vangles")
    register_clcmd("say /getmenu", "get_menu")
}

public get_menu(id)
{
    new menu = menu_create("\yGet Menu:", "get_show")
    
    menu_additem(menu, "\wOrigin", "1", 0)
    menu_additem(menu, "\wAngles", "2", 0)
    menu_additem(menu, "\wV Angles", "3", 0)
    
    menu_setprop(menu,MPROP_EXITNAME,"Salir")
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL)
    
    menu_display(id, menu, 0) 
    return PLUGIN_HANDLED
}

public get_show(id, menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
    
    new iData[6]
    new iAccess
    new iCallback
    new iName[64]
    
    menu_item_getinfo(menu, item, iAccess, iData, 5, iName, 63, iCallback)
    
    switch(str_to_num(iData))
    {
        case 1:
        {
            get_origin(id)
            menu_display(id, menu, 0)
        }
        case 2:
        {
            get_angles(id)
            menu_display(id, menu, 0)
        }
        case 3:
        {
            get_vangles(id)
            menu_display(id, menu, 0)
        }
    }
    return PLUGIN_HANDLED
}

public get_origin(id)
{
    new Float:fOrigin[3]
    pev(id , pev_origin , fOrigin)
    client_print(id, print_chat, "origin: %f, %f, %f", fOrigin[0], fOrigin[1], fOrigin[2])
    return PLUGIN_HANDLED
}

public get_angles(id)
{
    new Float:fAngles[3]
    pev(id , pev_angles , fAngles)
    client_print(id, print_chat, "angles: %f, %f, %f", fAngles[0], fAngles[1], fAngles[2])
    return PLUGIN_HANDLED
}

public get_vangles(id)
{
    new Float:fVAngles[3]
    pev(id , pev_v_angle , fVAngles)
    client_print(id, print_chat, "v_angles: %f, %f, %f", fVAngles[0], fVAngles[1], fVAngles[2])
    return PLUGIN_HANDLED
} 
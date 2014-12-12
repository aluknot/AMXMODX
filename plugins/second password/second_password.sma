/*                                                        //
*    AMX Mod X Script                                    //
*   ================                                    //
*                                                        //
*        PLUGIN: Second Password (cool style)            //
*        AUTHOR: Alucard^                                //
*        VERSION: 0.0.8                                    //
*                                                         //
* ////////////////////////////////////////////////////////
*
*
*                    Link: http://alliedmods...............................................
*
*                   This program is free software; you can redistribute it and/or modify it
*                      under the terms of the GNU General Public License as published by the
*                   Free Software Foundation; either version 2 of the License, or (at
*                   your option) any later version.
*
*                   This program is distributed in the hope that it will be useful, but
*                   WITHOUT ANY WARRANTY; without even the implied warranty of
*                   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*                   General Public License for more details.
*
*                       You should have received a copy of the GNU General Public License
*                   along with this program; if not, write to the Free Software Foundation,
*                   Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
*     Description:
*
*                     You know that you can set a password from a server cvar (sv_password). Well, with
*                     this plugin you can set ANOTHER password from an AMXX cvar. You can use this for
*                     add a second protection or maybe for a new cool style of password or the use that
*                     you want/like.
*
*                     If this second password is set, when a player join to the server he is freezed
*                     (he can't move) and the plugin show a menu to that player, asking if he know
*                     the password. If he enter the correct password, he can stay in the server, if
*                     not, get kicked. The player have a countdown to set the password (time configurable
*                     by cvar). If the countdown finish, the player are kicked.
*
*                     Also, when a player enter a correct password, if there are an admin into the server
*                     a menu appear to that admin (only one, the first found it) and give some options,
*                     to kick the player that entered a correct password, to change the actual password
*                     or to do nothing.
*
*                     Ofcourse the plugin have the implementation of Admin Inmunity, configurable by cvar.
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
*    Note:
*
*                     This plugin is an old idea, i did the base code some time ago. And now, i dont have
*                     internet for some weeks so... i want to script. And i found it some old incomplete
*                    plugins (this is one of these), so i am completing.
*
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
*     Changelog:
*
*                     0.0.1    » First Version (old version)
*
*
*                     0.0.7    » Removed useless code like for example an useless bool per player (now is global)
*                             » Fakemeta converted to Engine %100
*                             » Ham_Spawn changed to TeamInfo event
*                             » Completed and optimized a lot of code
*                             » Added little check to the set new password command
*                             » Added little optimization to the file path of wrong passwords
*                             » Now show the admin menu, only to the first admin found it
*
*
*                     0.0.8    » Player spawn check added to prevent a bug with freeze
*                             » Fixed little things
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/


#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <screenfade_util>

#define PLUGIN    "Second Password"
#define AUTHOR    "Alucard"
#define VERSION    "0.0.8"

#define IsUserAdmin(%1)  (get_user_flags(%1) & ADMIN_KICK)

#define TASK_ID_COUNTDOWN 1337

new p_SetPassword, p_AdminInmunity, p_KickTime, p_LogWrongPw;

new iCountdown, pID;

new bool:FirstSpawn[33], bool:IsFreeze[33];
new bool:HasPassword;

new Password[32], pName[32];

new Menu, Menu2;

new g_MaxPlayers;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    RegisterHam(Ham_Spawn, "player", "HookSpawnPlr", 1);

    register_event("TeamInfo", "HookJoinTeam", "a", "2!UNASSIGNED");

    register_clcmd("__________ENTER_PASSWORD", "CmdSetPw");
    register_clcmd("__________ENTER_NEW_PASSWORD", "CmdSetNewPw");

    p_SetPassword = register_cvar("amx_password", "hello");
    p_AdminInmunity = register_cvar("amx_pwadminm", "1");
    p_KickTime = register_cvar("amx_pwkicktime", "30");
    p_LogWrongPw = register_cvar("amx_badpwlog", "1");

    g_MaxPlayers = get_maxplayers();

    /* ------------------ Menu 1 ----------------------- */

    Menu = menu_create("\yDo you know the Password?", "HandlePwMenu");

    menu_additem(Menu, "\wYes", "1", 0);
    menu_additem(Menu, "\wNo", "2", 0);

    menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER);

    /* ------------------ Menu 2 ----------------------- */

    Menu2 = menu_create("\yWhat do you want to do?", "HandleAdmMenu");

    menu_additem(Menu2, "\wKick the player", "1", 0);
    menu_additem(Menu2, "\wChange the password", "2", 0);
    menu_additem(Menu2, "\wNothing", "3", 0);

    menu_setprop(Menu2, MPROP_EXIT, MEXIT_NEVER);
}

public client_putinserver(id)
{
    FirstSpawn[id] = true;
    IsFreeze[id] = false;

    get_pcvar_string(p_SetPassword, Password, 31);

    if(!strlen(Password) || Password[0] == ' ')
        HasPassword = false;
    else
    HasPassword = true;
}

public HookJoinTeam()
{
    static id; id = read_data(1);

    if(get_pcvar_num(p_AdminInmunity) && IsUserAdmin(id) )
        return PLUGIN_CONTINUE;

    if(HasPassword)
    {
        if(is_user_alive(id) )
        {
            entity_set_vector(id, EV_VEC_velocity, Float:{ 0.0, 0.0, 0.0 });
            entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) | FL_FROZEN);
        }

        set_hudmessage(80, 80, 80, -1.0, 0.35, 2, 0.1, 2.0, 0.05, 1.0, -1);
        show_hudmessage(id, "This server is protected with another password");

        set_task(2.5, "RequestPw", id);

        UTIL_FadeToBlack(id, 0.8);

        IsFreeze[id] = true;
    }

    return PLUGIN_CONTINUE;
}

public HookSpawnPlr(id)
{
    if(HasPassword && IsFreeze[id] && FirstSpawn[id])
    {
        if(!is_user_alive(id) )
            ExecuteHam(Ham_CS_RoundRespawn, id);

        entity_set_vector(id, EV_VEC_velocity, Float:{ 0.0, 0.0, 0.0 });
        entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) | FL_FROZEN);

        FirstSpawn[id] = false;
    }
}

public HandlePwMenu(id, Menu, item)
{
    new iData[6], iName[64];
    new iAccess, iCallback;

    menu_item_getinfo(Menu, item, iAccess, iData, 5, iName, 63, iCallback);

    switch(str_to_num(iData) )
    {
        case 1: client_cmd(id, "messagemode __________ENTER_PASSWORD");
        case 2: server_cmd("amx_kick #d Sorry but you have to know the password to stay in the server", get_user_userid(id) );
    }

    return PLUGIN_HANDLED;
}

public CmdSetPw(id)
{
    new arg[32];
    read_argv(1, arg, 31);

    if(!arg[0] || !strlen(arg) )
    {
        client_cmd(id, "messagemode __________ENTER_PASSWORD");
        return PLUGIN_HANDLED;
    }

    get_user_name(id, pName, 31);

    pID = get_user_userid(id);

    if(equal(arg, Password) )
    {
        entity_set_int(id, EV_INT_flags, entity_get_int(id, EV_INT_flags) & ~FL_FROZEN);

        set_hudmessage(80, 80, 80, -1.0, 0.35, 2, 0.1, 2.0, 0.05, 1.0, -1);
        show_hudmessage(id, "The password that you entered is correct^nNow you are unfreeze and can play in the server");

        set_task(3.0, "RemoveFade", id);

        for(new i = 1; i <= g_MaxPlayers; i++)
        {
            if(!is_user_connected(i) ) continue;
            if(!IsUserAdmin(i) ) continue;

            menu_display(i, Menu2);
            break;
        }

        client_print(0, print_chat, "%s entered the correct password...", pName);

        remove_task(id+TASK_ID_COUNTDOWN);

        IsFreeze[id] = false;
    }
    else
    {
        //server_cmd("amx_kick #d The password is not correct", pID)

        client_cmd(id, "messagemode __________ENTER_PASSWORD");

        client_print(id, print_chat, "The password that you entered is not correct");

        if(get_pcvar_num(p_LogWrongPw) )
        {
            new dir[192];
            format(dir, 191, "addons/amxmodx/configs/wrong_passwords")

            if(!dir_exists(dir) )
                mkdir(dir);

            format(dir, 191, "%s/%s.txt", dir, pName);
            log_to_file(dir, "Wrong Password: %s", arg);
        }
    }

    return PLUGIN_HANDLED;
}

public HandleAdmMenu(id, Menu2, item)
{
    new iData[6], iName[64];
    new iAccess, iCallback;

    menu_item_getinfo(Menu2, item, iAccess, iData, 5, iName, 63, iCallback);

    switch(str_to_num(iData) )
    {
        case 1: server_cmd("amx_kick #d", pID);
        case 2: client_cmd(id, "messagemode __________ENTER_NEW_PASSWORD");
        case 3: menu_destroy(Menu2);
    }

    return PLUGIN_HANDLED;
}

public CmdSetNewPw(id)
{
    new arg[32];
    read_argv(1, arg, 31);

    if(!arg[0] || !strlen(arg) )
    {
        client_cmd(id, "messagemode __________ENTER_NEW_PASSWORD");
        return PLUGIN_HANDLED;
    }

    set_pcvar_string(p_SetPassword, arg);
    return PLUGIN_HANDLED;
}

public RemoveFade(id)
    UTIL_ScreenFade(id);

public RequestPw(id)
{
    iCountdown = get_pcvar_num(p_KickTime);

    menu_display(id, Menu);
    set_task(1.0, "Countdown", id+TASK_ID_COUNTDOWN);
}

public Countdown(taskid)
{
    new id = taskid-TASK_ID_COUNTDOWN;

    if(iCountdown > 0)
    {
        set_hudmessage(80, 80, 80, -1.0, 0.1, 0, 0.0, 1.1, 0.0, 0.0, -1);
        show_hudmessage(id, "Tiempo antes de ser kickeado: %d", iCountdown);

        iCountdown--;

        set_task(1.0, "Countdown", id+TASK_ID_COUNTDOWN);
    }
    else
    server_cmd("amx_kick #d", get_user_userid(id) );
} 

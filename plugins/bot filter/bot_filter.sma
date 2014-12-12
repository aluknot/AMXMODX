/*
*    link pedido https://forums.alliedmods.net/showthread.php?t=132307
*
*    This program is free software; you can redistribute it and/or modify it
*    under the terms of the GNU General Public License as published by the
*    Free Software Foundation; either version 2 of the License, or (at
*    your option) any later version.
*
*    This program is distributed in the hope that it will be useful, but
*    WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*    General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program; if not, write to the Free Software Foundation,
*    Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
* ------------------------------------------------------------------------------------*/

#include <amxmodx>

#define PLUGIN  "Bot Filter"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

new p_MaxBots, p_StartKick;

new g_Bots, g_MaxPlayers, g_PlrConnected;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    p_MaxBots = register_cvar("max_bots", "8");
    p_StartKick = register_cvar("start_kick", "8");

    g_MaxPlayers = get_maxplayers();
}

public client_connect(id)
{
    if(is_user_bot(id) )
    {
        if(++g_Bots == get_pcvar_num(p_MaxBots) + 1)
            Disconnect(id);
    }
    else
    {
        g_PlrConnected++;

        new iBotKick = g_PlrConnected;

        if(g_Bots == get_pcvar_num(p_StartKick) )
        {
            for(new i = 1; i <= g_MaxPlayers; i++)
            {
                if(is_user_bot(i) )
                {
                    Disconnect(id);

                    iBotKick--;

                    if(iBotKick != 0) continue;

                    return;
                }
            }
        }
    }
}

public client_disconnect(id)
    g_PlrConnected--;

Disconnect(id)
{
    emessage_begin(MSG_ONE, SVC_DISCONNECT, _, id);
    emessage_end();
}

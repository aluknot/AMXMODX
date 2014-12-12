/*							   //
*   AMX Mod X Script				   //
*   ================				   //
*							   //
*		PLUGIN: Info Team MapZones	   //
*		AUTHOR: Alucard^			   //
*		VERSION: 0.0.1			   //			
* 							   //
* /////////////////////////////////////////////
* 
* 
*       			This program is free software; you can redistribute it and/or modify it
*      			under the terms of the GNU General Public License as published by the
*       			Free Software Foundation; either version 2 of the License, or (at
*       			your option) any later version.
*
*       			This program is distributed in the hope that it will be useful, but
*       			WITHOUT ANY WARRANTY; without even the implied warranty of
*       			MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*       			General Public License for more details.
*
*      			You should have received a copy of the GNU General Public License
*       			along with this program; if not, write to the Free Software Foundation,
*       			Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
* 
* 
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
* 
* 
* 	Description:
* 
*				When you use the chat in the game, your teammates can see in what MapZone
*				you are (or if you are in NoZone * not detected zone *). So you don't have
*				to write where you are. This plugin is simple, you don't need to edit nothing.
*				The MapZones are detected automatically by the plugin.
* 
*
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
* 
* 
* 	Changelog:
* 
* 				0.0.1	» First Version
* 									
* 
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
*/

#include <amxmodx>
#include <cstrike>

#define PLUGIN    "Info Team MapZones"
#define AUTHOR    "Alucard"
#define VERSION    "0.0.1"

#pragma semicolon 1

////////////////////////////////////////////////////////
/////////* Here you can change mapzones names */////////
////////////////////////////////////////////////////////

new const mapZones[][] =
{
	"NoZone",
	"BuyZone",
	"BombTarget",
	"HostageRescue",
	"EscapeZone",
	"VipSafety"
};

////////////////////////////////////////////////////////
///////////////* End modifications *////////////////////
////////////////////////////////////////////////////////

enum
{
	NOZONE = 0,
	BUYZONE,
	BOMBTARGET,
	HOSTAGE_RESCUE,
	ESCAPE,
	VIP_SAFETY
};

enum
{
	Normal = 0,
	Team,
	Total
};

new gMaxPlayers, gMsgSayText;

new p_Enable;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	register_cvar("itm_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY);
	register_cvar("itm_author", AUTHOR, FCVAR_SERVER|FCVAR_SPONLY);
	
	p_Enable = register_cvar("itm_enable", "1");
	
	register_clcmd("say", "HookCmdSay");
	register_clcmd("say_team", "HookCmdSayTeam");
	
	gMsgSayText = get_user_msgid("SayText");
	gMaxPlayers = get_maxplayers();
}

public HookCmdSayTeam(id)
{
	if(!get_pcvar_num(p_Enable) )
		return PLUGIN_CONTINUE;
	
	static message[256];
	read_args(message, 191); remove_quotes(message); trim(message);
	
	if(!strlen(message) )
		return PLUGIN_HANDLED_MAIN;
	
	new alive = is_user_alive(id);
	new team = get_user_team(id);
	new type = GetUserMapzone(id);
	
	static szDead[10];
	if(!alive)
		copy(szDead, 9, "!y*DEAD* ");
	
	static szName[32];
	get_user_name(id, szName, 31);
	
	format(message, 255, "%s!t%s [!g%s!t] !y:  %s", szDead, szName, mapZones[type], message[Team]);
	
	for(new i = 1; i <= gMaxPlayers; i++)
	{
		if(!is_user_connected(i) ) continue;
		if(is_user_alive(i) != alive) continue;
		if(get_user_team(i) != team) continue;
		
		chat_color(id, i, message);
	}
	
	return PLUGIN_HANDLED_MAIN;
}

public HookCmdSay(id)
{
	if(!get_pcvar_num(p_Enable) )
		return PLUGIN_CONTINUE;
	
	static message[Total][256];
	read_args(message[Normal], 191); remove_quotes(message[Normal]); trim(message[Normal]);
	read_args(message[Team], 191); remove_quotes(message[Team]); trim(message[Team]);
	
	if(!strlen(message[Normal]) || !strlen(message[Team]) )
		return PLUGIN_HANDLED_MAIN;
	
	new alive = is_user_alive(id);
	new team = get_user_team(id);
	new type = GetUserMapzone(id);
	
	static szDead[10];
	if(!alive)
		copy(szDead, 9, "!y*DEAD* ");
	
	static szName[32];
	get_user_name(id, szName, 31);
	
	format(message[Normal], 255, "%s!t%s !y:  %s", szDead, szName, message[Normal]);
	format(message[Team], 255, "%s!t%s [!g%s!t] !y:  %s", szDead, szName, mapZones[type], message[Team]);
	
	for(new i = 1; i <= gMaxPlayers; i++)
	{
		if(!is_user_connected(i) ) continue;
		if(is_user_alive(i) != alive) continue;
		if(get_user_team(i) == team)
		{
			chat_color(id, i, message[Team]);
		}
		else
		{
			chat_color(id, i, message[Normal]);
		}
	}
	
	return PLUGIN_HANDLED_MAIN;
}

stock GetUserMapzone(id)
{
	new zone = cs_get_user_mapzones(id);
	
	if(zone & CS_MAPZONE_BUY)
		return BUYZONE;
	else if(zone & CS_MAPZONE_BOMBTARGET)
		return BOMBTARGET;
	else if(zone & CS_MAPZONE_HOSTAGE_RESCUE)
		return HOSTAGE_RESCUE;
	else if(zone & CS_MAPZONE_ESCAPE)
		return ESCAPE;
	else if(zone & CS_MAPZONE_VIP_SAFETY)
		return VIP_SAFETY;
	
	return NOZONE;
}

stock chat_color(id, i, const Message[], any:...)
{    
	static szMsg[192];
	vformat(szMsg, 191, Message, 3);
	
	replace_all(szMsg, 191, "!y", "^x01");
	replace_all(szMsg, 191, "!t", "^x03");
	replace_all(szMsg, 191, "!g", "^x04");
	
	message_begin(i ? MSG_ONE : MSG_ALL, gMsgSayText, _, i);
	write_byte(id);
	write_string(szMsg);
	message_end();
}  
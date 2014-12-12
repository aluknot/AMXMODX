/*							   //
*   AMX Mod X Script				   //
*   ================				   //
*							   //
*		PLUGIN: All Admins Status Menu   //
*		AUTHOR: Alucard^			   //
*		VERSION: 0.2.7			   //			
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
* 				Maybe you know about Admin Check plugin by OneEyed or others similar plugins.
* 				Well, "All Admins Status Menu" have a similar base (show admins) but with
* 				some important differences. This plugin show ALL admins that are registered
* 				in users.ini (except STEAMID for now). But the show of the admins, is not by
* 				chat or hud message, is by MENU. Other special thing is that show the actual
* 				status per admin (Online or Offline).
* 
* 				Also, if you select an admin in the menu you can see some information of him
* 				(Real Name, Email and Status). But if you want, you can set some or all
* 				information as private (per admin). All this configurations can be made using
* 				users.ini file.
* 
* 
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
* 
* 
* 	Changelog:
* 
* 				0.0.1b	» First Version
* 					
*
* 				0.0.4b	» Now the plugin check admins in users.ini (not in a separate file)
* 						» Fixed status, but not tested at all, becouse i don't have internet :(
* 						» Some optimizations
* 
*
* 				0.0.8b	» Important changes in this version
* 							· Code restructured & cleaned
* 							· Detection of Admins changed (online & offline)
* 							· Global arrays implemented
* 							· Removed useless code & optimized
* 
*
* 				0.1.3b	» Important changes in this version
* 							· Added information per player 
* 							· New requierements in users.ini
* 							· Optionally you can private some information
* 							· ColorChat.inc added
* 
*
* 				0.1.4b	» Changed some little things
* 						» Cstrike mod detection for colorchat.inc use
* 						» This means the plugin work for all mods
* 
*
* 				0.1.5a	» Define added to determine the max count of admins
* 						» Removed a lot of useless code
* 						» Optimized & cleaned a bit
* 						» Compile fine but not tested, alpha stage now
*
*
* 				0.2.0		» Public Version (stable version now)
* 						» Added BuyIcon hide/draw when menu is used
* 						» Changed STEAM detection to flags & bitsum (thank to speed for this suggestion)
* 						» How to set private info changed & fixed
*						» Plugin tested, and work perfect!
*
*
* 				0.2.7		» Cstrike module required now, only if you want to install in this game
*						» Added more defines for preprocessors (ChatColor, Cstrike)
* 						» BuyIcon hide/draw only in Counter-Strike game
* 						» ChatColor.inc requirement removed, code included to this plugin
* 						» Added a delay to load admins in users.ini to prevent from crash
*						» Changed old files natives to "new" files natives
* 					
* 
* ----------------------------------------------------------------------------------------------------------------------------------------------------------
*/

#include <amxmodx>
#include <amxmisc>

/*
* 	Comment this if you don't want to install the plugin in Counter-Strike game
*/

#define USE_CSTRIKE

#if defined USE_CSTRIKE
#include <cstrike>
#endif

#define PLUGIN	"All Admins Status Menu"
#define AUTHOR	"Alucard^^"
#define VERSION	"0.2.7"

/*
* 	Comment this if you want chat color prints, for the information things
* 	But you have to know that this only work on Counter-Strike
*/

#define USE_CHAT_COLOR

/*
* 	Uncomment this if you want to destroy the menu after a player select an option
* 	To uncomment this you only have to remove the "//" 
*/

//#define DESTROY_MENU

#define MAX_ADMS 30

#define TASK_LOAD_TIME 2.0

#define IsUserAdmin(%1)  (get_user_flags(%1) & ADMIN_KICK)

//////////// Arrays /////////////////////////////////

new Array:AdminsOnline, Array:TotalAdmins

new Array:RealNames, Array:Emails, Array:AdmStatus

///////// Global Things /////////////////////////////

new gMaxPlayers, gTotalAdmsOnline, gTotalAdms;

new FindAdmins, gAdmsNum;

#if defined USE_CSTRIKE
new gMsgStatusIcon;
#endif

/////// Consts or Strings ///////////////////////////

#if defined USE_CHAT_COLOR
new const NoInfo[] = "^x03Private";
#else
new const NoInfo[] = "Private";
#endif

#if defined USE_CHAT_COLOR
enum Colors
{
	NORMAL = 1, // clients scr_concolor cvar color
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
};

new TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};
#endif

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_cvar("asm_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("asm_author", AUTHOR, FCVAR_SERVER|FCVAR_SPONLY)
	
	register_clcmd("say /adms", "HookCmdMenu");
	register_clcmd("say /admins", "HookCmdMenu");
	
	AdminsOnline = ArrayCreate(32, 1);
	TotalAdmins = ArrayCreate(32, 1);
	
	RealNames = ArrayCreate(32, 1);
	Emails = ArrayCreate(32, 1);
	AdmStatus = ArrayCreate(32, 1);
	
	gMaxPlayers = get_maxplayers();
	gAdmsNum = admins_num();
	
	#if defined USE_CSTRIKE
	gMsgStatusIcon = get_user_msgid("StatusIcon");
	#endif
	
	set_task(TASK_LOAD_TIME, "TaskLoadAdmins"); // added delay to prevent crash
}

public TaskLoadAdmins()
	FindAdmins = LoadTotalAdmins();

public HookCmdMenu(id)
{
	if(!gAdmsNum || !FindAdmins)
	{
		client_print(id, print_chat, "* This server don't have admins in users.ini!");
		return PLUGIN_HANDLED;
	}
	
	LoadAdminsOnline();
	
	new Menu = menu_create("Admin Status:", "AdminMenuHandler");
	
	new szAdmOnline[32], szAdmin[32], szTarget[10], Text[128];
	
	new iNum, Status;
	for(new i = 0; i < gTotalAdms; i++)
	{
		ArrayGetString(TotalAdmins, i, szAdmin, 32);
		
		if(i < gTotalAdmsOnline)
			ArrayGetString(AdminsOnline, i, szAdmOnline, 32);
		
		iNum++
		num_to_str(iNum, szTarget, 9);
		
		if(containi(szAdmOnline, szAdmin) != -1)
		{
			Status = 1;
		}
		else
		{
			Status = 0;
		}
		
		formatex(Text, 127, "%s: %s", szAdmin, Status ? "\yOnline" : "\rOffline");
		
		menu_additem(Menu, Text, szTarget, 0);
	}
	
	#if defined USE_CSTRIKE
	if(cs_get_user_buyzone(id) )
		BuyIcon(id, 0);
	#endif
	
	menu_display(id, Menu, 0);
	return PLUGIN_HANDLED;
}

public AdminMenuHandler(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		#if defined USE_CSTRIKE
		BuyIcon(id, 1);
		#endif
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}
	
	new data[6], iName[48], Access, callback;
	menu_item_getinfo(Menu, item, Access, data, 5, iName, 63, callback);
	
	static szName[32], szRealName[48], szEmail[48], szStatus[48];
	
	ArrayGetString(TotalAdmins, item, szName, 32);
	ArrayGetString(RealNames, item, szRealName, 47);
	ArrayGetString(Emails, item, szEmail, 47);
	ArrayGetString(AdmStatus, item, szStatus, 47);
	
	if(equali(szRealName, "allprivate") || (!strlen(szRealName) && !strlen(szEmail) && !strlen(szStatus) ) )
	{
		szRealName = NoInfo;
		szEmail = NoInfo;
		szStatus = NoInfo;
		
		#if defined USE_CHAT_COLOR
		ColorChat(id, RED, "^x01%s information of ^x04%s^x01 is %s^x01!", "* The", szName, NoInfo);
		#else
		client_print(id, print_chat, "* The information of %s is %s", szName, NoInfo);
		#endif
		
		return PLUGIN_HANDLED;
	}
	
	if(!strlen(szRealName) || equali(szRealName, "private") )
	{
		szRealName = NoInfo;
	}
	
	if(!strlen(szEmail) || equali(szEmail, "private") )
	{
		szEmail = NoInfo;
	}
	
	if(!strlen(szStatus) || equali(szStatus, "private") )
	{
		szStatus = NoInfo;
	}
	
	#if defined USE_CHAT_COLOR
	ColorChat(id, RED, "^x04Real Name: ^x01%s^x04 Email: ^x01%s ^x04Status: ^x01%s", szRealName, szEmail, szStatus);
	#else
	client_print(id, print_chat, "Real Name: %s | Email: %s | Status: %s", szRealName, szEmail, szStatus);
	#endif
	
	#if !defined DESTROY_MENU
	menu_display(id, Menu);
	#else
	#if defined USE_CSTRIKE
	BuyIcon(id, 1);
	#endif
	#endif
	return PLUGIN_HANDLED;
}

LoadTotalAdmins()
{
	new szUsersIni[48];
	get_configsdir(szUsersIni, 47);
	add(szUsersIni, 47, "/users.ini");
	
	if(!gAdmsNum)
		return 0;
	
	static Text[256], szAdmins[64], szFlags[10],
	RealName[48], Email[48], Status[48];
	
	new iFlags, f = fopen(szUsersIni, "rt");
	
	while(!feof(f) )
	{
		fgets(f, Text, 255);
		
		if(!strlen(Text) ) continue;
		if(Text[0] == ';') continue;
		if(Text[0] == '/' && Text[1] == '/') continue;
		
		parse(Text, szAdmins, 63, "", 0, "", 0, szFlags, 9, RealName, 47, Email, 47, Status, 47);
		
		iFlags = read_flags(szFlags);
		
		if(iFlags & FLAG_AUTHID) continue;
		
		ArrayPushString(TotalAdmins, szAdmins);
		
		ArrayPushString(RealNames, RealName);
		ArrayPushString(Emails, Email);
		ArrayPushString(AdmStatus, Status);
		
		gTotalAdms++;
	}
	
	fclose(f);
	
	return 1;
}

LoadAdminsOnline()
{
	static szName[32];	
	for(new i = 1; i <= gMaxPlayers; i++)
	{
		if(!is_user_connected(i) ) continue;
		if(!IsUserAdmin(i) ) continue;
		
		get_user_name(i, szName, 31);
		
		ArrayPushString(AdminsOnline, szName);
		
		gTotalAdmsOnline++
	}
}

#if defined USE_CSTRIKE
BuyIcon(id, iNum)
{
	message_begin(MSG_ONE_UNRELIABLE, gMsgStatusIcon, _, id);
	write_byte(iNum);
	write_string("buyzone");
	write_byte(0);
	write_byte(160);
	write_byte(0);
	message_end();
}
#endif

#if defined USE_CHAT_COLOR
ColorChat(id, Colors:type, const msg[], {Float,Sql,Result,_}:...)
{
	if( !get_playersnum() ) return;
	
	new message[256];

	switch(type)
	{
		case NORMAL: // clients scr_concolor cvar color
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], 251, msg, 4);

	// Make sure message is not longer than 192 character. Will crash the server.
	message[192] = '^0';

	new team, ColorChange, index, MSG_Type;
	
	if(id)
	{
		MSG_Type = MSG_ONE;
		index = id;
	} else {
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	}
	
	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);

	ShowColorMessage(index, MSG_Type, message);
		
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}

ShowColorMessage(id, type, message[])
{
	static bool:saytext_used;
	static get_user_msgid_saytext;
	if(!saytext_used)
	{
		get_user_msgid_saytext = get_user_msgid("SayText");
		saytext_used = true;
	}
	message_begin(type, get_user_msgid_saytext, _, id);
	write_byte(id)		
	write_string(message);
	message_end();	
}

Team_Info(id, type, team[])
{
	static bool:teaminfo_used;
	static get_user_msgid_teaminfo;
	if(!teaminfo_used)
	{
		get_user_msgid_teaminfo = get_user_msgid("TeamInfo");
		teaminfo_used = true;
	}
	message_begin(type, get_user_msgid_teaminfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();

	return 1;
}

ColorSelection(index, type, Colors:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}

	return 0;
}

FindPlayer()
{
	new i = -1;

	while(i <= get_maxplayers())
	{
		if(is_user_connected(++i))
			return i;
	}

	return -1;
}
#endif
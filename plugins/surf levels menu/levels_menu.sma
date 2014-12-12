/*					    //
*   AMX Mod X Script		    //
*   ================		    //
*					    //
*		PLUGIN: Levels Menu   //
*		AUTHOR: Alucard^	    //
*	   	VERSION: 0.0.2        //			
* 					    //
* //////////////////////////////////
* 
*     
*				Link: http://alliedmods...............................................
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
*      			 You should have received a copy of the GNU General Public License
*       			along with this program; if not, write to the Free Software Foundation,
*       			Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
* 
* 
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 
* 
* 	Changelog:
* 
* 				0.0.1		» First Version
* 
* 
* 				0.0.2		» Angles save added
* 						» Little cleaner added in plugin_end()
* 
* 
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGIN	"Levels Menu"
#define AUTHOR	"Alucard"
#define VERSION	"0.0.2"

new mapName[32], newfileName[128], mapFileName[128];

new fileName[] = "addons/amxmodx/configs/levels_map";

new menu;

public plugin_precache()
{
	get_mapname(mapName, 31);
	
	if(!dir_exists(fileName) )
		mkdir(fileName);
	
	formatex(newfileName, 127, "%s/levels_num.cfg", fileName);
	formatex(mapFileName, 127, "%s/%s.ini", fileName, mapName);
	
	if(!file_exists(newfileName) )
		fclose(fopen(newfileName, "wt") );
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("lvl_num", "HookCmdLevelsNum", ADMIN_KICK);
	register_clcmd("say /lvlmaker", "HookCmdLevelMaker", ADMIN_KICK);
	register_clcmd("say /lvlmenu", "HookCmdLevelMenu");
}

public HookCmdLevelMenu(id)
{
	if(!file_exists(mapFileName) || GetMapLevel(2) <= 0)
	{
		client_print(id, print_chat, "Este mapa no tiene levels seteados!");
		return PLUGIN_HANDLED;
	}
	
	if(!is_user_alive(id) )
	{
		client_print(id, print_chat, "Debes estar vivo para usar esta funcion!");
		return PLUGIN_HANDLED;
	}
	
	new iNum = GetMapLevel(1);
	
	static szItem[64], iLevel, szTarget[3];
	
	new Menu = menu_create("Level Map", "LevelMapHandler");
	
	iLevel = 0;
	for(new i = 0; i < iNum; i++)
	{
		iLevel++;
		num_to_str(iLevel, szTarget, 2);
		
		formatex(szItem, 63, "Level \y%d", iLevel);
		menu_additem(Menu, szItem, szTarget);
	}
	
	menu_display(id, Menu);
	return PLUGIN_HANDLED;
}

public LevelMapHandler(id, Menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(Menu);
		return PLUGIN_HANDLED;
	}

	new iData[6], iName[64];
	new iAccess, iCallback;

	menu_item_getinfo(Menu, item, iAccess, iData, 5, iName, 63, iCallback);
	
	static szLine[512], x[14], y[14], z[14], X[14], Y[14], Z[14];
	
	static iLine, iLen;
	while(read_file(mapFileName, iLine++, szLine, 511, iLen) )
	{
		if(!strlen(szLine) ) continue;
		
		parse(szLine, x, 13, y, 13, z, 13, X, 13, Y, 13, Z, 13);
		
		if(iLine == item+1)
		{
			new Float:LevelOrigin[3], Float:LevelAngle[3];
			
			LevelOrigin[0] = str_to_float(x);
			LevelOrigin[1] = str_to_float(y);
			LevelOrigin[2] = str_to_float(z);
			
			LevelAngle[0] = str_to_float(X);
			LevelAngle[1] = str_to_float(Y);
			LevelAngle[2] = str_to_float(Z);
			
			entity_set_origin(id, LevelOrigin);
			entity_set_vector(id, EV_VEC_angles, LevelAngle);
			entity_set_int(id, EV_INT_fixangle, 1);
			
			menu_display(id, Menu);
			return PLUGIN_HANDLED;
		}
	}
	
	return PLUGIN_HANDLED;
}

public HookCmdLevelMaker(id, level, cid)
{
	if(!cmd_access(id, level, cid, 1) )
		return PLUGIN_HANDLED;
	
	MenuLevelMaker(id);
	return PLUGIN_HANDLED;
}

public MenuLevelMaker(id)
{
	if(!file_exists(newfileName) )
	{
		client_print(id, print_chat, "No se encontro el archivo levels_num.ini");
		return PLUGIN_HANDLED;
	}
	
	new iLine = GetMapLevel(2);
	
	if(iLine <= 0)
	{
		client_print(id, print_chat, "Este mapa no tiene levels seteados");
		return PLUGIN_HANDLED;
	}
	
	new iNum = GetMapLevel(1);
	
	static szItem[64], iLevel, szTarget[3];
	
	menu = menu_create("Level Maker", "LevelMakerHandler");
	
	iLevel = 0;
	for(new i = 0; i < iNum; i++)
	{
		iLevel++;
		num_to_str(iLevel, szTarget, 2);
		
		formatex(szItem, 63, "Level \y%d", iLevel);
		menu_additem(menu, szItem, szTarget);
	}
	
	menu_display(id, menu);
	return PLUGIN_HANDLED;
}

public LevelMakerHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;
	}

	new iData[6], iName[64];
	new iAccess, iCallback;

	menu_item_getinfo(menu, item, iAccess, iData, 5, iName, 63, iCallback);
	
	if(!file_exists(mapFileName) )
		fclose(fopen(mapFileName, "wt") );
	
	new Float:LevelOrigin[3], Float:LevelAngle[3];
	entity_get_vector(id, EV_VEC_origin, LevelOrigin);
	entity_get_vector(id, EV_VEC_angles, LevelAngle);
	
	new szLine[512];
	formatex(szLine, 255, "%f %f %f", LevelOrigin[0], LevelOrigin[1], LevelOrigin[2]);
	format(szLine, 511, "%s %f %f %f", LevelAngle[0], LevelAngle[1], LevelAngle[2]);
	
	write_file(mapFileName, szLine, item);
	
	client_print(id, print_chat, "El origin & angle para el level %d fue seteado", szLine, item+1);
	
	//menu_item_setname(menu, item, iName);
	
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public HookCmdLevelsNum(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2) )
		return PLUGIN_HANDLED;
	
	new szArg[3];
	read_argv(1, szArg, 2);
	
	if(!IsValidNum(szArg) )
		return PLUGIN_HANDLED;
	
	new iNum = str_to_num(szArg);
	
	static szLine[32];
	if(file_exists(newfileName) )
	{
		new num = GetMapLevel(1);
		new iLine = GetMapLevel(2);
		
		if(iLine > 0)
		{
			formatex(szLine, 31, "%s %d", mapName, iNum);
			write_file(newfileName, szLine, iLine-1);
			client_print(id, print_chat, "La cantidad de levels para este mapa fue cambiada de %d a %d", num, iNum);
			return PLUGIN_HANDLED;
		}
	}
	
	formatex(szLine, 31, "%s %d", mapName, iNum);
	write_file(newfileName, szLine);
	client_print(id, print_chat, "La cantidad de levels para este mapa fue seteada a %d", iNum);
	
	return PLUGIN_HANDLED;
}

public plugin_end()
{
	new num = GetMapLevel(1);
	
	static szLine[256], iLine, iLen;
	
	while(read_file(mapFileName, iLine++, szLine, 255, iLen) )
	{
		if(iLine > num)
			write_file(mapFileName, "", iLine);
	}
}

GetMapLevel(param)
{
	static getMap[20], getNum[3], szLine[32], iLine, iLen;
	iLine = 0, iLen = 0;
	
	while(read_file(newfileName, iLine++, szLine, 31, iLen) )
	{
		if(!strlen(szLine) ) continue;
		
		parse(szLine, getMap, 19, getNum, 2);
		if(equali(getMap, mapName) )
		{
			if(param == 1) return str_to_num(getNum);
			if(param == 2) return iLine;
		}
	}
	
	return 0;
}

bool:IsValidNum(const string[])
{
	new len = strlen(string);
	if(!len) return false;
	
	for(new i = 0; i < len; i++)
	{
		if(!isdigit(string[i]) || string[i] == ' ')
			return false;
	}
	
	return true;
}
/*									   			//
*	AMX Mod X Script						   			//
*     ================					        	 		//
*									   			//
*		PLUGIN: Block rotating door when it's touched by a Weapon   //
*		AUTHOR: Alucard^				         			//
*		VERSION: 0.0.5					  			//			
* 									   			//
* ////////////////////////////////////////////////////////////////////////
* 
*     
*				Link: http://forums.alliedmods.net/showthread.php?t=109973
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
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
* 
*	Credits:
*
*				Exolent[jNr] - Helped in some things
*				VEN 		 - Detect the type of the grenade class (he|gs|fb)
*				Arkshine 	 - He gave me the link above of VEN post
*				xPaw 		 - For another method detection
*
*	
*				Note:  In 0.0.5 version, the plugin is restructured "at all".
*					 And maybe the methods that some people gave me (people
*					 in the credits) i am not using more, but i leave that
*					 peoples in the credits, becouse they helped me.
* 
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 
* 
* 	Changelog:
* 
* 				0.0.1	» First Release
* 
* 
* 				0.0.5	» Name of the plugin changed to "Block touch betwen doors & weapons"
* 					» Now the plugin detect all weapons, not only grenades
* 					» Name of cvars changed to bt_<wpnname>
* 					» Removed Fakemeta module requirement
* 					» Added admin inmunity (configurable by cvar)
* 					» Grenade detection changed
* 
* 
* 				0.0.6 » WeaponsName global moved to plugin_init( )
* 					» if( ) else if( ) -> if( ) else( )
* 					» bt_adm_inm cvar changed to bt_adm_imn
* 
* 
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

#include <amxmodx>
#include <engine>

#define PLUGIN	"Block rootating door when touch with weapons"
#define AUTHOR	"Alucard"
#define VERSION	"0.0.6"

#pragma semicolon 1

#define INM_FLAG ADMIN_SLAY

new p_Enabler, p_AdmInm, p_WeaponsCvar[31];

enum
{
	DoorRotating = 0,
	WeaponBox,
	Grenade
};

new const BlockClass[][] =
{ 
	"func_door_rotating", "weaponbox", "grenade"
};

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	p_Enabler = register_cvar("bt_enable", "1");
	p_AdmInm = register_cvar("bt_adm_imn", "0");
	
	new const WeaponsName[][] =
	{
		"",
		"p228", "shield", "scout", "hegrenade", "xm1014", "c4",
		"mac10", "aug", "smokegrenade", "elite", "fiveseven",
		"ump45", "sg550", "galil", "famas", "usp", "glock18",
		"awp", "mp5navy", "m249", "m3", "m4a1", "tmp", "g3sg1",
		"flashbang", "deagle", "sg552", "ak47", "knife", "p90"
	};
	
	new NameCvar[24];
	for(new i = 1; i < sizeof(p_WeaponsCvar); i++)
	{
		formatex(NameCvar, charsmax(NameCvar), "bt_%s", WeaponsName[i]);
		p_WeaponsCvar[i] = register_cvar(NameCvar, "1");
	}
	
	register_touch(BlockClass[DoorRotating], BlockClass[WeaponBox], "HookBlockTouch");
	register_touch(BlockClass[DoorRotating], BlockClass[Grenade], "HookBlockTouch");
}

public HookBlockTouch(iEntity, iWeapon)
{
	if(!get_pcvar_num(p_Enabler) || !is_valid_ent(iWeapon) )
		return PLUGIN_CONTINUE;
	
	new id = entity_get_edict(iWeapon, EV_ENT_owner);
	
	if(get_pcvar_num(p_AdmInm) && get_user_flags(id) & INM_FLAG)
		return PLUGIN_CONTINUE;
	
	static szClassname[32];
	entity_get_string(iWeapon, EV_SZ_classname, szClassname, 31);
	
	if(equal(szClassname, BlockClass[WeaponBox]) )
	{
		new type = GetWeaponboxType(iWeapon);
		if(get_pcvar_num(p_WeaponsCvar[type]) && type)
			return PLUGIN_HANDLED;
	}
	else
	{
		new type = GetWeaponType(id);
		if(get_pcvar_num(p_WeaponsCvar[type]) && type)
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

stock GetWeaponboxType(entity)
{
	static max_clients, max_entities;
	
	if(!max_clients)
		max_clients = get_global_int(GL_maxClients);
	if(!max_entities)
		max_entities = get_global_int(GL_maxEntities);
	
	for(new i = max_clients + 1; i < max_entities; ++i)
	{
		if(is_valid_ent(i) && entity == entity_get_edict(i, EV_ENT_owner) )
		{
			new wname[32];
			entity_get_string(i, EV_SZ_classname, wname, 31);
			return get_weaponid(wname);
		}
	}
	
	return 0;
}

stock GetWeaponType(id)
{
	return get_user_weapon(id);
}
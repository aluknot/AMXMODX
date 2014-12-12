/*									   //
*   AMX Mod X Script						   //
*   ================					         //
*									   //
*		PLUGIN: HLTV Parameters	(+ bugfix)		   //
*		AUTHOR: Alucard^				         //
*		VERSION: 0.2.0 BETA				   //			
* 									   //
* /////////////////////////////////////////////////////////  
* 
*     
*				Link: ...
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
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 
* 
* 	Descripcion:
*  				El plugin agrega nuevos parametros para mejor manejo del HLTV.	
*				Tales como bloquear la entrada del HLTV o de X cantidad de HLTV's.	
*				O ponerle automaticamente un prefix al nombre para identificarlo como HLTV.	
*				Y aparte el plugin fixea un "bug", que permite que el HLTV pueda usar cualquier nombre	
*                       (inclusive el de un admin registrado en el users.ini).
* 
* 
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 
* 
*  		Cvars:
*  				hltv_parameter	 <0|1>	- Activa/Desactiva el plugin entero.
*  				hltv_permited	 <valor>	- Numero de HLTV's permitidos (en 0 bloquea a todos).
*  				hltv_forceprefix   <0|1|2>	- Agrega un prefix al nombre del HLTV (para validar que es HLTV).
*  				hltv_bugfix		 <0|1>	- Fixea el bug que el HLTV puede usar el nombre de un admin	
*  									  sin ser kickeado. Al estar esta cvar en 0 ya no podra.	
* 
* 
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* 
* 		 
*	  Changelog:	
*				0.0.1		» First Version	
*											
* 			
*				0.0.2b	» The bugfix is more dynamic now (support for STEAMID and ip admins)	
*						» Beta stage of the plugin			
*			
* 		
*				0.0.4		» Fixed some things
*						» Added new mode in the bugfix cvar
*						» stable version... i think (last changes not tested yet)
*
* 
*				0.0.7b	» Removed a lot of useless code
*						» Optimized & cleaned some things
*						» Modify some detect methods
*						» Beta stage version now, not tested
*
* 
*				0.1.2a	» Tested last version, doesn't work and get crashes
*						» Important changes in this version (practically the whole plugin)
*						» A lot of problems & bugs fixed (i think)
*						» Changed detection methods
*						» Cleaned & removed useless code
*						» Optimized a lot of things
*						» Alpha stage version now, not tested
*
* 
*				0.1.3b	» Name change bug fixed
*
* 
*				0.1.5b	» Removed useless code
*						» Fixed little things
*						» Name change by HLTV, blocked (need test)
*						» Added plugin pause when no admins found
*
*				
*				0.2.0b	» First Public Version
*  
* 
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/


#include <amxmodx>
#include <amxmisc>

#define PLUGIN	"HLTV Parameters"
#define AUTHOR	"Alucard^^"
#define VERSION	"0.2.0 BETA"

new Array:AdminsUserIni, Array:AuthUserIni;

new p_Enable, p_ForcePrefix, p_HltvPermited, p_HltvBugFix;

new hltvCount, g_MaxPlayers, gAdminsNum;

new bool:FakeAdmHltv[33];

new const Prefix[] = "<Valid HLTV>";
new const BadAdm[] = "<Fake Adm HLTV>";

new gAdminsAuthFound, gAdminsNameFound;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	gAdminsNum = admins_num();
	
	if(!gAdminsNum)
	{
		log_amx("No hay admins registrados en el users.ini");
		pause("a");
	}
	
	AdminsUserIni = ArrayCreate(32, 1);
	AuthUserIni = ArrayCreate(32, 1);
	
	p_Enable = register_cvar("hltv_parameter", "1");
	p_HltvPermited = register_cvar("hltv_permited", "1");
	p_ForcePrefix = register_cvar("hltv_forceprefix", "1");
	p_HltvBugFix = register_cvar("hltv_bugfix", "1");
	
	g_MaxPlayers = get_maxplayers();
	
	CheckAdminsUserIni();
}

public client_infochanged(id)
{
	if(is_user_hltv(id) )
	{
		static oldName[32], newName[32];
		get_user_name(id, oldName, 31);
		get_user_info(id, "name", newName, 31);
		
		if(!equal(oldName, newName) )
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public client_connect(id)  // PRIMERO
{
	FakeAdmHltv[id] = false;
	
	if(is_user_admin(id) && get_pcvar_num(p_HltvBugFix) )
	{
		static szAdmName[32], szHLTVname[48];
		get_user_name(id, szAdmName, 31);
		
		for(new i = 1; i <= g_MaxPlayers; i++)
		{
			if(!is_user_hltv(i) ) continue;
			if(is_user_alive(i) ) continue;
			
			get_user_name(i, szHLTVname, 31);
			
			if(containi(szHLTVname, szAdmName) != -1)
			{
				if(get_pcvar_num(p_HltvBugFix) == 1)
				{
					new iD = get_user_userid(i);
					server_cmd("kick #%d", iD);
				}
				else if(get_pcvar_num(p_HltvBugFix) == 2)
				{
					if(FakeAdmHltv[i]) return;
					
					if(containi(szHLTVname, "Valid") != -1)
					{
						replace(szHLTVname, 47, "Valid", "Fake Adm");
					}
					else
					{
						format(szHLTVname, 47, "%s %s", BadAdm, szHLTVname);
					}
					
					set_user_info(i, "name", szHLTVname);
				}
			}
		}
	}
}

public client_disconnect(id)
{
	if(is_user_hltv(id) )
		hltvCount--;
}

public client_putinserver(id) // SEGUNDO
{
	if(!get_pcvar_num(p_Enable) )
		return PLUGIN_HANDLED;
	
	if(is_user_hltv(id) )
	{
		new userid = get_user_userid(id);
		
		if(!get_pcvar_num(p_HltvPermited) )
		{
			server_cmd("kick #%d", userid);
			return PLUGIN_HANDLED;
		}
		
		if(++hltvCount == (get_pcvar_num(p_HltvPermited) + 1) )
		{
			server_cmd("kick #%d", userid);
			hltvCount--;
			return PLUGIN_HANDLED;
		}
		
		CheckNickHltv(id);
	}
	
	return PLUGIN_HANDLED;
}

CheckNickHltv(id) 
{
	static HLTVname[48];
	get_user_name(id, HLTVname, 31);
	
	if(get_pcvar_num(p_HltvBugFix) )
	{
		if(!gAdminsNum)
		{
			return PLUGIN_HANDLED;
		}
		
		static szAdminFound[32];
		for(new i = 0; i < gAdminsNameFound; i++)
		{
			ArrayGetString(AdminsUserIni, i, szAdminFound, 32);
			
			if(containi(HLTVname, szAdminFound) != -1)
			{
				if(get_pcvar_num(p_HltvBugFix) == 1)
				{
					new userid = get_user_userid(id);
					server_cmd("kick #%d", userid);
					hltvCount--;
				}
				else if(get_pcvar_num(p_HltvBugFix) == 2)
				{
					FakeAdmHltv[id] = true;
				}
				
				return PLUGIN_HANDLED;
			}
		}
	}
	
	if(get_pcvar_num(p_ForcePrefix) )
	{
		if(!(containi(HLTVname, "HLTV") != -1) )
		{
			format(HLTVname, 47, "%s %s", Prefix, HLTVname);
			set_user_info(id, "name", HLTVname);
		}
	}
	
	return PLUGIN_HANDLED;
}

CheckAdminsUserIni()
{
	static szAdminFound[32];
	for(new i = 0; i < gAdminsNum; i++)
	{
		admins_lookup(i, AdminProp_Auth, szAdminFound, 31);
		
		if(containi(szAdminFound, "STEAM_") != -1)
		{
			ArrayPushString(AuthUserIni, szAdminFound);
			gAdminsAuthFound++;
		}
		else
		{
			ArrayPushString(AdminsUserIni, szAdminFound);
			gAdminsNameFound++;
		}
	}
	
	return 1;
}
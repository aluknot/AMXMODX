#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>

#define PLUGIN "Realistic Defuse"
#define AUTHOR "Alucard"
#define VERSION "1.4"

#define DEFUSE_RECIVED1 "/weapons/mine_activate.wav"
#define DEFUSE_RECIVED2 "/weapons/reload1.wav"
#define DEFUSE_RECIVED3 "/items/ammopickup1.wav"

#define NO_MONEY "/items/medshotno1.wav"

// Booleans
new bool:FirstSpawn[33], bool:NewDefuse

// Pcvars
new p_RemoveDefuse, p_BuyDefuse, p_DefuseCost, p_BuyZone, p_Defuses, p_ColorDefuse, p_BlockDefuse
new p_PluginTag, p_Enabler, p_BuySound, p_RemoveImmunity, p_BlockImmunity, p_DefuseReward

// Defuse Color
new Color[12], rgb[3][4], iRed, iGreen, iBlue

// Others
new Tag[32], Menu, Defuses

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	// GameMonitor
	register_cvar("real_defuse", VERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	// Forwards
	RegisterHam(Ham_Use, "grenade", "C4Used")
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn")
	
	// Events
	register_event("StatusIcon", "Event_StatusIcon_defuser", "be", "1=1", "2=defuser")
	
	// Pcvars
	p_RemoveDefuse = register_cvar("defuse_remove", "1")
	p_RemoveImmunity = register_cvar("defuse_remove_immunity", "1")
	p_Defuses = register_cvar("defuse_times", "3")
	p_BlockDefuse = register_cvar("defuse_block", "1")
	p_BlockImmunity = register_cvar("defuse_block_immunity", "1")
	p_DefuseReward = register_cvar("defuse_reward", "1")
	p_PluginTag = register_cvar("defuse_plugintag", "Realistic Defuse")
	
	p_BuyDefuse = register_cvar("new_defuse", "1")
	p_BuyZone = register_cvar("new_defuse_buyzone", "1")
	p_BuySound = register_cvar("new_defuse_sound", "1")
	p_DefuseCost = register_cvar("new_defuse_cost", "500")
	p_ColorDefuse = register_cvar("new_defuse_color", "0 0 255")
	
	p_Enabler = register_cvar("rd_enable", "1")
	
	// Commands
	register_clcmd("say /defuse", "MenuDefuse")
	
	// Multilingual
	register_dictionary("real_defuse.txt")
	
	// Others
	get_pcvar_string(p_PluginTag, Tag, 31)
	
	if(!get_pcvar_num(p_Enabler) )
		pause("a")
}

public MenuDefuse(id)
{
	if(!get_pcvar_num(p_BuyDefuse) )
	{
		client_print(id, print_chat, "%L", id, "ND_DESACTIVED", Tag)
		return PLUGIN_HANDLED
	}
	if(cs_get_user_defuse(id) )
	{
		client_print(id, print_chat, "%L", id, "ND_HAS_DEFUSE", Tag)
		return PLUGIN_HANDLED
	}	
	if(!is_user_alive(id) )
	{
		client_print(id, print_chat, "%L", id, "ND_ALIVE", Tag)
		return PLUGIN_HANDLED
	}
	if(get_user_team(id) != 2)
	{
		client_print(id, print_chat, "%L", id, "ND_T_CANT", Tag)
		return PLUGIN_HANDLED	
	}
	if(get_pcvar_num(p_BuyZone) && !cs_get_user_buyzone(id) )
	{
		client_print(id, print_chat, "%L", id, "ND_BUYZONE", Tag)
		return PLUGIN_HANDLED
	}
	
	static Items[64]
	
	formatex(Items, charsmax(Items), "%L", id, "MENU_TITLE")
	Menu = menu_create(Items, "BuyDefuse")	
	
	formatex(Items, charsmax(Items), "%L", id, "MENU_YES")
	menu_additem(Menu, Items, "1")
	
	formatex(Items, charsmax(Items), "%L", id, "MENU_NO")
	menu_additem(Menu, Items, "2")
	
	menu_addblank(Menu)
	menu_addblank(Menu)
	menu_addblank(Menu)
	
	formatex(Items, charsmax(Items), "%L", id, "MENU_TEXT", get_pcvar_num(p_DefuseCost))
	menu_addtext(Menu, Items)
	
	menu_setprop(Menu, MPROP_EXIT, MEXIT_NEVER)
	
	menu_display(id, Menu)
	
	BuyIconOff(id)
	
	return PLUGIN_HANDLED
}

public BuyDefuse(id, Menu, item)
{
	new iData[6]
	new iAccess
	new iCallback
	new iName[64]
	
	menu_item_getinfo(Menu, item, iAccess, iData, 5, iName, 63, iCallback)
	
	switch(str_to_num(iData))
	{
		case 1:
		{
			if(get_pcvar_num(p_BuyZone) && !cs_get_user_buyzone(id) ) // ppl cant bug with this!!!
			{
				client_print(id, print_chat, "%L", id, "ND_BUYZONE", Tag)
				return PLUGIN_HANDLED
			}
			
			if(!is_user_alive(id) ) // ppl cant bug with this!!!
			{
				client_print(id, print_chat, "%L", id, "ND_ALIVE", Tag)
				return PLUGIN_HANDLED
			}
			
			new cash, cost
			cash = cs_get_user_money(id)
			cost = get_pcvar_num(p_DefuseCost)
			
			if(cash < cost)
			{
				client_print(id, print_chat, "%L", id, "ND_MONEY", Tag)
				
				if(get_pcvar_num(p_BuySound) )
					client_cmd(id, "spk %s", NO_MONEY)
			}
			else
			{
				get_pcvar_string(p_ColorDefuse, Color, charsmax(Color) )
				parse(Color, rgb[0], 3, rgb[1], 3, rgb[2], 3)
				
				iRed = clamp(str_to_num(rgb[0]), 0, 255)
				iGreen = clamp(str_to_num(rgb[1]), 0, 255)
				iBlue = clamp(str_to_num(rgb[2]), 0, 255)
				
				cs_set_user_money(id, cash - cost)
				cs_set_user_defuse(id, 1, iRed, iGreen, iBlue)
				client_print(id, print_chat, "%L", id, "ND_RECIVED", Tag)
				NewDefuse = true
				
				switch(get_pcvar_num(p_BuySound) )
				{
					case 1:
					client_cmd(id, "spk %s", DEFUSE_RECIVED1)
					case 2:
					client_cmd(id, "spk %s", DEFUSE_RECIVED2)
					case 3:
					client_cmd(id, "spk %s", DEFUSE_RECIVED3)
				}
			}
			BuyIconOn(id)
		}
		case 2:
		{
			client_print(id, print_chat, "%L", id, "ND_BUY_DEFUSE", Tag)
			BuyIconOn(id)
		}
	}
	return PLUGIN_HANDLED
}

public bomb_defused(defuser)
{
	if(!get_pcvar_num(p_BlockDefuse) && get_pcvar_num(p_DefuseReward) && !cs_get_user_defuse(defuser) )
	{
		cs_set_user_defuse(defuser, 1)
		return PLUGIN_HANDLED
	}
	
	if(get_pcvar_num(p_RemoveDefuse) && cs_get_user_defuse(defuser) &&!NewDefuse)
	{	
		if(get_pcvar_num(p_RemoveImmunity) && is_user_admin(defuser) )
			return PLUGIN_HANDLED
		
		new num = get_pcvar_num(p_Defuses)
		
		if( (++Defuses == num) || num == 0)
		{
			cs_set_user_defuse(defuser, 0)
			Defuses = 0
		}
	}
	return PLUGIN_HANDLED
}

public client_putinserver(id)
	FirstSpawn[id] = true

public client_disconnect(id)
	FirstSpawn[id] = true

public PlayerSpawn(id)
{
	if(FirstSpawn[id])
	{
		client_print(id, print_chat, "[%s] This server is using Realistic Defuse by %s", Tag, AUTHOR)
		if(get_pcvar_num(p_BuyDefuse) )
			client_print(id, print_chat, "%L", id, "SPAWN_MESSAGE", Tag)
	}
	FirstSpawn[id] = false
}


public C4Used(iC4, id, idactivator, use_type, Float:value)
{
	if(use_type != 2 || value != 1.0 || get_user_team(id) != 2)
		return HAM_IGNORED
	
	if(get_pcvar_num(p_BlockImmunity) && is_user_admin(id) )
		return HAM_IGNORED
	
	if(!cs_get_user_defuse(id) && get_pcvar_num(p_BlockDefuse) )
	{
		client_print(id, print_center, "%L", id, "BD_MESSAGE", Tag)
		return HAM_SUPERCEDE
	}
	
	return HAM_IGNORED
} 

public Event_StatusIcon_defuser(id) // prevents the color change on respawn!!! Thx Connor
{
	if(NewDefuse)
		cs_set_user_defuse(id, 1, iRed, iGreen, iBlue)
} 

public BuyIconOn(id)
{
	message_begin(MSG_ONE, get_user_msgid("StatusIcon"), _, id)
	write_byte(1)
	write_string("buyzone")
	write_byte(0)
	write_byte(160)
	write_byte(0)
	message_end()
} 

public BuyIconOff(id)
{
	message_begin(MSG_ONE, get_user_msgid("StatusIcon"), _, id)
	write_byte(0)
	write_string("buyzone")
	message_end()
}  
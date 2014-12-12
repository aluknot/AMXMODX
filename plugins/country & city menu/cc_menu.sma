///////////////////////////////////////
//  Credits...                	     //
//                            	     //
//  Arkshine, xPaw, joropito, Kiske  //
//                            	     //
///////////////////////////////////////

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <geoip>

#define PLUGIN	"Country & City Menu"
#define AUTHOR	"Alucard"
#define VERSION	"1.3"

//--------------------START EDIT------------------------//

#define DURATION	8.0

#define RED		255
#define GREEN	255
#define BLUE	255

#define POS_X	0.02
#define POS_Y	0.23

#define is_user_admin2(%1)  (get_user_flags(%1) & ADMIN_KICK)

#define CMD_FLAG	ADMIN_ALL

//--------------------END EDIT-------------------------//

new Ip1[48], Ip2[48]

new g_msgSayText, g_Cstrike

new p_ShowMode, p_OnlyAdmins, p_ShowCode, p_EnablePlugin

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("cc_version", VERSION,FCVAR_SERVER|FCVAR_SPONLY)
	register_cvar("cc_author", AUTHOR,FCVAR_SERVER|FCVAR_SPONLY)
	
	register_clcmd("say /country", "CountryMenu")
	
	register_concmd("amx_distance", "HookCmdDistance", CMD_FLAG, "<player1> <player2>")
	
	p_EnablePlugin = register_cvar("cc_enable", "1")
	p_ShowMode = register_cvar("cc_showmode", "1")
	p_ShowCode = register_cvar("cc_showcode", "1")
	p_OnlyAdmins = register_cvar("cc_onlyadmins", "0")
	
	g_msgSayText = get_user_msgid("SayText")
	g_Cstrike = cstrike_running()
}

public HookCmdDistance(id, level, cid)
{
	if(!get_pcvar_num(p_EnablePlugin) )
		return PLUGIN_HANDLED
	
	if(!cmd_access(id, level, cid, 3) )
		return PLUGIN_HANDLED
	
	new arg1[32], arg2[32], Name1[32], Name2[32]
	
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 31)
	
	new player1 = cmd_target(id, arg1, 7)
	new player2 = cmd_target(id, arg2, 7)
	
	if(!player1 && !player2)
		return PLUGIN_HANDLED
	
	get_user_ip(player1, Ip1, 47, 1)
	get_user_ip(player2, Ip2, 47, 1)
	
	get_user_name(player1, Name1, 31)
	get_user_name(player2, Name2, 31)
	
	client_print(id, print_console, "--------------------------------------------------------")
	client_print(id, print_console, "[ Target 1: %s | Target 2: %s ]", Name1, Name2)
	client_print(id, print_console, "Distance: %f", geoip_distance(geoip_latitude(Ip1), geoip_longitude(Ip1), geoip_latitude(Ip2), geoip_longitude(Ip2) ) )
	client_print(id, print_console, "--------------------------------------------------------")
	
	return PLUGIN_HANDLED
}

public CountryMenu(id)
{
	if(!get_pcvar_num(p_EnablePlugin) )
		return PLUGIN_CONTINUE
	
	if(!get_pcvar_num(p_ShowMode) )
		return PLUGIN_CONTINUE
	
	if(get_pcvar_num(p_OnlyAdmins) && !is_user_admin2(id) )
		return PLUGIN_CONTINUE
	
	new Menu = menu_create("\rCountry Menu:", "CountryHandler")
	
	new szName[32], szTarget[10], players[32],
	Code2[3], Code3[4], Item[64], pnum, target
	
	get_players(players, pnum)
	
	for(new i; i < pnum; i++)
	{
		target = players[i]
		
		get_user_ip(target, Ip1, 47, 1)
		get_user_name(target, szName, 31)
		
		num_to_str(target, szTarget, 9)
		
		geoip_code2_ex(Ip1, Code2)
		geoip_code3_ex(Ip1, Code3)
		
		if(get_pcvar_num(p_ShowCode) == 0)
			formatex(Item, 63, "%s", szName)
		else if(get_pcvar_num(p_ShowCode) == 1)
			formatex(Item, 63, "%s \y[%s]", szName, Code2)
		else if(get_pcvar_num(p_ShowCode) == 2)
			formatex(Item, 63, "%s \y[%s]", szName, Code3)
		else
			formatex(Item, 63, "%s \y[%s]", szName, Code3)
		
		menu_additem(Menu, Item, szTarget, 0)
	}
	
	if(g_Cstrike)
	{
		if(cs_get_user_buyzone(id) )
			BuyIcon(id, 0)
	}
	
	menu_display(id, Menu, 0)
	return PLUGIN_HANDLED
}

public CountryHandler(id, Menu, item)
{
	if( item == MENU_EXIT )
	{
		if(g_Cstrike)
		{
			if(cs_get_user_buyzone(id) )
				BuyIcon(id, 1)	
		}
		
		menu_destroy(Menu)
		return PLUGIN_HANDLED
	}
	
	new data[6], iName[64]
	new access, callback
	menu_item_getinfo(Menu, item, access, data,5, iName, 63, callback)
	
	new target = str_to_num(data)
	
	static szCountry[48], szCity[48], szName[32], szTimeZone[48]
	
	get_user_name(target, szName, 31)
	
	get_user_ip(target, Ip1, 47, 1)
	get_user_ip(id, Ip2, 47, 1)
	
	geoip_timezone(Ip1, szTimeZone, 47)
	geoip_country(Ip1, szCountry, 47)
	geoip_city(Ip1, szCity, 47)
	
	if(equal(szCountry, "error") )
	{
		if(!contain(Ip1, "192.168.") || !contain(Ip1, "10.") || !contain(Ip1, "172.") || equal(Ip1, "127.0.0.1") )
		{
			szCountry = "LAN"
			szCity = "LAN"
			szTimeZone = "LAN"
		}
		else if(equal(Ip1, "loopback") )
		{
			szCountry = "LAN Owner"
			szCity = "LAN Owner"
			szTimeZone = "LAN Owner"
		}
		else
		{
			szCountry = "Unknown Country"
			szCity = "Unknown City"
			szTimeZone = "Unknown TimeZone"
		}	
	}
	
	if(equal(szCity, "error") )
	{
		szCity = "Unknown City"
		szTimeZone = "Unknow TimeZone"
	}
	
	switch(get_pcvar_num(p_ShowMode) )
	{
		case 1:
		{
			if(g_Cstrike)
			{
				chat_color(id, "!gName: !y%s !t| !gCountry: !y%s !t| !gCity: !y%s !t| !gTime: !y%s", szName, szCountry, szCity, szTimeZone)
				chat_color(id, "!gDistance: !y%f !t[From you]", geoip_distance(geoip_latitude(Ip1), geoip_longitude(Ip1), geoip_latitude(Ip2), geoip_longitude(Ip2) ) )
			}
			else
			{
				client_print(id, print_chat, "!gName: !y%s !t| !gCountry: !y%s !t| !gCity: !y%s !t| !gTime: !y%s", szName, szCountry, szCity, szTimeZone)
				client_print(id, print_chat, "!gDistance: !y%f !t[From you]", geoip_distance(geoip_latitude(Ip1), geoip_longitude(Ip1), geoip_latitude(Ip2), geoip_longitude(Ip2) ) )
			}
		}
		case 2:
		{
			set_hudmessage(RED, GREEN, BLUE, POS_X, POS_Y, 0, 6.0, DURATION, 0.1, 0.2, -1)
			show_hudmessage(id, "Name: %s^nCountry: %s^nCity: %s^nTime: %s^nDistance: %f [From you]", szName, szCountry, szCity, szTimeZone, 
			geoip_distance(geoip_latitude(Ip1), geoip_longitude(Ip1), geoip_latitude(Ip2), geoip_longitude(Ip2) ) )
		}
		case 3:
		{
			static MotdChars[1536], iLen
			
			iLen = formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<html>" ) 
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<body bgcolor=#000000><font color=#FFFFFF face=Verdana size=4>")
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<center><font size=8 color=#3399FF><b><u>Country & City Info</u></b></font></center>")
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<br><br><br><center><font color=#CCCC00>Name:</font> %s</center>", szName)
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<center><font color=#CCCC00>Country:</font> %s</center>", szCountry)
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<center><font color=#CCCC00>City:</font> %s</center>", szCity)
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<center><font color=#CCCC00>Time:</font> %s</center>", szTimeZone)
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "<center><font color=#CCCC00>Distance:</font> %f [From you]</center>", 
			geoip_distance(geoip_latitude(Ip1), geoip_longitude(Ip1), geoip_latitude(Ip2), geoip_longitude(Ip2) ) )
			
			iLen += formatex(MotdChars[iLen], (charsmax(MotdChars) ) - iLen, "</font></body></html>" )
			
			show_motd(id, MotdChars, "Country & City Info") 
		}
	}
	
	if(g_Cstrike)
	{
		if(cs_get_user_buyzone(id) )
			BuyIcon(id, 1)
	}
	
	menu_destroy(Menu)
	return PLUGIN_HANDLED	
}


stock chat_color(const id, const input[], any:...)
{
	static msg[191]
	vformat(msg, 190, input, 3)
	
	replace_all(msg, 190, "!g", "^4")
	replace_all(msg, 190, "!y", "^1")
	replace_all(msg, 190, "!t", "^3")
	
	message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, id)
	write_byte(id)
	write_string(msg)
	message_end()
}

BuyIcon(id, iNum)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("StatusIcon"), _, id)
	write_byte(iNum)
	write_string("buyzone")
	write_byte(0)
	write_byte(160)
	write_byte(0)
	message_end()
}
#include <amxmodx>
#include <fakemeta>
#include <cstrike>

#define PLUGIN	"Simple Burst/Silencer Blocker"
#define AUTHOR	"Alucard"
#define VERSION	"1.1"

#define GLOCK "GLOCK18"
#define FAMAS "FAMAS"
#define USP "USP"
#define M4 "M4A1"

new p_BlockBurst, p_BlockSil, p_Fade, p_FadeBurstColor, p_FadeSilColor, p_FadeAlpha

new g_msgSayText, g_maxplayers, g_fade

stock Fade(id, red, green, blue, alpha)
{
	message_begin(MSG_ONE,g_fade,{0,0,0},id)
	write_short(1<<10)
	write_short(1<<10)
	write_short(1<<12)
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(alpha)
	message_end()
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("burst_silencer_blocker", VERSION,FCVAR_SERVER|FCVAR_SPONLY)
	
	g_msgSayText = get_user_msgid("SayText")
	g_maxplayers = get_maxplayers()
	
	register_forward(FM_CmdStart, "fwdCmdStart", 0)
	
	g_fade = get_user_msgid("ScreenFade")
	
	//[Cmds]
	register_clcmd("say /burst", "cmdBurst")
	register_clcmd("say !burst", "cmdBurst")
	register_clcmd("say /silencer", "cmdSil")
	register_clcmd("say !silencer", "cmdSil")
	
	//[Pcvars]
	p_BlockBurst = register_cvar("block_burst", "0")
	p_BlockSil = register_cvar("block_sil", "0")
	
	p_Fade = register_cvar("fade_enable", "0")
	p_FadeBurstColor = register_cvar("fade_burstcolor", "255 0 0")
	p_FadeSilColor = register_cvar("fade_silcolor", "0 255 255")
	p_FadeAlpha = register_cvar("fade_alpha", "20")
	
	//[Language]
	register_dictionary("b&s_blocker.txt")
}

public fwdCmdStart(id, ucHandle)
{	
	static button, wp
	
	button = get_uc(ucHandle, UC_Buttons)
	wp = get_user_weapon(id)
	
	if(button & IN_ATTACK2)
	{
		switch(wp)
		{
			case CSW_GLOCK18:
			if(get_pcvar_num(p_BlockBurst) == 1 || get_pcvar_num(p_BlockBurst) == 3)
			{
				set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK2)
				burst_message(id)
			}
			case CSW_FAMAS:
			if(get_pcvar_num(p_BlockBurst) == 2 || get_pcvar_num(p_BlockBurst) == 3)
			{
				set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK2)
				burst_message(id)
			}
			case CSW_USP:
			if(get_pcvar_num(p_BlockSil) == 1 || get_pcvar_num(p_BlockSil) == 3)
			{
				set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK2)
				sil_message(id)
			}
			case CSW_M4A1:
			if(get_pcvar_num(p_BlockSil) == 2 || get_pcvar_num(p_BlockSil) == 3)
			{
				set_uc(ucHandle, UC_Buttons, button &= ~IN_ATTACK2)
				sil_message(id)
			}
		}
	}
	return FMRES_IGNORED
}

public cmdBurst(id)
{
	switch(get_pcvar_num(p_BlockBurst) )
	{
		case 0:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "BF_NOT_BLOCKED")
		case 1:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "BF_BLOCKED_FOR", GLOCK)
		case 2:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "BF_BLOCKED_FOR", FAMAS)
		case 3:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "BF_BLOCKED_BOTH", GLOCK, FAMAS)
	}
	return PLUGIN_HANDLED
}

public cmdSil(id)
{
	switch(get_pcvar_num(p_BlockSil) )
	{
		case 0:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "S_NOT_BLOCKED")
		case 1:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "S_BLOCKED_FOR", USP)
		case 2:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "S_BLOCKED_FOR", M4)
		case 3:
		colored_print(id, "^x03[Blocker]^x01 %L", id, "S_BLOCKED_BOTH", USP, M4)
	}
	return PLUGIN_HANDLED
}

public burst_message(id)
{	
	client_print(id, print_center, "[Blocker] %L", id, "BF_YOUR_WEAPON")
	if(get_pcvar_num(p_Fade) )
	{
		new Color[12], rgb[3][4], iRed, iGreen, iBlue
		get_pcvar_string(p_FadeBurstColor, Color, charsmax(Color) )
		parse(Color, rgb[0], 3, rgb[1], 3, rgb[2], 3)
		
		iRed = clamp(str_to_num(rgb[0]), 0, 255)
		iGreen = clamp(str_to_num(rgb[1]), 0, 255)
		iBlue = clamp(str_to_num(rgb[2]), 0, 255)
		
		Fade(id, iRed, iGreen, iBlue, get_pcvar_num(p_FadeAlpha) )
	}
}

public sil_message(id)
{
	client_print(id, print_center, "[Blocker] %L", id, "S_YOUR_WEAPON")
	if(get_pcvar_num(p_Fade) )
	{
		new Color[12], rgb[3][4], iRed, iGreen, iBlue
		get_pcvar_string(p_FadeSilColor, Color, charsmax(Color) )
		parse(Color, rgb[0], 3, rgb[1], 3, rgb[2], 3)
		
		iRed = clamp(str_to_num(rgb[0]), 0, 255)
		iGreen = clamp(str_to_num(rgb[1]), 0, 255)
		iBlue = clamp(str_to_num(rgb[2]), 0, 255)
		
		Fade(id, iRed, iGreen, iBlue, get_pcvar_num(p_FadeAlpha) )
	}
}

colored_print(target, const message[], any:...)
{
	static buffer[512], i, argscount
	argscount = numargs()
	
	if (!target)
	{
		static player
		for (player = 1; player <= g_maxplayers; player++)
		{
			if (!is_user_connected(player))
				continue;
			
			static changed[5], changedcount
			changedcount = 0
			
			for (i = 2; i < argscount; i++)
			{
				if (getarg(i) == LANG_PLAYER)
				{
					setarg(i, 0, player)
					changed[changedcount] = i
					changedcount++
				}
			}
			
			vformat(buffer, charsmax(buffer), message, 3)
			
			message_begin(MSG_ONE_UNRELIABLE, g_msgSayText, _, player)
			write_byte(player)
			write_string(buffer)
			message_end()
			
			for (i = 0; i < changedcount; i++)
				setarg(changed[i], 0, LANG_PLAYER)
		}
	}
	
	vformat(buffer, charsmax(buffer), message, 3)
	
	message_begin(MSG_ONE, g_msgSayText, _, target)
	write_byte(target)
	write_string(buffer)
	message_end()
}
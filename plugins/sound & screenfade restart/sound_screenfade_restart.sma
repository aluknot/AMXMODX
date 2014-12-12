/* link pedido https://forums.alliedmods.net/showthread.php?p=1213089#post1213089 */

#include <amxmodx>

#define PLUGIN  "Restart with Sound & Screenfade"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

#define RESTART_TIME 10.0

#define DO_RESTART 2.0

new bool:g_RoundStart;

new const RestartSound[] = "restart/tu_sonido.wav";

new g_ScreenFade;

public plugin_precache()
{
    precache_sound(RestartSound);
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_logevent("HookRoundStart", 2, "1=Round_Start");
    register_message(get_user_msgid("RoundTime"), "HookRoundTime");

    g_ScreenFade = get_user_msgid("ScreenFade");
}

public HookRoundStart()
{
    g_RoundStart = true;
}

public HookRoundTime()
{
    if(g_RoundStart)
    {
        set_hudmessage(80, 80, 80, -1.0, 0.35, 2, 0.1, 2.0, 0.05, 1.0, -1);
        show_hudmessage(0, "Dentro de %d se producira un restart", floatround(RESTART_TIME) );

        client_cmd(0, "spk %s", RestartSound);

        set_task(RESTART_TIME, "TaskRestart");
        g_RoundStart = false;
    }
}

public TaskRestart()
{
    client_cmd(0, "stopsound");
    ScreenFade();

    set_task(DO_RESTART, "DoTheRestart");
}

public DoTheRestart()
    server_cmd("sv_restart 1");

stock ScreenFade()
{
    message_begin(MSG_ALL, g_ScreenFade, _, 0);
    write_short(2<<12);
    write_short(1<<12);
    write_short(1<<12);
    write_byte(0);
    write_byte(0);
    write_byte(0);
    write_byte(255);
    message_end();
}

/* link pedido https://forums.alliedmods.net/showthread.php?t=132217 */

#include <amxmodx>

#define PLUGIN  "HLDS Shutdown"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

#define HOUR    17
#define MINS    30

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    set_task(1.0, "CheckTime", .flags="b");
}

public CheckTime(id)
{
    new szMins[8], szHours[8], iMins, iHours;

    get_time("%M", szMins, 7); iMins = str_to_num(szMins);
    get_time("%H", szHours, 7); iHours = str_to_num(szHours);

    if(iMins == MINS && iHours == HOUR)
        server_cmd("quit");
}

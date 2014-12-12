/* pedido https://forums.alliedmods.net/showthread.php?t=133701 */

#include <amxmodx>
#include <fun>

#define PLUGIN  "Frag Limiter"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

#define FRAG_LIMIT 1000

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_event("ScoreInfo", "EventScoreInfo", "a");
}

public EventScoreInfo()
{
    new id = read_data(1);
    new iFrags = read_data(2);

    if(iFrags > FRAG_LIMIT)
    {
        set_user_frags(id, FRAG_LIMIT);
        client_print(id, print_chat, "Sorry you were over the limit. Your frags have been set to 1,000.");
    }
}

/* link pedido https://forums.alliedmods.net/showthread.php?t=109919 */

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN  "No Weaps at Spawn"
#define AUTHOR  "Alucard"
#define VERSION "1.0"

new const WeaponsName[][] =
{
    "c4",
    "shield",
    "p228",
    "shield",
    "scout",
    "xm1014",
    "mac10",
    "aug",
    "elite",
    "fiveseven",
    "ump45",
    "sg550",
    "galil",
    "famas",
    "usp",
    "glock18",
    "awp",
    "mp5navy ",
    "m249",
    "m3",
    "m4a1",
    "tmp",
    "g3sg1",
    "deagle",
    "sg552 ",
    "ak47",
    "p90"
}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)

    RegisterHam(Ham_Spawn, "player", "HookSpawnPL", 1)
}

public HookSpawnPL(id)
{
    if(is_user_alive(id) )
    {
        new weapons[32]
        for(new i = 0; i < sizeof(WeaponsName); i++)
        {
            formatex(weapons, charsmax(weapons), "weapon_%s", WeaponsName[i])
            ham_strip_weapon(id, weapons)
        }
    }
}

stock ham_strip_weapon(id,weapon[])
{
    if(!equal(weapon, "weapon_", 7) ) return 0

    new wId = get_weaponid(weapon)
    if(!wId) return 0

    new wEnt
    while( (wEnt = engfunc(EngFunc_FindEntityByString,wEnt,"classname", weapon) ) && pev(wEnt, pev_owner) != id) {}
    if(!wEnt) return 0

    if(get_user_weapon(id) == wId) ExecuteHamB(Ham_Weapon_RetireWeapon, wEnt)

    if(!ExecuteHamB(Ham_RemovePlayerItem, id, wEnt) ) return 0
    ExecuteHamB(Ham_Item_Kill ,wEnt)

    set_pev(id, pev_weapons, pev(id, pev_weapons) & ~(1<<wId) )

    return 1
}

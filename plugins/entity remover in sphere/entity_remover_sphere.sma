#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>

#define PLUGIN    "Entity Remover in Sphere"
#define AUTHOR    "Alucard"
#define VERSION    "0.0.1"

#define MAX_ENTS 5
#define MAX_ENTS_REMOVE 20

#define TASK_ID_CHECK 9999

#define RADIO 50.0

new const ENTS_REMOVED[] = "addons/amxmodx/configs/ERS";

new entTarget[33][MAX_ENTS];

new Array:gClass;
new Array:gModel;

new mapName[48], entsFile[128];

new TotalEnts;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_concmd("ers_remove", "HookCmdRemove", ADMIN_KICK);
    register_concmd("ers_reset", "HookCmdReset", ADMIN_KICK);
}

public plugin_precache()
{
    if(!dir_exists(ENTS_REMOVED) )
        mkdir(ENTS_REMOVED);

    gClass = ArrayCreate(32, 1);
    gModel = ArrayCreate(32, 1);

    get_mapname(mapName, charsmax(mapName) );
    formatex(entsFile, 127, "%s/%s.cfg", ENTS_REMOVED, mapName);

    LoadEntsRemoved();

    register_forward(FM_Spawn, "HookFmSpawn", 0);
}

public HookFmSpawn(ent)
{
    if(is_valid_ent(ent) )
    {
        //log_amx("FM_SPAWN");

        new szClass[32], szModel[32];
        entity_get_string(ent, EV_SZ_classname, szClass, 31);
        entity_get_string(ent, EV_SZ_model, szModel, 31);

        log_amx("FM_SPAWN totalents %d", TotalEnts);

        new loadClass[32], loadModel[32];
        for(new i = 0; i < TotalEnts; i++)
        {
            log_amx("FM_SPAWN ents %d", i);

            ArrayGetString(gClass, i, loadClass, 32);
            ArrayGetString(gModel, i, loadModel, 32);

            if(equal(szClass, loadClass) && equal(szModel, loadModel) )
            {
                log_amx("FM_SPAWN class: %s %s", szClass, loadClass);
                remove_entity(ent);
            }
        }
    }
}

public HookCmdReset(id, level, cid)
{
    if(!cmd_access(id, level, cid, 1) )
        return PLUGIN_HANDLED;

    if(file_exists(entsFile) )
    {
        delete_file(entsFile);
        client_print(id, print_console, "Archivo removido");
    }

    return PLUGIN_HANDLED;
}

public HookCmdRemove(id, level, cid)
{
    if(!cmd_access(id, level, cid, 1) )
        return PLUGIN_HANDLED;

    EntCount(id);
    return PLUGIN_HANDLED;
}

EntCount(id)
{
    new Float:fOrigin[3];
    entity_get_vector(id, EV_VEC_origin, fOrigin);

    new Menu = menu_create("\ySe encontraron las siguientes entidades:", "MenuEntDeleteHandler", 0);

    new iEnt, szNum[5], szClassname[32];
    new iNum, weap;
    while(iEnt = find_ent_in_sphere(iEnt, fOrigin, RADIO) )
    {
        /*if(iNum == MAX_ENTS)
        break;*/

        entity_get_string(iEnt, EV_SZ_classname, szClassname, 31);

        weap = find_ent_by_owner(-1, szClassname, id);

        if(iEnt == id || iEnt == weap) continue;
        if(contain(szClassname, "info_player_") != -1) continue;

        iNum++;
        num_to_str(iNum, szNum, 4);

        SetRendering(iEnt, kRenderFxNone, 255, 0, 0, kRenderTransColor, 255);
        menu_additem(Menu, szClassname, szNum, 0);

        entTarget[id][iNum-1] = iEnt // i am not sure, but i think this method is a crap, or not?
    }

    if(iNum > 0)
    {
        menu_display(id, Menu);
    }
    else
    client_print(id, print_chat, "No se encontro ninguna entidad alrededor");
}

public MenuEntDeleteHandler(id, Menu, item)
{
    if(item == MENU_EXIT)
    {
        menu_destroy(Menu);
        return PLUGIN_HANDLED;
    }

    new data[6], iName[64];
    new access, callback;
    menu_item_getinfo(Menu, item, access, data, 5, iName, 63, callback);

    new iEnt = entTarget[id][item];

    if(!is_valid_ent(iEnt) )
        return PLUGIN_HANDLED;

    SaveEntity(iEnt, iName);
    remove_entity(iEnt);

    //menu_destroy(Menu);
    return PLUGIN_HANDLED;
}

SaveEntity(iEnt, const Classname[])
{
    new szModel[32], szData[84];
    new f = fopen(entsFile, "at");

    entity_get_string(iEnt, EV_SZ_model, szModel, 31);

    formatex(szData, 83, "%s %s^n", Classname, szModel);
    fputs(f, szData);

    fclose(f);
}

LoadEntsRemoved()
{
    if(!file_exists(entsFile) )
        return 0;

    new szData[84], szClass[32], szModel[48];
    //new entModel[48], entClass[32];
    new f = fopen(entsFile, "rt");

    while(!feof(f) )
    {
        //log_amx("que ondis");

        fgets(f, szData, 83);
        parse(szData, szClass, 31, szModel, 47);

        ArrayPushString(gClass, szClass);
        ArrayPushString(gModel, szModel);

        TotalEnts++

        /*entity_get_string(ent, EV_SZ_model, entModel, 47);
        entity_get_string(ent, EV_SZ_classname, entClass, 31);

        if(equal(entClass, szClass) && equal(entModel, szModel) )
            remove_entity(ent);*/
    }

    fclose(f);

    return 1;
}

stock SetRendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
    new Float:RenderColor[3];
    RenderColor[0] = float(r);
    RenderColor[1] = float(g);
    RenderColor[2] = float(b);

    entity_set_int(entity, EV_INT_renderfx, fx);
    entity_set_vector(entity, EV_VEC_rendercolor, RenderColor);
    entity_set_int(entity, EV_INT_rendermode, render);
    entity_set_float(entity, EV_FL_renderamt, float(amount) );

    return 1;
}

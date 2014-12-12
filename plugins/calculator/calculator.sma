/*
*   AMX Mod X Script
*   ================
*
*      PLUGIN: Calculator
*      AUTHOR: Alucard^
*      VERSION: 0.0.1
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*
*                   This program is free software; you can redistribute it and/or modify it
*          under the terms of the GNU General Public License as published by the
*                   Free Software Foundation; either version 2 of the License, or (at
*                   your option) any later version.
*
*                   This program is distributed in the hope that it will be useful, but
*                   WITHOUT ANY WARRANTY; without even the implied warranty of
*                   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*                   General Public License for more details.
*
*              You should have received a copy of the GNU General Public License
*                   along with this program; if not, write to the Free Software Foundation,
*                   Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
*/

#include <amxmodx>
#include <amxmisc>

#define PLUGIN  "Calculator"
#define AUTHOR  "Alucard"
#define VERSION "0.0.1"

#define MAX_CHAR 32

new bool:g_CalActive[33];

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);

    register_clcmd("say", "HookSayPlr");
    register_clcmd("say_team", "HookSayPlr");

    register_clcmd("say /calculator", "HookCmdCalculator");
}

public client_connect(id)
    g_CalActive[id] = false;

public HookCmdCalculator(id)
{
    g_CalActive[id] = !g_CalActive[id];

    client_print(id, print_chat, "La calculadora esta %sactivada", g_CalActive[id] ? "" : "des");
}

public HookSayPlr(id)
{
    if(!g_CalActive[id])
        return PLUGIN_CONTINUE;

    new szSay[192];
    read_args(szSay, 191);
    remove_quotes(szSay); trim(szSay);

    if(szSay[0] == ' ' || !isdigit(szSay[0]) || strfind(szSay, ".") )
        return PLUGIN_CONTINUE;

    static const HexOperators[5] =
    {
        0x2A, 0x2B, 0x2C, 0x2F, 0x5E
    };

    new bool:CanCalculate;

    static hexChar;

    for(new i = 0; i < sizeof(HexOperators); i++)
    {
        if(contain(szSay, HexOperators[i]) != -1)
        {
            CanCalculate = true;
            hexChar = HexOperators[i];
            break;
        }
    }

    if(!CanCalculate)
        return PLUGIN_CONTINUE;

    new iLeft[MAX_CHAR], iRight[MAX_CHAR], iLeftValue, iRightValue;
    strtok(szSay, iLeft, charsmax(iLeft), iRight, charsmax(iRight), hexChar, 1);

    iLeftValue = str_to_num(iLeft); iRightValue = str_to_num(iRight);

    switch(hexChar)
    {
        case 0x2A: iLeftValue *= iRightValue;
        case 0x2B: iLeftValue += iRightValue;
        case 0x2C: iLeftValue -= iRightValue;
        case 0x2F: iLeftValue /= iRightValue;
        case 0x5E: iLeftValue ^= iRightValue; // si no funca seria: power(iLeftValue, iRightValue);
    }

    client_print(id, print_chat, "Resultado %d", iLeftValue);

    return PLUGIN_HANDLED_MAIN;
} 

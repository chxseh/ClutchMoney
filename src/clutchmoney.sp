#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdktools_gamerules>
#include <cstrike>

public Plugin myinfo = {
    name = "clutchmoney",
    author = "Chase <c@chse.dev> (https://chse.dev)",
    description = "During a 1vX situation, you get 2x the normal kill bonus.",
    version = "1.0",
    url = "https://github.com/chxseh/clutchmoney"
};

public OnPluginStart() {
    HookEvent("player_death", DeathEvent);
}

public DeathEvent(Handle: event,
    const String: name[], bool: dontBroadcast) {
    if (GameRules_GetProp("m_bWarmupPeriod") == 1)
        return; // Ignore Warmup
    new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!IsValidPlayer(attacker) || victim == attacker)
        return; // Attacker is not a player or it was a suicide
    int aliveTeammates = 0;
    for (new i = 1; i <= MaxClients; i++) {
        if (IsValidPlayer(i) && GetClientTeam(i) == GetClientTeam(attacker) && IsPlayerAlive(i)) {
            aliveTeammates++;
        }
    }
    if (aliveTeammates > 1)
        return; // Not a clutch
    new String: weaponName[80];
    GetEventString(event, "weapon", weaponName, sizeof(weaponName));
    new bonus = GetWeaponKillBonus(weaponName);
    AddMoney(attacker, bonus); // Give the attacker the bonus amount
    if (bonus != 0)
        PrintToChat(attacker, " \x01\x06+$%d\x01: Award for clutching.", bonus);
}

// Returns the kill bonus for a weapon, based on its name
stock GetWeaponKillBonus(const String: weaponName[]) {
    if ((StrEqual(weaponName, "glock", false) || StrEqual(weaponName, "hkp2000", false) || StrEqual(weaponName, "usp_silencer", false) ||
            StrEqual(weaponName, "elite", false) || StrEqual(weaponName, "p250", false) || StrEqual(weaponName, "tec9", false) ||
            StrEqual(weaponName, "fiveseven", false) || StrEqual(weaponName, "deagle", false)))
        return 300; // Pistols @ $300.
    if (StrEqual(weaponName, "cz75a", false))
        return 100; // CZ75 @ $100.
    if (StrEqual(weaponName, "nova", false) || StrEqual(weaponName, "xm1014", false) || StrEqual(weaponName, "sawedoff", false) || StrEqual(weaponName, "mag7", false))
        return 900; // Shotguns @ $900.
    if (StrEqual(weaponName, "m249", false) || StrEqual(weaponName, "negev", false))
        return 300; // LMGs @ $300.
    if (StrEqual(weaponName, "mac10", false) || StrEqual(weaponName, "mp9", false) || StrEqual(weaponName, "mp7", false) || StrEqual(weaponName, "ump45", false) || StrEqual(weaponName, "bizon", false))
        return 600; // SMGs @ $600.
    if (StrEqual(weaponName, "p90", false))
        return 300; // P90 @ $300.
    if (StrEqual(weaponName, "galilar", false) || StrEqual(weaponName, "famas", false) || StrEqual(weaponName, "ak47", false) || StrEqual(weaponName, "m4a1", false) || StrEqual(weaponName, "m4a1_silencer", false) || StrEqual(weaponName, "ssg08", false) || StrEqual(weaponName, "sg556", false) || StrEqual(weaponName, "aug", false) || StrEqual(weaponName, "g3sg1", false) || StrEqual(weaponName, "scar20", false))
        return 300; // Rifles @ $300.
    if (StrEqual(weaponName, "awp", false))
        return 100; // AWP @ $100.
    if (StrEqual(weaponName, "incgrenade", false) || StrEqual(weaponName, "flashbang", false) || StrEqual(weaponName, "hegrenade	", false) || StrEqual(weaponName, "decoy", false) || StrEqual(weaponName, "smokegrenade", false) || StrEqual(weaponName, "taser", false) || StrEqual(weaponName, "molotov", false))
        return 300; // Grenades & Zeus @ $300.
    if (StrContains(weaponName, "knife", false) != -1)
        return 1500; // Knife @ $1500.
    return 300; // Unknown weapon, give "default".
}

AddMoney(client, amount) {
    new clientMoney = GetEntProp(client, Prop_Send, "m_iAccount");
    clientMoney += amount;
    Handle maxMoneyHandle = FindConVar("mp_maxmoney");
    int maxMoney = GetConVarInt(maxMoneyHandle);
    if (clientMoney > maxMoney)
        clientMoney = maxMoney;
    SetEntProp(client, Prop_Send, "m_iAccount", clientMoney);
}

bool: IsValidPlayer(client) {
    if (client < 1 || client > MaxClients || !IsClientConnected(client))
        return false;
    return IsClientInGame(client);
}

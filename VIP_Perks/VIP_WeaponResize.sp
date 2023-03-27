#include <sourcemod>
#include <morecolors>
#include <clientprefs>
#include <sdktools>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define MIN_SIZE 1.0
#define MAX_SIZE 4.0
#define MELEE_SLOT 2

Handle g_hCookie;

float g_fWeaponSize[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[TF2] VIP - Weapon Resize", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hCookie = RegClientCookie("vip_weaponsize", "Weapon size of VIP players", CookieAccess_Protected);
	
	HookEvent("post_inventory_application", Event_PlayerRegen);
	
	RegConsoleCmd("sm_rw", Command_ResizeWeapon, "Resize Your Weapon (Short)");
	RegConsoleCmd("sm_resizeweapon", Command_ResizeWeapon, "Resize Your Weapon");
}

/* Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[10];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		if (szBuffer[0] != 0)
			g_fWeaponSize[client] = StringToFloat(szBuffer);
		else
			g_fWeaponSize[client] = 0.0;
	}
}

public void OnClientDisconnect(int client)
{
	g_fWeaponSize[client] = 0.0;
}

public Action Event_PlayerRegen(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(client))
	{
		if (g_fWeaponSize[client])
			ResizeWeapons(client);
	}
	
	return Plugin_Continue;
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("rw", "Resize Weapon");
}

/* */

/* Commands */

public Action Command_ResizeWeapon(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	if (args != 1)
	{
		CReplyToCommand(client, "%s Usage: sm_resizeweapon <1.0{axis}~{default}4.0>", PREFIX);
		return Plugin_Handled;
	}
	
	char szArg[10];
	GetCmdArg(1, szArg, sizeof(szArg));
	
	float fSize = StringToFloat(szArg);
	if (!(MIN_SIZE <= fSize <= MAX_SIZE))
	{
		CReplyToCommand(client, "%s The size must be between {axis}%f {default}to {axis}%f{default}.", PREFIX, MIN_SIZE, MAX_SIZE);
		return Plugin_Handled;
	}
	
	g_fWeaponSize[client] = fSize;
	
	char szBuffer[10];
	FloatToString(fSize, szBuffer, sizeof(szBuffer));
	SetClientCookie(client, g_hCookie, szBuffer);
	
	if (IsPlayerAlive(client))
		ResizeWeapons(client);
	
	CPrintToChat(client, "%s Changed weapons size to {axis}%.2f{default}.", PREFIX, fSize);
	return Plugin_Handled;
}

/* */

/* Functions */

void ResizeWeapons(int client)
{
	int iWeapon;
	for (int i = 0; i <= MELEE_SLOT; i++)
	{
		iWeapon = GetPlayerWeaponSlot(client, i);
		if (iWeapon != -1)
			SetEntPropFloat(iWeapon, Prop_Send, "m_flModelScale", g_fWeaponSize[client]);
	}
}

/* */
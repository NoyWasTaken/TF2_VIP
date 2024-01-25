#include <sourcemod>
#include <morecolors>
#include <clientprefs>
#include <sdktools>
#include <tf2items_giveweapon>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define MELEE_SLOT 2
#define SAXXY_INDEX 423

Handle g_hCookie;

bool g_bSaxxy[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[TF2] VIP - Saxxy", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hCookie = RegClientCookie("vip_saxxy", "Spawn a saxxy weapon every round for VIP player", CookieAccess_Protected);
	
	HookEvent("post_inventory_application", Event_PlayerRegen);
	
	RegConsoleCmd("sm_saxxy", Command_Saxxy, "Gives a Saxxy Weapon");
}

/* Hooks, Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[16];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		if (!strcmp(szBuffer, "true"))
			g_bSaxxy[client] = true;
		else
			g_bSaxxy[client] = false;
	}
}

public void OnClientDisconnect(int client)
{
	g_bSaxxy[client] = false;
}

public Action Event_PlayerRegen(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(client))
	{
		if (g_bSaxxy[client])
			TF2Items_GiveWeapon(client, SAXXY_INDEX);
	}
	
	return Plugin_Continue;
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("saxxy", "Toggle Saxxy");
}

/* */

/* Commands */

public Action Command_Saxxy(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	g_bSaxxy[client] = !g_bSaxxy[client];
	SetClientCookie(client, g_hCookie, g_bSaxxy[client] ? "true":"false");
	
	if (g_bSaxxy[client])
	{
		if (IsPlayerAlive(client))
		{
			int iMelee = GetPlayerWeaponSlot(client, MELEE_SLOT);
			if (iMelee > MaxClients && IsValidEdict(iMelee) && GetEntProp(iMelee, Prop_Send, "m_iItemDefinitionIndex") != SAXXY_INDEX)
				TF2Items_GiveWeapon(client, SAXXY_INDEX);
		}
	}
	
	CPrintToChat(client, "%s %s the {axis}Saxxy{default}.", PREFIX, g_bSaxxy[client] ? "Enabled":"Disabled");
	return Plugin_Handled;
}

/* */
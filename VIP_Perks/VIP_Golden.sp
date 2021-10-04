#include <sourcemod>
#include <regex>
#include <morecolors>
#include <clientprefs>
#include <tf2items>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

Handle g_hCookie;
Handle g_hGoldItem;

bool g_bGolden[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[TF2] VIP - Golden Kills", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hCookie = RegClientCookie("vip_golden", "Golden perk of VIP users", CookieAccess_Protected);
	
	RegConsoleCmd("sm_golden", Command_Golden);
	
	g_hGoldItem = TF2Items_CreateItem(48);
	TF2Items_SetNumAttributes(g_hGoldItem, 1);
	TF2Items_SetAttribute(g_hGoldItem, 0, 150, 1.0);
}

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[10];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		g_bGolden[client] = !strcmp(szBuffer, "true");
	}
}

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (VIP_IsPlayerVIP(client) && g_bGolden[client])
	{
		hItem = g_hGoldItem;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("golden", "Toggle Golden Statues");
}

/* Commands */

public Action Command_Golden(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	g_bGolden[client] = !g_bGolden[client];
	SetClientCookie(client, g_hCookie, g_bGolden[client] ? "true":"false");
	
	CPrintToChat(client, "%s %s the {gold}Golden Status{default}.", PREFIX, g_bGolden[client] ? "Enabled":"Disabled");
	return Plugin_Handled;
}

/* */
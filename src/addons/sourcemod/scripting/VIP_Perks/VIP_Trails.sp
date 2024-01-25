#include <sourcemod>
#include <sdktools>
#include <morecolors>
#include <clientprefs>
#include <tf2attributes>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define TRAIL_COUNT 18

Handle g_hCookie;

char g_szFootPrints[TRAIL_COUNT][32] = 
{
	"No Effect", 
	"Team Based", 
	"Blue", 
	"Light Blue", 
	"Yellow", 
	"Corrupted Green", 
	"Dark Green", 
	"Lime", 
	"Brown", 
	"Oak Tree Brown", 
	"Flames", 
	"Cream", 
	"Pink", 
	"Satan's Blue", 
	"Purple", 
	"4 8 15 16 23 42", 
	"Ghost In The Machine", 
	"Holy Flame"
};

int g_iTrail[MAXPLAYERS + 1];
int g_iFootPrintsID[TRAIL_COUNT] = {
	0, 
	1, 
	7777, 
	933333, 
	8421376, 
	4552221, 
	3100495, 
	51234123, 
	5322826, 
	8355220, 
	13595446, 
	8208497, 
	41234123, 
	300000, 
	2, 
	3, 
	83552, 
	9335510
};

public Plugin myinfo = 
{
	name = "[TF2] VIP - Trails", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hCookie = RegClientCookie("vip_trail", "Trail of VIP users", CookieAccess_Protected);
	
	HookEvent("post_inventory_application", Event_PlayerRegen);
	
	RegConsoleCmd("sm_trails", Command_Trails, "Opens The Trails Menu");
	RegConsoleCmd("sm_footprints", Command_Trails, "Opens The Trails Menu");
}

/* Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[10];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		if (szBuffer[0] != 0)
			g_iTrail[client] = StringToInt(szBuffer);
		else
			g_iTrail[client] = 0;
	}
}

public Action Event_PlayerRegen(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(client))
	{
		if (g_iTrail[client])
			TF2Attrib_SetByName(client, "SPELL: set Halloween footstep type", float(g_iFootPrintsID[g_iTrail[client]]));
	}
	
	return Plugin_Continue;
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("trails", "Footprints Menu");
}

/* */

/* Commands */

public Action Command_Trails(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	Menu_ShowTrails(client);
	return Plugin_Handled;
}

/* */

/* Menus */

void Menu_ShowTrails(int client)
{
	Menu menu = new Menu(Handler_Trails);
	menu.SetTitle("%s Select a Trail\n ", PREFIX_MENU);
	
	for (int i = 0; i < sizeof(g_szFootPrints); i++)
	{
		menu.AddItem(g_szFootPrints[i], g_szFootPrints[i]);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_Trails(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		FakeClientCommandEx(client, "sm_vip");
	} else if (action == MenuAction_Select) {
		g_iTrail[client] = itemNum;
		
		if (g_iTrail[client] == 0)
			TF2Attrib_RemoveByName(client, "SPELL: set Halloween footstep type");
		else
			TF2Attrib_SetByName(client, "SPELL: set Halloween footstep type", float(g_iFootPrintsID[g_iTrail[client]]));
		
		char szBuffer[10];
		IntToString(itemNum, szBuffer, sizeof(szBuffer));
		SetClientCookie(client, g_hCookie, szBuffer);
		
		CPrintToChat(client, "%s Changed trail to: %s.", PREFIX, g_szFootPrints[itemNum]);
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

/* */
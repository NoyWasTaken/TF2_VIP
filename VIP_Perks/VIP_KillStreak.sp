#include <sourcemod>
#include <morecolors>
#include <sdktools>
#include <VIP_Core>
#include <tf2attributes>
#include <clientprefs>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define MAX_TYPES 4
#define MAX_EFFECTS 8
#define MAX_SHEENS 8
#define MAX_WEAPONS 8

#define SETTING_TYPE 0
#define SETTING_EFFECT 1
#define SETTING_SHEEN 2
#define MAX_SETTINGS 3
#define KILLSTREAK_COUNT 100

#define KILLSTREAK_EFFECT_ATTRIBUTE 2013
#define KILLSTREAK_SHEEN_ATTRIBUTE 2014
#define KILLSTREAK_TIER_ATTRIBUTE 2025

Handle g_hTypeCookie;
Handle g_hEffectCookie;
Handle g_hSheenCookie;

float g_fTypes[MAX_TYPES] = {
	0.0, 
	1.0, 
	2.0, 
	3.0
}

float g_fEffects[MAX_EFFECTS] = {
	0.0, 
	2002.0, 
	2003.0, 
	2004.0, 
	2005.0, 
	2006.0, 
	2007.0, 
	2008.0
}

float g_fSheens[MAX_SHEENS] = {
	0.0, 
	1.0, 
	2.0, 
	3.0, 
	4.0, 
	5.0, 
	6.0, 
	7.0
}

int g_iSettings[MAXPLAYERS + 1][MAX_SETTINGS];

char g_szTypes[MAX_TYPES][64] = {
	"None", 
	"Normal Killstreak", 
	"Specialized Killstreak", 
	"Professional Killstreak"
}

char g_szEffects[MAX_EFFECTS][64] = {
	"None", 
	"Fire Horns", 
	"Cerebral Discharge", 
	"Tornado", 
	"Flames", 
	"Singularity", 
	"Incinerator", 
	"Hypno-Beam"
}

char g_szSheens[MAX_SHEENS][64] = {
	"None", 
	"Team Shine", 
	"Deadly Daffodil", 
	"Manndarin", 
	"Mean Green", 
	"Agonizing Emerald", 
	"Villainous Violet", 
	"Hot Rod"
}

public Plugin myinfo = 
{
	name = "[TF2] VIP - KillStreak Effect", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hTypeCookie = RegClientCookie("vip_killstreak_type", "VIP killstreak type setting", CookieAccess_Protected);
	g_hEffectCookie = RegClientCookie("vip_killstreak_effect", "VIP killstreak effect setting", CookieAccess_Protected);
	g_hSheenCookie = RegClientCookie("vip_killstreak_sheen", "VIP sheen type setting", CookieAccess_Protected);
	
	HookEvent("post_inventory_application", Event_PlayerRegen);
	
	RegConsoleCmd("sm_ks", Command_KillStreak);
}

/* Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[10];
		GetClientCookie(client, g_hTypeCookie, szBuffer, sizeof(szBuffer));
		g_iSettings[client][SETTING_TYPE] = szBuffer[0] != 0 ? StringToInt(szBuffer):0;
		
		GetClientCookie(client, g_hEffectCookie, szBuffer, sizeof(szBuffer));
		g_iSettings[client][SETTING_EFFECT] = szBuffer[0] != 0 ? StringToInt(szBuffer):0;
		
		GetClientCookie(client, g_hSheenCookie, szBuffer, sizeof(szBuffer));
		g_iSettings[client][SETTING_SHEEN] = szBuffer[0] != 0 ? StringToInt(szBuffer):0;
		
	}
}

public Action Event_PlayerRegen(Event event, char[] name, bool dontBroadcast)
{
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(iClient))
	{
		for (int i = 0; i < MAX_WEAPONS; i++)
		{
			int iWeapon = GetPlayerWeaponSlot(iClient, i);
			if (IsValidEntity(iWeapon))
			{
				TF2Attrib_SetByDefIndex(iWeapon, KILLSTREAK_TIER_ATTRIBUTE, g_fTypes[g_iSettings[iClient][SETTING_TYPE]]);
				if (g_iSettings[iClient][SETTING_TYPE] > 0)
				{
					SetEntProp(iClient, Prop_Send, "m_nStreaks", KILLSTREAK_COUNT);
					TF2Attrib_SetByDefIndex(iWeapon, KILLSTREAK_EFFECT_ATTRIBUTE, g_fEffects[g_iSettings[iClient][SETTING_EFFECT]]);
					TF2Attrib_SetByDefIndex(iWeapon, KILLSTREAK_SHEEN_ATTRIBUTE, g_fSheens[g_iSettings[iClient][SETTING_SHEEN]]);
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("ks", "Killstreak Menu");
}

/* */

/* Commands */

public Action Command_KillStreak(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	Menus_ShowMain(client);
	return Plugin_Handled;
}

/* */

/* Menus */

void Menus_ShowMain(int client)
{
	Menu menu = new Menu(Handler_MainMenu);
	menu.SetTitle("%s Killstreak Menu\n ", PREFIX_MENU);
	
	menu.AddItem("type", "Select a Type");
	menu.AddItem("effect", "Select an Effect");
	menu.AddItem("sheen", "Select a Sheen");
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_MainMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		FakeClientCommand(client, "sm_vipmenu");
	} else if (action == MenuAction_Select) {
		char szInfo[32];
		menu.GetItem(itemNum, szInfo, sizeof(szInfo));
		
		if (!strcmp(szInfo, "type"))
		{
			Menus_ShowType(client);
		} else if (!strcmp(szInfo, "effect")) {
			Menus_ShowEffect(client);
		} else if (!strcmp(szInfo, "sheen")) {
			Menus_ShowSheen(client);
		}
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

void Menus_ShowType(int client)
{
	Menu menu = new Menu(Handler_TypeMenu);
	menu.SetTitle("%s Select a Type\n ", PREFIX_MENU);
	
	for (int i = 0; i < MAX_TYPES; i++)
	{
		menu.AddItem(g_szTypes[i], g_szTypes[i], g_iSettings[client][SETTING_TYPE] == i);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_TypeMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		Menus_ShowMain(client);
	} else if (action == MenuAction_Select) {
		char szValue[10];
		IntToString(itemNum, szValue, sizeof(szValue));
		SetClientCookie(client, g_hTypeCookie, szValue);
		
		g_iSettings[client][SETTING_TYPE] = itemNum;
		CPrintToChat(client, "%s You changed your killstreak type to: %s.", PREFIX, g_szTypes[itemNum]);
		
		Menus_ShowType(client);
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

void Menus_ShowEffect(int client)
{
	Menu menu = new Menu(Handler_EffectMenu);
	menu.SetTitle("%s Select an Effect\n ", PREFIX_MENU);
	
	for (int i = 0; i < MAX_EFFECTS; i++)
	{
		menu.AddItem(g_szEffects[i], g_szEffects[i], g_iSettings[client][SETTING_EFFECT] == i);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_EffectMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		Menus_ShowMain(client);
	} else if (action == MenuAction_Select) {
		char szValue[10];
		IntToString(itemNum, szValue, sizeof(szValue));
		SetClientCookie(client, g_hEffectCookie, szValue);
		
		g_iSettings[client][SETTING_EFFECT] = itemNum;
		CPrintToChat(client, "%s You changed your killstreak effect to: %s.", PREFIX, g_szEffects[itemNum]);
		
		Menus_ShowEffect(client);
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

void Menus_ShowSheen(int client)
{
	Menu menu = new Menu(Handler_SheenMenu);
	menu.SetTitle("%s Select a Sheen\n ", PREFIX_MENU);
	
	for (int i = 0; i < MAX_EFFECTS; i++)
	{
		menu.AddItem(g_szSheens[i], g_szSheens[i], g_iSettings[client][SETTING_SHEEN] == i);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_SheenMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		Menus_ShowMain(client);
	} else if (action == MenuAction_Select) {
		char szValue[10];
		IntToString(itemNum, szValue, sizeof(szValue));
		SetClientCookie(client, g_hSheenCookie, szValue);
		
		g_iSettings[client][SETTING_SHEEN] = itemNum;
		CPrintToChat(client, "%s You changed your killstreak sheen to: %s.", PREFIX, g_szSheens[itemNum]);
		
		Menus_ShowSheen(client);
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

/* */
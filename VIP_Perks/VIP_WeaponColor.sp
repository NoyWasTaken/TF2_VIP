#include <sourcemod>
#include <morecolors>
#include <clientprefs>
#include <sdktools>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define MELEE_SLOT 2

#define COLORS_AMOUNT 14

#define RGB_SIZE 3
#define RGB_RED 0
#define RGB_GREEN 1
#define RGB_BLUE 2

Handle g_hCookie;

char g_szColors[COLORS_AMOUNT][32] = 
{
	"None", 
	"Red", 
	"Green", 
	"Blue", 
	"Gold", 
	"Purple", 
	"Mint", 
	"Orange", 
	"Pink", 
	"Olive", 
	"Lime", 
	"Slate", 
	"Menta", 
	"Black"
};

int g_iColor[MAXPLAYERS + 1];
int g_iColors[COLORS_AMOUNT][RGB_SIZE] = {
	{ 255, ... }, 
	{ 255, 0, 0 }, 
	{ 0, 255, 0 }, 
	{ 0, 0, 255 }, 
	{ 255, 255, 0 }, 
	{ 255, 0, 255 }, 
	{ 0, 255, 255 }, 
	{ 255, 128, 0 }, 
	{ 255, 0, 128 }, 
	{ 128, 255, 0 }, 
	{ 0, 255, 128 }, 
	{ 128, 0, 255 }, 
	{ 0, 128, 255 }, 
	{ 0, ... }
};

public Plugin myinfo = 
{
	name = "[TF2] VIP - Weapon Color", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hCookie = RegClientCookie("vip_weaponcolor", "Weapon color of VIP players", CookieAccess_Protected);
	
	HookEvent("post_inventory_application", Event_PlayerRegen);
	
	RegConsoleCmd("sm_cw", Command_ColorWeapon, "Set Color Your Weapon (Short)");
	RegConsoleCmd("sm_wcolor", Command_ColorWeapon, "Set Color Your Weapon");
}

/* Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[10];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		if (szBuffer[0] != 0)
			g_iColor[client] = StringToInt(szBuffer);
		else
			g_iColor[client] = 0;
	}
}

public Action Event_PlayerRegen(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(client))
	{
		if (g_iColor[client])
			SetWeaponColors(client, g_iColors[g_iColor[client]][RGB_RED], g_iColors[g_iColor[client]][RGB_GREEN], g_iColors[g_iColor[client]][RGB_BLUE]);
	}
	
	return Plugin_Continue;
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("wcolor", "Color my Weapon");
}

/* */

/* Commands */

public Action Command_ColorWeapon(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	Menu_ShowColors(client);
	return Plugin_Handled;
}

/* */

/* Menus */

void Menu_ShowColors(int client)
{
	Menu menu = new Menu(Handler_WeaponColors);
	menu.SetTitle("%s Select a Color\n ", PREFIX_MENU);
	
	for (int i = 0; i < sizeof(g_szColors); i++)
	{
		menu.AddItem(g_szColors[i], g_szColors[i]);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_WeaponColors(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		FakeClientCommandEx(client, "sm_vip");
	} else if (action == MenuAction_Select) {
		g_iColor[client] = itemNum;
		
		char szBuffer[10];
		IntToString(itemNum, szBuffer, sizeof(szBuffer));
		SetClientCookie(client, g_hCookie, szBuffer);
		
		SetWeaponColors(client, g_iColors[itemNum][RGB_RED], g_iColors[itemNum][RGB_GREEN], g_iColors[itemNum][RGB_BLUE]);
		CPrintToChat(client, "%s Changed weapon color to: %s.", PREFIX, g_szColors[itemNum]);
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

/* */

/* Functions */

void SetWeaponColors(int client, int red, int green, int blue)
{
	int iWeapon;
	for (int i = 0; i <= MELEE_SLOT; i++)
	{
		iWeapon = GetPlayerWeaponSlot(client, i);
		if (iWeapon != -1)
		{
			SetEntityRenderMode(iWeapon, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iWeapon, red, green, blue, 255);
		}
	}
}

/* */
#include <sourcemod>
#include <morecolors>
#include <clientprefs>
#include <tf2>
#include <tf2_stocks>
#include <VIP_Core>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"

#define EFFECT_PARTICLE 0
#define EFFECT_DISPLAY_NAME 1

Handle g_hCookie;

int g_iEffect[MAXPLAYERS + 1];
int g_iParticle[MAXPLAYERS + 1];

char g_szEffects[][][] = {
	{ "", "No Effect" }, 
	{ "utaunt_firework_teamcolor_red", "Showstopper (RED)" }, 
	{ "utaunt_firework_teamcolor_blue", "Showstopper (BLUE)" }, 
	{ "utaunt_beams_yellow", "Holy Grail" }, 
	{ "utaunt_disco_party", "'72" }, 
	{ "utaunt_hearts_glow_parent", "Fountain of Delight" }, 
	{ "utaunt_meteor_parent", "Screaming Tiger" }, 
	{ "utaunt_cash_confetti", "Skill Gotten Gains" }, 
	{ "utaunt_tornado_parent_black", "Midnight Whirlwind" }, 
	{ "utaunt_tornado_parent_black", "Silver Cyclone" }, 
	{ "utaunt_lightning_parent", "Mega Strike" }, 
	{ "utaunt_souls_green_parent", "Souls Green" }, 
	{ "utaunt_souls_purple_parent", "Souls Purple" }, 
	{ "utaunt_hellpit_parent", "Hell Pit" }, 
	{ "utaunt_hellswirl", "Hell Swirl" }, 
	{ "utaunt_headless", "Headless" }, 
	{ "utaunt_merasmus", "Merasmus" }, 
	{ "utaunt_bubbles_glow_green_parent", "Bubbles Glow Green" }, 
	{ "utaunt_bubbles_glow_orange_parent", "Bubbles Glow Orange" }, 
	{ "utaunt_bubbles_glow_purple_parent", "Bubbles Glow Purple" }, 
	{ "utaunt_firework_dragon_parent", "Firework Dragon" }, 
	{ "utaunt_smoke_moon_parent", "Smoke Moon" }, 
	{ "utaunt_smoke_moon_green_parent", "Smoke Moon Green" }
};

public Plugin myinfo = 
{
	name = "[TF2] VIP - Unusual Taunts", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_hCookie = RegClientCookie("vip_taunt_effect", "Taunt effect of VIP players.", CookieAccess_Protected);
	
	RegConsoleCmd("sm_utaunt", Command_Effects);
}

/* Events */

public void OnClientCookiesCached(int client)
{
	if (VIP_IsPlayerVIP(client))
	{
		char szBuffer[10];
		GetClientCookie(client, g_hCookie, szBuffer, sizeof(szBuffer));
		
		if (szBuffer[0] != 0)
			g_iEffect[client] = StringToInt(szBuffer);
		else
			g_iEffect[client] = 0;
	}
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if (VIP_IsPlayerVIP(client) && g_iEffect[client] && condition == TFCond_Taunting)
	{
		float fPos[3] = { 0.0 };
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", fPos, 0);
		g_iParticle[client] = createParticle(client, g_szEffects[g_iEffect[client]][EFFECT_PARTICLE], fPos);
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if (g_iEffect[client] && condition == TFCond_Taunting)
	{
		if (IsValidEntity(g_iParticle[client]))
			AcceptEntityInput(g_iParticle[client], "Kill");
	}
}

public void VIP_OnMenuOpenned(int client, Menu menu)
{
	menu.AddItem("utaunt", "Unusual Taunts");
}

/* */

/* Commands */

public Action Command_Effects(int client, int args)
{
	if (!VIP_IsPlayerVIP(client))
	{
		CReplyToCommand(client, "%s You are not a {axis}VIP {default}member! type {axis}!vips {default}for info.", PREFIX);
		return Plugin_Handled;
	}
	
	Menus_ShowEffects(client);
	return Plugin_Handled;
}

/* */

/* Menus */

void Menus_ShowEffects(int client)
{
	Menu menu = new Menu(Handler_Effects);
	menu.SetTitle("%s Select an Effect\n ", PREFIX_MENU);
	
	for (int i = 0; i < sizeof(g_szEffects); i++)
	{
		menu.AddItem(g_szEffects[i][EFFECT_PARTICLE], g_szEffects[i][EFFECT_DISPLAY_NAME]);
	}
	
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Handler_Effects(Menu menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Cancel && itemNum == MenuCancel_ExitBack)
	{
		FakeClientCommandEx(client, "sm_vip");
	} else if (action == MenuAction_Select) {
		g_iEffect[client] = itemNum;
		
		char szBuffer[10];
		IntToString(itemNum, szBuffer, sizeof(szBuffer));
		SetClientCookie(client, g_hCookie, szBuffer);
		
		CPrintToChat(client, "%s Changed taunt effect to: %s.", PREFIX, g_szEffects[itemNum][EFFECT_DISPLAY_NAME]);
	} else if (action == MenuAction_Cancel) {
		delete menu;
	}
	
	return 0;
}

/* */

/* Functions */

int createParticle(int client, char[] effect, float fPos[3])
{
	int iParticle = CreateEntityByName("info_particle_system", -1);
	char szName[16];
	if (iParticle != -1)
	{
		TeleportEntity(iParticle, fPos, NULL_VECTOR, NULL_VECTOR);
		FormatEx(szName, sizeof(szName), "target%d", client);
		DispatchKeyValue(client, "targetname", szName);
		DispatchKeyValue(iParticle, "targetname", "tf2particle");
		DispatchKeyValue(iParticle, "parentname", szName);
		DispatchKeyValue(iParticle, "effect_name", effect);
		DispatchSpawn(iParticle);
		SetVariantString(szName);
		AcceptEntityInput(iParticle, "SetParent", iParticle, iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "start");
		return iParticle;
	}
	return -1;
}

/* */
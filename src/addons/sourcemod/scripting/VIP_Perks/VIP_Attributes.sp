#include <sourcemod>
#include <morecolors>
#include <VIP_Core>
#include <tf2attributes>

#define PLUGIN_AUTHOR "NoyB"
#define PLUGIN_VERSION "1.0"
#define FORCE_HOLIDAY 2

ConVar g_cvHoliday;

public Plugin myinfo = 
{
	name = "[TF2] VIP - Attributes Perks", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = "https://steamcommunity.com/id/noywastaken"
};

public void OnPluginStart()
{
	g_cvHoliday = FindConVar("tf_forced_holiday");
	g_cvHoliday.AddChangeHook(OnCvarChange);
	g_cvHoliday.SetInt(FORCE_HOLIDAY);
	
	HookEvent("post_inventory_application", Event_PlayerRegen);
}

void OnCvarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	convar.SetInt(FORCE_HOLIDAY);
}

public Action Event_PlayerRegen(Event event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (VIP_IsPlayerVIP(client))
	{
		TF2Attrib_SetByName(client, "health regen", 2.0);
		TF2Attrib_SetByName(client, "SPELL: Halloween green flames", 1.0);
		TF2Attrib_SetByName(client, "SPELL: Halloween pumpkin explosions", 1.0);
	}
	
	return Plugin_Continue;
} 